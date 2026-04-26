import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';

/// Generates a contextual notification message from matching hours.
///
/// Uses the highest precipitation probability found.
String getRainNotificationMessage(List<HourlyForecast> matchingHours) {
  final maxProb = matchingHours
      .map((h) => h.precipitationProbability)
      .reduce((a, b) => a > b ? a : b);
  return '🌧️ Lluvia probable en las próximas horas (${maxProb.toStringAsFixed(0)}%)';
}
