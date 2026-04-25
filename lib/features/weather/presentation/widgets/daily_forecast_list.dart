import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';

/// List widget displaying daily forecast.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.forecast,
  });

  final List<DailyForecast> forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayFormat = DateFormat.EEEE();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final day = forecast[index];
          final dayName = index == 0 ? 'Hoy' : dayFormat.format(day.date);

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: ListTile(
              leading: Icon(
                _getWeatherIcon(day.weatherCode),
                size: 32,
                color: theme.colorScheme.primary,
              ),
              title: Text(dayName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${day.temperatureMax.toStringAsFixed(0)}°',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${day.temperatureMin.toStringAsFixed(0)}°',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  if (day.precipitationProbabilityMax > 0) ...[
                    Icon(
                      Icons.water_drop,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${day.precipitationProbabilityMax.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(
                    Icons.wb_twilight,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.Hm().format(day.sunrise),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.nights_stay,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.Hm().format(day.sunset),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: forecast.length,
      ),
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
