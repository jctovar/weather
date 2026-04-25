import 'package:dartz/dartz.dart';
import 'package:weather/core/error/failures.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';
import 'package:weather/features/weather/domain/repositories/weather_repository.dart';

/// Use case for getting hourly forecast.
class GetHourlyForecast {
  const GetHourlyForecast(this.repository);

  final WeatherRepository repository;

  Future<Either<Failure, List<HourlyForecast>>> call({
    required double latitude,
    required double longitude,
  }) {
    return repository.getHourlyForecast(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
