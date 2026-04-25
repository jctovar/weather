# weather

Flutter Android app showing weather from Open-Meteo API (no API key required).

## Commands

```
flutter pub get          # Run after any pubspec.yaml change
flutter run              # Run on connected device
flutter run -d android   # Run on Android specifically
flutter analyze          # Lint + static analysis (run before committing)
flutter test             # Run all tests
```

## Architecture

Clean Architecture with Riverpod state management (not BLoC). Single feature: `weather`.

```
lib/
├── main.dart                      # Entry point — initializes Hive + ProviderScope
├── core/
│   ├── constants/app_constants.dart
│   ├── error/failures.dart        # dartz Either-based error handling
│   ├── network/dio_client.dart    # Dio HTTP client config
│   └── theme/app_theme.dart       # Material 3 light/dark themes
└── features/weather/
    ├── data/
    │   ├── datasources/           # open_meteo_api_datasource.dart, local_cache_datasource.dart
    │   ├── models/                # DTOs with fromJson/toJson
    │   └── repositories/          # WeatherRepositoryImpl
    ├── domain/
    │   ├── entities/              # Weather, HourlyForecast, DailyForecast
    │   ├── repositories/          # WeatherRepository (abstract)
    │   └── usecases/              # GetCurrentWeather, GetHourlyForecast, GetDailyForecast
    └── presentation/
        ├── bloc/                  # weather_notifier.dart + weather_state.dart (Riverpod, not BLoC)
        ├── pages/home_page.dart
        └── widgets/               # current_weather_card, hourly_forecast_list, daily_forecast_list
```

## Key facts

- **State management**: `flutter_riverpod` + `state_notifier`. Files under `bloc/` are Riverpod notifiers, not BLoCs.
- **HTTP**: `dio` via `lib/core/network/dio_client.dart`
- **Cache**: `hive` + `hive_flutter`, box name `'weather_box'`. Opened in `main.dart`.
- **Errors**: `dartz` `Either<Failure, T>` pattern in domain layer.
- **API**: Open-Meteo at `https://api.open-meteo.com/v1/forecast`. CC BY 4.0 attribution required.
- **SDK**: Dart ^3.11.5

## Testing

- Tests require Hive init: `await Hive.initFlutter(); await Hive.openBox('weather_box');`
- Mocking: `mocktail` for abstract classes.
- Single test file exists: `test/widget_test.dart` (smoke test).
- PLAN.md defines intended test structure under `test/unit/`, `test/integration/`, `test/widget/` — not yet created.

## Android

- Permissions already configured in `android/app/src/main/AndroidManifest.xml`: INTERNET, ACCESS_NETWORK_STATE, ACCESS_COARSE_LOCATION, ACCESS_FINE_LOCATION, RECEIVE_BOOT_COMPLETED, WAKE_LOCK.
- Missing from manifest (per PLAN.md): POST_NOTIFICATIONS, FOREGROUND_SERVICE — add when implementing notifications/background.
- `android/app/build.gradle.kts` — check `minSdk`/`targetSdk` if adding plugins with SDK requirements.

## PLAN.md

Full project plan at `PLAN.md` includes architecture, API params, background work, widget, notifications, roadmap phases. Treat as the source of truth for intended features not yet implemented.
