//! Valores de retomada informados no build; não recupera estado da flash.

use crate::{
    api::Snapshot,
    control::STEPS_PER_REV,
    counting::{RunTimer, TurnCounter},
};

/// Ausência de uma variável mantém zero. Valores inválidos impedem a partida.
pub fn initial_snapshot(
    turns: Option<&str>,
    uptime_s: Option<&str>,
) -> Result<Snapshot, &'static str> {
    let turns = turns
        .unwrap_or("0")
        .parse::<f64>()
        .map_err(|_| "COIL_INITIAL_TURNS: use um numero decimal com ponto")?;
    // Arredonda uma única vez ao pulso mais próximo, inclusive valores negativos.
    let steps = turns * f64::from(STEPS_PER_REV);
    let steps = steps + if steps < 0.0 { -0.5 } else { 0.5 };
    // O limite superior é exclusivo: i64::MAX como f64 arredonda para 2^63.
    if !steps.is_finite() || !((i64::MIN as f64)..-(i64::MIN as f64)).contains(&steps) {
        return Err("COIL_INITIAL_TURNS: valor fora do intervalo do contador");
    }
    let elapsed_us = uptime_s
        .unwrap_or("0")
        .parse::<u64>()
        .ok()
        .and_then(|seconds| seconds.checked_mul(1_000_000))
        .ok_or("COIL_INITIAL_UPTIME_S: use segundos inteiros nao negativos dentro do limite u64/1000000")?;

    Ok(Snapshot {
        counter: TurnCounter::with_initial_steps(steps as i64),
        run_timer: RunTimer::with_initial_elapsed_us(elapsed_us),
        ..Snapshot::initial()
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{api::ApiStatus, control::Direction};

    #[test]
    fn omitted_values_start_at_zero_and_stopped() {
        let status = ApiStatus::from_snapshot(initial_snapshot(None, None).unwrap(), u64::MAX);
        assert_eq!(status.turns, 0.0);
        assert_eq!(status.uptime_s, 0);
        assert_eq!(status.phase, "stopped");
        assert!(!status.play_active);
        assert_eq!(status.target_rpm, 0);
    }

    #[test]
    fn each_value_can_be_configured_independently() {
        let turns = ApiStatus::from_snapshot(initial_snapshot(Some("123.75"), None).unwrap(), 0);
        assert_eq!(turns.turns, 123.75);
        assert_eq!(turns.uptime_s, 0);
        let time = ApiStatus::from_snapshot(initial_snapshot(None, Some("3600")).unwrap(), 0);
        assert_eq!(time.turns, 0.0);
        assert_eq!(time.uptime_s, 3600);
    }

    #[test]
    fn resumed_count_adds_and_subtracts_only_new_steps() {
        for turns in ["123.75", "-123.75"] {
            let mut snapshot = initial_snapshot(Some(turns), Some("3600")).unwrap();
            let before = snapshot.counter.net_steps();
            assert_eq!(snapshot.counter.total_steps(), 0);
            snapshot.counter.record_step(Direction::Clockwise);
            assert_eq!(snapshot.counter.net_steps(), before + 1);
            snapshot.counter.record_step(Direction::CounterClockwise);
            assert_eq!(snapshot.counter.net_steps(), before);
            assert_eq!(snapshot.counter.total_steps(), 2);
        }
    }

    #[test]
    fn decimal_turns_are_rounded_to_the_nearest_step() {
        for (turns, expected) in [("0.0001", 1), ("-0.0001", -1), ("0.00001", 0)] {
            let snapshot = initial_snapshot(Some(turns), None).unwrap();
            assert_eq!(snapshot.counter.net_steps(), expected);
        }
    }

    #[test]
    fn resumed_timer_excludes_boot_and_pauses_and_preserves_fractions() {
        let mut snapshot = initial_snapshot(Some("123.75"), Some("3600")).unwrap();
        assert_eq!(
            ApiStatus::from_snapshot(snapshot, 10_000_000).uptime_s,
            3600
        );
        snapshot.run_timer.set_running(10_000_000, true);
        snapshot.run_timer.set_running(10_750_000, false);
        assert_eq!(
            ApiStatus::from_snapshot(snapshot, 50_000_000).uptime_s,
            3600
        );
        snapshot.run_timer.set_running(50_000_000, true);
        assert_eq!(
            ApiStatus::from_snapshot(snapshot, 50_250_000).uptime_s,
            3601
        );
    }

    #[test]
    fn invalid_turns_are_rejected() {
        for turns in [
            "", "abc", "1,5", "NaN", "inf", "-inf", "1e300", "1e20", "-1e20",
        ] {
            assert!(initial_snapshot(Some(turns), None).is_err(), "{turns}");
        }
    }

    #[test]
    fn invalid_or_overflowing_times_are_rejected() {
        for time in [
            "",
            "abc",
            "-1",
            "1.5",
            "01:00:00",
            "18446744073710",
            "18446744073709551616",
        ] {
            assert!(initial_snapshot(None, Some(time)).is_err(), "{time}");
        }
        let snapshot = initial_snapshot(None, Some("18446744073709")).unwrap();
        assert_eq!(
            snapshot.run_timer.elapsed_seconds(u64::MAX),
            18_446_744_073_709
        );
    }
}
