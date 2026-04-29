import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/core/error/failures.dart';
import 'package:weather/core/network/dio_provider.dart';
import 'package:weather/core/utils/app_logger.dart';
import 'package:weather/core/utils/weather_code_mapper.dart';
import 'package:weather/features/home_widget/data/services/home_widget_service.dart';
import 'package:weather/features/weather/data/datasources/local_cache_datasource.dart';
import 'package:weather/features/weather/data/datasources/open_meteo_api_datasource.dart';
import 'package:weather/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';
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

  /// Cancel tokens for in-flight requests.
  CancelToken? _currentWeatherToken;
  CancelToken? _hourlyForecastToken;
  CancelToken? _dailyForecastToken;

  LocalCacheDataSource get cacheDataSource => _cacheDataSource;

  @override
  WeatherState build() {
    // Use injected Dio from provider
    final dio = ref.read(dioProvider);
    _initRepository(dio);
    return const WeatherLoading();
  }

  void _initRepository(Dio dio) {
    final apiDataSource = OpenMeteoApiDataSource(dio: dio);
    _cacheDataSource = LocalCacheDataSource();

    _repository = WeatherRepositoryImpl(
      apiDataSource: apiDataSource,
      cacheDataSource: _cacheDataSource,
    );

    _getCurrentWeather = GetCurrentWeather(_repository);
    _getHourlyForecast = GetHourlyForecast(_repository);
    _getDailyForecast = GetDailyForecast(_repository);
  }

  /// Initializes cache, resolves device location, then fetches current,
  /// hourly and daily weather concurrently. Allows partial success.
  Future<void> init() async {
    state = const WeatherLoading();

    try {
      await _cacheDataSource.init();

      // Get user's location
      final position = await _determinePosition();

      // Save location for background tasks
      await _cacheDataSource.saveLastLocation(
        position.latitude,
        position.longitude,
      );

      // Resolve location name via reverse geocoding
      final locationName = await _resolveLocationName(
        position.latitude,
        position.longitude,
      );

      // Fetch all weather data concurrently with cancellation support
      final results = await Future.wait([
        _fetchWithCancellation(
          () => _getCurrentWeather(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
          () => _currentWeatherToken,
          (token) => _currentWeatherToken = token,
        ),
        _fetchWithCancellation(
          () => _getHourlyForecast(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
          () => _hourlyForecastToken,
          (token) => _hourlyForecastToken = token,
        ),
        _fetchWithCancellation(
          () => _getDailyForecast(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
          () => _dailyForecastToken,
          (token) => _dailyForecastToken = token,
        ),
      ]);

      final weatherResult = results[0] as Either<Failure, dynamic>;
      final hourlyResult = results[1] as Either<Failure, dynamic>;
      final dailyResult = results[2] as Either<Failure, dynamic>;

      // Allow partial success: use data if available, fallback to empty/defaults
      final weather = weatherResult.fold(
        (failure) => null,
        (data) => data,
      );
      final hourly = hourlyResult.fold(
        (failure) => <dynamic>[],
        (data) => data,
      );
      final daily = dailyResult.fold(
        (failure) => <dynamic>[],
        (data) => data,
      );

      // If all three failed, show error
      if (weather == null && hourly.isEmpty && daily.isEmpty) {
        state = const WeatherError(
          'No se pudo cargar el clima. Verifica tu conexión e inténtalo de nuevo.',
        );
        return;
      }

      state = WeatherLoaded(
        currentWeather: weather,
        hourlyForecast: hourly,
        dailyForecast: daily,
        locationName: locationName,
      );

      // Update home screen widget if we have current weather
      if (weather != null) {
        await HomeWidgetService.saveWeatherData(
          locationName: locationName,
          temperature: weather.temperature,
          weatherCode: weather.weatherCode,
          isDay: weather.isDay,
          description: WeatherCodeMapper.description(weather.weatherCode),
          tempMax: daily.isNotEmpty ? daily.first.temperatureMax : null,
          tempMin: daily.isNotEmpty ? daily.first.temperatureMin : null,
        );
      }
    } catch (e) {
      AppLogger.error('Failed to initialize weather: $e');
      state = const WeatherError(
        'No se pudo cargar el clima. Verifica tu conexión e inténtalo de nuevo.',
      );
    }
  }

  /// Wraps a fetch operation with CancelToken support.
  Future<Either<Failure, T>> _fetchWithCancellation<T>(
    Future<Either<Failure, T>> Function() fetchFn,
    CancelToken? Function() getToken,
    void Function(CancelToken) setToken,
  ) async {
    // Cancel previous in-flight request
    final existingToken = getToken();
    if (existingToken != null && !existingToken.isCancelled) {
      existingToken.cancel('Cancelled by new request');
    }

    // Create new cancel token
    final newToken = CancelToken();
    setToken(newToken);

    try {
      return await fetchFn();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        AppLogger.info('Request cancelled');
        return Left(NetworkFailure('Request cancelled'));
      }
      return Left(NetworkFailure(e.message ?? 'Network error'));
    }
  }

  /// Resolves a human-readable location name from coordinates.
  /// Falls back to coordinates if geocoding fails.
  Future<String> _resolveLocationName(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) {
        return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
      }
      final place = placemarks.first;
      final name = place.locality ??
          place.subLocality ??
          place.administrativeArea ??
          place.country;
      if (name == null || name.isEmpty) {
        return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
      }
      AppLogger.location('Resolved: $name');
      return name;
    } catch (e) {
      AppLogger.warn('Geocoding failed, using coordinates: $e');
      return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
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
    AppLogger.location(
      'Got position: ${_redact(position.latitude)}, ${_redact(position.longitude)}',
    );
    return position;
  }

  /// Refreshes weather data.
  Future<void> refresh() async {
    state = const WeatherLoading();
    await init();
  }

  /// Redacts a coordinate for safe logging (replaces last digits with 'x').
  String _redact(double value) {
    final s = value.toStringAsFixed(2);
    return '${s.substring(0, s.length - 1)}x';
  }
}

/// Provider for the weather notifier.
final weatherProvider = NotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);

/// Derived provider that only watches current weather data.
final currentWeatherProvider = Provider<Weather?>((ref) {
  final state = ref.watch(weatherProvider);
  return switch (state) {
    WeatherLoaded(:final currentWeather) => currentWeather,
    _ => null,
  };
});

/// Derived provider that only watches hourly forecast data.
final hourlyForecastProvider = Provider<List<HourlyForecast>>((ref) {
  final state = ref.watch(weatherProvider);
  return switch (state) {
    WeatherLoaded(:final hourlyForecast) => hourlyForecast,
    _ => const [],
  };
});

/// Derived provider that only watches daily forecast data.
final dailyForecastProvider = Provider<List<DailyForecast>>((ref) {
  final state = ref.watch(weatherProvider);
  return switch (state) {
    WeatherLoaded(:final dailyForecast) => dailyForecast,
    _ => const [],
  };
});

/// Derived provider that only watches location name.
final locationNameProvider = Provider<String?>((ref) {
  final state = ref.watch(weatherProvider);
  return switch (state) {
    WeatherLoaded(:final locationName) => locationName,
    _ => null,
  };
});

/// Derived provider that watches loading state.
final isWeatherLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(weatherProvider);
  return switch (state) {
    WeatherLoading() => true,
    _ => false,
  };
});

/// Derived provider that watches error state.
final weatherErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(weatherProvider);
  return switch (state) {
    WeatherError(:final message) => message,
    _ => null,
  };
});
