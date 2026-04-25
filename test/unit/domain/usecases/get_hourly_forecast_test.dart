import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather/core/error/failures.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';
import 'package:weather/features/weather/domain/repositories/weather_repository.dart';
import 'package:weather/features/weather/domain/usecases/get_hourly_forecast.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late GetHourlyForecast usecase;
  late MockWeatherRepository mockRepository;

  setUp(() {
    mockRepository = MockWeatherRepository();
    usecase = GetHourlyForecast(mockRepository);
  });

  const tLatitude = 40.4168;
  const tLongitude = -3.7038;

  test('should get hourly forecast from the repository', () async {
    final tForecast = [
      HourlyForecast(
        time: DateTime(2024, 1, 1, 12),
        temperature: 20,
        precipitationProbability: 10,
        precipitation: 0,
        weatherCode: 0,
        windSpeed: 10,
      ),
    ];

    when(() => mockRepository.getHourlyForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async => Right(tForecast));

    final result = await usecase(
      latitude: tLatitude,
      longitude: tLongitude,
    );

    expect(result, Right(tForecast));
    verify(() => mockRepository.getHourlyForecast(
          latitude: tLatitude,
          longitude: tLongitude,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when repository fails', () async {
    const tFailure = NetworkFailure('Network error');

    when(() => mockRepository.getHourlyForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async => Left(tFailure));

    final result = await usecase(
      latitude: tLatitude,
      longitude: tLongitude,
    );

    expect(result, Left(tFailure));
  });
}
