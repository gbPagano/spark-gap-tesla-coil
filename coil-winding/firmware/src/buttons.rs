//! Botão GPIO → GND, com pull-up interno e debounce de 20 ms.

use coil_winding_firmware::debounce::Debouncer;
use embassy_time::Instant;
use esp_hal::gpio::Input;

pub struct Button {
    pin: Input<'static>,
    debounce: Debouncer,
}

impl Button {
    pub fn new(pin: Input<'static>) -> Self {
        let debounce = Debouncer::new(pin.is_low(), Instant::now().as_millis());
        Self { pin, debounce }
    }

    pub fn poll_pressed(&mut self, now: Instant) -> bool {
        self.debounce
            .poll_pressed(self.pin.is_low(), now.as_millis())
    }
}
