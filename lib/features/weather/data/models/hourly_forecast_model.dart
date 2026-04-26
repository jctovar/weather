import 'package:weather/core/utils/json_helpers.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';

/// Data model for hourly forecast from Open-Meteo API.
class HourlyForecastModel {
  const HourlyForecastModel({
    required this.times,
    required this.temperatures,
    required this.precipitationProbabilities,
    required this.precipitations,
    required this.weatherCodes,
    required this.windSpeeds,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'] as Map<String, dynamic>;

    return HourlyForecastModel(
      times: (hourly['time'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      temperatures: (hourly['temperature_2m'] as List<dynamic>)
          .map((e) => jsonToDouble(e))
          .toList(),
      precipitationProbabilities: (hourly['precipitation_probability']
              as List<dynamic>)
          .map((e) => jsonToDouble(e))
          .toList(),
      precipitations: (hourly['precipitation'] as List<dynamic>)
          .map((e) => jsonToDouble(e))
          .toList(),
      weatherCodes: (hourly['weather_code'] as List<dynamic>)
          .map((e) => jsonToInt(e))
          .toList(),
      windSpeeds: (hourly['wind_speed_10m'] as List<dynamic>)
          .map((e) => jsonToDouble(e))
          .toList(),
    );
  }

  final List<DateTime> times;
  final List<double> temperatures;
  final List<double> precipitationProbabilities;
  final List<double> precipitations;
  final List<int> weatherCodes;
  final List<double> windSpeeds;

  /// Converts the model to a list of domain entities.
  List<HourlyForecast> toEntityList() {
    return List.generate(times.length, (index) {
      return HourlyForecast(
        time: times[index],
        temperature: temperatures[index],
        precipitationProbability: precipitationProbabilities[index],
        precipitation: precipitations[index],
        weatherCode: weatherCodes[index],
        windSpeed: windSpeeds[index],
      );
    });
  }
}
