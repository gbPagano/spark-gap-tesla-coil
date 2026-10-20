//! Estado desejado, rampa de velocidade e inversão, sem dependência de GPIO.

pub const FULL_STEPS_PER_REV: u32 = 200;
/// Deve corresponder aos jumpers M0/M1/M2. Preservado em 1/32.
pub const MICROSTEPS: u32 = 32;
pub const STEPS_PER_REV: u32 = FULL_STEPS_PER_REV * MICROSTEPS;
pub const MAX_RPM: u32 = 60;
/// Limite de variação da velocidade comandada, em rpm/s.
pub const ACCEL_RPM_PER_SECOND: u32 = 30;
const START_MILLIRPM: u32 = 1_000;
/// Não converter uma longa suspensão do executor em salto grande de velocidade.
const MAX_RAMP_ELAPSED_US: u64 = 100_000;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Direction {
    Clockwise,
    CounterClockwise,
}

impl Direction {
    pub fn opposite(self) -> Self {
        match self {
            Self::Clockwise => Self::CounterClockwise,
            Self::CounterClockwise => Self::Clockwise,
        }
    }
}

/// A tarefa dos controles é a única escritora. O estado completo pode ser
/// coalescido sem perder a intenção final dos botões e do potenciômetro.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct ControlState {
    pub running: bool,
    pub direction: Direction,
    pub speed_rpm: u32,
}

impl Default for ControlState {
    fn default() -> Self {
        Self {
            running: false,
            direction: Direction::Clockwise,
            speed_rpm: 0,
        }
    }
}

impl ControlState {
    pub fn toggle_running(&mut self) {
        self.running = !self.running;
    }

