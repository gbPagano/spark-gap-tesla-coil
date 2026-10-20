//! Exercita o mesmo handler HTTP sobre TCP local, sem rádio ou GPIO simulados.

use crate::{
    api::{ApiStatus, Snapshot},
    control::{Direction, STEPS_PER_REV},
    http::serve_connection,
};
use core::convert::Infallible;
use std::{
    io::{Read as _, Write as _},
    net::{TcpListener, TcpStream},
    string::String,
    sync::{Arc, Mutex},
    thread,
    time::Duration,
};

struct HostSocket(TcpStream);

impl embedded_io_async::ErrorType for HostSocket {
    type Error = Infallible;
}
impl embedded_io_async::Read for HostSocket {
    async fn read(&mut self, buffer: &mut [u8]) -> Result<usize, Self::Error> {
        Ok(self.0.read(buffer).expect("leitura TCP do teste"))
    }
}
impl embedded_io_async::Write for HostSocket {
    async fn write(&mut self, bytes: &[u8]) -> Result<usize, Self::Error> {
        Ok(self.0.write(bytes).expect("escrita TCP do teste"))
    }
    async fn flush(&mut self) -> Result<(), Self::Error> {
        self.0.flush().expect("flush TCP do teste");
        Ok(())
    }
}

#[test]
fn successive_http_reads_observe_forward_reverse_and_paused_counts() {
    let listener = TcpListener::bind("127.0.0.1:0").unwrap();
    let address = listener.local_addr().unwrap();
    let snapshot = Arc::new(Mutex::new(Snapshot::initial()));
    let server_snapshot = Arc::clone(&snapshot);
    let server = thread::spawn(move || {
        for _ in 0..3 {
            let (stream, _) = listener.accept().unwrap();
            stream
                .set_read_timeout(Some(Duration::from_secs(3)))
                .unwrap();
            stream
                .set_write_timeout(Some(Duration::from_secs(3)))
                .unwrap();
            futures::executor::block_on(serve_connection(&mut HostSocket(stream), || {
                let snapshot = *server_snapshot.lock().unwrap();
                ApiStatus::from_snapshot(snapshot, 10_000_000)
            }))
            .unwrap();
        }
    });
    let query = || {
        let mut client = TcpStream::connect_timeout(&address, Duration::from_secs(3)).unwrap();
        client
            .set_read_timeout(Some(Duration::from_secs(3)))
            .unwrap();
        client
            .write_all(b"GET /api/status HTTP/1.1\r\nHost: esp\r\n\r\n")
            .unwrap();
        let mut response = String::new();
        client.read_to_string(&mut response).unwrap();
        let (headers, body) = response.split_once("\r\n\r\n").unwrap();
        assert!(headers.starts_with("HTTP/1.1 200 OK"));
        assert!(headers.contains("Cache-Control: no-store"));
        serde_json::from_str::<serde_json::Value>(body).unwrap()
    };
    let initial = query();
    assert_eq!(initial["turns"], 0.0);
    assert_eq!(initial["uptime_s"], 0);
    {
        let mut snapshot = snapshot.lock().unwrap();
        for _ in 0..STEPS_PER_REV {
            snapshot.counter.record_step(Direction::Clockwise);
        }
        snapshot.run_timer.set_running(1_000_000, true);
        snapshot.run_timer.set_running(3_500_000, false);
    }
    let forward = query();
    assert_eq!(forward["turns"], 1.0);
    assert_eq!(forward["uptime_s"], 2);
    {
        let mut snapshot = snapshot.lock().unwrap();
        for _ in 0..STEPS_PER_REV / 4 {
            snapshot.counter.record_step(Direction::CounterClockwise);
        }
        snapshot.run_timer.set_running(5_000_000, true);
        snapshot.run_timer.set_running(5_750_000, false);
    }
    let status = query();
    assert_eq!(status["turns"], 0.75);
    assert_eq!(status["phase"], "stopped");
    assert_eq!(status["estimated"], true);
    assert_eq!(status["uptime_s"], 3);
    assert_eq!(
        snapshot.lock().unwrap().counter.net_steps(),
        i64::from(STEPS_PER_REV) * 3 / 4
    );
    server.join().unwrap();
}
