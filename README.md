# 🌤️ Weather App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern, feature-rich weather application for Android built with **Flutter** and **Clean Architecture**. Get real-time weather data, hourly forecasts, and 7-day predictions based on your device's GPS location — all powered by the free [Open-Meteo API](https://open-meteo.com) (no API key required).

Includes **background rain alerts**, an **Android home screen widget**, and **offline caching** so your weather is always available.

---

## ✨ Features

| Feature | Status | Description |
|---------|--------|-------------|
| 📍 **GPS Location** | ✅ | Auto-detects your position for local weather |
| 🏙️ **City Name** | ✅ | Reverse geocoding displays your locality |
| 🌡️ **Current Weather** | ✅ | Temperature, humidity, wind, precipitation |
| ⏰ **Hourly Forecast** | ✅ | Next 24 hours with weather icons |
| 📅 **7-Day Forecast** | ✅ | Daily highs/lows with sunrise/sunset |
| 🌙 **Dark Mode** | ✅ | Automatic system theme switching |
| 💾 **Offline Cache** | ✅ | Hive-based caching with 1-hour TTL |
| 🔄 **Pull to Refresh** | ✅ | Swipe down to update weather data |
| 🔔 **Rain Notifications** | ✅ | Background alerts when rain ≥70% in next 3h |
| 📱 **Home Widget** | ✅ | Android 4×2 widget with current weather |
| 🔒 **Security Hardened** | ✅ | Release keystore, ProGuard, log redaction |

> 🚧 = Planned feature (see [PLAN.md](PLAN.md) for roadmap)

---

## 📸 Screenshots

<!-- Add your screenshots here -->
<!-- Example: -->
<!-- <img src="screenshots/home_light.png" width="250"> <img src="screenshots/home_dark.png" width="250"> -->

*Screenshots coming soon*

---

## 🛠️ Tech Stack

