import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather/core/error/failures.dart';
import 'package:weather/features/weather/data/datasources/local_cache_datasource.dart';
import 'package:weather/features/weather/data/datasources/open_meteo_api_datasource.dart';
import 'package:weather/features/weather/data/models/daily_forecast_model.dart';
import 'package:weather/features/weather/data/models/hourly_forecast_model.dart';
import 'package:weather/features/weather/data/models/weather_model.dart';
import 'package:weather/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';

class MockApiDataSource extends Mock implements OpenMeteoApiDataSource {}

class MockCacheDataSource extends Mock implements LocalCacheDataSource {}

class FakeWeatherModel extends Fake implements WeatherModel {}

class FakeHourlyForecastModel extends Fake implements HourlyForecastModel {}

class FakeDailyForecastModel extends Fake implements DailyForecastModel {}

void main() {
  late WeatherRepositoryImpl repository;
  late MockApiDataSource mockApiDataSource;
  late MockCacheDataSource mockCacheDataSource;

  setUpAll(() {
    registerFallbackValue(FakeWeatherModel());
    registerFallbackValue(FakeHourlyForecastModel());
    registerFallbackValue(FakeDailyForecastModel());
  });

  setUp(() {
    mockApiDataSource = MockApiDataSource();
    mockCacheDataSource = MockCacheDataSource();
    repository = WeatherRepositoryImpl(
      apiDataSource: mockApiDataSource,
      cacheDataSource: mockCacheDataSource,
    );
  });

  const tLatitude = 40.4168;
  const tLongitude = -3.7038;

  group('getCurrentWeather', () {
    final tWeatherModel = WeatherModel(
      temperature: 22.5,
      apparentTemperature: 20.0,
      humidity: 65,
      precipitation: 0.0,
      rain: 0.0,
      weatherCode: 0,
      windSpeed: 12.3,
      isDay: true,
      time: DateTime(2024, 1, 15, 12),
    );

    test('should return Weather when API call is successful', () async {
      when(
        () => mockApiDataSource.getCurrentWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => tWeatherModel);
      when(
        () => mockCacheDataSource.saveCurrentWeather(any()),
      ).thenAnswer((_) async => {});

      final result = await repository.getCurrentWeather(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result, isA<Right<Failure, Weather>>());
      result.fold(
        (failure) => fail('Should be Right'),
        (weather) {
          expect(weather.temperature, 22.5);
          expect(weather.apparentTemperature, 20.0);
        },
      );
      verify(
        () => mockCacheDataSource.saveCurrentWeather(tWeatherModel),
      ).called(1);
    });

    test('should return cached Weather when API fails', () async {
      when(
        () => mockApiDataSource.getCurrentWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenThrow(const OpenMeteoApiException('Network error'));
      when(
        () => mockCacheDataSource.getCurrentWeather(),
      ).thenAnswer((_) async => tWeatherModel);

      final result = await repository.getCurrentWeather(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result, isA<Right<Failure, Weather>>());
      verify(
        () => mockCacheDataSource.getCurrentWeather(),
      ).called(1);
    });

    test('should return NetworkFailure when API fails and no cache', () async {
      when(
        () => mockApiDataSource.getCurrentWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenThrow(const OpenMeteoApiException('Network error'));
      when(
        () => mockCacheDataSource.getCurrentWeather(),
      ).thenAnswer((_) async => null);

      final result = await repository.getCurrentWeather(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result, isA<Left<Failure, Weather>>());
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(
            failure.message,
            'Failed to fetch weather data and no cache available',
          );
        },
        (_) => fail('Should be Left'),
      );
    });
  });

  group('getHourlyForecast', () {
    final tForecastModel = HourlyForecastModel(
      times: [DateTime(2024, 1, 15, 12)],
      temperatures: [20.0],
      precipitationProbabilities: [10.0],
      precipitations: [0.0],
      weatherCodes: [0],
      windSpeeds: [10.0],
    );

    test('should return hourly forecast when API call is successful', () async {
      when(
        () => mockApiDataSource.getHourlyForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => tForecastModel);
      when(
        () => mockCacheDataSource.saveHourlyForecast(any()),
      ).thenAnswer((_) async => {});

      final result = await repository.getHourlyForecast(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result, isA<Right<Failure, List<HourlyForecast>>>());
      result.fold(
        (failure) => fail('Should be Right'),
        (forecast) {
          expect(forecast.length, 1);
          expect(forecast[0].temperature, 20.0);
        },
      );
    });

    test('should return cached hourly forecast when API fails', () async {
      when(
        () => mockApiDataSource.getHourlyForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenThrow(const OpenMeteoApiException('Network error'));
      when(
        () => mockCacheDataSource.getHourlyForecast(),
      ).thenAnswer((_) async => tForecastModel);

      final result = await repository.getHourlyForecast(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result, isA<Right<Failure, List<HourlyForecast>>>());
    });

    test('should return NetworkFailure when API fails and no cache', () async {
      when(
        () => mockApiDataSource.getHourlyForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenThrow(const OpenMeteoApiException('Network error'));
      when(
        () => mockCacheDataSource.getHourlyForecast(),
      ).thenAnswer((_) async => null);

      final result = await repository.getHourlyForecast(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result, isA<Left<Failure, List<HourlyForecast>>>());
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(
            failure.message,
            'Failed to fetch hourly forecast and no cache available',
          );
        },
        (_) => fail('Should be Left'),
      );
    });
  });

  group('getDailyForecast', () {
    final tForecastModel = DailyForecastModel(
      dates: [DateTime(2024, 1, 15)],
      weatherCodes: [0],
      temperatureMaxes: [25.0],
      temperatureMins: [15.0],
      sunrises: [DateTime(2024, 1, 15, 7, 30)],
      sunsets: [DateTime(2024, 1, 15, 18, 45)],
      uvIndexMaxes: [5.0],
      precipitationSums: [0.0],
      precipitationProbabilityMaxes: [10.0],
    );

    test('should return daily forecast when API call is successful', () async {
      when(
        () => mockApiDataSource.getDailyForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => tForecastModel);
      when(
        () => mockCacheDataSource.saveDailyForecast(any()),
      ).thenAnswer((_) async => {});

      final result = await repository.getDailyForecast(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result, isA<Right<Failure, List<DailyForecast>>>());
      result.fold(
        (failure) => fail('Should be Right'),
        (forecast) {
          expect(forecast.length, 1);
          expect(forecast[0].temperatureMax, 25.0);
        },
      );
    });

    test('should return cached daily forecast when API fails', () async {
      when(
        () => mockApiDataSource.getDailyForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenThrow(const OpenMeteoApiException('Network error'));
      when(
        () => mockCacheDataSource.getDailyForecast(),
      ).thenAnswer((_) async => tForecastModel);

      final result = await repository.getDailyForecast(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result, isA<Right<Failure, List<DailyForecast>>>());
    });

    test('should return NetworkFailure when API fails and no cache', () async {
      when(
        () => mockApiDataSource.getDailyForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenThrow(const OpenMeteoApiException('Network error'));
      when(
        () => mockCacheDataSource.getDailyForecast(),
      ).thenAnswer((_) async => null);

      final result = await repository.getDailyForecast(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result, isA<Left<Failure, List<DailyForecast>>>());
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(
            failure.message,
            'Failed to fetch daily forecast and no cache available',
          );
        },
        (_) => fail('Should be Left'),
      );
    });
  });
}
