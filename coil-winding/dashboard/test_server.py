import csv
from functools import partial
from http.server import ThreadingHTTPServer
import json
from pathlib import Path
import tempfile
import threading
import unittest
from urllib.error import HTTPError
from urllib.request import urlopen

from server import COLUMNS, Handler, SampleUnavailable, TAIL_BYTES, read_latest


class LatestTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name) / "data.csv"
        self.values = ["1792320000000", "true", "0.75", "stopped", "counterclockwise", "false", "30", "10"]

    def write(self, rows=None):
        with self.path.open("w", newline="") as file:
            writer = csv.writer(file)
            writer.writerow(COLUMNS)
            writer.writerows(rows if rows is not None else [self.values])

    def test_missing_empty_header_only(self):
        for content in (None, b"", b"meta.timestamp_ms", (",".join(COLUMNS) + "\n").encode()):
            if content is not None:
                self.path.write_bytes(content)
            with self.assertRaises(SampleUnavailable):
                read_latest(self.path)

    def test_types_and_last_row(self):
        backward = self.values.copy()
        backward[2] = "-0.25"
        self.write([self.values, backward])
        sample = read_latest(self.path)
        self.assertEqual(sample["turns"], -0.25)
        self.assertIs(sample["estimated"], True)
        self.assertIs(sample["play_active"], False)
        self.assertEqual(sample["uptime_s"], 10)
        self.assertEqual(len(sample), 8)

    def test_partial_append_is_ignored_until_newline(self):
        self.write()
        with self.path.open("ab") as file:
            file.write(",".join(self.values[:3]).encode())
        self.assertEqual(read_latest(self.path)["turns"], 0.75)
        with self.path.open("ab") as file:
            file.write(("," + ",".join(self.values[3:]) + "\n").encode())
        self.assertEqual(read_latest(self.path)["target_rpm"], 30)

    def test_large_file_tail_and_blank_lines(self):
        self.write([self.values] * 2000)
        self.assertGreater(self.path.stat().st_size, TAIL_BYTES)
        with self.path.open("ab") as file:
            file.write(b"\r\n\n")
        self.assertEqual(read_latest(self.path)["uptime_s"], 10)

    def test_replacement_and_truncation(self):
        self.write()
        self.assertEqual(read_latest(self.path)["uptime_s"], 10)
        self.values[7] = "0"
        self.write()
        self.assertEqual(read_latest(self.path)["uptime_s"], 0)
        self.path.write_bytes(b"")
        with self.assertRaises(SampleUnavailable):
            read_latest(self.path)

    def test_invalid_fields(self):
        for index, invalid in [(0, "-1"), (1, "yes"), (2, "NaN"), (2, "inf"), (3, "unknown"), (4, "left"), (5, "0"), (6, "-5"), (7, "1.5"), (0, str(2**53))]:
            with self.subTest(index=index, invalid=invalid):
                values = self.values.copy()
                values[index] = invalid
                self.write([values])
                with self.assertRaises(SampleUnavailable):
                    read_latest(self.path)

    def test_invalid_schema_and_encoding(self):
        for content in [b"wrong,header\n1,2\n", (",".join(COLUMNS) + "\n1,2\n").encode(), (",".join(COLUMNS) + "\n").encode() + b"\xff\n"]:
            self.path.write_bytes(content)
            with self.assertRaises(SampleUnavailable):
                read_latest(self.path)

    def test_csv_quoting_and_bom(self):
        self.write()
        content = self.path.read_bytes().replace(b"true", b'"true"')
        self.path.write_bytes(b"\xef\xbb\xbf" + content)
        self.assertTrue(read_latest(self.path)["estimated"])

    def test_http_routes_readonly_and_recovery(self):
        server = ThreadingHTTPServer(("127.0.0.1", 0), partial(Handler, csv_path=self.path))
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        base = f"http://127.0.0.1:{server.server_port}"
        try:
            with self.assertRaises(HTTPError) as error:
                urlopen(base + "/api/latest")
            self.assertEqual(error.exception.code, 503)
            error.exception.close()
            self.write()
            with urlopen(base + "/api/latest") as response:
                self.assertEqual(response.headers["Cache-Control"], "no-store")
                self.assertEqual(json.load(response)["sample"]["turns"], 0.75)
            for route in ["/", "/dashboard.css", "/dashboard.js"]:
                with urlopen(base + route) as response:
                    self.assertEqual(response.status, 200)
            for route in ["/../server.py", "/courier.toml", "/data.csv"]:
                with self.assertRaises(HTTPError) as error:
                    urlopen(base + route)
                self.assertEqual(error.exception.code, 404)
                error.exception.close()
            with self.assertRaises(HTTPError) as error:
                urlopen(base + "/api/latest", data=b"command")
            self.assertEqual(error.exception.code, 501)
            error.exception.close()
        finally:
            server.shutdown()
            server.server_close()
            thread.join()


if __name__ == "__main__":
    unittest.main()
