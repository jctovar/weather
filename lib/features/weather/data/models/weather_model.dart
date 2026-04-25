import 'package:weather/features/weather/domain/entities/weather.dart';

/// Data model for current weather from Open-Meteo API.
class WeatherModel {
  const WeatherModel({
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

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;

    return WeatherModel(
      temperature: _toDouble(current['temperature_2m']),
      apparentTemperature: _toDouble(current['apparent_temperature']),
      humidity: _toInt(current['relative_humidity_2m']),
      precipitation: _toDouble(current['precipitation']),
      rain: _toDouble(current['rain']),
      weatherCode: _toInt(current['weather_code']),
      windSpeed: _toDouble(current['wind_speed_10m']),
      isDay: _toInt(current['is_day']) == 1,
      time: DateTime.parse(current['time'] as String),
    );
  }

  /// Converts the model to a domain entity.
  Weather toEntity() {
    return Weather(
      temperature: temperature,
      apparentTemperature: apparentTemperature,
      humidity: humidity,
      precipitation: precipitation,
      rain: rain,
      weatherCode: weatherCode,
      windSpeed: windSpeed,
      isDay: isDay,
      time: time,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    return value is double ? value : double.parse(value.toString());
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    return value is int ? value : int.parse(value.toString());
  }
}
