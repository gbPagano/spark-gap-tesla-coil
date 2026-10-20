//! HTTP somente de consulta, uma requisição por conexão, com buffers limitados.

use core::fmt::Write as _;

use embedded_io_async::{Read, Write};

use crate::api::ApiStatus;

pub const REQUEST_CAPACITY: usize = 1024;
pub const JSON_CAPACITY: usize = 768;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Request {
    Partial,
    Status,
    Malformed,
    NotFound,
    MethodNotAllowed,
    TooLarge,
}

fn parse_request(bytes: &[u8]) -> Request {
    let mut headers = [httparse::EMPTY_HEADER; 16];
    let mut request = httparse::Request::new(&mut headers);
    match request.parse(bytes) {
        Ok(httparse::Status::Partial) => return Request::Partial,
        Err(httparse::Error::TooManyHeaders) => return Request::TooLarge,
        Err(_) => return Request::Malformed,
        Ok(httparse::Status::Complete(_)) => {}
    }
    if !matches!(request.version, Some(0 | 1)) {
        return Request::Malformed;
    }
    if request.method != Some("GET") {
        return Request::MethodNotAllowed;
    }
    if request.version == Some(1) {
        let mut hosts = request
            .headers
            .iter()
            .filter(|header| header.name.eq_ignore_ascii_case("host"));
        if hosts.next().is_none_or(|header| header.value.is_empty()) || hosts.next().is_some() {
            return Request::Malformed;
        }
    }
    // Não aceitar corpo/chunked em GET. A conexão sempre fecha após a resposta.
    if request.headers.iter().any(|header| {
        header.name.eq_ignore_ascii_case("transfer-encoding")
            || (header.name.eq_ignore_ascii_case("content-length") && header.value != b"0")
    }) {
        return Request::Malformed;
    }
    match request.path.and_then(|path| path.split('?').next()) {
        Some("/api/status") => Request::Status,
        _ => Request::NotFound,
    }
}

/// Não segura locks nem chama a fonte de dados antes de validar a requisição.
/// O chamador aplica o timeout global da conexão.
pub async fn serve_connection<S: Read + Write>(
    socket: &mut S,
    read_status: impl FnOnce() -> ApiStatus,
) -> Result<(), S::Error> {
    let mut request_buffer = [0_u8; REQUEST_CAPACITY];
    let mut length = 0;
    let route = loop {
        if length == request_buffer.len() {
            break Request::TooLarge;
        }
        let read = socket.read(&mut request_buffer[length..]).await?;
        if read == 0 {
            if length == 0 {
                return Ok(());
            }
            break Request::Malformed;
        }
        length += read;
        let route = parse_request(&request_buffer[..length]);
        if route != Request::Partial {
            break route;
        }
    };

    let mut json = [0_u8; JSON_CAPACITY];
    let (code, body): (&str, &[u8]) = match route {
        Request::Status => match serde_json_core::to_slice(&read_status(), &mut json) {
            Ok(length) => ("200 OK", &json[..length]),
            Err(_) => (
                "500 Internal Server Error",
                b"{\"error\":\"serialization_failed\"}",
            ),
        },
        Request::NotFound => ("404 Not Found", b"{\"error\":\"not_found\"}"),
        Request::MethodNotAllowed => ("405 Method Not Allowed", b"{\"error\":\"read_only\"}"),
        Request::TooLarge => (
            "431 Request Header Fields Too Large",
            b"{\"error\":\"headers_too_large\"}",
        ),
        _ => ("400 Bad Request", b"{\"error\":\"bad_request\"}"),
    };
    let mut header = HeaderBuffer::new();
    // Tamanho máximo é conhecido: só códigos estáticos e comprimento decimal.
    let result = write!(&mut header,
        "HTTP/1.1 {code}\r\nContent-Type: application/json\r\nContent-Length: {}\r\nCache-Control: no-store\r\nConnection: close\r\n{}\r\n",
        body.len(), if route == Request::MethodNotAllowed { "Allow: GET\r\n" } else { "" },
    );
    if result.is_err() {
        return Ok(());
    }
    socket.write_all(header.as_bytes()).await?;
    socket.write_all(body).await?;
    socket.flush().await
}

struct HeaderBuffer {
    bytes: [u8; 256],
    length: usize,
}

impl HeaderBuffer {
    fn new() -> Self {
        Self {
            bytes: [0; 256],
            length: 0,
        }
    }
    fn as_bytes(&self) -> &[u8] {
        &self.bytes[..self.length]
    }
}

