import 'package:dartz/dartz.dart';
import 'package:weather/core/error/failures.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';

/// Abstract repository for weather data operations.
abstract class WeatherRepository {
  /// Gets current weather for the given coordinates.
  Future<Either<Failure, Weather>> getCurrentWeather({
    required double latitude,
    required double longitude,
  });

  /// Gets hourly forecast for the given coordinates.
  Future<Either<Failure, List<HourlyForecast>>> getHourlyForecast({
    required double latitude,
    required double longitude,
  });

  /// Gets daily forecast for the given coordinates.
  Future<Either<Failure, List<DailyForecast>>> getDailyForecast({
    required double latitude,
    required double longitude,
  });
}
