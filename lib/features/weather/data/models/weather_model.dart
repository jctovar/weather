import 'package:weather/core/utils/json_helpers.dart';
import 'package:weather/core/utils/weather_code_mapper.dart';
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
    final current = requireMap(json['current'], 'current');

    return WeatherModel(
      temperature: jsonToDouble(current['temperature_2m']),
      apparentTemperature: jsonToDouble(current['apparent_temperature']),
      humidity: jsonToInt(current['relative_humidity_2m']),
      precipitation: jsonToDouble(current['precipitation']),
      rain: jsonToDouble(current['rain']),
      weatherCode: jsonToInt(current['weather_code']),
      windSpeed: jsonToDouble(current['wind_speed_10m']),
      isDay: jsonToInt(current['is_day']) == 1,
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

  /// Human-readable weather description via [WeatherCodeMapper].
  String get description => WeatherCodeMapper.description(weatherCode);
}
