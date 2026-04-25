# PLAN.md — App de Clima en Flutter (Android) con Open-Meteo

## 1. Resumen del proyecto

App **freeware** de clima para Android desarrollada en Flutter, que consume la API gratuita de [Open-Meteo](https://open-meteo.com) (CC BY 4.0). Incluye widget en pantalla de inicio, notificaciones locales de lluvia y actualización automática horaria en segundo plano.

**Características clave:**

- Actualización del clima cada hora (background)
- Widget nativo en home screen de Android
- Notificación local cuando se detecta lluvia próxima
- Sin necesidad de API key
- Funcionamiento offline con caché

## 2. Stack tecnológico

| Capa | Herramienta | Justificación |
|------|-------------|---------------|
| Framework | Flutter 3.x (Dart 3.x) | Cross-platform, performance nativa |
| Estado | `riverpod` | Patrón ya familiar, predecible, testeable |
| HTTP | `dio` | Interceptores, retry, cache |
| Background | `workmanager` | Más confiable que `android_alarm_manager_plus` para tareas periódicas |
| Widget Android | `home_widget` | Comunicación Flutter ↔ AppWidgetProvider |
| Notificaciones | `flutter_local_notifications` | Estándar de facto, soporta canales Android 8+ |
| Localización | `geolocator` + `geocoding` | GPS + reverse geocoding |
| Cache | `hive` o `shared_preferences` | Hive para datos estructurados; SP para flags simples |
| Permisos | `permission_handler` | Manejo unificado de permisos runtime |
| i18n | `flutter_localizations` + `intl` | Soporte ES/EN |
| DI | `get_it` + `injectable` | Inversión de dependencias limpia |
| Logging | `logger` | Debug en dev, silencioso en producción |

## 3. Arquitectura (Clean Architecture)

```text
lib/
├── core/
│   ├── constants/        # Endpoints, claves de prefs, IDs de notif
│   ├── error/            # Failures, exceptions
│   ├── network/          # Dio config, interceptores
│   ├── utils/            # Helpers (fecha, conversiones)
│   └── theme/            # Material 3, dark/light
├── features/
│   ├── weather/
│   │   ├── data/
│   │   │   ├── datasources/   # OpenMeteoApi, LocalCache
│   │   │   ├── models/        # WeatherModel (DTO)
│   │   │   └── repositories/  # WeatherRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/      # Weather, HourlyForecast
│   │   │   ├── repositories/  # WeatherRepository (abstract)
│   │   │   └── usecases/      # GetCurrentWeather, GetHourlyForecast
│   │   └── presentation/
│   │       ├── bloc/          # WeatherBloc
│   │       ├── pages/         # HomePage, SettingsPage
│   │       └── widgets/       # WeatherCard, HourlyList
│   ├── location/         # Manejo de ubicación y favoritos
│   ├── notifications/    # Servicio de notif de lluvia
│   └── home_widget/      # Lógica del widget Android
├── background/
│   └── workmanager_callback.dart  # Tarea horaria
└── main.dart
```

## 4. Funcionalidades principales

### 4.1 Consumo de Open-Meteo

**Endpoint base:**

```text
https://api.open-meteo.com/v1/forecast
```

**Parámetros recomendados:**

```dart
{
  'latitude': lat,
  'longitude': lon,
  'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
             'is_day,precipitation,rain,weather_code,wind_speed_10m',
  'hourly': 'temperature_2m,precipitation_probability,precipitation,'
            'weather_code,wind_speed_10m',
  'daily': 'weather_code,temperature_2m_max,temperature_2m_min,'
           'sunrise,sunset,uv_index_max,precipitation_sum,'
           'precipitation_probability_max',
  'timezone': 'auto',
  'forecast_days': 7,
}
```

**Buenas prácticas:**

- Cachear respuesta con TTL de 1 hora
- Retry con backoff exponencial ante fallo de red
- Atribución obligatoria: *"Datos meteorológicos: Open-Meteo.com (CC BY 4.0)"*
- Respetar el rate limit razonable (no más de 1 req/min en uso normal)

### 4.2 Tarea horaria en background

Usar **WorkManager** con restricciones realistas en Android moderno (Doze, App Standby):

```dart
Workmanager().registerPeriodicTask(
  'weather-hourly-fetch',
  'fetchWeatherTask',
  frequency: const Duration(hours: 1),
  constraints: Constraints(
    networkType: NetworkType.connected,
    requiresBatteryNotLow: false,
  ),
  existingWorkPolicy: ExistingWorkPolicy.keep,
  backoffPolicy: BackoffPolicy.exponential,
);
```

**Importante:** Android no garantiza ejecución exacta cada hora. Con Doze mode puede retrasarse. Si necesitas precisión estricta, usa `AlarmManager` con `setExactAndAllowWhileIdle` (requiere permiso `SCHEDULE_EXACT_ALARM` en Android 12+) — pero para clima esto **no es necesario**.

### 4.3 Widget en pantalla de inicio

**Flujo:**

1. WorkManager dispara la tarea horaria
2. Se obtienen datos de Open-Meteo
3. Se guardan con `HomeWidget.saveWidgetData()`
4. Se invoca `HomeWidget.updateWidget()` que notifica al `AppWidgetProvider`

**Lado Android (Kotlin):**

- Crear `WeatherWidgetProvider extends AppWidgetProvider`
- Layout XML en `res/layout/weather_widget.xml`
- Configuración en `res/xml/weather_widget_info.xml`
- Registrar en `AndroidManifest.xml`

**Tamaños sugeridos:** 2x1 (mínimo), 4x2 (recomendado con forecast), 4x4 (extendido).

**Tap en el widget** → abre la app con un deep link (`HomeWidget.registerInteractivityCallback`).

### 4.4 Notificaciones locales de lluvia

**Lógica de detección:**

```dart
bool shouldNotifyRain(HourlyForecast forecast) {
  final next3Hours = forecast.hourly.take(3);
  return next3Hours.any((h) =>
    h.precipitationProbability >= 70 &&
    h.precipitation > 0.5 // mm
  );
}
```

**Implementación:**

- Canal `weather_rain_channel` con `Importance.high`
- Evitar spam: no notificar más de **1 vez cada 6 horas** para el mismo evento
- Persistir último timestamp de notif en `SharedPreferences`
- Mensaje contextual: *"🌧️ Lluvia probable en la próxima hora (85%)"*
- Permiso `POST_NOTIFICATIONS` en Android 13+

## 5. Permisos en `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```

**Solicitar runtime:**

- Ubicación (al primer uso)
- Notificaciones (Android 13+)
- Optimización de batería (sugerir al usuario excluir la app para fiabilidad del widget)

## 6. Consideraciones de Android moderno

| Tema | Recomendación |
|------|---------------|
| Doze mode | Aceptar que las actualizaciones pueden tener delay; no luchar contra el sistema |
| App Standby Buckets | Mantener al usuario abriendo la app ocasionalmente para estar en bucket "Active" |
| Battery Optimization | Mostrar diálogo opcional para que el usuario excluya la app |
| Scoped Storage | No aplica para esta app (no hay archivos de usuario) |
| targetSdk 34+ | Obligatorio para Play Store; ajustar permisos en consecuencia |
| Predictive Back | Habilitar `android:enableOnBackInvokedCallback="true"` |
| Material You | Soportar dynamic colors en widget y app (Android 12+) |

## 7. Sugerencias adicionales para incorporar

### Funcionales

- **Múltiples ubicaciones favoritas** (casa, trabajo, viaje)
- **Pronóstico extendido 7 días** con gráfica de temperatura/precipitación
- **Alertas severas** (viento fuerte, calor extremo, helada) — Open-Meteo expone estos datos
- **Índice UV y calidad del aire** (endpoint separado: `air-quality-api.open-meteo.com`)
- **Sunrise/sunset** con animación de transición
- **Probabilidad de lluvia visualizada** como gráfica de barras horarias
- **Modo offline** mostrando última lectura con timestamp visible
- **Quick Settings Tile** (Android) con temperatura actual
- **Pantalla de detalle** con humedad, presión, viento, sensación térmica

### UX/UI

- **Material 3 con colores dinámicos** según condición (azul=lluvia, naranja=calor)
- **Animaciones Lottie** para condiciones (sol, lluvia, nieve, tormenta)
- **Modo oscuro automático** según hora del día
- **Pull-to-refresh** con feedback háptico
- **Widget configurable**: elegir ubicación, mostrar/ocultar pronóstico

### Técnicas

- **Tests unitarios** para BLoCs y use cases (mínimo 70% coverage)
- **Tests de integración** para el flujo de WorkManager
- **CI/CD** con GitHub Actions: análisis estático + tests + build APK
- **Crash reporting** con Sentry (free tier) o Firebase Crashlytics
- **Analytics anónimos opcionales** (con opt-in explícito) para entender uso del widget
- **Tema mediante `flex_color_scheme`** para consistencia
- **Versionado semántico** y CHANGELOG.md
- **Conventional Commits** para historial limpio

### Privacidad y cumplimiento

- **Política de privacidad clara**: solo se envía lat/lon a Open-Meteo
- **Sin tracking de terceros** (mantener freeware genuino)
- **Atribución visible** a Open-Meteo en pantalla "Acerca de"
- **Sin anuncios** (de lo contrario pasa a comercial y rompe la licencia gratuita)

## 8. Roadmap por fases

### Fase 1 — MVP (1-2 semanas)

- Setup del proyecto + estructura Clean Architecture
- Integración Open-Meteo (clima actual + pronóstico horario)
- Pantalla principal con clima actual
- Permisos de ubicación
- Caché local básico

### Fase 2 — Background y notificaciones (1 semana)

- WorkManager con tarea horaria
- Notificaciones locales de lluvia
- Lógica anti-spam
- Configuración de notificaciones por usuario

### Fase 3 — Widget Android (1 semana)

- AppWidgetProvider en Kotlin
- Layouts 2x1 y 4x2
- Comunicación Flutter ↔ Widget vía `home_widget`
- Tap deep link a la app

### Fase 4 — Pulido (1 semana)

- Material 3 + colores dinámicos
- Animaciones Lottie
- Modo oscuro
- Múltiples ubicaciones
- Localización ES/EN

### Fase 5 — Extras opcionales

- Calidad del aire
- Quick Settings Tile
- Tests + CI/CD
- Publicación en F-Droid (si es open source) y/o Play Store

## 9. Testing

```text
test/
├── unit/
│   ├── data/repositories/
│   ├── domain/usecases/
│   └── presentation/bloc/
├── integration/
│   └── weather_flow_test.dart
└── widget/
    └── home_page_test.dart
```

**Mocks:** `mocktail` para clases abstractas.
**API testing:** `dio_test` o `http_mock_adapter`.

## 10. Recursos útiles

- [Open-Meteo Docs](https://open-meteo.com/en/docs)
- [Open-Meteo License](https://open-meteo.com/en/license)
- [home_widget pub.dev](https://pub.dev/packages/home_widget)
- [workmanager pub.dev](https://pub.dev/packages/workmanager)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [Android Background Work guide](https://developer.android.com/develop/background-work)
- [Material 3 Flutter](https://m3.material.io/develop/flutter)

## 11. Atribución obligatoria

En la pantalla "Acerca de" y/o footer:

```text
Datos meteorológicos proporcionados por Open-Meteo.com
Licencia: CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/)
```

---

**Estimación total:** 4-5 semanas a tiempo parcial para MVP funcional con widget y notificaciones.
