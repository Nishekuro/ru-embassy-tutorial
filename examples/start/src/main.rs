#![no_std]
#![no_main]

use defmt::*; // отладочная информация
use embassy_executor::Spawner; // базовый компонент для работы фрейймворка embassy
use embassy_stm32::{
    Peri, bind_interrupts,
    exti::{self, ExtiInput},
    gpio::{AnyPin, Level, Output, Pull, Speed},
    interrupt,
}; // управление пинами входа-выхода
use embassy_time::Timer; // функции ожидания
use {defmt_rtt as _, panic_probe as _}; // обработка ошибок

bind_interrupts!(
    pub struct Irqs{
        EXTI0 => exti::InterruptHandler<interrupt::typelevel::EXTI0>;
});

#[embassy_executor::task]
async fn blinky(pin: Peri<'static, AnyPin>) {
    let mut led = Output::new(pin, Level::High, Speed::Low); // инициализация пина C13

    loop {
        info!("high");
        led.set_low();
        Timer::after_secs(1).await;

        info!("low");
        led.set_high();
        Timer::after_secs(1).await;
    }
}

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let p = embassy_stm32::init(Default::default()); // инициализацция переферии
    info!("Hello World!");

    spawner.spawn(blinky(p.PC13.into()).unwrap());

    let mut button = ExtiInput::new(p.PA0, p.EXTI0, Pull::Up, Irqs);

    loop {
        button.wait_for_falling_edge().await;
        info!("Pressed!");
        button.wait_for_rising_edge().await;
        info!("Released!");
    }
}
