import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';

/// Card widget displaying current weather conditions.
class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.weather,
  });

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.Hm();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Temperature
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Weather condition
            Text(
              weather.description,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Weather details grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  context,
                  Icons.thermostat,
                  'Sensación',
                  '${weather.apparentTemperature.toStringAsFixed(1)}°C',
                ),
                _buildDetailItem(
                  context,
                  Icons.water_drop,
                  'Humedad',
                  '${weather.humidity}%',
                ),
                _buildDetailItem(
                  context,
                  Icons.air,
                  'Viento',
                  '${weather.windSpeed.toStringAsFixed(1)} km/h',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Additional details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  context,
                  Icons.cloud,
                  'Precipitación',
                  '${weather.precipitation.toStringAsFixed(1)} mm',
                ),
                _buildDetailItem(
                  context,
                  Icons.wb_sunny,
                  'Día',
                  weather.isDay ? 'Sí' : 'No',
                ),
                _buildDetailItem(
                  context,
                  Icons.schedule,
                  'Actualizado',
                  dateFormat.format(weather.time),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 28, color: theme.colorScheme.secondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
