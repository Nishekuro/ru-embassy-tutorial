// == Использование примеров

// Создайте директорию общую для всех будущих проектов embassy rust, в нее клонируем репозиторий Github:

// ```bash
// git clone https://github.com/embassy-rs/embassy.git
// cd embassy
// ```

// Внутри директории embassy/ перейдите директорию с примерами exampels/, а в ней в директорию, соответствующей вашему микроконтроллеру (stm32f4/ в нашем случае):

// ```bash
// cd examples/stm32f4
// ```

// Далее внутри src/bin/ вы обнаружите несколько примеров кода, в том числе blinky и hello. Перед применением любого примера, необходимо проверить соответствие конфигурации вашему чипу. Откройте файл .cargo/config.toml и проверьте строку runner:

// ```toml
// ...
// runner = "probe-rs run --chip STM32F411CEUx"    # Black pill
// # runner = "probe-rs run --chip STM32F103C8x"   # Blue pill
// ...
// ```

// Для компиляции примера и прошивки платы используем следующую команду:

// ```bash
// cargo run --bin blinky --release
// ```

// Плата будет прошита сразу после компиляции, и в консоль должна начать выводиться отладочная информация о состоянии светодиода.

// /*
//     В ведении записать устаовку rust, ide, дополнений. probe-rs
// */

= Структура проекта

- #link("https://embassy.dev/book/")[Официальное руководство Embassy]
- #link("https://github.com/embassy-rs/embassy")[Официальный репозиторий Embassy]

== Создание минимального проекта

/*
  hello world в консоль и включение кнопки по нажатию ассинхронно

#![no_std]
#![no_main]

use defmt::info;
use defmt_rtt as _;
use panic_probe as _;

use embassy_executor::Spawner;
use embassy_rp::gpio::{Input, Level, Output, Pull};
use embassy_time::Timer;

#[embassy_executor::task]
async fn hello_task() {
  loop {
      info!("Hello, world!");
      Timer::after_secs(1).await;
  }
}

#[embassy_executor::task]
async fn button_led_task(mut led: Output<'static>, mut button: Input<'static>) {
  loop {
      // Ждем нажатия (без busy polling!)
      button.wait_for_low().await;
      led.set_high();

      // Ждем отпускания
      button.wait_for_high().await;
      led.set_low();
  }
}

#[embassy_executor::main]
async fn main(spawner: Spawner) {
  let p = embassy_rp::init(Default::default());

  let led = Output::new(p.PIN_25, Level::Low);
  let button = Input::new(p.PIN_14, Pull::Up);

  // В учебных целях используем unwrap()
  spawner.spawn(hello_task()).unwrap();
  spawner.spawn(button_led_task(led, button)).unwrap();
}
*/
Разберем специфику embedded rust на Embassy, создав минимальный проект вручную. Открыв терминал, создадим новый проект с названием `bilnky` классической командой:

```sh
 cargo new blinky
```

Внутри мы увидим базовую структуру проекта:

```md
blinky/
├── src/
│   └── main.rs
└── Cargo.toml

```

// zed [
При открытии проекта в Zed, в корень будут добавлены объекты `target` и `Cargo.lock`. Таким образом, структура проекта будет выглядеть следующим образом:

```md
blinky/
├── src/
│   └── main.rs
├── src/
├── Cargo.lock
└── Cargo.toml

```
// ]

=== .cargo.config.toml

// .cargo.config.toml [

Для того чтобы прошивать плату с помощью `probe-rs` в корне проекта необходимо создать файл `.cargo/config.toml` и прописать в него примерно следующую информацию:

```toml
[target.'cfg(all(target_arch = "arm", target_os = "none"))']
runner = "probe-rs run --chip STM32F411CE"
[build]
target = "thumbv7em-none-eabihf"

[env]
DEFMT_LOG = "info"
```
// ]
// probe-rs [
Ключ `runner` позволяет нам удобно прошивать плату через `probe-rs` используя команду `cargo run`. Для этого необходимо прописать соответсвующий идентификатор чипа. Правильное написание идентификатора можно узнать использовав команду:

