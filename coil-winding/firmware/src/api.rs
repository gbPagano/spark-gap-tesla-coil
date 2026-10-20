//! Snapshot coerente e resposta JSON. Nenhum handler altera o movimento.

use serde::Serialize;

use crate::{
    control::{Direction, Phase, STEPS_PER_REV},
    counting::{RunTimer, TurnCounter},
};

#[derive(Clone, Copy)]
pub struct Snapshot {
    pub counter: TurnCounter,
    pub run_timer: RunTimer,
    pub phase: Phase,
    pub direction: Direction,
    pub play_active: bool,
    pub target_rpm: u32,
}

impl Snapshot {
    pub const fn initial() -> Self {
        Self {
            counter: TurnCounter::new(),
            run_timer: RunTimer::new(),
            phase: Phase::Stopped,
            direction: Direction::Clockwise,
            play_active: false,
            target_rpm: 0,
        }
    }
}

#[derive(Serialize)]
pub struct ApiStatus {
    pub estimated: bool,
    pub turns: f64,
    pub phase: &'static str,
    pub direction: &'static str,
    pub play_active: bool,
    pub target_rpm: u32,
    pub uptime_s: u64,
}

impl ApiStatus {
    pub fn from_snapshot(snapshot: Snapshot, now_us: u64) -> Self {
        Self {
            estimated: true,
            turns: snapshot.counter.net_steps() as f64 / f64::from(STEPS_PER_REV),
            phase: match snapshot.phase {
                Phase::Stopped => "stopped",
                Phase::Accelerating => "accelerating",
                Phase::Running => "running",
                Phase::Decelerating => "decelerating",
            },
            direction: match snapshot.direction {
                Direction::Clockwise => "clockwise",
                Direction::CounterClockwise => "counterclockwise",
            },
            play_active: snapshot.play_active,
            target_rpm: snapshot.target_rpm,
            uptime_s: snapshot.run_timer.elapsed_seconds(now_us),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn one_turn_then_quarter_turn_back_is_three_quarters() {
        let mut snapshot = Snapshot::initial();
        for _ in 0..STEPS_PER_REV {
            snapshot.counter.record_step(Direction::Clockwise);
        }
        for _ in 0..STEPS_PER_REV / 4 {
            snapshot.counter.record_step(Direction::CounterClockwise);
        }
        let status = ApiStatus::from_snapshot(snapshot, 1_000);
        assert_eq!(status.turns, 0.75);
        assert!(status.estimated);
        assert_eq!(
            snapshot.counter.net_steps(),
            i64::from(STEPS_PER_REV) * 3 / 4
        );
    }

    #[test]
    fn negative_partial_turn_is_preserved() {
        let mut snapshot = Snapshot::initial();
        snapshot.counter.record_step(Direction::CounterClockwise);
        let status = ApiStatus::from_snapshot(snapshot, 510);
        assert!(status.turns < 0.0 && status.turns > -1.0);
        assert_eq!(snapshot.counter.net_steps(), -1);
    }

    #[test]
    fn uptime_is_reported_in_completed_seconds() {
        for (microseconds, seconds) in [
            (0, 0),
            (999_999, 0),
            (1_000_000, 1),
            (10_999_999, 10),
            (u64::MAX, u64::MAX / 1_000_000),
        ] {
            let mut snapshot = Snapshot::initial();
            snapshot.run_timer.set_running(0, true);
            assert_eq!(
                ApiStatus::from_snapshot(snapshot, microseconds).uptime_s,
                seconds
            );
        }
    }

    #[test]
    fn response_is_bounded_valid_json_without_credentials() {
        let status = ApiStatus::from_snapshot(Snapshot::initial(), u64::MAX);
        let mut buffer = [0_u8; crate::http::JSON_CAPACITY];
        let len = serde_json_core::to_slice(&status, &mut buffer).unwrap();
        let value: serde_json::Value = serde_json::from_slice(&buffer[..len]).unwrap();
        assert_eq!(value["estimated"], true);
        assert_eq!(value["turns"], 0.0);
        assert_eq!(value["phase"], "stopped");
        assert_eq!(value["target_rpm"], 0);
        assert_eq!(value.as_object().unwrap().len(), 7);
        for removed in [
            "net_steps",
            "commanded_rpm",
            "sample_age_ms",
            "uptime_ms",
            "total_steps",
            "steps_per_turn",
        ] {
            assert!(
                value.get(removed).is_none(),
                "campo removido voltou à API: {removed}"
            );
        }
        assert!(value.get("ssid").is_none() && value.get("password").is_none());
    }

    #[test]
    fn all_counter_extremes_still_fit_the_response_buffer() {
        let status = ApiStatus {
            estimated: true,
            turns: i64::MIN as f64 / f64::from(STEPS_PER_REV),
            phase: "decelerating",
            direction: "counterclockwise",
            play_active: true,
            target_rpm: u32::MAX,
            uptime_s: u64::MAX / 1_000_000,
        };
        let mut buffer = [0_u8; crate::http::JSON_CAPACITY];
        let len = serde_json_core::to_slice(&status, &mut buffer).unwrap();
        assert!(serde_json::from_slice::<serde_json::Value>(&buffer[..len]).is_ok());
    }

    #[test]
    fn current_target_is_reported_even_while_paused() {
        let mut snapshot = Snapshot::initial();
        for target in [10, 30, 60, 0] {
            snapshot.target_rpm = target;
            let status = ApiStatus::from_snapshot(snapshot, 1_000);
            assert_eq!(status.target_rpm, target);
            assert_eq!(status.phase, "stopped");
            assert!(!status.play_active);
        }
    }

    #[test]
    fn repeated_http_snapshots_do_not_add_paused_time() {
        let mut snapshot = Snapshot::initial();
        snapshot.run_timer.set_running(10_000_000, true);
        snapshot.run_timer.set_running(12_500_000, false);
        for now in [12_500_000, 100_000_000, 1_000_000_000] {
            assert_eq!(ApiStatus::from_snapshot(snapshot, now).uptime_s, 2);
        }
        snapshot.run_timer.set_running(1_000_000_000, true);
        assert_eq!(
            ApiStatus::from_snapshot(snapshot, 1_000_500_000).uptime_s,
            3
        );
    }
}
