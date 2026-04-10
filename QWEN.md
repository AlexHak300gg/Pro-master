# QWEN.md — Профориентация (Profaritashion)

## Project Overview

**Profaritashion** — это Flutter-приложение для профориентации учащихся Удмуртской Республики. Приложение помогает школьникам выбирать профессии, сдавать экзамены (ЕГЭ/ОГЭ), находить учебные заведения и строить карьерные планы.

### Ключевой функционал

- **Аутентификация** — регистрация и вход в систему
- **Тестирование** — выбор и прохождение тестов для определения склонностей к профессиям
- **Карта колледжей** — интерактивная карта учебных заведений Удмуртии (flutter_map)
- **Пользовательские места** — добавление интересных мест на карту с отзывами и рейтингами
- **Рейтинг колледжей** — просмотр и оценка учебных заведений
- **Профессии** — справочник профессий и перспективных направлений
- **Учебные инструменты** — Pomodoro-таймер, расписание, заметки
- **ЕГЭ/ОГЭ** — материалы и подготовка к экзаменам
- **Чат** — карьерная консультация в чате
- **Профиль пользователя** — управление данными пользователя
- **Магазин мерча** — встроенный магазин merchandise
- **Шансы поступления** — расчёт вероятности поступления в учебные заведения

### Технологии и зависимости

- **Flutter** (SDK ^3.9.2) / **Dart**
- **Firebase Core** + **Firebase Realtime Database** — бэкенд и хранение данных
- **flutter_map** + **latlong2** — отображение карт
- **Provider** — управление состоянием
- **Google Fonts** — типографика
- **shared_preferences** — локальное хранение настроек
- **image_picker** — выбор изображений
- **url_launcher** — открытие внешних ссылок

### Платформы

Android, iOS, Web, Windows, macOS, Linux

---

## Directory Structure

```
lib/
├── main.dart                  # Точка входа, инициализация Firebase, роутинг
├── main_animation.dart        # Анимационная стартовая страница
├── login.dart / registration.dart  # Аутентификация
├── choice_of_tests.dart       # Выбор тестов
├── tests.dart / test_questions.dart  # Тестирование
├── map_page.dart              # Карта колледжей и пользовательских мест
├── places_list_page.dart      # Список всех пользовательских мест
├── college_rating.dart        # Рейтинг колледжей
├── professions.dart           # Справочник профессий
├── profile.dart               # Профиль пользователя
├── chat_page.dart             # Карьерный чат
├── ege_screen.dart / oge_screen.dart  # Экзамены
├── admission_chances_screen.dart  # Шансы поступления
├── merch_shop_screen.dart     # Магазин мерча
├── perspective_professions_screen.dart  # Перспективные профессии
├── theme/                     # Темизация и анимированный фон
│   ├── theme_manager.dart     # Управление темами (светлая/тёмная)
│   ├── app_theme.dart         # Определение темы
│   ├── animated_background.dart
│   ├── particle_painters.dart
│   └── themed_page.dart
├── widgets/
│   └── bottom_nav.dart        # Нижняя навигация
├── games/                     # Игровые модули (если есть)
├── study/                     # Учебные инструменты
│   ├── pomodoro_page.dart
│   ├── schedule_calendar_page.dart
│   └── notes_page.dart
└── firebase_options.dart      # Конфигурация Firebase
```

---

## Firebase Structure

**Project ID:** `databaseauthproject`

### Database Rules (`database.rules.json`)

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

### Data Paths

```
/places/{placeId} — пользовательские места на карте
  ├── name, description, url, lat, lng, addedBy, timestamp
  └── /reviews/{reviewId}
        ├── userId, rating, comment, timestamp
```

---

## Building and Running

### Prerequisites

- Flutter SDK ^3.9.2
- Настроенный Firebase проект `databaseauthproject`
- `google-services.json` для Android (`android/app/google-services.json`)

### Commands

```bash
# Установка зависимостей
flutter pub get

# Запуск приложения (debug)
flutter run

# Запуск на конкретном устройстве
flutter run -d <device_id>

# Сборка APK
flutter build apk --release

# Анализ кода
flutter analyze

# Запуск тестов
flutter test

# Генерация иконок
flutter pub run flutter_launcher_icons
```

---

## Development Conventions

- **State Management:** Provider (`ChangeNotifierProvider` + `Consumer`)
- **Theme:** Кастомная система тем через `ThemeManager` с поддержкой светлой/тёмной темы
- **Routing:** Named routes с передачей `userId` через `ModalRoute.settings.arguments`
- **Linting:** `flutter_lints` (стандартный набор, см. `analysis_options.yaml`)
- **Code Style:** Dart conventions, Google Fonts для типографики
- **UI:** Material Design компоненты, анимированный звёздный фон в тёмной теме
- **Firebase:** Realtime Database с открытыми правилами чтения/записи (для разработки)

---

## Key Implementation Details

### Карта (map_page.dart)

- Использует `flutter_map` с OSM тайлами
- Центрирована на Удмуртскую Республику
- Маркеры колледжей: синие (БПОУ УР) и зелёные (АПОУ УР)
- Пользовательские места: красные маркеры
- Границы Удмуртии: широта 56.0–58.5, долгота 51.0–55.0

### Пользовательские места (places_list_page.dart)

- Добавление через кнопку "+" на карте
- Система отзывов с рейтингом 0.5–5 звёзд (шаг 0.5)
- Средний рейтинг рассчитается автоматически

### Темизация

- `ThemeManager` — ChangeNotifier для переключения тем
- `AppTheme.getThemeData()` — генерация ThemeData на основе текущей темы
- Поддержка анимированного фона с частицами
