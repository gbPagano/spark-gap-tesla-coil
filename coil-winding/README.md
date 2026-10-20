# coil-winding — enroladora do secundário

Firmware em Rust `no_std`, com Embassy e `esp-hal` (ESP32-S3), para enrolar a bobina secundária
do TCC: tubo de 100 mm, ~500 mm de enrolamento, fio AWG 26
(~1.050–1.150 espiras em enrolamento fechado).

## Etapa atual — 1: rotação do mandril

O firmware gira o motor do eixo de rotação com rampa de
aceleração/desaceleração, comandado por dois botões: **PLAY/PAUSE** alterna
entre girar e parar, e **INVERSÃO** troca o sentido (a máquina desacelera,
para, troca o sentido e volta a acelerar). Um potenciômetro no **GP1** seleciona
**0–60 rpm**, com micropasso **1/32**. Sobe parado, esperando o play.
Ainda não há eixo de avanço da guia de fio.
O firmware estima as voltas pelos pulsos STEP e oferece o estado por HTTP
na rede Wi-Fi existente, sem alterar os controles físicos.

## Execução assíncrona

- **Controles:** tarefa principal Embassy, botões a cada 2 ms com debounce de
  20 ms. O ADC do potenciômetro é consultado sem espera ocupada: uma conversão
  incompleta é consultada no próximo tick, sem bloquear o motor ou os botões.
  Após cada leitura concluída, aguarda pelo menos 10 ms para iniciar outra.
- **Motor:** tarefa em executor de interrupção dedicado (SWI2, prioridade 2),
  com `embassy-time`, rampa e prazos absolutos. Pode preemptar as tarefas normais
  de HTTP, rede e formatação. Não há a
  antiga pausa de 10 ms a cada 256 passos, nem espera quantizada pelo FreeRTOS.
- **Comunicação:** `embassy-sync::Signal` transmite o estado desejado completo
  (girar/parar, sentido e velocidade). Eventos sucessivos podem ser coalescidos
  sem perder a intenção final do operador.
- **Rampa:** limite de 30 rpm/s em aceleração e desaceleração, calculado pelo
  tempo decorrido, inclusive em mudanças do potenciômetro. Partida em 1 rpm;
  a parada termina abaixo de 1 rpm. O limite é `ACCEL_RPM_PER_SECOND` em
  `control.rs`, não depende do número de micropassos.
- **Logs:** tarefa separada, mudanças de estado/alvo limitadas a 4 mensagens/s,
  em linhas curtas para reduzir esperas do FIFO USB. Mostram fase, sentido
  (`CW`/`CCW`), alvo e pulsos emitidos, não o movimento físico medido.
  Não há impressão a cada passo ou volta.
- **Rede:** `esp-radio` em modo station, DHCP via `embassy-net` e duas tarefas
  TCP/HTTP assíncronas. Requisições têm buffers e prazo de atendimento limitados.
  O handler copia um snapshot sob lock curto e formata o JSON fora dele.

O executor e o driver de tempo são integrados por `esp-rtos` 0.3; não é
FreeRTOS. Não há `std`, `esp-idf-svc` ou runtime ESP-IDF. O Wi-Fi usa um heap
interno de 100 KiB; controles, contagem e buffers HTTP não alocam por requisição.
A CPU usa a frequência máxima do chip para atender rádio e tarefas.
A dependência
`esp-bootloader-esp-idf` fornece apenas o descritor de imagem compatível com o
bootloader usado pelo `espflash`.

## Contagem estimada de voltas

- Na configuração atual, **200 × 32 = 6400 pulsos por volta**. Pressupõe
  acoplamento motor/tubo **1:1** e ausência de escorregamento.
- O sentido lógico **Clockwise soma**; **CounterClockwise subtrai**. Conferir
  qual sentido físico enrola o fio antes de interpretar o sinal do contador.
  O saldo pode ficar negativo ao retornar além do ponto inicial.
- Contam-se todos os pulsos emitidos, inclusive nas rampas e na desaceleração
  de uma pausa/inversão. Frações ficam preservadas em um contador inteiro com
  sinal, não em arredondamentos sucessivos de voltas.
- O saldo de pulsos e o percurso total nos dois sentidos são mantidos
  internamente, mas não são expostos no JSON.
  A contagem fica preservada ao pausar ou perder o Wi-Fi. Reiniciar/desenergizar
  a ESP zera a contagem: **não há persistência nem endpoint de zerar** nesta etapa.
