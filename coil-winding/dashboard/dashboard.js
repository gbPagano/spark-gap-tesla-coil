"use strict";

const fields = Object.fromEntries(
  ["turns", "target", "uptime", "phase", "direction", "play", "estimated", "sample-time", "connection", "detail"]
    .map((id) => [id, document.getElementById(id)])
);
const connection = document.querySelector(".connection");
const number = new Intl.NumberFormat("pt-BR", { maximumFractionDigits: 4 });
const date = new Intl.DateTimeFormat("pt-BR", { dateStyle: "short", timeStyle: "medium" });
const phases = { stopped: "Parado", accelerating: "Acelerando", running: "Girando", decelerating: "Desacelerando" };
let latest = null;

function duration(seconds) {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const remainder = seconds % 60;
  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}:${String(remainder).padStart(2, "0")}`;
}

function announce(state, title, detail) {
  connection.dataset.state = state;
  // Não anunciar novamente a mesma mensagem ao leitor de tela a cada segundo.
  if (fields.connection.textContent !== title) fields.connection.textContent = title;
  fields.detail.textContent = detail;
}

function showSample(sample) {
  latest = sample;
  fields.turns.textContent = number.format(sample.turns);
  fields.target.textContent = number.format(sample.target_rpm);
  fields.uptime.textContent = duration(sample.uptime_s);
  fields.phase.textContent = phases[sample.phase];
  fields.direction.textContent = sample.direction === "clockwise" ? "Horário" : "Anti-horário";
  fields.play.textContent = sample.play_active ? "Ativo" : "Em pausa";
  fields.estimated.textContent = sample.estimated ? "Sim" : "Não";
  fields["sample-time"].textContent = date.format(sample.timestamp_ms);
  fields["sample-time"].dateTime = new Date(sample.timestamp_ms).toISOString();
}

async function poll() {
  try {
    const response = await fetch("/api/latest", { cache: "no-store", signal: AbortSignal.timeout(3000) });
    const result = await response.json();
    if (!response.ok) throw new Error(result.error || "Não foi possível ler o CSV.");
    showSample(result.sample);
    const age = Math.floor((Date.now() - latest.timestamp_ms) / 1000);
    if (age < -3) {
      announce("stale", "Horário da amostra no futuro", "Confira o relógio do computador que executa o Courier.");
    } else if (age > 3) {
      announce("stale", "Amostra atrasada", `Sem nova amostra há ${number.format(age)} s. Confira o Courier e a conexão com a ESP.`);
    } else {
      announce("live", "Coleta atualizada", "Leitura do CSV a cada segundo. O painel não controla o motor.");
    }
  } catch (error) {
    const message = error.name === "TimeoutError" ? "O servidor local não respondeu a tempo." : error.message;
    announce("error", latest ? "Leitura interrompida" : "Aguardando dados", `${message} ${latest ? "Valores mantidos da última amostra." : "O painel tentará novamente automaticamente."}`);
  } finally {
    // Sem requisições sobrepostas, mesmo se o servidor estiver lento.
    setTimeout(poll, 1000);
  }
}

poll();
