import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';

/// Checks if any of the given hours meets rain notification criteria.
///
/// Criteria: [precipitationProbability] >= 70% AND [precipitation] > 0.5mm.
bool shouldNotifyRain(List<HourlyForecast> hours) {
  return hours.any(
    (h) => h.precipitationProbability >= 70 && h.precipitation > 0.5,
  );
}
