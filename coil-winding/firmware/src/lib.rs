//! Lógica independente de hardware, compartilhada pelo firmware e pelos testes.
#![no_std]

#[cfg(test)]
extern crate std;

pub mod api;
pub mod control;
pub mod counting;
pub mod debounce;
pub mod http;
pub mod speed;
pub mod startup;

#[cfg(test)]
mod http_tcp_tests;
