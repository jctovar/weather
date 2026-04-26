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
    final daily = requireMap(json['daily'], 'daily');

    return DailyForecastModel(
      dates: requireList(daily['time'], 'daily.time')
          .map((e) => DateTime.parse(e as String))
          .toList(),
      weatherCodes: requireList(daily['weather_code'], 'daily.weather_code')
          .map((e) => jsonToInt(e))
          .toList(),
      temperatureMaxes: requireList(
        daily['temperature_2m_max'],
        'daily.temperature_2m_max',
      )
          .map((e) => jsonToDouble(e))
          .toList(),
      temperatureMins: requireList(
        daily['temperature_2m_min'],
        'daily.temperature_2m_min',
      )
          .map((e) => jsonToDouble(e))
          .toList(),
      sunrises: requireList(daily['sunrise'], 'daily.sunrise')
          .map((e) => DateTime.parse(e as String))
          .toList(),
      sunsets: requireList(daily['sunset'], 'daily.sunset')
          .map((e) => DateTime.parse(e as String))
          .toList(),
      uvIndexMaxes: requireList(daily['uv_index_max'], 'daily.uv_index_max')
          .map((e) => jsonToDouble(e))
          .toList(),
      precipitationSums: requireList(
        daily['precipitation_sum'],
        'daily.precipitation_sum',
      )
          .map((e) => jsonToDouble(e))
          .toList(),
      precipitationProbabilityMaxes: requireList(
        daily['precipitation_probability_max'],
        'daily.precipitation_probability_max',
      )
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