- É uma **estimativa**, não medição: perdas de passos, folgas, acoplamento
  escorregando ou fio rompido não são detectados. O retorno HTTP nunca confirma
  que as espiras foram efetivamente depositadas.

## HTTP na rede Wi-Fi existente

Conectar a uma rede **2,4 GHz**, WPA2-Personal (ou aberta com senha vazia),
usando `WIFI_SSID`/`WIFI_PASSWORD` no build. Não há modo access point, portal
de configuração, TLS, autenticação HTTP, CORS permissivo ou controle remoto.
Usar apenas uma LAN confiável e não redirecionar a porta 80 para a internet.

Depois do DHCP, o monitor serial informa o endereço real:

```text
HTTP: http://<IP-DA-ESP>/api/status
```

Consulta somente de leitura:

```sh
curl --fail --max-time 3 "http://<IP-DA-ESP>/api/status"
```

Exemplo **ilustrativo**, com uma volta para frente e um quarto de volta de retorno:

```json
{
  "estimated": true,
  "turns": 0.75,
  "phase": "stopped",
  "direction": "counterclockwise",
  "play_active": false,
  "target_rpm": 30,
  "uptime_s": 10
}
```

- `turns` é o saldo interno de pulsos dividido por 6400 na configuração atual
  (200 passos × 32 micropassos). A contagem interna continua inteira, sem perder
  frações a cada movimento; apenas a apresentação é decimal.
- `phase`: `stopped`, `accelerating`, `running` ou `decelerating`.
- `play_active` distingue uma pausa de play ativo com potenciômetro em zero.
- `target_rpm` é a seleção atual do potenciômetro, inclusive em pausa; não é
  uma medição da velocidade física do eixo.
- `uptime_s` é o tempo **acumulado de movimento comandado**, em segundos inteiros,
  não o tempo ligado. Inclui aceleração, desaceleração e os dois sentidos;
  congela parado, inclusive com play ativo e potenciômetro em zero. Retomar
  continua a soma, preservando frações de segundo entre pausas. Reiniciar a
  placa zera o tempo. Sem sensor, ele não detecta motor fisicamente travado.
  O snapshot é atualizado
  após cada STEP e mudança de estado; não há velocidade medida ou idade do
  snapshot na resposta HTTP.
- É um snapshot atual por GET, com `Cache-Control: no-store`, não streaming.
  Começar consultando a cada **250–500 ms** no cliente e verificar o timing
  físico antes de aumentar o tráfego.
- Uma requisição por conexão, dois atendimentos concorrentes, headers de no
  máximo 1024 bytes/16 campos e JSON limitado a 768 bytes. Prazo de 2 s por
  atendimento; métodos de escrita retornam 405 e outras rotas retornam 404.
- Reconexão Wi-Fi a cada 5 s após falha. A rede não zera a contagem nem comanda
  o motor; o IP DHCP pode mudar e será informado novamente no log.

## Coleta em CSV com Courier

