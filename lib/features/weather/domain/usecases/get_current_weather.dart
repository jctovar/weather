import 'package:dartz/dartz.dart';
import 'package:weather/core/error/failures.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';
import 'package:weather/features/weather/domain/repositories/weather_repository.dart';

/// Use case for getting current weather.
class GetCurrentWeather {
  const GetCurrentWeather(this.repository);

  final WeatherRepository repository;

  Future<Either<Failure, Weather>> call({
    required double latitude,
    required double longitude,
  }) {
    return repository.getCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
