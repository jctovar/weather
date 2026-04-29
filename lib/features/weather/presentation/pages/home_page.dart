import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';
import 'package:weather/features/weather/presentation/bloc/weather_notifier.dart';
import 'package:weather/features/weather/presentation/bloc/weather_state.dart';
import 'package:weather/features/weather/presentation/widgets/current_weather_card.dart';
import 'package:weather/features/weather/presentation/widgets/daily_forecast_list.dart';
import 'package:weather/features/notifications/presentation/widgets/notification_settings_sheet.dart';
import 'package:weather/features/weather/presentation/widgets/hourly_forecast_list.dart';

/// Home page displaying current weather and forecasts.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    final weatherNotifier = ref.read(weatherProvider.notifier);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await weatherNotifier.refresh();
        },
        child: switch (weatherState) {
          WeatherLoading() || WeatherInitial() => const Center(
              child: CircularProgressIndicator(),
            ),
          WeatherLoaded(
            :final currentWeather,
            :final hourlyForecast,
            :final dailyForecast,
            :final locationName
          ) =>
            _buildSuccessContent(
              context,
              weatherNotifier,
              currentWeather,
              hourlyForecast,
              dailyForecast,
              locationName,
            ),
          WeatherError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar el clima',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      weatherNotifier.refresh();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
        },
      ),
      bottomNavigationBar: _buildBottomAttribution(context),
    );
  }

  Widget _buildSuccessContent(
    BuildContext context,
    WeatherNotifier weatherNotifier,
    Weather? currentWeather,
    List<HourlyForecast> hourlyForecast,
    List<DailyForecast> dailyForecast,
    String locationName,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(locationName),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                weatherNotifier.refresh();
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => const NotificationSettingsSheet(),
                );
              },
            ),
          ],
        ),
        if (currentWeather != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CurrentWeatherCard(
                weather: currentWeather,
                locationName: locationName,
              ),
            ),
          ),
        if (hourlyForecast.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Pronóstico por Hora',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: HourlyForecastList(forecast: hourlyForecast),
            ),
          ),
        ],
        if (dailyForecast.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Pronóstico por Día',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          DailyForecastList(forecast: dailyForecast),
        ],
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
      ],
    );
  }

  Widget _buildBottomAttribution(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          AppConstants.openMeteoAttribution,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
