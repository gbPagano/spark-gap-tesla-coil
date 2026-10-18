//! Potenciômetro: mediana, suavização e histerese centrada no RPM publicado.

use crate::control::MAX_RPM;

pub const ADC_MAX: u16 = 4095;
/// Margens nos extremos, não uma calibração automática pelo curso observado.
const ADC_ZERO: u16 = 100;
const ADC_FULL: u16 = 4000;
const MEDIAN_SAMPLES: usize = 5;
const FILTER_DIVISOR: i32 = 16;
const RPM_SCALE: u32 = 256;
/// Exige um deslocamento de pelo menos 1 rpm em relação ao valor publicado.
/// Depois da mudança, oscilar perto da mesma fronteira não a desfaz.
const HYSTERESIS_RPM: u32 = RPM_SCALE;

fn rpm_fixed_from_adc(raw: u16) -> u32 {
    let span = u32::from(ADC_FULL - ADC_ZERO);
    let value = u32::from(raw.min(ADC_FULL).saturating_sub(ADC_ZERO));
    value * MAX_RPM * RPM_SCALE / span
}

pub fn rpm_from_adc(raw: u16) -> u32 {
    (rpm_fixed_from_adc(raw) + RPM_SCALE / 2) / RPM_SCALE
}

#[derive(Default)]
pub struct SpeedInput {
    samples: [u16; MEDIAN_SAMPLES],
    next_sample: usize,
    sample_count: usize,
    /// Ponto fixo evita travar o filtro por truncamento antes do valor final.
    filtered: Option<i32>,
    accepted_rpm: Option<u32>,
}

impl SpeedInput {
    pub fn filtered_adc(&self) -> Option<u16> {
        self.filtered.map(|value| ((value + 128) >> 8) as u16)
    }

    pub fn update(&mut self, raw: u16) -> Option<u32> {
        self.samples[self.next_sample] = raw.min(ADC_MAX);
        self.next_sample = (self.next_sample + 1) % MEDIAN_SAMPLES;
        self.sample_count = (self.sample_count + 1).min(MEDIAN_SAMPLES);
        if self.sample_count < MEDIAN_SAMPLES {
            return None;
        }

        let mut sorted = self.samples;
        sorted.sort_unstable();
        let sample = i32::from(sorted[MEDIAN_SAMPLES / 2]) << 8;
        self.filtered = Some(match self.filtered {
            None => sample,
            Some(previous) => previous + (sample - previous) / FILTER_DIVISOR,
        });
        let raw = self.filtered_adc()?;
        let fixed_rpm = rpm_fixed_from_adc(raw);
        let rpm = rpm_from_adc(raw);
        if let Some(previous) = self.accepted_rpm {
            if previous == rpm || fixed_rpm.abs_diff(previous * RPM_SCALE) < HYSTERESIS_RPM {
                return None;
            }
        }
        self.accepted_rpm = Some(rpm);
        Some(rpm)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn settled(raw: u16) -> SpeedInput {
        let mut input = SpeedInput::default();
        for _ in 0..MEDIAN_SAMPLES {
            input.update(raw);
        }
        input
    }

    #[test]
    fn endpoints_and_out_of_range_values_are_safe() {
        assert_eq!(rpm_from_adc(0), 0);
        assert_eq!(rpm_from_adc(ADC_ZERO), 0);
        assert_eq!(rpm_from_adc(ADC_FULL), MAX_RPM);
        assert_eq!(rpm_from_adc(ADC_MAX), MAX_RPM);
        assert_eq!(rpm_from_adc(u16::MAX), MAX_RPM);
    }

    #[test]
    fn mapping_is_monotonic_and_bounded() {
        let mut previous = 0;
        for raw in 0..=ADC_MAX {
            let rpm = rpm_from_adc(raw);
            assert!(rpm >= previous && rpm <= MAX_RPM);
            previous = rpm;
        }
    }

    #[test]
    fn startup_requires_five_samples_and_does_not_invent_a_zero_reading() {
        let mut input = SpeedInput::default();
        for _ in 1..MEDIAN_SAMPLES {
            assert_eq!(input.update(ADC_MAX), None);
        }
        assert_eq!(input.update(ADC_MAX), Some(MAX_RPM));
        assert_eq!(input.update(ADC_MAX), None);
    }

    #[test]
    fn isolated_spike_is_rejected_without_a_speed_change() {
        let mut input = settled(0);
        assert_eq!(input.update(ADC_MAX), None);
        for _ in 0..100 {
            assert_eq!(input.update(0), None);
        }
        assert_eq!(input.filtered_adc(), Some(0));
    }

    #[test]
    fn two_outliers_in_a_five_sample_window_are_rejected() {
        let mut input = settled(0);
        assert_eq!(input.update(ADC_MAX), None);
        assert_eq!(input.update(ADC_MAX), None);
        assert_eq!(input.filtered_adc(), Some(0));
    }

    #[test]
    fn no_one_rpm_chatter_at_any_rounding_boundary() {
        let span = u32::from(ADC_FULL - ADC_ZERO);
        for rpm in 0..MAX_RPM {
            let boundary = u32::from(ADC_ZERO) + span * (2 * rpm + 1) / (2 * MAX_RPM);
            let mut input = settled(boundary as u16);
            // Ruído mantido por várias amostras, não apenas picos isolados.
            for index in 0..1_000 {
                let raw = if (index / 40) % 2 == 0 {
                    boundary - 16
                } else {
                    boundary + 16
                };
                assert_eq!(input.update(raw as u16), None, "fronteira de {rpm} rpm");
            }
        }
    }

    #[test]
    fn full_travel_reaches_both_endpoints() {
        let mut input = settled(0);
        let mut published = 0;
        for _ in 0..300 {
            if let Some(rpm) = input.update(ADC_MAX) {
                published = rpm;
            }
        }
        assert_eq!(published, MAX_RPM);
        for _ in 0..300 {
            if let Some(rpm) = input.update(0) {
                published = rpm;
            }
        }
        assert_eq!(published, 0);
    }

    #[test]
    fn deliberate_one_rpm_adjustment_is_still_possible() {
        let span = u32::from(ADC_FULL - ADC_ZERO);
        let raw = |rpm| (u32::from(ADC_ZERO) + span * rpm / MAX_RPM) as u16;
        let mut input = settled(raw(20));
        let mut published = 20;
        for _ in 0..300 {
            if let Some(rpm) = input.update(raw(21)) {
                published = rpm;
            }
        }
        assert_eq!(published, 21);
        for _ in 0..300 {
            if let Some(rpm) = input.update(raw(20)) {
                published = rpm;
            }
        }
        assert_eq!(published, 20);
    }

    #[test]
    fn returning_to_the_same_boundary_does_not_undo_a_change() {
        let mut input = settled(2050); // 30 rpm
        let mut published = 30;
        for _ in 0..300 {
            if let Some(rpm) = input.update(2120) {
                published = rpm;
            }
        }
        assert_eq!(published, 31);
        for _ in 0..500 {
            assert_eq!(input.update(2080), None);
        }
    }
}
