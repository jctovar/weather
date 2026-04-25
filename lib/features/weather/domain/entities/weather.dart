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
  String get description => _weatherDescription(weatherCode);

  static String _weatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Cielo despejado';
      case 1:
      case 2:
      case 3:
        return 'Parcialmente nublado';
      case 45:
      case 48:
        return 'Niebla';
      case 51:
      case 53:
      case 55:
        return 'Llovizna';
      case 61:
      case 63:
      case 65:
        return 'Lluvia';
      case 71:
      case 73:
      case 75:
        return 'Nieve';
      case 80:
      case 81:
      case 82:
        return 'Chubascos';
      case 95:
      case 96:
      case 99:
        return 'Tormenta';
      default:
        return 'Desconocido';
    }
  }
}