impl core::fmt::Write for HeaderBuffer {
    fn write_str(&mut self, value: &str) -> core::fmt::Result {
        let end = self.length + value.len();
        let target = self
            .bytes
            .get_mut(self.length..end)
            .ok_or(core::fmt::Error)?;
        target.copy_from_slice(value.as_bytes());
        self.length = end;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::api::Snapshot;
    use core::convert::Infallible;
    use std::{string::String, vec::Vec};

    struct Socket {
        request: Vec<u8>,
        offset: usize,
        response: Vec<u8>,
        fragment: usize,
    }
    impl embedded_io_async::ErrorType for Socket {
        type Error = Infallible;
    }
    impl Read for Socket {
        async fn read(&mut self, buffer: &mut [u8]) -> Result<usize, Self::Error> {
            let size = buffer
                .len()
                .min(self.fragment)
                .min(self.request.len() - self.offset);
            buffer[..size].copy_from_slice(&self.request[self.offset..self.offset + size]);
            self.offset += size;
            Ok(size)
        }
    }
    impl Write for Socket {
        async fn write(&mut self, bytes: &[u8]) -> Result<usize, Self::Error> {
            // Testa também write_all com escritas parciais.
            let size = bytes.len().min(7);
            self.response.extend_from_slice(&bytes[..size]);
            Ok(size)
        }
        async fn flush(&mut self) -> Result<(), Self::Error> {
            Ok(())
        }
    }
    fn exchange(request: &[u8], fragment: usize) -> String {
        let mut socket = Socket {
            request: request.to_vec(),
            offset: 0,
            response: Vec::new(),
            fragment,
        };
        futures::executor::block_on(serve_connection(&mut socket, || {
            ApiStatus::from_snapshot(Snapshot::initial(), 1234)
        }))
        .unwrap();
        String::from_utf8(socket.response).unwrap()
    }

    #[test]
    fn fragmented_request_returns_fresh_json_with_correct_length_and_no_cache() {
        let response = exchange(b"GET /api/status HTTP/1.1\r\nHost: esp\r\n\r\n", 1);
        let (headers, body) = response.split_once("\r\n\r\n").unwrap();
        assert!(headers.starts_with("HTTP/1.1 200 OK"));
        assert!(headers.contains("Cache-Control: no-store"));
        assert!(headers.contains("Connection: close"));
        let length: usize = headers
            .lines()
            .find_map(|line| line.strip_prefix("Content-Length: "))
            .unwrap()
            .parse()
            .unwrap();
        assert_eq!(length, body.len());
        let value: serde_json::Value = serde_json::from_str(body).unwrap();
        assert_eq!(value["uptime_s"], 0);
        assert_eq!(value["estimated"], true);
    }

    #[test]
    fn rejects_write_methods_without_reading_or_mutating_motor_state() {
        for method in ["POST", "PUT", "DELETE", "PATCH"] {
            let request = std::format!("{method} /api/status HTTP/1.1\r\nHost: esp\r\n\r\n");
            let response = exchange(request.as_bytes(), 5);
            assert!(response.starts_with("HTTP/1.1 405 Method Not Allowed"));
            assert!(response.contains("Allow: GET\r\n"));
            assert!(response.ends_with("{\"error\":\"read_only\"}"));
        }
    }

    #[test]
    fn unknown_route_returns_404() {
        assert!(
            exchange(b"GET /motor/start HTTP/1.1\r\nHost: esp\r\n\r\n", 100)
                .starts_with("HTTP/1.1 404")
        );
    }

    #[test]
    fn oversized_headers_are_bounded_and_rejected() {
        let request = std::format!("GET /api/status HTTP/1.1\r\nX: {}", "a".repeat(2_000));
        assert!(exchange(request.as_bytes(), 100).starts_with("HTTP/1.1 431"));
    }

    #[test]
    fn malformed_or_incomplete_requests_are_rejected() {
        for request in [
            b"invalid\r\n\r\n".as_slice(),
            b"GET /api/status HTTP/1.1\r\nHost: esp",
        ] {
            assert!(exchange(request, 3).starts_with("HTTP/1.1 400"));
        }
    }

    #[test]
    fn rejects_get_bodies_and_transfer_encoding() {
        for header in ["Content-Length: 8", "Transfer-Encoding: chunked"] {
            let request = std::format!("GET /api/status HTTP/1.1\r\nHost: esp\r\n{header}\r\n\r\n");
            assert!(exchange(request.as_bytes(), 100).starts_with("HTTP/1.1 400"));
        }
    }

    #[test]
    fn query_string_and_http_10_are_supported() {
        assert!(exchange(b"GET /api/status?t=1 HTTP/1.0\r\n\r\n", 100).starts_with("HTTP/1.1 200"));
    }

    #[test]
    fn closes_after_first_request_and_does_not_process_pipelined_commands() {
        let response = exchange(
            b"GET /api/status HTTP/1.1\r\nHost: esp\r\n\r\nPOST /motor/start HTTP/1.1\r\n\r\n",
            100,
        );
        assert_eq!(response.matches("HTTP/1.1").count(), 1);
        assert!(response.starts_with("HTTP/1.1 200"));
    }

    #[test]
    fn unused_browser_connection_can_close_without_a_response() {
        assert_eq!(exchange(b"", 100), "");
    }

    #[test]
    fn http_11_requires_a_single_nonempty_host() {
        for headers in ["", "Host: \r\n", "Host: one\r\nHost: two\r\n"] {
            let request = std::format!("GET /api/status HTTP/1.1\r\n{headers}\r\n");
            assert!(exchange(request.as_bytes(), 100).starts_with("HTTP/1.1 400"));
        }
    }

    #[test]
    fn too_many_small_headers_are_also_bounded() {
        let mut request = String::from("GET /api/status HTTP/1.1\r\nHost: esp\r\n");
        for index in 0..16 {
            request.push_str(&std::format!("X-{index}: a\r\n"));
        }
        request.push_str("\r\n");
        assert!(request.len() < REQUEST_CAPACITY);
        assert!(exchange(request.as_bytes(), 100).starts_with("HTTP/1.1 431"));
    }
}
