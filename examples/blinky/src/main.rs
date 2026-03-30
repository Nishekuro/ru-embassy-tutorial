#![no_std]
#![no_main]

use defmt::*; // отладочная информация
use embassy_executor::Spawner; // базовый компонент для работы фрейймворка embassy
use embassy_stm32::gpio::{Level, Output, Speed}; // управление пинами входа-выхода
use embassy_time::Timer; // функции ожидания
use {defmt_rtt as _, panic_probe as _}; // обработка ошибок

#[embassy_executor::main]
async fn main(_spawner: Spawner) {
    let p = embassy_stm32::init(Default::default()); // инициализацция переферии
    info!("Hello World!");

    let mut led = Output::new(p.PC13, Level::High, Speed::Low); // инициализация пина C13

    loop {
        info!("high");
        led.set_low();
        Timer::after_secs(1).await;

        info!("low");
        led.set_high();
        Timer::after_secs(1).await;
    }
}