```sh
probe-rs chip list | grep -i "примерное_название_чипа"
```

Пример:

```sh
probe-rs chip list | grep -i stm32f411
        STM32F411CC
        STM32F411CE # <- точный идентификатор нашего чипа
        STM32F411RC
        STM32F411RE
        STM32F411VC
        STM32F411VE
```
// ]

В ключ `target` прописывается идентификатор архитектуры, который мы определили ранее.

// defmt [

// ]

=== Cargo.toml

// Склонировать себе гитхаб в ведении

Теперь, когда компилятор знает идентификатор чипа, добавим в проект все необходимые зависимости. Важно понимать, что, в силу своего недавнего появления, Embassy -- очень нестабильный проект. Crates.io -- площадка эсперементов данного проекта, и установка зависимостей командой стандартной командой `cargo add` крайне не рекомендуется; в большинстве случаем крейты не будут работать друг с другом. Гарантию работы можно получить в #link("https://github.com/embassy-rs/embassy")[официальном репозитории на Github]. Внутри директории `examples/` мы можем найти интересующую нас платформу, конфигурационный файл и примеры для нее. Такой конфигурационный файл содержит все крейты проекта наиболее свежих крейтов, прошедших тестирование на взаимную работу. Скопируем соответствующий файл `Cargo.toml` в корень своего проекта. Внутри мы должны увидеть примерно следующее:

```toml
...
[dependencies]
...
embassy-stm32 = { version = "0.6.0", features = [
  "defmt",
  "stm32f411ce",
  "unstable-pac",
  "memory-x",
  "time-driver-any",
  "exti",
] }
embassy-executor = { version = "0.10.0", features = [
  "platform-cortex-m",
  "executor-thread",
  "defmt",
] }
embassy-time = { version = "0.5.1", features = [
  "defmt",
  "defmt-timestamp-uptime",
] }

defmt = "1.0.1"
defmt-rtt = "1.0.0"

cortex-m = { version = "0.7.6", features = ["critical-section-single-core"] }
cortex-m-rt = "0.7.0"

panic-probe = { version = "1.0.0", features = ["print-defmt"] }
...
```

Для крейтов с названием `embassy-*` очень важным явдляется определить совместимую версию. Остальные крейты работают почти всегда.

// отдельная глава с объяснением крейтов
Описание наиболее популярных крейтов будет дано далее по ходу руководства и в отдельной главе.
//

// defmt [
Чтобы в `release` сборе проекта отладочная информация сохранилась, необходимо это явно указать в `Cargo.toml`:

```toml
...
[profile.release]
debug = 2 # 2 - полная отладочная информация
...
```
// ]

// После всех этих действий конфигурационный файл должен выглядеть примерно следующим образом:

=== build.rs

Данный файл является платформо-зависиммым, потому его всегда копируют из официального репозитория.
// stm32 [
Для stm32f411ce содержимое данного файла выглядит следующим образом:

```rs
fn main() {
    println!("cargo:rustc-link-arg-bins=--nmagic");
    println!("cargo:rustc-link-arg-bins=-Tlink.x");
    println!("cargo:rustc-link-arg-bins=-Tdefmt.x");
}
```
// ]

=== src/main.rs

Первое, что мы должны сделать перейдя в `src/main.rs`, это добавить следующие строки в самом начале проекта:

```rs
#![no_std]
#![no_main]

use {defmt_rtt as _, panic_probe as _};
```
// rust-embedded-specifics [
`#![no_std]` указывает на то, что данная программа не будет использовать весь стандартный крейт (пакет) `std` полностью. Вместо этого программа будет работать только с его подмножеством - крейтом `core`. Этот крейт содержит лишь те компоненты, которые не зависят от операционной системы: не требуют выделения памяти, не работают со стандартными потоками и т.д.

`!#[no_main]` означает, что программа не будет использовать стандартный интерфейс `main`, так как она запускается вне операционной системы.
// ]

