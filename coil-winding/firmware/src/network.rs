//! Wi-Fi station + DHCP + HTTP de consulta, separado da geração de passos.

use coil_winding_firmware::{api::ApiStatus, http::serve_connection};
use embassy_executor::Spawner;
use embassy_net::{tcp::TcpSocket, Runner, Stack, StackResources};
use embassy_time::{with_timeout, Duration, Instant, Timer};
use esp_hal::{peripherals::WIFI, rng::Rng};
use esp_radio::wifi::{
    sta::StationConfig, AuthenticationMethod, Config, ControllerConfig, Interface, WifiController,
};
use static_cell::StaticCell;

use crate::telemetry::TELEMETRY;

// env! faz o Cargo recompilar quando as variáveis mudam. Nunca logar a senha.
const SSID: &str = env!(
    "WIFI_SSID",
    "Defina WIFI_SSID no ambiente do cargo build/run"
);
const PASSWORD: &str = env!(
    "WIFI_PASSWORD",
    "Defina WIFI_PASSWORD no ambiente do cargo build/run"
);
const fn validate_credentials(ssid: &str, password: &str) {
    assert!(
        !ssid.is_empty() && ssid.len() <= 32,
        "WIFI_SSID deve ter 1–32 bytes"
    );
    assert!(
        password.is_empty() || (password.len() >= 8 && password.len() <= 64),
        "WIFI_PASSWORD deve estar vazia (rede aberta) ou ter 8–64 bytes"
    );
}
const CREDENTIALS: (&str, &str) = {
    validate_credentials(SSID, PASSWORD);
    (SSID, PASSWORD)
};

fn authentication_method(password: &str) -> AuthenticationMethod {
    if password.is_empty() {
        AuthenticationMethod::None
    } else {
        AuthenticationMethod::Wpa2Personal
    }
}

static RESOURCES: StaticCell<StackResources<4>> = StaticCell::new();

#[embassy_executor::task]
pub async fn run(wifi: WIFI<'static>, spawner: Spawner) {
    let (ssid, password) = CREDENTIALS;
    esp_println::println!("Wi-Fi: iniciando station; aguardando conexao e DHCP");
    let station = Config::Station(
        StationConfig::default()
            .with_ssid(ssid)
            .with_auth_method(authentication_method(password))
            .with_password(password.into()),
    );
    let Ok((controller, interfaces)) = esp_radio::wifi::new(
        wifi,
        ControllerConfig::default().with_initial_config(station),
    ) else {
        esp_println::println!("Wi-Fi: falha ao inicializar; controles locais continuam ativos");
        return;
    };
    let rng = Rng::new();
    let seed = (u64::from(rng.random()) << 32) | u64::from(rng.random());
    let (stack, runner) = embassy_net::new(
        interfaces.station,
        embassy_net::Config::dhcpv4(Default::default()),
        RESOURCES.init(StackResources::new()),
        seed,
    );
    spawner.spawn(connection(controller).unwrap());
    spawner.spawn(net_task(runner).unwrap());
    spawner.spawn(http_task(0, stack).unwrap());
    spawner.spawn(http_task(1, stack).unwrap());

    let mut last_address = None;
    loop {
        let address = stack
            .config_v4()
            .filter(|_| stack.is_link_up())
            .map(|config| config.address.address());
        if address != last_address {
            match address {
                Some(address) => esp_println::println!("HTTP: http://{address}/api/status"),
                None => {
                    esp_println::println!("Wi-Fi: sem IP; contagem e controles locais preservados")
                }
            }
            last_address = address;
        }
        Timer::after(Duration::from_secs(1)).await;
    }
}

#[embassy_executor::task]
async fn connection(mut controller: WifiController<'static>) {
    loop {
        match controller.connect_async().await {
            Ok(_) => {
                let _ = controller.wait_for_disconnect_async().await;
            }
            Err(_) => esp_println::println!("Wi-Fi: conexao falhou; nova tentativa em 5 s"),
        }
        Timer::after(Duration::from_secs(5)).await;
    }
}

#[embassy_executor::task]
async fn net_task(mut runner: Runner<'static, Interface<'static>>) {
    runner.run().await
}

fn read_status() -> ApiStatus {
    let snapshot = TELEMETRY.lock(|value| value.get());
    ApiStatus::from_snapshot(snapshot, Instant::now().as_micros())
}

#[embassy_executor::task(pool_size = 2)]
async fn http_task(_id: usize, stack: Stack<'static>) {
    let mut rx = [0_u8; 1536];
    let mut tx = [0_u8; 1536];
    loop {
        stack.wait_config_up().await;
        let mut socket = TcpSocket::new(stack, &mut rx, &mut tx);
        socket.set_timeout(Some(Duration::from_secs(2)));
        if socket.accept(80).await.is_err() {
            continue;
        }
        // Prazo absoluto, inclusive contra clientes que enviam headers lentamente.
        let _ = with_timeout(
            Duration::from_secs(2),
            serve_connection(&mut socket, read_status),
        )
        .await;
        socket.close();
        let _ = with_timeout(Duration::from_millis(200), socket.flush()).await;
        socket.abort();
        // Não imprimir por conexão: a rede não deve gerar logs a cada consulta.
    }
}
