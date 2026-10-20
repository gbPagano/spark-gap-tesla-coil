//! Enroladora do secundário: ESP32-S3 Super Mini + DRV8825, com Embassy.
#![no_std]
#![no_main]

use core::cell::Cell;

use coil_winding_firmware::control::{
    ControlState, Direction, Phase, MAX_RPM, MICROSTEPS, STEPS_PER_REV,
};
use embassy_executor::Spawner;
use embassy_sync::blocking_mutex::{raw::CriticalSectionRawMutex, Mutex};
use embassy_time::{Duration, Instant, Ticker, Timer};
use esp_backtrace as _;
use esp_hal::{
    clock::CpuClock,
    gpio::{Input, InputConfig, Level, Output, OutputConfig, Pull},
    interrupt::{software::SoftwareInterruptControl, Priority},
    timer::timg::TimerGroup,
};

mod buttons;
mod motor;
mod network;
mod potentiometer;
mod telemetry;

use buttons::Button;
use motor::{Commands, Status, StepDirMotor};
use potentiometer::{PotReading, Potentiometer};

// Apenas o descritor de imagem do bootloader. Não vincula o runtime ESP-IDF.
esp_bootloader_esp_idf::esp_app_desc!();

static COMMANDS: Commands = Commands::new();
static STATUS: Status = Status::new();
static POT_READING: Mutex<CriticalSectionRawMutex, Cell<Option<PotReading>>> =
    Mutex::new(Cell::new(None));
static MOTOR_EXECUTOR: static_cell::StaticCell<esp_rtos::embassy::InterruptExecutor<2>> =
    static_cell::StaticCell::new();

#[embassy_executor::task]
async fn report_status() {
    loop {
        let mut state = STATUS.wait().await;
        // Limita a impressão a 4 Hz mesmo ao girar rapidamente o potenciômetro.
        Timer::after(Duration::from_millis(250)).await;
        if let Some(latest) = STATUS.try_take() {
            state = latest;
        }
        esp_println::println!(
            // Linha curta para evitar encher o FIFO USB durante o movimento.
            "motor {:?} {} alvo={}rpm passos={}",
            state.phase,
            match state.direction {
                Direction::Clockwise => "CW",
                Direction::CounterClockwise => "CCW",
            },
            state.target_rpm,
            state.steps,
        );
        // Diagnóstico só quando o motor está parado. Não imprimir ADC a cada
        // amostra nem criar uma rajada periódica de logs durante o movimento.
        if state.phase == Phase::Stopped {
            if let Some(reading) = POT_READING.lock(|value| value.get()) {
                esp_println::println!(
                    "pot raw={} filtro={} min={} max={}",
                    reading.raw,
                    reading.filtered,
                    reading.minimum,
                    reading.maximum,
                );
            }
        }
    }
}

#[esp_rtos::main]
async fn main(spawner: Spawner) {
    let peripherals = esp_hal::init(esp_hal::Config::default().with_cpu_clock(CpuClock::max()));
    // O driver Wi-Fi precisa de heap; controles, contagem e HTTP usam buffers fixos.
    esp_alloc::heap_allocator!(size: 100 * 1024);

    // Saídas seguras desde a configuração: STEP baixo e driver desabilitado.
    let step = Output::new(peripherals.GPIO4, Level::Low, OutputConfig::default());
    let dir = Output::new(peripherals.GPIO5, Level::High, OutputConfig::default());
    let enable = Output::new(peripherals.GPIO6, Level::High, OutputConfig::default());
    let spindle = StepDirMotor::new(step, dir, enable);

    let sw_int = SoftwareInterruptControl::new(peripherals.SW_INTERRUPT);
    let timg0 = TimerGroup::new(peripherals.TIMG0);
    esp_rtos::start(timg0.timer0, sw_int.software_interrupt0);

    let input_config = InputConfig::default().with_pull(Pull::Up);
    let mut play = Button::new(Input::new(peripherals.GPIO9, input_config));
    let mut invert = Button::new(Input::new(peripherals.GPIO8, input_config));
    let mut speed = Potentiometer::new(peripherals.ADC1, peripherals.GPIO1);
    // GP2 reservado, sem alimentação ou sinal do potenciômetro neste projeto.

    esp_println::println!(
        "enroladora Embassy: 0–{} rpm no GP1, {} passos/volta, micropasso 1/{}; inicia parada",
        MAX_RPM,
        STEPS_PER_REV,
        MICROSTEPS,
    );
    esp_println::println!("GP9 = play/pause; GP8 = inverter; botões para GND");
    esp_println::println!("GP1 ADC calibrado; em pausa, mova o pot para ver raw/filtro/min/max");

    spawner.spawn(report_status().unwrap());
    // O motor pode preemptar parsing HTTP e tarefas normais do executor.
    let motor_executor = MOTOR_EXECUTOR.init(esp_rtos::embassy::InterruptExecutor::new(
        sw_int.software_interrupt2,
    ));
    motor_executor
        .start(Priority::Priority2)
        .spawn(motor::run(spindle, &COMMANDS, &STATUS, &telemetry::TELEMETRY).unwrap());
    spawner.spawn(network::run(peripherals.WIFI, spawner).unwrap());

    // Tarefa dos botões: estado desejado independente do sentido físico atual.
    let mut requested = ControlState::default();
    let mut ticker = Ticker::every(Duration::from_millis(2));
    loop {
        ticker.next().await;
        let now = Instant::now();
        let play_pressed = play.poll_pressed(now);
        let invert_pressed = invert.poll_pressed(now);
        let mut speed_changed = false;
        if let Some(rpm) = speed.poll(now) {
            speed_changed = requested.speed_rpm != rpm;
            requested.speed_rpm = rpm;
        }
        if let Some(reading) = speed.reading() {
            POT_READING.lock(|value| value.set(Some(reading)));
        }
        if play_pressed {
            requested.toggle_running();
        }
        if invert_pressed {
            requested.reverse();
        }
        if play_pressed || invert_pressed || speed_changed {
            COMMANDS.signal(requested);
        }
    }
}
