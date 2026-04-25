import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather/core/error/failures.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';
import 'package:weather/features/weather/domain/repositories/weather_repository.dart';
import 'package:weather/features/weather/domain/usecases/get_daily_forecast.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late GetDailyForecast usecase;
  late MockWeatherRepository mockRepository;

  setUp(() {
    mockRepository = MockWeatherRepository();
    usecase = GetDailyForecast(mockRepository);
  });

  const tLatitude = 40.4168;
  const tLongitude = -3.7038;

  test('should get daily forecast from the repository', () async {
    final tForecast = [
      DailyForecast(
        date: DateTime(2024, 1, 1),
        weatherCode: 0,
        temperatureMax: 25,
        temperatureMin: 15,
        sunrise: DateTime(2024, 1, 1, 7, 30),
        sunset: DateTime(2024, 1, 1, 18, 45),
        uvIndexMax: 5,
        precipitationSum: 0,
        precipitationProbabilityMax: 10,
      ),
    ];

    when(() => mockRepository.getDailyForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async => Right(tForecast));

    final result = await usecase(
      latitude: tLatitude,
      longitude: tLongitude,
    );

    expect(result, Right(tForecast));
    verify(() => mockRepository.getDailyForecast(
          latitude: tLatitude,
          longitude: tLongitude,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when repository fails', () async {
    const tFailure = NetworkFailure('Network error');

    when(() => mockRepository.getDailyForecast(
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
