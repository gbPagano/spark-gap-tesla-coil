//! Contadores de pulsos e tempo de movimento comandado, sem medição física.

use crate::control::Direction;

/// Clockwise é o sentido lógico escolhido como enrolar. Acoplamento 1:1.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct TurnCounter {
    net_steps: i64,
    total_steps: u64,
}

impl TurnCounter {
    pub const fn new() -> Self {
        Self::with_initial_steps(0)
    }

    /// Saldo anterior informado pelo operador; percurso conta só os novos pulsos.
    pub const fn with_initial_steps(net_steps: i64) -> Self {
        Self {
            net_steps,
            total_steps: 0,
        }
    }

    /// Chamar apenas depois da emissão de STEP, com o sentido efetivo atual.
    pub fn record_step(&mut self, direction: Direction) {
        self.total_steps = self.total_steps.saturating_add(1);
        self.net_steps = match direction {
            Direction::Clockwise => self.net_steps.saturating_add(1),
            Direction::CounterClockwise => self.net_steps.saturating_sub(1),
        };
    }

    pub const fn net_steps(self) -> i64 {
        self.net_steps
    }
    pub const fn total_steps(self) -> u64 {
        self.total_steps
    }
}

/// Tempo acumulado apenas enquanto o firmware está gerando movimento.
/// Preserva frações de segundo entre pausas; consultas não alteram o relógio.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct RunTimer {
    accumulated_us: u64,
    running_since_us: Option<u64>,
}

impl RunTimer {
    pub const fn new() -> Self {
        Self::with_initial_elapsed_us(0)
    }

    /// Começa parado, preservando o tempo de movimento de uma sessão anterior.
    pub const fn with_initial_elapsed_us(accumulated_us: u64) -> Self {
        Self {
            accumulated_us,
            running_since_us: None,
        }
    }

    pub fn set_running(&mut self, now_us: u64, running: bool) {
        match (self.running_since_us, running) {
            (None, true) => self.running_since_us = Some(now_us),
            (Some(start), false) => {
                self.accumulated_us = self
                    .accumulated_us
                    .saturating_add(now_us.saturating_sub(start));
                self.running_since_us = None;
            }
            _ => {}
        }
    }

    pub fn elapsed_us(self, now_us: u64) -> u64 {
        self.accumulated_us.saturating_add(
            self.running_since_us
                .map_or(0, |start| now_us.saturating_sub(start)),
        )
    }