O arquivo [`courier.toml`](courier.toml) configura o
[Courier](https://github.com/gbPagano/courier) para consultar `GET /api/status`
**uma vez por segundo** e acrescentar cada resposta válida ao CSV. Não há
comandos de movimento nem filtro de estado: a coleta continua durante pausas.

Com o Courier instalado, executar a partir da raiz do repositório:

```sh
cd coil-winding
export COIL_STATUS_URL='http://<IP-DA-ESP>/api/status' # substituir pelo IP real
courier validate --config courier.toml
courier run --config courier.toml
```

O resultado fica em `coil-winding/out/coil-winding.csv`, com cabeçalho e todos
os sete campos da API. A coluna adicional `meta.timestamp_ms` registra o horário
da coleta no computador (milissegundos desde Unix epoch); `payload.uptime_s`
continua sendo apenas o tempo acumulado de movimento comandado pela ESP.
Os nomes das colunas preservam os prefixos `meta.` e `payload.` do Courier.

O diretório é criado automaticamente e ignorado pelo Git. Reiniciar o Courier
acrescenta linhas ao mesmo arquivo, sem repetir o cabeçalho. Para separar ensaios,
informar outro caminho, relativo ao diretório de execução ou absoluto:

```sh
COIL_CSV_PATH='./out/ensaio-02.csv' courier run --config courier.toml
```

Encerrar com `Ctrl+C`. Falhas de rede/HTTP/JSON não geram linhas de amostra;
podem existir lacunas maiores que um segundo. A cadência não é de tempo real
e depende da resposta da ESP. Se o DHCP mudar o IP, atualizar `COIL_STATUS_URL`
e reiniciar o Courier.

## Painel local em tempo real

Com o Courier coletando, abrir **outro terminal** na raiz do repositório:

```sh
python3 coil-winding/dashboard/server.py
```

Acessar **http://127.0.0.1:8765** no navegador. Requer Python 3.10+ e não precisa
instalar pacotes. O servidor usa por padrão `coil-winding/out/coil-winding.csv`,
independentemente do diretório de execução. Se o Courier grava em outro arquivo:

```sh
python3 coil-winding/dashboard/server.py --csv /caminho/do/ensaio.csv
```

Também aceita `COIL_CSV_PATH` e `--port 8766`; caminhos relativos explicitamente
fornecidos são relativos ao diretório de execução, como no Courier.

A página consulta o servidor local a cada segundo, exibindo o último registro
completo do CSV (cabeçalho + até 64 KiB finais, sem reler o histórico inteiro).
Linhas ainda sem terminador são ignoradas até a próxima consulta. O leitor é
específico para os campos escalares sem quebras de linha de `courier.toml`.
Não altera o CSV, não consulta a ESP e não controla o motor.

Mostra os sete campos da API, tempo em movimento no formato `hh:mm:ss`, horário
da amostra e aviso se ela tiver mais de três segundos. Se a leitura falhar,
mantém os valores anteriores com aviso explícito, sem apresentá-los como atuais.
CSV ausente/vazio é tratado como espera de dados; o painel recupera sozinho
quando a coleta começa. O relógio do computador deve estar correto.

O servidor escuta **somente em 127.0.0.1**, sem autenticação, para uso local.
O layout se adapta a telas estreitas, mas não há acesso pela LAN nesta versão.
Encerrar com `Ctrl+C`, sem interromper o Courier no outro terminal.

Testes do leitor e do HTTP local:

```sh
python3 -m unittest discover -s coil-winding/dashboard -v
```

## Protótipos mecânicos

O modelo FreeCAD editável e o projeto de fatiamento estão em
[`mechanical/`](mechanical/README.md). O CAD usa Bodies, sketches e operações
nativas de Part Design; as peças e testes podem ser exportados conforme necessário.
Há dois tipos de suporte com 608ZZ
para o tubo nominal Ø100 × 700 mm e acionamento com o NEMA 17HD48002-24B.
O acoplamento, eixo e retenções da R02 são impressos e ainda experimentais.
Conferir diâmetro externo do tubo e medidas do motor antes das peças finais.

![Vista isométrica da enroladora do secundário no FreeCAD](mechanical/coil-winding.png)

## Hardware previsto

| Item           | Referência                                        |
| -------------- | ------------------------------------------------- |
| MCU            | ESP32-S3 (DevKitC-1 ou Super Mini S3)             |
| Driver         | DRV8825 (ou A4988), interface step/dir           |
| Motor          | NEMA 17, 1,8°/passo (200 passos/volta em inteiro) |
| Fonte do motor | 8–35 Vcc (12 V típico), separada da lógica       |

## Pinagem (firmware atual)

| Sinal    | GPIO | Observação                                |
| -------- | ---- | ----------------------------------------- |
| STEP     | 4    | pulso 3 µs (DRV8825 exige ≥ 1,9 µs)       |
| DIR      | 5    | nível alto = horário (invertível em software) |
| ~ENABLE  | 6    | ativo-baixo; alto = pontes desligadas     |
| PLAY     | 9    | botão para o GND; pressionar alterna girar/parar |
| INVERTER | 8    | botão para o GND; pressionar troca o sentido |
| VELOCIDADE | 1  | cursor do potenciômetro, ADC1_CH0; sinal entre GND e 3V3 |
| RESERVADO | 2   | não usado; não alimentar o potenciômetro por este GPIO |
| GND      | GND  | comum entre MCU e driver                  |

- No ESP32-S3, evitar GPIO 0, 3, 45 e 46 (strap), 19/20 (USB-Serial-JTAG)
  e 26–37 (flash/PSRAM). Na Super Mini, GP0 é o botão BOOT e GP48 é o LED RGB
  WS2812 — nenhum dos dois se usa aqui.
- Ligação completa com o DRV8825 (potência, RST/SLP, VREF, motor):
  [`wiring-drv8825.md`](wiring-drv8825.md).
- No A4988, manter RESET e SLEEP interligados (ou em nível alto).

### Botões

Cada botão liga o GPIO ao GND — sem resistor, sem trilha até o 3V3: o
pull-up interno do ESP32-S3 mantém o pino alto em repouso e o pressionar puxa
para baixo. Os dois usam pinos do cabeçalho frontal da Super Mini: a face de
cima traz GP1–GP13, TX, RX e as alimentações; GP14–GP18, GP21, GP33–GP42 e
GP45–GP48 só existem como pads na face inferior.

- **PLAY/PAUSE** gira e para; parado, o motor continua energizado (segura o
  torque) e só os passos são suspensos.
- **INVERSÃO** é uma parada com inversão: desacelera, para, troca o pino DIR
  e acelera de volta. Com o motor já parado, só troca o sentido do próximo
  play. Apertar de novo durante a desaceleração devolve o sentido original.
  Pausar durante a inversão impede a partida automática no novo sentido.
- Uma transição só vale após 20 ms de estabilidade. Segurar o botão não
  repete comandos; se ligar a placa com um botão apertado, é necessário
  soltá-lo e apertar novamente para comandar.
- Nesta placa o LED RGB é o WS2812 no GPIO 48, então GP8 e GP9 ficam livres.
  Se precisar trocar, use qualquer outro pino do cabeçalho (GP10–GP13) e ajuste
  `peripherals.GPIO8`/`peripherals.GPIO9` no `main.rs`.
- O botão BOOT da placa (GP0) parece um terceiro botão de graça, mas GP0 é
  pino de strap: segurá-lo no reset entra em modo download. Não use aqui.

### Potenciômetro de velocidade

Usar preferencialmente um potenciômetro **linear de 10 kΩ**, com três terminais:

```text
3V3 ───── extremo do potenciômetro
GP1 ───── cursor (normalmente o terminal central; conferir o componente)
GND ───── outro extremo do potenciômetro
GP2 ───── sem conexão (reservado)
```

- **Nunca ligar GP1 ou o potenciômetro aos 5 V/12 V.** O GPIO é de 3,3 V.
  Fazer as conexões com fonte e USB desligados. Para inverter o sentido do
  ajuste, trocar apenas os dois extremos, mantendo o cursor no GP1.
- O ajuste seleciona **0–60 rpm**, em incrementos de 1 rpm. A calibração básica
  de bias do ADC usa os eFuses (ou calibração interna de GND como fallback),
  antes de truncar a leitura para 12 bits. Sem ela o offset pode cortar parte
  do curso; não se deve simplesmente remapear uma leitura mínima alta para zero.
- O filtro combina **mediana de 5 amostras** (rejeita até dois picos na janela),
  média exponencial com **1/16 da nova leitura** e **histerese de 1 rpm centrada
  no último valor publicado**. Cruzar repetidamente uma fronteira de
  arredondamento não deve ficar alternando dois valores adjacentes. Ajustes
  deliberados de 1 rpm continuam possíveis, mas o controle fica menos sensível.
- Há margens de ADC até 100 para zero e a partir de 4000 para o máximo.
  Mudanças grandes podem levar cerca de 0,5–1 s para assentar no filtro;
  a rampa do motor ainda se aplica depois dele. Não é parada de emergência.
- No mínimo, o motor desacelera e para, mas **o play continua ativo** se não
  tiver sido pausado: girar o potenciômetro para cima faz o motor partir.
  Se estiver em pausa, alterar o potenciômetro só muda a velocidade da próxima
  partida. Ligar a placa nunca inicia o motor automaticamente.
- Recomendado: resistor **100 kΩ entre GP1 e GND** para não deixar a entrada
  flutuando se o cursor se desconectar; capacitor **100 nF entre GP1 e GND**
  próximo à placa para filtrar ruído. Esses componentes não detectam todas as
  falhas de ligação nem constituem uma parada de segurança.
- Atenuação ADC de 11 dB, leitura relativa de 12 bits com bias corrigido:
  não é uma medição metrológica de tensão/ângulo. O extremo superior pode
  saturar antes do fim do
  curso; ruído e variações do ADC podem exigir ajuste das margens em `speed.rs`.
- `MAX_RPM = 60` e `MICROSTEPS = 32` ficam em `firmware/src/control.rs`.
  O limite preserva a velocidade do firmware anterior; não é uma garantia de
  operação sem perda de passos para qualquer carga mecânica.

#### Diagnóstico de curso e ruído

Com o motor **em pausa**, mover o potenciômetro faz o log mostrar também:

```text
pot raw=... filtro=... min=... max=...
```

`raw` é a última contagem ADC após correção de bias; `filtro` é a leitura
suavizada. `min/max` são extremos observados desde o boot, incluindo possíveis
picos, e não são usados para autoajustar o mapeamento. Não há impressão de
diagnóstico ADC durante movimento, nem uma linha por amostra.
Percorrer o curso inteiro: o mínimo deve se aproximar de zero e o máximo da
região alta do ADC. Se o mínimo continuar perto de 2000, conferir a tensão
entre GP1 e GND nos dois extremos e as ligações do cursor antes de mudar a escala.

## Pré-requisitos

```sh
# Se `rustup toolchain list` ainda não mostrar `esp`:
cargo install espup --locked
espup install
# Se espflash ainda não estiver instalado (ou use o pacote do sistema):
cargo install espflash --locked

# Inclui o linker Xtensa no PATH; repetir nos novos terminais.
source "$HOME/export-esp.sh"
```

O ESP32-S3 exige a toolchain Xtensa `esp`, com `rust-src`, e o linker GNU
`xtensa-esp32s3-elf-gcc` instalado pelo `espup`. O alvo agora é
**`xtensa-esp32s3-none-elf`**, não `xtensa-esp32s3-espidf`.
Não são mais necessários `ldproxy`, ESP-IDF, CMake ou Ninja.

Versões validadas: toolchain `esp` Rust 1.88.0, `esp-hal` 1.1.2,
`esp-rtos` 0.3.0, Embassy Executor 0.10, Embassy Time 0.5.1,
`esp-radio` 0.18.0 e `embassy-net` 0.8.0.
O `Cargo.lock` fixa também as dependências transitivas compatíveis; use
`--locked` para reproduzir a compilação.

## Compilar, gravar e monitorar

```sh
source "$HOME/export-esp.sh"
cd coil-winding/firmware # a partir da raiz do repositório
export WIFI_SSID='SUA_REDE_2G4'
export WIFI_PASSWORD='SUA_SENHA'
cargo build --release --locked # apenas compilar
cargo run --release --locked   # grava via USB e abre o monitor serial
```

Também é possível passar as variáveis só para um comando:

```sh
WIFI_SSID='SUA_REDE_2G4' WIFI_PASSWORD='SUA_SENHA' cargo build --release --locked
```

Ambas são obrigatórias ao compilar o binário; `WIFI_PASSWORD=''` seleciona rede
aberta. SSID tem 1–32 bytes e senha protegida tem 8–64 bytes. `env!` faz o Cargo
recompilar quando mudam, sem `build.rs`, `.env` ou arquivo local de credenciais.
Fornecer as variáveis também ao `cargo run`: sem elas o Cargo não reutiliza
silenciosamente um build anterior com credenciais antigas.

Não colocar credenciais reais no Git, logs ou exemplos. Evitar gravar a senha
no histórico do terminal; ela pode ser fornecida pelo ambiente/gerenciador de
segredos. **O ELF/binário contém as credenciais**, portanto também é sensível.
O endpoint não retorna SSID ou senha.

O runner mantém flash de **4 MB, modo DIO**, para a Super Mini deste projeto.
Em outra placa, ajuste `--flash-size` em `.cargo/config.toml` ao tamanho real.
Logs e mensagens de panic saem pela USB-Serial-JTAG nativa (GPIO19/20), não
pela UART TX/RX. A compilação não grava a placa; `cargo run` grava.

## Testes no computador

```sh
cd coil-winding/firmware # a partir da raiz do repositório
cargo +stable test --lib --target x86_64-unknown-linux-gnu --locked
cargo fmt --check
WIFI_SSID='compile-check' WIFI_PASSWORD='compile-only-not-secret' cargo clippy --release --locked -- -D warnings
```

Os 57 testes cobrem boot parado, rampas por tempo, seleção de velocidade,
potenciômetro em zero, pausa/inversão com mudanças de velocidade, limite de
RPM, comandos coalescidos, prazos, debounce, rejeição de picos, leitura inicial
e histerese nas fronteiras de todos os valores de RPM, sem perder ajustes de 1 rpm.
Incluem contagem líquida/negativa, frações, rampas de parada, saturação dos
contadores, JSON e o handler HTTP com requisições fragmentadas, inválidas,
grandes, métodos de escrita e escritas parciais. Um teste também usa TCP real
em loopback e consulta avanço/retorno sobre o mesmo handler.

Os testes do host não precisam de credenciais Wi-Fi. Build e teste local TCP
não comprovam associação ao roteador, DHCP na placa ou ausência de jitter
com rádio ativo: esses ensaios físicos ainda são necessários.

### Troubleshooting: após gravar, o monitor mostra "waiting for download"

Conhecido do ESP32-S3 com USB-Serial-JTAG nativo (porta `/dev/ttyACM0`): o
reset de fim de gravação usa o reset do próprio USB
(`rst:0x15 USB_UART_CHIP_RESET`) e devolve o chip ao modo download — o app
não chega a rodar. A gravação em si não é afetada. Opções:

1. Pressionar o botão **RESET** da placa: o app sobe e os logs aparecem no
   monitor já aberto.
2. Pedir um reset por watchdog na hora de gravar (evita o reset via USB):
   ```sh
   espflash flash --monitor --after watchdog-reset \
      --flash-size 4mb --flash-mode dio \
      target/xtensa-esp32s3-none-elf/release/coil-winding-firmware
   ```
   Se funcionar de forma confiável na sua placa, vale fixar no `runner` do
   `.cargo/config.toml`.
3. Sem botão de reset: desconectar e reconectar o USB.

### Placa não enumera / `error -71` no kernel — evite hub USB

Se `/dev/ttyACM*` não aparecer e o `journalctl -k` mostrar algo como
`device not accepting address ... error -71` ou `unable to enumerate USB
device`, conecte a placa **direto numa porta do computador**. A USB nativa do
ESP32-S3 re-enumera a cada reset do chip e é sensível a latência/integridade
de sinal: hubs — em especial docks/monitores USB 3 — falham justamente
nesses re-estabelecimentos, enquanto a conexão direta funciona. Se precisar
de hub, prefira um hub USB 2.0 alimentado e cabo de dados curto e bom.

## Antes do primeiro ensaio mecânico

- Ajustar a corrente do driver ANTES de rodar (fórmulas em
  `wiring-drv8825.md`): DRV8825 → `VREF ≈ 0,5 × I`; A4988 → `VREF ≈ 0,8 × I`
  (ambos com Rs = 0,1 Ω). Sem dissipador extra, limitar a ~1,0–1,2 A.
- Conferir `MICROSTEPS = 32` em `firmware/src/control.rs` e os jumpers do
  DRV8825: por exemplo M0 = 3V3, M1 = GND e M2 = 3V3. Alterar a constante não
  muda os jumpers. Fazer mudanças com a alimentação desligada.
- Começar com o potenciômetro baixo. O firmware sobe parado e parte em 1 rpm,
  respeitando o limite de aceleração. Para reduzir o teto, alterar `MAX_RPM`.
- Verificar o sentido real de rotação: se estiver trocado, use o botão de
  inversão para conferir no ato e, se quiser que fique fixo assim, ajuste
  o mapeamento de `Direction` em `motor.rs`, em vez de trocar a fiação.
- Play/pause é comando operacional, não parada de emergência. Na pausa as
  bobinas permanecem energizadas e podem aquecer. A parada desde 60 rpm leva
  aproximadamente 2 s pela rampa, além da latência de leitura/comandos.

## Limitações conhecidas (etapa 1)

- Faixa atual de 0–60 rpm pelo potenciômetro; sem realimentação de velocidade.
  O ADC não distingue todos os defeitos de cursor/fiação de uma posição válida.
- Sem fim de curso, contagem persistente, avanço ou encoder. Contagem estimada
  com sinal, zerada a cada reinício, não confirmação física de espiras.
- Os pulsos ainda são emitidos por software: timers assíncronos eliminam a
  pausa artificial, mas interrupções, executor e logs podem introduzir jitter.
  Se perder um prazo inteiro, o próximo é reagendado sem recuperar em rajada.
- A prioridade do motor evita que o HTTP o bloqueie como uma tarefa comum, mas
  interrupções/seções críticas do rádio ainda podem afetar STEP. Validar na placa
  primeiro sem carga e depois com carga, inclusive com consultas HTTP simultâneas.
- Só a largura alta do pulso STEP e o setup de DIR usam espera ocupada de
  3 µs. O restante da espera de movimento é assíncrono, sem ticks de 10 ms.
- A rampa limita a velocidade comandada por tempo, mas STEP continua discreto;
  partida em 1 rpm e parada abaixo de 1 rpm, não controle contínuo até zero.
- Passo inteiro, ressonância mecânica, corrente incorreta e mau contato ainda
  podem causar vibração. A migração não comprova a causa nem a solução física.

## Roadmap

1. Rotação, play/pause, inversão, potenciômetro, contagem estimada e HTTP (atual)
2. Eixo de avanço da guia + coordenação por interpolação (passos do avanço
   sincronizados às voltas do mandril, passo = Ø do fio com esmalte)
3. Fim de curso do avanço, confirmação de voltas por sensor e persistência
4. Geração de pulsos por hardware (RMT ou equivalente), se a medição mostrar
   necessidade; integração das rampas com o futuro eixo de avanço
5. Controle de tensão do fio e rebobinamento do carretel

## Estrutura

```
coil-winding/
├── README.md
└── firmware/          # crate Rust no_std / Embassy para ESP32-S3
    ├── .cargo/config.toml
    ├── Cargo.toml
    ├── Cargo.lock
    ├── rust-toolchain.toml
    └── src/
        ├── main.rs     # inicialização, controles e logs
        ├── motor.rs    # tarefa do motor e GPIO STEP/DIR/~ENABLE
        ├── buttons.rs  # adaptação GPIO do debounce
        ├── control.rs  # estado, rampa, configuração de velocidade e testes
        ├── debounce.rs # debounce por tempo e testes
        ├── potentiometer.rs # ADC não bloqueante no GP1
        ├── speed.rs    # filtro, histerese, mapeamento ADC/RPM e testes
        ├── counting.rs # saldo e percurso em pulsos, sem arredondar frações
        ├── api.rs      # snapshot e JSON do estado estimado
        ├── http.rs     # parser httparse e atendimento HTTP assíncrono limitado
        ├── http_tcp_tests.rs # teste do handler em TCP local
        ├── network.rs  # Wi-Fi station, DHCP, reconexão e dois workers HTTP
        ├── telemetry.rs # armazenamento compartilhado de snapshot
        └── lib.rs      # lógica independente de hardware
```

## Referências consultadas

- [Embassy](https://embassy.dev/book/) — executor e programação assíncrona.
- [esp-rs/esp-hal, exemplo Embassy na revisão esp-rtos-v0.3.0](https://github.com/esp-rs/esp-hal/blob/esp-rtos-v0.3.0/examples/async/embassy_hello_world/src/main.rs) —
  inicialização do executor no ESP32-S3 (Apache-2.0/MIT).
- [Exemplo Wi-Fi/DHCP do esp-rs na revisão esp-rtos-v0.3.0](https://github.com/esp-rs/esp-hal/blob/esp-rtos-v0.3.0/examples/wifi/embassy_dhcp/src/main.rs) —
  integração station/driver/stack assíncronos; não é um servidor HTTP pronto.
- [httparse 1.10.1](https://docs.rs/httparse/1.10.1/httparse/) — parser dos
  headers HTTP; transporte e limites ficam em `http.rs`/`network.rs`.
- [owl-and-goat/coil-winder](https://github.com/owl-and-goat/coil-winder) —
  arquitetura de enroladora CNC em Rust (MIT).
- [sandy9159/DIY-Arduino-based-Guitar-Pickup-Coil-Winder](https://github.com/sandy9159/DIY-Arduino-based-Guitar-Pickup-Coil-Winder) —
  referência de máquina 2 eixos + HMI (GPL-3.0).
- [Rylangrayston/winder](https://github.com/Rylangrayston/winder) —
  referência de tensão de fio fina (GPL-3.0).
