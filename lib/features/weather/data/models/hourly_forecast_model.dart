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
    final hourly = requireMap(json['hourly'], 'hourly');

    return HourlyForecastModel(
      times: requireList(hourly['time'], 'hourly.time')
          .map((e) => DateTime.parse(e as String))
          .toList(),
      temperatures: requireList(hourly['temperature_2m'], 'hourly.temperature_2m')
          .map((e) => jsonToDouble(e))
          .toList(),
      precipitationProbabilities: requireList(
        hourly['precipitation_probability'],
        'hourly.precipitation_probability',
      )
          .map((e) => jsonToDouble(e))
          .toList(),
      precipitations: requireList(hourly['precipitation'], 'hourly.precipitation')
          .map((e) => jsonToDouble(e))
          .toList(),
      weatherCodes: requireList(hourly['weather_code'], 'hourly.weather_code')
          .map((e) => jsonToInt(e))
          .toList(),
      windSpeeds: requireList(hourly['wind_speed_10m'], 'hourly.wind_speed_10m')
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
