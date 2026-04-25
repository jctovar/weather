import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather/core/error/failures.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';
import 'package:weather/features/weather/domain/repositories/weather_repository.dart';
import 'package:weather/features/weather/domain/usecases/get_current_weather.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late GetCurrentWeather usecase;
  late MockWeatherRepository mockRepository;

  setUp(() {
    mockRepository = MockWeatherRepository();
    usecase = GetCurrentWeather(mockRepository);
  });

  const tLatitude = 40.4168;
  const tLongitude = -3.7038;

  test('should get current weather from the repository', () async {
    final tWeather = Weather(
      temperature: 20,
      apparentTemperature: 18,
      humidity: 50,
      precipitation: 0,
      rain: 0,
      weatherCode: 0,
      windSpeed: 10,
      isDay: true,
      time: DateTime(2024, 1, 1, 12),
    );

    when(() => mockRepository.getCurrentWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async => Right(tWeather));

    final result = await usecase(
      latitude: tLatitude,
      longitude: tLongitude,
    );

    expect(result, Right(tWeather));
    verify(() => mockRepository.getCurrentWeather(
          latitude: tLatitude,
          longitude: tLongitude,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return NetworkFailure when repository fails', () async {
    const tFailure = NetworkFailure('Network error');

    when(() => mockRepository.getCurrentWeather(
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
