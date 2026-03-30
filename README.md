### ==== Attention! ====

This is not an official translation of Embassy documentation, but just student notes in Russian.

---

### ==== Структура репозитория ====

```
ru-embassy-tutorial/
├── Ru-Embassy-Tutorial.pdf # Рководство в pdf формате
├── template.typ            # Шаблон формления документов
├── main.typ                # Основоной документ
├── themes/                 # Главы руководста и отдельные темы
│   ├── 1-intro.typ
│   ├── 2-project-structure.typ
│   ├── 3-gpio-interrupts.typ
│   ├── ...
│   │
│   ├── configuration.typ
│   │
│   ├── tools/              # Инструменты разработки
│   │   ├── probe-rs.typ
│   │   ├── cargo-generate.typ
│   │   └── defmt.typ
│   ├── platforms/          # Информация о платформах
│   │   ├── stm32.typ
│   │   ├── esp32.typ
│   │   └── rp2040.typ
│   └── ...
├── exemples/               # Проекты из руководства
│   ├── stm32/
│   │   ├── blinky/
│   │   ├── start/
│   │   └── ...
│   ├── rp2040/
│   ├── esp32/
│   └── ...
├── ...
└── README.md
```

### ==== Содержание ====

1. Введение
    1. Требования к знаниям
    2. Что такое Embassy
    3. IDE
    4. Targets
    5. Probe-rs
2. Создание проекта
    1. Создание проекта вручную
    2. Blinky
    3. Генерация проекта
3. GPIO и EXTI


### ==== TODO ====

- [x] ведение-0.1
- [ ] структура_проекта-0.1
- [ ] официальные примеры
- [ ] блинк
- [ ] блинк + кнопка с прерыванием
- [ ] async/await
- [ ] перенос разделов
- [ ] настройка зеркал crates.io, git
- [ ] альтернативная установка
- [ ] FAQ
- [ ] настройка .zed
- [ ] хоткеи Zed
- [ ] команды probe-rs
- [ ] картинки
