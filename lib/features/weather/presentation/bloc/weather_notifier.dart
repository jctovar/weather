import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/core/error/failures.dart';
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

  /// Prevents concurrent weather fetches.
  bool _isLoading = false;

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

  /// Unwraps an Either result, setting error state on failure.
  T? _unwrap<T>(Either<Failure, T> result) {
    return result.fold(
      (failure) {
        state = WeatherError(failure.message);
        return null;
      },
      (data) => data,
    );
  }

  /// Initializes cache, resolves device location, then fetches current,
  /// hourly and daily weather. Falls back to [WeatherError] on any failure.
  /// Ignored if a fetch is already in progress.
  Future<void> init() async {
    if (_isLoading) return;
    _isLoading = true;
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

      // Fetch all weather data
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

      final weather = _unwrap(weatherResult);
      if (weather == null) return;

      final hourly = _unwrap(hourlyResult);
      if (hourly == null) return;

      final daily = _unwrap(dailyResult);
      if (daily == null) return;

      state = WeatherLoaded(
        currentWeather: weather,
        hourlyForecast: hourly,
        dailyForecast: daily,
        locationName: locationName,
      );
    } catch (e) {
      AppLogger.error('Failed to initialize weather: $e');
      state = const WeatherError(
        'No se pudo cargar el clima. Verifica tu conexión e inténtalo de nuevo.',
      );
    } finally {
      _isLoading = false;
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
