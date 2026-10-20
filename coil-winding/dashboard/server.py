#!/usr/bin/env python3
"""Painel local somente de leitura; Python 3.10+, sem dependências externas."""

import argparse
import csv
from functools import partial
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import math
import os
from pathlib import Path
from urllib.parse import urlsplit


DIRECTORY = Path(__file__).resolve().parent
TAIL_BYTES = 65_536
COLUMNS = (
    "meta.timestamp_ms",
    "payload.estimated",
    "payload.turns",
    "payload.phase",
    "payload.direction",
    "payload.play_active",
    "payload.target_rpm",
    "payload.uptime_s",
)


class SampleUnavailable(ValueError):
    """O CSV ainda não tem uma amostra utilizável."""


def read_latest(path):
    """Lê cabeçalho + até 64 KiB finais, ignorando a escrita incompleta.

    O esquema do Courier contém apenas escalares sem quebras de linha.
    O terminador de linha é a confirmação de que o registro foi concluído.
    O arquivo é reaberto em cada consulta para suportar troca/truncamento.
    """
    try:
        with path.open("rb") as file:
            header = file.readline(4097)
            if not header.endswith(b"\n") or len(header) > 4096:
                raise SampleUnavailable("Aguardando o cabeçalho completo do CSV.")
            data_start = file.tell()
            size = file.seek(0, os.SEEK_END)
            start = max(data_start, size - TAIL_BYTES)
            file.seek(start)
            tail = file.read(TAIL_BYTES)
    except FileNotFoundError as error:
        raise SampleUnavailable("CSV ainda não encontrado. Inicie o Courier.") from error
    except OSError as error:
        raise SampleUnavailable("Não foi possível ler o CSV. Confira o caminho e as permissões.") from error

    # Se a janela começa no meio de uma linha, essa primeira linha é descartada.
    if start > data_start:
        _, separator, tail = tail.partition(b"\n")
        if not separator:
            tail = b""
    complete, separator, _ = tail.rpartition(b"\n")
    lines = complete.splitlines() if separator else []
    last = next((line for line in reversed(lines) if line.strip()), None)
    if last is None:
        raise SampleUnavailable("Aguardando a primeira amostra completa do Courier.")
    try:
        names = next(csv.reader([header.decode("utf-8-sig")], strict=True))
        values = next(csv.reader([last.decode("utf-8")], strict=True))
        if len(names) != len(set(names)) or len(values) != len(names):
            raise ValueError("quantidade de colunas inválida")
        row = dict(zip(names, values))
        if not set(COLUMNS).issubset(row):
            raise ValueError("esquema diferente de courier.toml")

        def boolean(key):
            value = row[f"payload.{key}"]
            if value not in ("true", "false"):
                raise ValueError("booleano inválido")
            return value == "true"

        def natural(key):
            value = int(row[key])
            if value < 0 or value > 2**53 - 1:
                raise ValueError("inteiro fora do intervalo seguro do navegador")
            return value

        turns = float(row["payload.turns"])
        phase = row["payload.phase"]
        direction = row["payload.direction"]
        if not math.isfinite(turns):
            raise ValueError("voltas inválidas")
        if phase not in ("stopped", "accelerating", "running", "decelerating"):
            raise ValueError("fase inválida")
        if direction not in ("clockwise", "counterclockwise"):
            raise ValueError("sentido inválido")
        return {
            "timestamp_ms": natural("meta.timestamp_ms"),
            "estimated": boolean("estimated"),
            "turns": turns,
            "phase": phase,
            "direction": direction,
            "play_active": boolean("play_active"),
            "target_rpm": natural("payload.target_rpm"),
            "uptime_s": natural("payload.uptime_s"),
        }
    except (ValueError, UnicodeError, csv.Error, StopIteration) as error:
        raise SampleUnavailable("Última linha inválida. Confira o CSV e as colunas de courier.toml.") from error


class Handler(BaseHTTPRequestHandler):
    def __init__(self, *args, csv_path, **kwargs):
        self.csv_path = csv_path
        super().__init__(*args, **kwargs)

    def setup(self):
        super().setup()
        self.connection.settimeout(5)

    def respond(self, status, content_type, body):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("Content-Security-Policy", "default-src 'self'; object-src 'none'; frame-ancestors 'none'; base-uri 'none'")
        self.end_headers()
        try:
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            pass

    def do_GET(self):
        route = urlsplit(self.path).path
        if route == "/api/latest":
            try:
                response = {"sample": read_latest(self.csv_path)}
                status = 200
            except SampleUnavailable as error:
                response = {"error": str(error)}
                status = 503
            self.respond(status, "application/json; charset=utf-8", json.dumps(response, allow_nan=False).encode())
            return
        assets = {
            "/": ("index.html", "text/html; charset=utf-8"),
            "/index.html": ("index.html", "text/html; charset=utf-8"),
            "/dashboard.css": ("dashboard.css", "text/css; charset=utf-8"),
            "/dashboard.js": ("dashboard.js", "text/javascript; charset=utf-8"),
        }
        if route in assets:
            name, content_type = assets[route]
            self.respond(200, content_type, (DIRECTORY / name).read_bytes())
        else:
            self.respond(404, "text/plain; charset=utf-8", b"Not found\n")

    def log_message(self, *_args):
        # Não imprimir uma linha por segundo nem dados de cada amostra.
        pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--csv", type=Path, default=Path(os.environ.get("COIL_CSV_PATH", str(DIRECTORY.parent / "out/coil-winding.csv"))))
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    if not 1 <= args.port <= 65535:
        parser.error("a porta deve estar entre 1 e 65535")
    handler = partial(Handler, csv_path=args.csv.resolve())
    with ThreadingHTTPServer(("127.0.0.1", args.port), handler) as server:
        print(f"Painel: http://127.0.0.1:{args.port}", flush=True)
        print(f"CSV: {args.csv.resolve()}\nSomente leitura. Ctrl+C para encerrar.", flush=True)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    main()