### Core
| Technology | Purpose |
|------------|---------|
| [Flutter](https://flutter.dev) | UI Framework |
| [Dart](https://dart.dev) | Programming Language |
| [Material 3](https://m3.material.io) | Design System |

### State Management
| Technology | Purpose |
|------------|---------|
| [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) | State Management (Notifier pattern) |

### Networking & Data
| Technology | Purpose |
|------------|---------|
| [dio](https://pub.dev/packages/dio) | HTTP Client with interceptors |
| [hive](https://pub.dev/packages/hive) | Local NoSQL Database |
| [dartz](https://pub.dev/packages/dartz) | Functional Programming (Either type) |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Simple key-value settings storage |

### Background & Platform
| Technology | Purpose |
|------------|---------|
| [workmanager](https://pub.dev/packages/workmanager) | Periodic background tasks (hourly weather + rain checks) |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Local rain alerts with Android notification channels |
| [home_widget](https://pub.dev/packages/home_widget) | Flutter ↔ Android AppWidget data sync |
| [permission_handler](https://pub.dev/packages/permission_handler) | Runtime permission requests (location, notifications) |

### Location
| Technology | Purpose |
|------------|---------|
| [geolocator](https://pub.dev/packages/geolocator) | GPS Position |
| [geocoding](https://pub.dev/packages/geocoding) | Reverse Geocoding (coordinates → city) |

### Testing
| Technology | Purpose |
|------------|---------|
| [flutter_test](https://docs.flutter.dev/testing) | Widget & Integration Tests |
| [mocktail](https://pub.dev/packages/mocktail) | Mocking for unit tests |

---

## 🏗️ Architecture

This project follows **Clean Architecture** with 3 layers:

```
lib/
├── main.dart                      # Entry point — initializes Hive, WorkManager, notifications, widget
├── background/
│   └── workmanager_callback.dart  # Top-level entry point for periodic background tasks
├── core/
│   ├── constants/                 # App constants, API endpoints, notification keys
│   ├── error/                     # Failure classes (Network, Cache, Location)
│   ├── network/                   # Dio client configuration
│   ├── theme/                     # Material 3 light/dark themes
│   └── utils/                     # Shared utilities (JSON helpers, weather mapper, logger)
├── features/
│   ├── weather/
│   │   ├── data/
│   │   │   ├── datasources/       # OpenMeteoApiDataSource, LocalCacheDataSource
│   │   │   ├── models/            # DTOs (WeatherModel, HourlyForecastModel, DailyForecastModel)
│   │   │   └── repositories/      # WeatherRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/          # Weather, HourlyForecast, DailyForecast
│   │   │   ├── repositories/      # WeatherRepository (abstract)
│   │   │   └── usecases/          # GetCurrentWeather, GetHourlyForecast, GetDailyForecast
│   │   └── presentation/
│   │       ├── bloc/              # WeatherNotifier + WeatherState
│   │       ├── pages/             # HomePage
│   │       └── widgets/           # CurrentWeatherCard, HourlyForecastList, DailyForecastList
│   ├── notifications/
│   │   ├── domain/usecases/       # shouldNotifyRain, getRainNotificationMessage
│   │   ├── data/services/         # NotificationService, BackgroundCheckService
│   │   └── presentation/
│   │       ├── providers/         # NotificationSettingsNotifier (Riverpod)
│   │       └── widgets/           # NotificationSettingsSheet (BottomSheet)
│   └── home_widget/
│       └── data/services/         # HomeWidgetService (Flutter ↔ Android sync)
```

### Key Architectural Decisions

- **🎯 Single Responsibility**: Each layer has a clear, distinct responsibility
- **🔄 Dependency Inversion**: Domain layer depends on abstractions, not implementations
- **📦 Dartz Either**: All repository methods return `Either<Failure, T>` for explicit error handling
- **💾 Cache-First Strategy**: Data is cached locally with 1-hour TTL; fallback to cache on API failure
- **🧪 Testable**: All layers are independently testable with mocked dependencies

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or higher)
- [Dart SDK](https://dart.dev/get-dart) (^3.11.5)
- Android Studio / VS Code with Flutter extension
- Android device or emulator (API 21+)

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd weather

# Install dependencies
flutter pub get

# Run the app
flutter run

# Or run specifically on Android
flutter run -d android
```

### Development Commands

```bash
# Install dependencies (run after pubspec.yaml changes)
flutter pub get

# Run static analysis and lints (run before committing)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/unit/domain/entities/weather_test.dart

# Build release APK
flutter build apk --release
```

---

## 🌐 API

This app uses the [Open-Meteo Weather API](https://open-meteo.com/en/docs) — a free, open-source weather API that requires **no API key**.

**Base URL:** `https://api.open-meteo.com/v1/forecast`

### Requested Parameters
- **Current**: temperature, humidity, apparent temperature, precipitation, weather code, wind speed
- **Hourly**: temperature, precipitation probability, weather code (next 48 hours)
- **Daily**: max/min temperature, sunrise/sunset, UV index, precipitation (next 7 days)

### Attribution
> Weather data provided by [Open-Meteo.com](https://open-meteo.com)  
> License: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

---

## 🧪 Testing

The project includes comprehensive tests across all layers:

```bash
test/
├── unit/
│   ├── domain/
│   │   ├── entities/weather_test.dart        # WMO code description tests
│   │   └── usecases/                         # Use case delegation tests
│   └── data/
│       ├── models/                           # JSON parsing & serialization
│       ├── datasources/                      # API & cache data source tests
│       └── repositories/                     # Repository logic & fallback tests
└── widget/
    └── home_page_test.dart                   # UI state tests (loading, success, error)
```

### Test Prerequisites

Tests require Hive initialization:

```dart
setUpAll(() async {
  Hive.init('.hive_test');
  await Hive.openBox<String>('weather_box');
});
```

### Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage
```

---

## 📋 Roadmap

See [PLAN.md](PLAN.md) for the complete development plan.

### ✅ Completed

| Phase | Feature | Status |
|-------|---------|--------|
| Phase 1 | 🏗️ Clean Architecture + Riverpod setup | ✅ |
| Phase 1 | 🌤️ Current weather + hourly + daily forecasts | ✅ |
| Phase 1 | 💾 Hive cache with TTL | ✅ |
| Phase 2 | 🔔 Rain notifications (WorkManager + local notifications) | ✅ |
| Phase 2 | ⏰ Background hourly updates | ✅ |
| Phase 3 | 📱 Android home screen widget | ✅ |
| Security | 🔒 Release keystore, ProGuard, coordinate redaction | ✅ |

### 🚧 Upcoming

| Phase | Feature | Priority |
|-------|---------|----------|
| Phase 4 | 🎨 Animations & Lottie polish | Medium |
| Phase 4 | 🌍 Multiple saved locations | Low |
| Phase 5 | 🌬️ Air quality integration | Low |
| Phase 5 | 🔲 Quick Settings Tile | Low |

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Android Build Notes

This project uses **core library desugaring** (required by `flutter_local_notifications` v18 for `java.time` APIs on Android API < 26). Already configured in `android/app/build.gradle.kts`:

```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### Before Committing

```bash
flutter analyze   # Ensure no lint errors
flutter test      # Ensure all tests pass
```

---

## 📄 License

This project is open source. Weather data is provided by [Open-Meteo](https://open-meteo.com) under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

---

## 🙏 Acknowledgments

- [Open-Meteo](https://open-meteo.com) for providing free, high-quality weather data
- [Flutter Team](https://flutter.dev) for the amazing framework
- [Material Design](https://m3.material.io) for the design system

---

<p align="center">Made with ❤️ and Flutter</p>
