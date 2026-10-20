//! Seção crítica curta: copiar snapshot, nunca formatar ou aguardar sob lock.

use coil_winding_firmware::api::Snapshot;
use core::cell::Cell;
use embassy_sync::blocking_mutex::{raw::CriticalSectionRawMutex, Mutex};

pub type Telemetry = Mutex<CriticalSectionRawMutex, Cell<Snapshot>>;

pub static TELEMETRY: Telemetry = Mutex::new(Cell::new(Snapshot::initial()));
