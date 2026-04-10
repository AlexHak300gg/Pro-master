# Flutter Theme Implementation Prompt

> **Role:** Expert Flutter Developer  
> **Task:** Implement a new, switchable theme for a Flutter application based on the detailed design specification below. The application currently has a "default space theme," which must be preserved.

---

## 🎯 Core Requirements

1.  **Implement the New Theme:** Create a new theme exactly as described in the "Детальное описание дизайна для реализации" section. This theme features a multi-layered background with a custom-painted grid and a semi-transparent image.
2.  **Preserve the Old Theme:** The existing "default space theme" must be saved and remain accessible. For the purpose of this task, you can represent the space theme as a standard dark `ThemeData` object.
3.  **Implement Theme Switching:** Create a system that allows the user to switch between the new "Profgid" theme and the old "Space" theme.
4.  **Theme Selection UI:** The theme selection control should be located on a "Profile" screen.
5.  **Global Application:** The chosen theme must be applied consistently across all screens of the application. The new theme's custom background must be visible on every screen.

---

## 🛠 Implementation Strategy

Follow these steps to structure your code:

### 1. Theme Management
- Use the `provider` package for state management. Create a `ThemeProvider` class that extends `ChangeNotifier`.
- This provider will hold the current theme state and notify listeners of changes.
- Define an enum `AppTheme { profgid, space }` to represent the available themes.

### 2. Theme Structure
- The new "Profgid" theme is more than just colors; it's a background widget. The "Space" theme is a standard `ThemeData` object. You need a way to manage both.
- A good approach is to create a wrapper widget, let's call it `ThemeWrapper`, that listens to the `ThemeProvider`.
- This `ThemeWrapper` will build the correct background based on the selected theme and place the screen's content (`child`) on top of it.
    - If `AppTheme.profgid` is selected, build the `Stack` with the `CustomPainter` and the image asset as the background.
    - If `AppTheme.space` is selected, just use a standard `Scaffold` which will inherit its colors from the space theme's `ThemeData`.

### 3. New Theme Implementation
- Create a dedicated widget for the new theme's background, e.g., `ProfgidThemeBackground`.
- This widget will contain the `Stack` with the `CustomPaint` and the `Image.asset`.
- Create the `CustomPainter` class (`GraphPaperPainter`) as specified in the design document.
- **Crucially, implement the design from the file below exactly.**

### 4. Application Root (`main.dart`)
- Wrap the `MaterialApp` widget with `ChangeNotifierProvider`, providing your `ThemeProvider`.
- The `MaterialApp`'s `home` or `router` will point to your app's screens.
- Set the `MaterialApp.theme` property based on the theme provider:
    - For the "Profgid" theme: use a light `ThemeData` that complements the design (e.g., with the specified orange as the primary color).
    - For the "Space" theme: use a dark `ThemeData`.
- The `ThemeWrapper` should wrap the content of each route/screen to apply the correct background.

### 5. Profile Screen
- Create a simple `ProfileScreen` widget.
- Add UI elements (e.g., `RadioListTile` or a `DropdownButton`) to allow the user to select `profgid` or `space`.
- When the user makes a selection, call a method on your `ThemeProvider` (e.g., `setTheme(AppTheme theme)`) to update the state.

---

## 📝 Design Specification (Implement This)

### 1. Общая структура экрана

- Экран должен использовать `Scaffold` с `backgroundColor: Colors.white`.
- Ключевой элемент — многослойная композиция. Для этого необходимо использовать виджет `Stack`.

### 2. Слой 1: Фон в клетку (Graph Paper Background)

- **Задача:** Создать фон, имитирующий тетрадный лист в клетку.
- **Реализация:** Не использовать растровое изображение. Вместо этого необходимо создать кастомный виджет с помощью `CustomPainter`.
- **`CustomPainter` должен делать следующее:**
    - Получать размеры холста (`Size`).
    - Рисовать тонкие, светло-серые (`Colors.grey[300]`) горизонтальные и вертикальные линии с фиксированным шагом (например, `20.0` логических пикселей).
    - Линии должны покрывать весь экран.

### 3. Слой 2: Полупрозрачный фоновый рисунок

- **Задача:** Разместить на фоне полупрозрачный силуэт здания.
- **Реализация:**
    - Используй `Image.asset` для загрузки силуэта. Предположим, что ассет находится по пути `'assets/images/building_silhouette.png'`. Ассет должен быть в формате PNG с прозрачным фоном.
    - Размести изображение в `Stack` с помощью виджета `Align` с `alignment: Alignment.bottomLeft`, чтобы оно находилось в левой нижней части экрана.
    - Примени к изображению низкую прозрачность. Наилучший способ — использовать `ColorFiltered` для одновременной окраски и установки прозрачности:
      ```dart
      ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.orange.withOpacity(0.1), 
          BlendMode.srcIn
        ), 
        child: ...
      )
      ```
    - Это позволит перекрасить любой (даже черный) силуэт в нужный бледно-оранжевый цвет.

### 4. Слой 3: Текстовый контент

- **Задача:** Разместить заголовок и подзаголовок по центру экрана.
- **Реализация:**
    - Используй виджет `Center`, внутри которого будет `Padding` для боковых отступов, а внутри него — `Column`.
    - `Column` будет содержать два `Text` виджета. `mainAxisAlignment` должен быть `MainAxisAlignment.center`.

#### Стилизация текста (Типографика)

| Элемент | Свойство | Значение |
|---------|----------|----------|
| **Заголовок** | Текст | `'ПРОФГИД СПО УР'` (верхний регистр) |
| | `fontFamily` | `'Montserrat'` (или другой подходящий sans-serif) |
| | `fontWeight` | `FontWeight.w800` |
| | `color` | `const Color(0xFFFF6A00)` |
| | `fontSize` | `32.0` |
| **Подзаголовок** | Текст | `'Мобильное приложение для абитуриентов\nСПО Удмуртской Республики'` |
| | `textAlign` | `TextAlign.center` |
| | `fontFamily` | `'Montserrat'` |
| | `fontWeight` | `FontWeight.w500` |
| | `color` | `Colors.black87` |
| | `fontSize` | `18.0` |
| | `height` | `1.4` |

- Между заголовком и подзаголовком добавь отступ: `SizedBox(height: 16.0)`.

---

## ⚙️ Итоговая структура виджета (псевдокод)

```dart
Scaffold(
  body: Stack(
    children: [
      // Слой 1: Фон в клетку
      Positioned.fill(
        child: CustomPaint(
          painter: GraphPaperPainter(),
        ),
      ),

      // Слой 2: Силуэт здания
      Align(
        alignment: Alignment.bottomLeft,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.orange.withOpacity(0.1),
            BlendMode.srcIn,
          ),
          child: Image.asset('assets/images/building_silhouette.png'),
        ),
      ),

      // Слой 3: Текст
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Заголовок
              Text(
                'ПРОФГИД СПО УР',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF6A00),
                  fontSize: 32.0,
                ),
              ),
              SizedBox(height: 16.0),
              // Подзаголовок
              Text(
                'Мобильное приложение для абитуриентов\nСПО Удмуртской Республики',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontSize: 18.0,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);