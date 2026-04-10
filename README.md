# LangToggle — Language Learning Widget

Lightweight native home-screen widgets for **Android** and **iOS** that help you learn a new language by periodically switching your phone's in-app locale to a random target language.

**No Flutter. No heavy framework. Pure native code.**

## Features

- Home-screen widget shows current language flag + name with ON/OFF toggle
- Tap widget to toggle between learning mode and native mode
- Settings screen to pick native language, target languages, and rotation interval
- Background rotation via WorkManager (Android) / WidgetKit timeline (iOS)
- Per-app locale switching on Android 13+ via `LocaleManager`

## Project Structure

```
android/                         # Standalone native Android project
├── app/src/main/
│   ├── kotlin/com/example/langtoggle/
│   │   ├── Language.kt          # Language data model
│   │   ├── ChangeInterval.kt    # Interval enum
│   │   ├── PrefsManager.kt      # SharedPreferences wrapper
│   │   ├── LangToggleWidget.kt  # AppWidgetProvider + toggle logic
│   │   ├── SettingsActivity.kt  # Minimal settings UI
│   │   └── RotationWorker.kt    # WorkManager background task
│   └── res/                     # Layouts, drawables, values

ios/                             # Native iOS project (SwiftUI + WidgetKit)
├── project.yml                  # xcodegen config
├── LangToggle/
│   ├── LangToggleApp.swift      # App entry (handles widget deep link)
│   ├── ContentView.swift        # Settings UI (SwiftUI)
│   └── Shared/                  # Shared between app + widget
│       ├── Language.swift
│       ├── ChangeInterval.swift
│       └── PreferencesManager.swift
└── LangToggleWidget/
    └── LangToggleWidget.swift   # WidgetKit extension
```

## Android

### Prerequisites
- Android Studio (or `gradle` CLI)
- Android SDK 34+
- JDK 17

### Build & Run

```bash
cd android
# If no Gradle wrapper, generate one:
gradle wrapper --gradle-version 8.4
# Then build:
./gradlew assembleDebug
./gradlew installDebug
```

Or open `android/` in Android Studio and run directly.

### Add widget
Long-press home screen → Widgets → find **LangToggle** → drag to home screen.

## iOS

### Prerequisites
- macOS with Xcode 15+
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Generate Xcode project & build

```bash
cd ios
xcodegen generate
open LangToggle.xcodeproj
```

Then build & run from Xcode to a simulator or device.

### Add widget
Long-press home screen → tap **+** → search **LangToggle** → add Small or Medium widget.

## How it works

1. Open the app → choose your native language, target languages, and rotation interval.
2. Add the widget to your home screen.
3. Tap the widget toggle to **ON** — a random target language is applied immediately.
4. Background task rotates to a new random language at each interval.
5. Tap the widget again to revert to your native language.

> **Note:** iOS does not allow programmatic system language changes. LangToggle changes in-app locale only. On Android 13+ it also sets the per-app system locale via `LocaleManager`.
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
