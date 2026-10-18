//! Debounce por tempo, independente da frequência dos passos do motor.

const DEBOUNCE_MS: u64 = 20;

pub struct Debouncer {
    candidate: bool,
    stable: bool,
    changed_at_ms: u64,
    armed: bool,
}

impl Debouncer {
    /// Se ligar com o botão apertado, exige soltura antes do primeiro comando.
    pub fn new(initial_pressed: bool, now_ms: u64) -> Self {
        Self {
            candidate: initial_pressed,
            stable: initial_pressed,
            changed_at_ms: now_ms,
            armed: !initial_pressed,
        }
    }

    /// `true` uma vez por pressão estável, nunca na soltura ou ao segurar.
    pub fn poll_pressed(&mut self, raw_pressed: bool, now_ms: u64) -> bool {
        if raw_pressed != self.candidate {
            self.candidate = raw_pressed;
            self.changed_at_ms = now_ms;
        }
        if now_ms.saturating_sub(self.changed_at_ms) < DEBOUNCE_MS {
            return false;
        }
        if !self.candidate {
            self.armed = true;
        }
        if self.stable == self.candidate {
            return false;
        }
        self.stable = self.candidate;
        self.stable && self.armed
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn short_bounce_does_not_press() {
        let mut button = Debouncer::new(false, 0);
        assert!(!button.poll_pressed(true, 10));
        assert!(!button.poll_pressed(false, 15));
        assert!(!button.poll_pressed(false, 50));
    }

    #[test]
    fn fires_once_per_press_and_requires_stable_release() {
        let mut button = Debouncer::new(false, 0);
        assert!(!button.poll_pressed(true, 10));
        assert!(!button.poll_pressed(true, 29));
        assert!(button.poll_pressed(true, 30));
        assert!(!button.poll_pressed(true, 1_000));
        assert!(!button.poll_pressed(false, 1_010));
        assert!(!button.poll_pressed(true, 1_015));
        assert!(!button.poll_pressed(true, 1_050));
        assert!(!button.poll_pressed(false, 1_100));
        assert!(!button.poll_pressed(false, 1_120));
        assert!(!button.poll_pressed(true, 1_200));
        assert!(button.poll_pressed(true, 1_220));
    }

    #[test]
    fn held_at_boot_requires_release_then_new_press() {
        let mut button = Debouncer::new(true, 0);
        assert!(!button.poll_pressed(true, 100));
        assert!(!button.poll_pressed(false, 110));
        assert!(!button.poll_pressed(false, 130));
        assert!(!button.poll_pressed(true, 140));
        assert!(button.poll_pressed(true, 160));
    }
}
