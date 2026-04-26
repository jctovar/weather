import 'package:weather/core/utils/weather_code_mapper.dart';

/// Represents current weather conditions.
class Weather {
  const Weather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.rain,
    required this.weatherCode,
    required this.windSpeed,
    required this.isDay,
    required this.time,
  });

  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final double rain;
  final int weatherCode;
  final double windSpeed;
  final bool isDay;
  final DateTime time;

  /// Returns a human-readable weather description based on WMO codes.
  String get description => WeatherCodeMapper.description(weatherCode);
}