Следующая строка определяет то, как мы будем работать с паникой и обработкой ошибок.
// defmt [
В процессе разработки хорошей практикой является опора на `defmt-rtt` и `panic-prode` для вывода диагностической информации в консоль.
// ]

// Добавить целевую платформу глобально `Rust`:

// ```bash
// rustup target add thumbv7em-none-eabihf

// # rustup target list --installed - установленные

// # rustup show - установленная по-умолчанию
// ```

// === memory.x

// Добавление `memory.x` для линковщика:

// ```text
// MEMORY
// {
// FLASH : ORIGIN = 0x08000000, LENGTH = 512K
// RAM : ORIGIN = 0x20000000, LENGTH = 128K
// }
// ```

// === rust-toollchain.toml

=== Настройка Zed

Как говорилось ранее, редактор Zed (как и VSCode) в контексте embedded rust требует специфичной настройки каждого проекта через JSON-файлы. Мнинимальные действия, которые необходимо сделать, это дать #link("https://habr.com/ru/companies/sberbank/articles/838786/")[LSP] (rust-analyzer в нашем случае) понять, что работа в данном проекте ведется не для классической desctop архитектуры. Сделать это можно, создав в корне проекта скрытую директорию `.zed` (точка в начале названия указывает на то, что директория скрытая), и поместив внутрь файл `settings.json` со следующим содержимым:

```json
{
  "lsp": {
    "rust-analyzer": {
      "initialization_options": {
        "cargo": {
          "target": "thumbv7em-none-eabihf",
        },
        "check": {
          "allTargets": false,
        },
      },
    },
  },
}

```

Сразу после сохранения файла, Zed должен сделать перепроверку всего проекта и перестать ругаться на первые строки файла `src/main.rs`.

=== Итоговая структура проекта

/*
Cargo genirane
Дипсих опиывает немного другую структуру
Утилиты для создания поектов
Также расположжение тасков либ и пр
Заметки и ридми, карго лок, гитигнор и настройки вскод
rust-toolchain.toml


*/

Структура файлов верхнего уровня вашего проекта должна выглядеть следующим образом:

```
blinky/
├── .zed/
├── └── settings.json
├── .cargo/
├── └── config.toml
├── src/
├── └── main.rs
├── build.rs
├── Cargo.toml
├── Cargo.lock
├── target/
├── {memory.x}
└── {rust-toolchain.toml}

```

Файлы, указанные внутри фигурных скобок могут потребоваться для работы с некоторыми микроконтроллерами (например RP2040), однако для работы с серией STM32F4 они не нужны.

== Blink

// описать значение функций
// почему пишется _spawner

Исходя из всего вышесказанного создадим свой первый рабочий проект, в котором просто помигаем встроенным светодиодом и выведем сообщения на экран. В файл `src/main.rs` добавим код, чтобы получилось следующее:

```rs
#![no_std]
#![no_main]

use defmt::*;                                    // отладочная информация
use embassy_executor::Spawner;                   // базовый компонент для работы фрейймворка embassy
use embassy_stm32::gpio::{Level, Output, Speed}; // управление пинами входа-выхода
use embassy_time::Timer;                         // функции ожидания
use {defmt_rtt as _, panic_probe as _};          // обработка ошибок

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
```

== Утилиты создания проекта

`cargo generate` — это мощный инструмент для создания новых проектов из готовых шаблонов (templates). Для Embassy это особенно полезно, так как позволяет быстро получить правильно настроенную структуру проекта без ручного копирования конфигураций. Однако такой способ может проигрывать ручному, когда дело касается свежести крейтов, так как создатели таких утилит и шаблонов не всегда успевают за репозиторием Embassy.

На практике все теоретические преимущества автоматической генерации проекта на данный момент ликвидируются тем факом, что `Cargo.toml` подтягиваются не все возможные для данной платформы, а необходимый минимум для запуска hellow-world-программы.

```md
Короче говоря, пока руками собирайте)))
```
