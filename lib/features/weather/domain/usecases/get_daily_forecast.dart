import 'package:dartz/dartz.dart';
import 'package:weather/core/error/failures.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';
import 'package:weather/features/weather/domain/repositories/weather_repository.dart';

/// Use case for getting daily forecast.
class GetDailyForecast {
  const GetDailyForecast(this.repository);

  final WeatherRepository repository;

  Future<Either<Failure, List<DailyForecast>>> call({
    required double latitude,
    required double longitude,
  }) {
    return repository.getDailyForecast(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
