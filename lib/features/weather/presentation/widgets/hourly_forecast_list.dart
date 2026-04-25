import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';

/// Horizontal list widget displaying hourly forecast.
class HourlyForecastList extends StatelessWidget {
  const HourlyForecastList({
    super.key,
    required this.forecast,
  });

  final List<HourlyForecast> forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat.Hm();

    // Show next 24 hours
    final nextHours = forecast.take(24).toList();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: nextHours.length,
      itemBuilder: (context, index) {
        final hour = nextHours[index];

        return Container(
          width: 80,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 12,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    index == 0 ? 'Ahora' : timeFormat.format(hour.time),
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    _getWeatherIcon(hour.weatherCode),
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hour.temperature.toStringAsFixed(0)}°',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hour.precipitationProbability > 0) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${hour.precipitationProbability.toStringAsFixed(0)}%',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny;
      case 1:
      case 2:
        return Icons.cloud;
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
      case 61:
        return Icons.bubble_chart;
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return Icons.water_drop;
      case 71:
      case 73:
      case 75:
        return Icons.ac_unit;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm;
      default:
        return Icons.cloud;
    }
  }
}
