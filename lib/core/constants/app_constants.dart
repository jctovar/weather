/// Constants for the weather application.
class AppConstants {
  AppConstants._();

  /// Open-Meteo API base URL.
  static const String openMeteoBaseUrl = 'https://api.open-meteo.com/v1';

  /// Cache box name for weather data.
  static const String weatherBoxName = 'weather_box';

  /// Cache key for current weather.
  static const String currentWeatherKey = 'current_weather';

  /// Cache key for hourly forecast.
  static const String hourlyForecastKey = 'hourly_forecast';

  /// Cache key for daily forecast.
  static const String dailyForecastKey = 'daily_forecast';

  /// Cache TTL in seconds (1 hour).
  static const int cacheTtlSeconds = 3600;

  /// Attribution text for Open-Meteo.
  static const String openMeteoAttribution =
      'Datos meteorológicos: Open-Meteo.com (CC BY 4.0)';

  // ── Notification settings ────────────────────────────────────

  /// SharedPreferences key for rain notifications toggle.
  static const String rainNotificationsEnabledKey =
      'rain_notifications_enabled';

  /// SharedPreferences key for last rain notification timestamp.
  static const String lastRainNotificationTimeKey =
      'last_rain_notification_time';

  /// Android notification channel ID for rain alerts.
  static const String rainNotificationChannelId = 'weather_rain_channel';

  /// Android notification channel name for rain alerts.
  static const String rainNotificationChannelName = 'Alertas de lluvia';

  // ── Background task ──────────────────────────────────────────

  /// WorkManager task name for periodic rain checks.
  static const String rainCheckTaskName = 'rainCheckTask';

  /// WorkManager task tag for periodic rain checks.
  static const String rainCheckTaskTag = 'weather-hourly-rain-check';

  /// Cooldown between rain notifications (hours).
  static const int rainCooldownHours = 6;

  /// Interval between background rain checks (minutes).
  /// WorkManager minimum is ~15 min, we use 60.
  static const int rainCheckIntervalMinutes = 60;

  // ── Location cache for background ────────────────────────────

  /// Hive key for the last known location (used by background tasks).
  static const String lastLocationKey = 'last_location';
}