    pub fn reverse(&mut self) {
        self.direction = self.direction.opposite();
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Action {
    Idle,
    SetDirection(Direction),
    Step { period_us: u32 },
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Phase {
    Stopped,
    Accelerating,
    Running,
    Decelerating,
}

pub struct Motion {
    requested: ControlState,
    direction: Direction,
    speed_millirpm: u32,
    last_update_us: Option<u64>,
    ramp_remainder: u64,
}

impl Default for Motion {
    fn default() -> Self {
        Self {
            requested: ControlState::default(),
            direction: Direction::Clockwise,
            speed_millirpm: 0,
            last_update_us: None,
            ramp_remainder: 0,
        }
    }
}

impl Motion {
    pub fn request(&mut self, mut state: ControlState) {
        state.speed_rpm = state.speed_rpm.min(MAX_RPM);
        self.requested = state;
    }

    pub fn direction(&self) -> Direction {
        self.direction
    }
    pub fn speed_millirpm(&self) -> u32 {
        self.speed_millirpm
    }
    pub fn target_rpm(&self) -> u32 {
        self.requested.speed_rpm
    }

    pub fn play_active(&self) -> bool {
        self.requested.running
    }

    fn goal_millirpm(&self) -> u32 {
        if self.requested.running && self.requested.direction == self.direction {
            self.requested.speed_rpm * 1_000
        } else {
            0
        }
    }

    pub fn phase(&self) -> Phase {
        if self.speed_millirpm == 0 {
            Phase::Stopped
        } else if self.speed_millirpm > self.goal_millirpm() {
            Phase::Decelerating
        } else if self.speed_millirpm < self.goal_millirpm() {
            Phase::Accelerating
        } else {
            Phase::Running
        }
    }

    pub fn is_settled(&self) -> bool {
        self.speed_millirpm == 0
            && self.goal_millirpm() == 0
            && self.direction == self.requested.direction
    }

    /// Avança a rampa pelo tempo decorrido, não pelo número de passos. Mudar o
    /// potenciômetro não provoca salto instantâneo do período de STEP.
    pub fn next_action(&mut self, now_us: u64) -> Action {
        if self.speed_millirpm == 0 && self.direction != self.requested.direction {
            self.direction = self.requested.direction;
            self.last_update_us = None;
            return Action::SetDirection(self.direction);
        }

        let goal = self.goal_millirpm();
        let elapsed = self.last_update_us.map_or(0, |previous| {
            now_us.saturating_sub(previous).min(MAX_RAMP_ELAPSED_US)
        });
        self.last_update_us = Some(now_us);

        if self.speed_millirpm == 0 && goal > 0 {
            // Partida em 1 rpm: evita intervalos enormes de uma velocidade
            // quase zero. Não ultrapassa a menor seleção positiva do controle.
            self.speed_millirpm = START_MILLIRPM.min(goal);
            self.ramp_remainder = 0;
        } else if self.speed_millirpm != goal {
            let budget = self.ramp_remainder + u64::from(ACCEL_RPM_PER_SECOND) * 1_000 * elapsed;
            let delta = (budget / 1_000_000) as u32;
            self.ramp_remainder = budget % 1_000_000;
            self.speed_millirpm = if self.speed_millirpm < goal {
                self.speed_millirpm.saturating_add(delta).min(goal)
            } else {
                self.speed_millirpm.saturating_sub(delta).max(goal)
            };
            if goal == 0 && self.speed_millirpm < START_MILLIRPM {
                self.speed_millirpm = 0;
            }
        }
        if self.speed_millirpm == goal {
            self.ramp_remainder = 0;
        }

        if self.speed_millirpm == 0 {
            self.last_update_us = None;
            Action::Idle
        } else {
            let denominator = u64::from(self.speed_millirpm) * u64::from(STEPS_PER_REV);
            Action::Step {
                period_us: (60_000_000_000 / denominator) as u32,
            }
        }
    }
}

/// Mantém prazos absolutos, sem recuperar passos perdidos em rajada.
pub fn next_deadline_us(previous: u64, now: u64, period: u32) -> u64 {
    let next = previous + u64::from(period);
    if next <= now {
        now + u64::from(period)
    } else {
        next
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn state(rpm: u32) -> ControlState {
        ControlState {
            running: true,
            speed_rpm: rpm,
            ..ControlState::default()
        }
    }

    fn running() -> (Motion, u64) {
        let mut motion = Motion::default();
        motion.request(state(MAX_RPM));
        for index in 0..=300 {
            motion.next_action(index * 10_000);
        }
        assert_eq!(motion.phase(), Phase::Running);
        (motion, 3_000_000)
    }

    #[test]
    fn boots_stopped_even_after_a_speed_reading() {
        let mut motion = Motion::default();
        assert_eq!(motion.next_action(0), Action::Idle);
        motion.request(ControlState {
            speed_rpm: MAX_RPM,
            ..ControlState::default()
        });
        assert_eq!(motion.next_action(10_000), Action::Idle);
        assert!(motion.is_settled());
    }

    #[test]
    fn play_accelerates_monotonically_to_the_selected_speed() {
        let mut motion = Motion::default();
        motion.request(state(MAX_RPM));
        let mut previous = u32::MAX;
        for index in 0..=300 {
            let Action::Step { period_us } = motion.next_action(index * 10_000) else {
                panic!()
            };
            assert!(period_us <= previous);
            previous = period_us;
        }
        assert_eq!(motion.speed_millirpm(), MAX_RPM * 1_000);
        assert_eq!(previous, 60_000_000 / (MAX_RPM * STEPS_PER_REV));
    }

    #[test]
    fn speed_changes_are_ramped_in_both_directions() {
        let (mut motion, now) = running();
        motion.request(state(10));
        motion.next_action(now + 10_000);
        assert_eq!(motion.speed_millirpm(), MAX_RPM * 1_000 - 300);
        for index in 2..=200 {
            motion.next_action(now + index * 10_000);
        }
        assert_eq!(motion.speed_millirpm(), 10_000);
        motion.request(state(30));
        motion.next_action(now + 2_010_000);
        assert_eq!(motion.speed_millirpm(), 10_300);
    }

    #[test]
    fn long_executor_delay_does_not_cause_a_large_speed_jump() {
        let mut motion = Motion::default();
        motion.request(state(MAX_RPM));
        motion.next_action(0);
        motion.next_action(10_000_000);
        assert_eq!(motion.speed_millirpm(), 4_000);
    }

    #[test]
    fn fractional_acceleration_is_not_lost_at_high_step_rates() {
        let mut motion = Motion::default();
        motion.request(state(MAX_RPM));
        motion.next_action(0);
        for index in 1..=1_000 {
            motion.next_action(index * 156);
        }
        assert_eq!(motion.speed_millirpm(), 1_000 + 4_680);
    }

    #[test]
    fn pause_stops_without_changing_the_selected_speed() {
        let (mut motion, now) = running();
        motion.request(ControlState {
            running: false,
            ..state(MAX_RPM)
        });
        for index in 1..=300 {
            motion.next_action(now + index * 10_000);
        }
        assert_eq!(motion.next_action(now + 4_000_000), Action::Idle);
        assert_eq!(motion.target_rpm(), MAX_RPM);
        assert!(motion.is_settled());
    }

    #[test]
    fn zero_pot_stops_and_turning_it_up_restarts_only_if_play_is_active() {
        let (mut motion, now) = running();
        motion.request(state(0));
        for index in 1..=300 {
            motion.next_action(now + index * 10_000);
        }
        assert!(motion.is_settled());
        motion.request(state(10));
        assert!(matches!(
            motion.next_action(now + 4_000_000),
            Action::Step { .. }
        ));
        let mut paused = Motion::default();
        paused.request(ControlState {
            speed_rpm: 10,
            ..ControlState::default()
        });
        assert_eq!(paused.next_action(0), Action::Idle);
    }

    #[test]
    fn reverse_never_changes_direction_while_moving() {
        let (mut motion, now) = running();
        let mut request = state(MAX_RPM);
        request.reverse();
        motion.request(request);
        let mut stopped = false;
        let mut reversed = false;
        for index in 1..=300 {
            match motion.next_action(now + index * 10_000) {
                Action::Idle => stopped = true,
                Action::SetDirection(direction) => {
                    assert!(stopped);
                    assert_eq!(direction, Direction::CounterClockwise);
                    reversed = true;
                    break;
                }
                Action::Step { .. } => assert_eq!(motion.direction(), Direction::Clockwise),
            }
        }
        assert!(reversed);
        assert!(matches!(
            motion.next_action(now + 4_000_000),
            Action::Step { .. }
        ));
    }

    #[test]
    fn reversal_at_rest_does_not_start_the_motor() {
        let mut motion = Motion::default();
        let mut request = ControlState::default();
        request.reverse();
        motion.request(request);
        assert_eq!(
            motion.next_action(0),
            Action::SetDirection(Direction::CounterClockwise)
        );
        assert_eq!(motion.next_action(1_000), Action::Idle);
        assert!(motion.is_settled());
    }

    #[test]
    fn second_reverse_cancels_the_first() {
        let (mut motion, now) = running();
        let mut request = state(MAX_RPM);
        request.reverse();
        motion.request(request);
        motion.next_action(now + 10_000);
        request.reverse();
        motion.request(request);
        motion.next_action(now + 20_000);
        assert_eq!(motion.direction(), Direction::Clockwise);
        assert_eq!(motion.phase(), Phase::Running);
    }

    #[test]
    fn pause_and_speed_change_during_reverse_do_not_restart() {
        let (mut motion, now) = running();
        let mut request = state(MAX_RPM);
        request.reverse();
        motion.request(request);
        motion.next_action(now + 10_000);
        request.toggle_running();
        request.speed_rpm = 20;
        motion.request(request);
        for index in 2..=300 {
            motion.next_action(now + index * 10_000);
        }
        assert_eq!(motion.direction(), Direction::CounterClockwise);
        assert!(motion.is_settled());
    }

    #[test]
    fn clamps_excessive_speed_requests() {
        let mut motion = Motion::default();
        motion.request(state(u32::MAX));
        assert_eq!(motion.target_rpm(), MAX_RPM);
    }

    #[test]
    fn command_coalescing_keeps_buttons_and_speed() {
        let mut request = ControlState::default();
        request.toggle_running();
        request.reverse();
        request.speed_rpm = 42;
        request.toggle_running();
        request.reverse();
        assert_eq!(
            request,
            ControlState {
                speed_rpm: 42,
                ..ControlState::default()
            }
        );
    }

    #[test]
    fn deadlines_do_not_accumulate_normal_loop_overhead() {
        assert_eq!(next_deadline_us(1_000, 1_003, 5_000), 6_000);
    }

    #[test]
    fn missed_deadline_is_rescheduled_without_catch_up_burst() {
        assert_eq!(next_deadline_us(1_000, 20_000, 5_000), 25_000);
    }
}
