//! Motor em tarefa Embassy: esperas de período assíncronas, sem pausa periódica.

use crate::telemetry::Telemetry;
use coil_winding_firmware::control::{
    next_deadline_us, Action, ControlState, Direction, Motion, Phase,
};
use coil_winding_firmware::{
    api::Snapshot,
    counting::{RunTimer, TurnCounter},
};
use embassy_sync::{blocking_mutex::raw::CriticalSectionRawMutex, signal::Signal};
use embassy_time::{Duration, Instant, Timer};
use esp_hal::{delay::Delay, gpio::Output};

pub type Commands = Signal<CriticalSectionRawMutex, ControlState>;
pub type Status = Signal<CriticalSectionRawMutex, MotorStatus>;

#[derive(Clone, Copy)]
pub struct MotorStatus {
    pub phase: Phase,
    pub direction: Direction,
    pub steps: u64,
    pub target_rpm: u32,
}

pub struct StepDirMotor {
    step: Output<'static>,
    dir: Output<'static>,
    enable: Output<'static>,
    delay: Delay,
}

impl StepDirMotor {
    /// Saídas já configuradas com STEP baixo, DIR alto e ~ENABLE alto.
    pub fn new(step: Output<'static>, dir: Output<'static>, enable: Output<'static>) -> Self {
        Self {
            step,
            dir,
            enable,
            delay: Delay::new(),
        }
    }

    fn set_direction(&mut self, direction: Direction) {
        self.dir.set_level(match direction {
            Direction::Clockwise => esp_hal::gpio::Level::High,
            Direction::CounterClockwise => esp_hal::gpio::Level::Low,
        });
        // Setup de DIR do DRV8825 ≥650 ns. Não esperar o executor para isso.
        self.delay.delay_micros(3);
    }

    fn pulse(&mut self) {
        self.step.set_high();
        // Única espera ocupada do movimento: largura mínima do pulso.
        // DRV8825 exige ≥1,9 µs; A4988 ≥1 µs. Não há await com STEP alto.
        self.delay.delay_micros(3);
        self.step.set_low();
    }
}

#[embassy_executor::task]
pub async fn run(
    mut spindle: StepDirMotor,
    commands: &'static Commands,
    status: &'static Status,
    telemetry: &'static Telemetry,
) {
    let mut motion = Motion::default();
    let mut last_status = None;
    let mut counter = TurnCounter::new();
    let mut run_timer = RunTimer::new();

    spindle.set_direction(Direction::Clockwise);
    spindle.enable.set_low(); // Energizado, mas inicia sem emitir passos.
    Timer::after(Duration::from_millis(2)).await;
    let mut deadline = Instant::now();

    loop {
        if let Some(state) = commands.try_take() {
            motion.request(state);
        }
        let now_us = Instant::now().as_micros();
        let action = motion.next_action(now_us);
        // Inclui rampas e os dois sentidos, mas não play ativo com velocidade
        // zero, espera inicial ou o intervalo parado entre inversões.
        run_timer.set_running(now_us, matches!(action, Action::Step { .. }));
        let current_status = (motion.phase(), motion.direction(), motion.target_rpm());
        if last_status != Some(current_status) {
            // A impressão serial fica em outra tarefa, não neste caminho.
            status.signal(MotorStatus {
                phase: current_status.0,
                direction: current_status.1,
                steps: counter.total_steps(),
                target_rpm: current_status.2,
            });
            last_status = Some(current_status);
        }

        let wait_until = match action {
            Action::Step { period_us } => {
                spindle.pulse();
                counter.record_step(motion.direction());
                deadline = Instant::from_micros(next_deadline_us(
                    deadline.as_micros(),
                    Instant::now().as_micros(),
                    period_us,
                ));
                Some(deadline)
            }
            Action::SetDirection(direction) => {
                spindle.set_direction(direction);
                deadline = Instant::now();
                None
            }
            Action::Idle => {
                deadline = Instant::now();
                None
            }
        };
        // Snapshot copiado após o pulso, incluindo todos os passos das rampas.
        let snapshot = Snapshot {
            counter,
            run_timer,
            phase: motion.phase(),
            direction: motion.direction(),
            play_active: motion.play_active(),
            target_rpm: motion.target_rpm(),
        };
        telemetry.lock(|value| value.set(snapshot));
        if let Some(deadline) = wait_until {
            Timer::at(deadline).await;
        } else if action == Action::Idle && motion.is_settled() {
            motion.request(commands.wait().await);
            deadline = Instant::now();
        }
    }
}
