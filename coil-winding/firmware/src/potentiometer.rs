//! GP1 = ADC1_CH0. Conversão não bloqueante, consultada pela tarefa de controles.

use coil_winding_firmware::speed::{SpeedInput, ADC_MAX};
use embassy_time::{Duration, Instant};
use esp_hal::{
    analog::adc::{Adc, AdcCalBasic, AdcConfig, AdcPin, Attenuation},
    peripherals::{ADC1, GPIO1},
    Blocking,
};

pub struct Potentiometer {
    adc: Adc<'static, ADC1<'static>, Blocking>,
    pin: AdcPin<GPIO1<'static>, ADC1<'static>, AdcCalBasic<ADC1<'static>>>,
    filter: SpeedInput,
    next_sample: Instant,
    raw: Option<u16>,
    minimum: u16,
    maximum: u16,
}

#[derive(Clone, Copy, PartialEq, Eq)]
pub struct PotReading {
    pub raw: u16,
    pub filtered: u16,
    pub minimum: u16,
    pub maximum: u16,
}

impl Potentiometer {
    pub fn new(adc: ADC1<'static>, pin: GPIO1<'static>) -> Self {
        let mut config = AdcConfig::new();
        // Corrige o bias ANTES de truncar a leitura para 12 bits. Sem essa
        // calibração, até 0 V pode produzir uma leitura alta e reduzir o curso.
        let pin =
            config.enable_pin_with_cal::<_, AdcCalBasic<ADC1<'static>>>(pin, Attenuation::_11dB);
        Self {
            adc: Adc::new(adc, config),
            pin,
            filter: SpeedInput::default(),
            next_sample: Instant::now(),
            raw: None,
            minimum: ADC_MAX,
            maximum: 0,
        }
    }

    pub fn reading(&self) -> Option<PotReading> {
        Some(PotReading {
            raw: self.raw?,
            filtered: self.filter.filtered_adc()?,
            minimum: self.minimum,
            maximum: self.maximum,
        })
    }

    pub fn poll(&mut self, now: Instant) -> Option<u32> {
        if now < self.next_sample {
            return None;
        }
        match self.adc.read_oneshot(&mut self.pin) {
            Ok(raw) => {
                self.next_sample = now + Duration::from_millis(10);
                self.raw = Some(raw);
                self.minimum = self.minimum.min(raw);
                self.maximum = self.maximum.max(raw);
                self.filter.update(raw)
            }
            // No ESP32-S3 desta versão do HAL não há ADC async. Em vez de
            // block!, voltamos ao executor e consultamos de novo no próximo tick.
            Err(nb::Error::WouldBlock) => None,
            Err(nb::Error::Other(())) => {
                self.next_sample = now + Duration::from_millis(10);
                self.filter = SpeedInput::default();
                Some(0)
            }
        }
    }
}
