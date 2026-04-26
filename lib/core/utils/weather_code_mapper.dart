import 'package:flutter/material.dart';

/// Maps WMO weather codes to human-readable descriptions and icons.
class WeatherCodeMapper {
  WeatherCodeMapper._();

  static const _descriptions = <int, String>{
    0: 'Cielo despejado',
    1: 'Parcialmente nublado',
    2: 'Parcialmente nublado',
    3: 'Parcialmente nublado',
    45: 'Niebla',
    48: 'Niebla',
    51: 'Llovizna',
    53: 'Llovizna',
    55: 'Llovizna',
    61: 'Lluvia',
    63: 'Lluvia',
    65: 'Lluvia',
    71: 'Nieve',
    73: 'Nieve',
    75: 'Nieve',
    80: 'Chubascos',
    81: 'Chubascos',
    82: 'Chubascos',
    95: 'Tormenta',
    96: 'Tormenta',
    99: 'Tormenta',
  };

  static const _icons = <int, IconData>{
    0: Icons.wb_sunny,
    1: Icons.cloud,
    2: Icons.cloud,
    3: Icons.cloud,
    45: Icons.foggy,
    48: Icons.foggy,
    51: Icons.bubble_chart,
    53: Icons.bubble_chart,
    55: Icons.bubble_chart,
    61: Icons.bubble_chart,
    63: Icons.water_drop,
    65: Icons.water_drop,
    71: Icons.ac_unit,
    73: Icons.ac_unit,
    75: Icons.ac_unit,
    80: Icons.water_drop,
    81: Icons.water_drop,
    82: Icons.water_drop,
    95: Icons.thunderstorm,
    96: Icons.thunderstorm,
    99: Icons.thunderstorm,
  };

  /// Returns a human-readable weather description based on WMO code.
  static String description(int code) =>
      _descriptions[code] ?? 'Desconocido';

  /// Returns an appropriate Material icon for the WMO code.
  static IconData icon(int code) => _icons[code] ?? Icons.cloud;
}
