import 'package:dartz/dartz.dart';
import 'package:weather/core/error/failures.dart';
import 'package:weather/features/weather/data/datasources/local_cache_datasource.dart';
import 'package:weather/features/weather/data/datasources/open_meteo_api_datasource.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';
import 'package:weather/features/weather/domain/repositories/weather_repository.dart';

/// Implementation of [WeatherRepository] that combines API and cache.
class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl({
    required this.apiDataSource,
    required this.cacheDataSource,
  });

  final OpenMeteoApiDataSource apiDataSource;
  final LocalCacheDataSource cacheDataSource;

  /// Retries an operation with exponential backoff.
  Future<T> _withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        final delay = Duration(milliseconds: 1000 << (attempt - 1));
        await Future.delayed(delay);
      }
    }
  }

  @override
  Future<Either<Failure, Weather>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final weatherModel = await _withRetry(
        () => apiDataSource.getCurrentWeather(
          latitude: latitude,
          longitude: longitude,
        ),
      );

      await cacheDataSource.saveCurrentWeather(weatherModel);

      return Right(weatherModel.toEntity());
    } on OpenMeteoApiException {
      final cached = await cacheDataSource.getCurrentWeather();
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return const Left(
        NetworkFailure('Failed to fetch weather data and no cache available'),
      );
    } catch (e) {
      return Left(NetworkFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HourlyForecast>>> getHourlyForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final forecastModel = await _withRetry(
        () => apiDataSource.getHourlyForecast(
          latitude: latitude,
          longitude: longitude,
        ),
      );

      await cacheDataSource.saveHourlyForecast(forecastModel);

      return Right(forecastModel.toEntityList());
    } on OpenMeteoApiException {
      final cached = await cacheDataSource.getHourlyForecast();
      if (cached != null) {
        return Right(cached.toEntityList());
      }
      return const Left(
        NetworkFailure(
          'Failed to fetch hourly forecast and no cache available',
        ),
      );
    } catch (e) {
      return Left(NetworkFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DailyForecast>>> getDailyForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final forecastModel = await _withRetry(
        () => apiDataSource.getDailyForecast(
          latitude: latitude,
          longitude: longitude,
        ),
      );

      await cacheDataSource.saveDailyForecast(forecastModel);

      return Right(forecastModel.toEntityList());
    } on OpenMeteoApiException {
      final cached = await cacheDataSource.getDailyForecast();
      if (cached != null) {
        return Right(cached.toEntityList());
      }
      return const Left(
        NetworkFailure(
          'Failed to fetch daily forecast and no cache available',
        ),
      );
    } catch (e) {
      return Left(NetworkFailure('Unexpected error: $e'));
    }
  }
}
