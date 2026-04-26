import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';
import 'package:weather/features/weather/presentation/bloc/weather_notifier.dart';
import 'package:weather/features/weather/presentation/bloc/weather_state.dart';
import 'package:weather/features/weather/presentation/pages/home_page.dart';
import 'package:weather/features/weather/presentation/widgets/current_weather_card.dart';
import 'package:weather/features/weather/presentation/widgets/hourly_forecast_list.dart';

class MockWeatherNotifier extends WeatherNotifier {
  MockWeatherNotifier(this._initialState);

  final WeatherState _initialState;

  @override
  WeatherState build() => _initialState;

  @override
  Future<void> init() async {}

  @override
  Future<void> refresh() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Hive.init('.hive_test_widget');
    await Hive.openBox<String>(AppConstants.weatherBoxName);
  });

  tearDownAll(() async {
    if (Hive.isBoxOpen(AppConstants.weatherBoxName)) {
      await Hive.box<String>(AppConstants.weatherBoxName).close();
    }
    await Hive.close();
  });

  group('HomePage', () {
    testWidgets('shows loading indicator when state is WeatherInitial',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherProvider.overrideWith(
              () => MockWeatherNotifier(WeatherInitial()),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator when state is WeatherLoading',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherProvider.overrideWith(
              () => MockWeatherNotifier(WeatherLoading()),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows weather content when state is WeatherLoaded',
        (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);

      final tWeather = Weather(
        temperature: 22.5,
        apparentTemperature: 20.0,
        humidity: 65,
        precipitation: 0.0,
        rain: 0.0,
        weatherCode: 0,
        windSpeed: 12.3,
        isDay: true,
        time: DateTime(2024, 1, 15, 12),
      );

      final tHourly = [
        HourlyForecast(
          time: DateTime(2024, 1, 15, 12),
          temperature: 20.0,
          precipitationProbability: 10.0,
          precipitation: 0.0,
          weatherCode: 0,
          windSpeed: 10.0,
        ),
      ];

      final tDaily = [
        DailyForecast(
          date: DateTime(2024, 1, 15),
          weatherCode: 0,
          temperatureMax: 25.0,
          temperatureMin: 15.0,
          sunrise: DateTime(2024, 1, 15, 7, 30),
          sunset: DateTime(2024, 1, 15, 18, 45),
          uvIndexMax: 5.0,
          precipitationSum: 0.0,
          precipitationProbabilityMax: 10.0,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherProvider.overrideWith(
              () => MockWeatherNotifier(
                WeatherLoaded(
                  currentWeather: tWeather,
                  hourlyForecast: tHourly,
                  dailyForecast: tDaily,
                  locationName: 'Madrid',
                ),
              ),
            ),
          ],
          child: MaterialApp(home: HomePage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CurrentWeatherCard), findsOneWidget);
      expect(find.byType(HourlyForecastList), findsOneWidget);
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.text('Madrid'), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('shows error message and retry button when state is WeatherError',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherProvider.overrideWith(
              () => MockWeatherNotifier(
                const WeatherError('Network error'),
              ),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      expect(find.text('Error al cargar el clima'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows Open-Meteo attribution in bottom bar', (tester) async {
      final tWeather = Weather(
        temperature: 20,
        apparentTemperature: 18,
        humidity: 50,
        precipitation: 0,
        rain: 0,
        weatherCode: 0,
        windSpeed: 10,
        isDay: true,
        time: DateTime(2024, 1, 15, 12),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherProvider.overrideWith(
              () => MockWeatherNotifier(
                WeatherLoaded(
                  currentWeather: tWeather,
                  hourlyForecast: const [],
                  dailyForecast: const [],
                  locationName: '40.42, -3.70',
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      expect(
        find.textContaining('Open-Meteo'),
        findsOneWidget,
      );
    });
  });
}
