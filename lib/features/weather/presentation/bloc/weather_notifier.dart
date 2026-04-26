import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/core/network/dio_client.dart';
import 'package:weather/core/utils/app_logger.dart';
import 'package:weather/features/weather/data/datasources/local_cache_datasource.dart';
import 'package:weather/features/weather/data/datasources/open_meteo_api_datasource.dart';
import 'package:weather/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:weather/features/weather/domain/usecases/get_current_weather.dart';
import 'package:weather/features/weather/domain/usecases/get_daily_forecast.dart';
import 'package:weather/features/weather/domain/usecases/get_hourly_forecast.dart';
import 'package:weather/features/weather/presentation/bloc/weather_state.dart';

/// Weather notifier that manages weather data fetching.
class WeatherNotifier extends Notifier<WeatherState> {
  late final WeatherRepositoryImpl _repository;
  late final LocalCacheDataSource _cacheDataSource;
  late final GetCurrentWeather _getCurrentWeather;
  late final GetHourlyForecast _getHourlyForecast;
  late final GetDailyForecast _getDailyForecast;

  LocalCacheDataSource get cacheDataSource => _cacheDataSource;

  @override
  WeatherState build() {
    _initRepository();
    return const WeatherInitial();
  }

  void _initRepository() {
    final apiDataSource = OpenMeteoApiDataSource(dio: createDioClient());
    _cacheDataSource = LocalCacheDataSource();

    _repository = WeatherRepositoryImpl(
      apiDataSource: apiDataSource,
      cacheDataSource: _cacheDataSource,
    );

    _getCurrentWeather = GetCurrentWeather(_repository);
    _getHourlyForecast = GetHourlyForecast(_repository);
    _getDailyForecast = GetDailyForecast(_repository);
  }

  /// Initializes the cache and loads weather data.
  Future<void> init() async {
    state = const WeatherLoading();

    try {
      await _cacheDataSource.init();

      // Get user's location
      final position = await _determinePosition();

      // Fetch all weather data in parallel
      final weatherResult = await _getCurrentWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      final hourlyResult = await _getHourlyForecast(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      final dailyResult = await _getDailyForecast(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      weatherResult.fold(
        (failure) {
          state = WeatherError(failure.message);
        },
        (weather) {
          hourlyResult.fold(
            (failure) {
              state = WeatherError(failure.message);
            },
            (hourly) {
              dailyResult.fold(
                (failure) {
                  state = WeatherError(failure.message);
                },
                (daily) {
                  state = WeatherLoaded(
                    currentWeather: weather,
                    hourlyForecast: hourly,
                    dailyForecast: daily,
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      AppLogger.error('Failed to initialize weather: $e');
      state = WeatherError('Failed to load weather: $e');
    }
  }

  /// Determines the current position of the device.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.error('Location services are disabled');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      AppLogger.warn('Location permission denied, requesting...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.error('Location permissions denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger.error('Location permissions permanently denied');
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can continue.
    final position = await Geolocator.getCurrentPosition();
    AppLogger.location('Got position: ${position.latitude}, ${position.longitude}');
    return position;
  }

  /// Refreshes weather data.
  Future<void> refresh() async {
    state = const WeatherLoading();
    await init();
  }
}

/// Provider for the weather notifier.
final weatherProvider = NotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);