    pub fn elapsed_seconds(self, now_us: u64) -> u64 {
        self.elapsed_us(now_us) / 1_000_000
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::control::{Action, ControlState, Motion, MAX_RPM, STEPS_PER_REV};

    #[test]
    fn starts_at_zero_and_preserves_partial_turns() {
        let mut counter = TurnCounter::new();
        assert_eq!(counter.net_steps(), 0);
        for _ in 0..STEPS_PER_REV + 123 {
            counter.record_step(Direction::Clockwise);
        }
        assert_eq!(counter.net_steps(), i64::from(STEPS_PER_REV + 123));
        assert_eq!(counter.total_steps(), u64::from(STEPS_PER_REV + 123));
    }

    #[test]
    fn reverse_subtracts_without_losing_total_travel() {
        let mut counter = TurnCounter::new();
        for _ in 0..100 {
            counter.record_step(Direction::Clockwise);
        }
        for _ in 0..25 {
            counter.record_step(Direction::CounterClockwise);
        }
        assert_eq!(counter.net_steps(), 75);
        assert_eq!(counter.total_steps(), 125);
    }

    #[test]
    fn can_return_to_zero_and_go_negative_without_unsigned_wrap() {
        let mut counter = TurnCounter::new();
        counter.record_step(Direction::Clockwise);
        counter.record_step(Direction::CounterClockwise);
        assert_eq!(counter.net_steps(), 0);
        counter.record_step(Direction::CounterClockwise);
        assert_eq!(counter.net_steps(), -1);
        assert_eq!(counter.total_steps(), 3);
    }

    #[test]
    fn pause_preserves_count_including_the_deceleration_steps() {
        let mut motion = Motion::default();
        let mut counter = TurnCounter::new();
        let mut request = ControlState {
            running: true,
            speed_rpm: MAX_RPM,
            ..ControlState::default()
        };
        motion.request(request);
        for index in 0..300 {
            if matches!(motion.next_action(index * 10_000), Action::Step { .. }) {
                counter.record_step(motion.direction());
            }
        }
        let before_braking = counter;
        request.toggle_running();
        motion.request(request);
        for index in 300..600 {
            if matches!(motion.next_action(index * 10_000), Action::Step { .. }) {
                counter.record_step(motion.direction());
            }
        }
        assert!(counter.total_steps() > before_braking.total_steps());
        let stopped = counter;
        for index in 600..800 {
            assert_eq!(motion.next_action(index * 10_000), Action::Idle);
        }
        assert_eq!(counter, stopped);
    }

    #[test]
    fn extreme_counters_saturate_instead_of_wrapping() {
        let mut counter = TurnCounter {
            net_steps: i64::MAX,
            total_steps: u64::MAX,
        };
        counter.record_step(Direction::Clockwise);
        assert_eq!(counter.net_steps(), i64::MAX);
        assert_eq!(counter.total_steps(), u64::MAX);
        let mut counter = TurnCounter {
            net_steps: i64::MIN,
            total_steps: 0,
        };
        counter.record_step(Direction::CounterClockwise);
        assert_eq!(counter.net_steps(), i64::MIN);
    }

    #[test]
    fn run_timer_excludes_time_before_first_movement() {
        let timer = RunTimer::new();
        assert_eq!(timer.elapsed_us(u64::MAX), 0);
    }

    #[test]
    fn active_time_is_visible_without_mutating_the_snapshot() {
        let mut timer = RunTimer::new();
        timer.set_running(10_000_000, true);
        assert_eq!(timer.elapsed_seconds(10_999_999), 0);
        assert_eq!(timer.elapsed_seconds(11_000_000), 1);
        assert_eq!(timer.elapsed_seconds(12_000_000), 2);
    }

    #[test]
    fn repeated_steps_do_not_reset_the_run_timer() {
        let mut timer = RunTimer::new();
        timer.set_running(1_000_000, true);
        timer.set_running(2_000_000, true);
        timer.set_running(3_000_000, true);
        assert_eq!(timer.elapsed_seconds(4_000_000), 3);
    }

    #[test]
    fn pauses_are_excluded_and_subsecond_runs_accumulate() {
        let mut timer = RunTimer::new();
        timer.set_running(1_000_000, true);
        timer.set_running(1_650_000, false);
        assert_eq!(timer.elapsed_us(50_000_000), 650_000);
        timer.set_running(50_000_000, true);
        timer.set_running(50_650_000, false);
        assert_eq!(timer.elapsed_us(100_000_000), 1_300_000);
        assert_eq!(timer.elapsed_seconds(100_000_000), 1);
    }

    #[test]
    fn run_timer_is_defensive_against_overflow_and_backward_timestamps() {
        let mut timer = RunTimer {
            accumulated_us: u64::MAX - 1,
            running_since_us: Some(10),
        };
        assert_eq!(timer.elapsed_us(9), u64::MAX - 1);
        timer.set_running(100, false);
        assert_eq!(timer.elapsed_us(u64::MAX), u64::MAX);
    }

    #[test]
    fn play_active_with_zero_speed_does_not_accumulate_time() {
        let mut motion = Motion::default();
        let mut timer = RunTimer::new();
        motion.request(ControlState {
            running: true,
            ..ControlState::default()
        });
        for index in 0..100 {
            let now = index * 1_000_000;
            let action = motion.next_action(now);
            timer.set_running(now, matches!(action, Action::Step { .. }));
        }
        assert_eq!(timer.elapsed_seconds(100_000_000), 0);
    }
}
