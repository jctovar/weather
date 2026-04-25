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
}
