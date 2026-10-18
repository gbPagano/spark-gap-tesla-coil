//! Motor em tarefa Embassy: esperas de período assíncronas, sem pausa periódica.

use coil_winding_firmware::control::{
    next_deadline_us, Action, ControlState, Direction, Motion, Phase,
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
pub async fn run(mut spindle: StepDirMotor, commands: &'static Commands, status: &'static Status) {
    let mut motion = Motion::default();
    let mut last_status = None;
    let mut steps = 0_u64;

    spindle.set_direction(Direction::Clockwise);
    spindle.enable.set_low(); // Energizado, mas inicia sem emitir passos.
    Timer::after(Duration::from_millis(2)).await;
    let mut deadline = Instant::now();

    loop {
        if let Some(state) = commands.try_take() {
            motion.request(state);
        }
        let action = motion.next_action(Instant::now().as_micros());
        let current_status = (motion.phase(), motion.direction(), motion.target_rpm());
        if last_status != Some(current_status) {
            // A impressão serial fica em outra tarefa, não neste caminho.
            status.signal(MotorStatus {
                phase: current_status.0,
                direction: current_status.1,
                steps,
                target_rpm: current_status.2,
            });
            last_status = Some(current_status);
        }

        match action {
            Action::Step { period_us } => {
                spindle.pulse();
                steps = steps.wrapping_add(1);
                deadline = Instant::from_micros(next_deadline_us(
                    deadline.as_micros(),
                    Instant::now().as_micros(),
                    period_us,
                ));
                // Cede ao executor em TODO passo, sem inserir atrasos extras.
                Timer::at(deadline).await;
            }
            Action::SetDirection(direction) => {
                spindle.set_direction(direction);
                deadline = Instant::now();
            }
            Action::Idle => {
                if motion.is_settled() {
                    motion.request(commands.wait().await);
                }
                deadline = Instant::now();
            }
        }
    }
}
