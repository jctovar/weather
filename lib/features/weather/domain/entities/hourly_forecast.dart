/// Represents an hourly forecast entry.
class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  final DateTime time;
  final double temperature;
  final double precipitationProbability;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
}
