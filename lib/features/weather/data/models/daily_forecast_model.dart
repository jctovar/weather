import 'package:weather/core/utils/json_helpers.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';

/// Data model for daily forecast from Open-Meteo API.
class DailyForecastModel {
  const DailyForecastModel({
    required this.dates,
    required this.weatherCodes,
    required this.temperatureMaxes,
    required this.temperatureMins,
    required this.sunrises,
    required this.sunsets,
    required this.uvIndexMaxes,
    required this.precipitationSums,
    required this.precipitationProbabilityMaxes,
  });

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'] as Map<String, dynamic>;

    return DailyForecastModel(
      dates: (daily['time'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      weatherCodes: (daily['weather_code'] as List<dynamic>)
          .map((e) => jsonToInt(e))
          .toList(),
      temperatureMaxes: (daily['temperature_2m_max'] as List<dynamic>)
          .map((e) => jsonToDouble(e))
          .toList(),
      temperatureMins: (daily['temperature_2m_min'] as List<dynamic>)
          .map((e) => jsonToDouble(e))
          .toList(),
      sunrises: (daily['sunrise'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      sunsets: (daily['sunset'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      uvIndexMaxes: (daily['uv_index_max'] as List<dynamic>)
          .map((e) => jsonToDouble(e))
          .toList(),
      precipitationSums: (daily['precipitation_sum'] as List<dynamic>)
          .map((e) => jsonToDouble(e))
          .toList(),
      precipitationProbabilityMaxes: (daily['precipitation_probability_max']
              as List<dynamic>)
          .map((e) => jsonToDouble(e))
          .toList(),
    );
  }

  final List<DateTime> dates;
  final List<int> weatherCodes;
  final List<double> temperatureMaxes;
  final List<double> temperatureMins;
  final List<DateTime> sunrises;
  final List<DateTime> sunsets;
  final List<double> uvIndexMaxes;
  final List<double> precipitationSums;
  final List<double> precipitationProbabilityMaxes;

  /// Converts the model to a list of domain entities.
  List<DailyForecast> toEntityList() {
    return List.generate(dates.length, (index) {
      return DailyForecast(
        date: dates[index],
        weatherCode: weatherCodes[index],
        temperatureMax: temperatureMaxes[index],
        temperatureMin: temperatureMins[index],
        sunrise: sunrises[index],
        sunset: sunsets[index],
        uvIndexMax: uvIndexMaxes[index],
        precipitationSum: precipitationSums[index],
        precipitationProbabilityMax: precipitationProbabilityMaxes[index],
      );
    });
  }
}
