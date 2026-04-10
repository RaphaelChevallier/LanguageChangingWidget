# LangToggle — Language Learning Widget

A Flutter app for Android and iOS that helps you learn a new language by periodically switching your phone's in-app language to one of your chosen target languages.

## Features

- **Home-screen / Lock-screen Widget** — A tiny native widget (Android AppWidget + iOS WidgetKit) shows the current language and lets you toggle learning mode on/off without opening the app.
- **Toggle** — Flip between *Learning Mode* (random language from your list) and *Native Mode* (your home language) with a single tap.
- **Language selection** — Pick as many target languages as you like from a list of 20+ languages.
- **Native language** — Set your default language that's restored when you toggle off.
- **Flexible intervals** — Choose how often the language rotates:
  - Every unlock / wake
  - Every hour
  - Every 6 hours
  - Once a day
  - Every 3 days
  - Once a week

## Tech Stack

| Layer | Technology |
|---|---|
| App framework | Flutter 3 (Dart) |
| State / storage | `shared_preferences` |
| Background scheduler | `workmanager` |
| Android widget | Native `AppWidgetProvider` (Kotlin) |
| iOS widget | Native WidgetKit extension (Swift) |
| Locale change (Android 13+) | `LocaleManager` via platform channel |

## Project Structure

```
lib/
├── main.dart                        # App entry point
├── models/
│   ├── language.dart                # Language data model
│   └── change_interval.dart         # Interval enum
├── screens/
│   ├── home_screen.dart             # Main toggle UI
│   └── settings_screen.dart         # Settings (languages, interval)
└── services/
    ├── settings_service.dart        # SharedPreferences wrapper
    ├── language_service.dart        # Locale switching logic
    └── scheduler_service.dart       # WorkManager scheduling

android/app/src/main/
├── kotlin/…/
│   ├── MainActivity.kt              # Flutter activity + platform channel
│   └── LangToggleWidgetProvider.kt  # Android home-screen widget
└── res/
    ├── layout/lang_toggle_widget.xml
    └── xml/lang_toggle_widget_info.xml

ios/
├── Runner/AppDelegate.swift         # iOS platform channel + WidgetKit refresh
└── LangToggleWidget/
    └── LangToggleWidget.swift       # iOS WidgetKit extension
```

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0
- Android Studio / Xcode

### Run

```bash
flutter pub get
flutter run
```

### Add the widget to your home screen

**Android:** Long-press the home screen → Widgets → scroll to *LangToggle*.

**iOS:** Long-press the home screen → tap **+** → search *LangToggle* → choose Small or Medium size.

## How it works

1. Open the app and tap **Settings** to choose your native language, target languages, and rotation interval.
2. Flip the big toggle to **ON** — the app immediately picks a random language from your list and applies it.
3. Every time the configured interval elapses (background WorkManager task on Android, system refresh on iOS), a new random language is chosen automatically.
4. Tap the widget or the toggle again to instantly revert to your native language.

> **Note:** iOS does not allow programmatic system language changes for security reasons. LangToggle changes the in-app language. On Android 13+ (API 33) it also changes the per-app system locale via `LocaleManager`.
