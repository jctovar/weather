import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/core/utils/weather_code_mapper.dart';
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
          width: 72,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    index == 0 ? 'Ahora' : timeFormat.format(hour.time),
                    style: theme.textTheme.labelSmall,
                  ),
                  Icon(
                    WeatherCodeMapper.icon(hour.weatherCode),
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                  Text(
                    '${hour.temperature.toStringAsFixed(0)}°',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hour.precipitationProbability > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 10,
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
              ),
            ),
          ),
        );
      },
    );
  }

}
