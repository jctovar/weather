import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather/features/weather/data/datasources/open_meteo_api_datasource.dart';
import 'package:weather/features/weather/data/models/weather_model.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<Map<String, dynamic>> {}

void main() {
  late OpenMeteoApiDataSource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = OpenMeteoApiDataSource(dio: mockDio);
  });

  const tLatitude = 40.4168;
  const tLongitude = -3.7038;

  group('getCurrentWeather', () {
    final tApiResponse = {
      'current': {
        'temperature_2m': 22.5,
        'apparent_temperature': 20.0,
        'relative_humidity_2m': 65,
        'precipitation': 0.0,
        'rain': 0.0,
        'weather_code': 0,
        'wind_speed_10m': 12.3,
        'is_day': 1,
        'time': '2024-01-15T12:00',
      },
    };

    test('should return WeatherModel when response is 200', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(tApiResponse);
      when(
        () => mockDio.get(
          '/forecast',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getCurrentWeather(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result, isA<WeatherModel>());
      expect(result.temperature, 22.5);
      verify(
        () => mockDio.get(
          '/forecast',
          queryParameters: {
            'latitude': tLatitude,
            'longitude': tLongitude,
            'current':
                'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,weather_code,wind_speed_10m',
            'timezone': 'auto',
          },
        ),
      ).called(1);
    });

    test('should throw OpenMeteoApiException when response is not 200',
        () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(500);
      when(
        () => mockDio.get(
          '/forecast',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => mockResponse);

      expect(
        () => dataSource.getCurrentWeather(
          latitude: tLatitude,
          longitude: tLongitude,
        ),
        throwsA(isA<OpenMeteoApiException>()),
      );
    });

    test('should throw OpenMeteoApiException on DioException', () async {
      when(
        () => mockDio.get(
          '/forecast',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/forecast'),
        message: 'Network error',
      ));

      expect(
        () => dataSource.getCurrentWeather(
          latitude: tLatitude,
          longitude: tLongitude,
        ),
        throwsA(isA<OpenMeteoApiException>()),
      );
    });
  });

  group('getHourlyForecast', () {
    final tApiResponse = {
      'hourly': {
        'time': ['2024-01-15T12:00'],
        'temperature_2m': [20.0],
        'precipitation_probability': [10.0],
        'precipitation': [0.0],
        'weather_code': [0],
        'wind_speed_10m': [10.0],
      },
    };

    test('should return HourlyForecastModel when response is 200', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(tApiResponse);
      when(
        () => mockDio.get(
          '/forecast',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getHourlyForecast(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result.times.length, 1);
      expect(result.temperatures[0], 20.0);
    });

    test('should throw OpenMeteoApiException when response is not 200',
        () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(404);
      when(
        () => mockDio.get(
          '/forecast',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => mockResponse);

      expect(
        () => dataSource.getHourlyForecast(
          latitude: tLatitude,
          longitude: tLongitude,
        ),
        throwsA(isA<OpenMeteoApiException>()),
      );
    });
  });

  group('getDailyForecast', () {
    final tApiResponse = {
      'daily': {
        'time': ['2024-01-15T00:00'],
        'weather_code': [0],
        'temperature_2m_max': [25.0],
        'temperature_2m_min': [15.0],
        'sunrise': ['2024-01-15T07:30'],
        'sunset': ['2024-01-15T18:45'],
        'uv_index_max': [5.0],
        'precipitation_sum': [0.0],
        'precipitation_probability_max': [10.0],
      },
    };

    test('should return DailyForecastModel when response is 200', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn(tApiResponse);
      when(
        () => mockDio.get(
          '/forecast',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await dataSource.getDailyForecast(
        latitude: tLatitude,
        longitude: tLongitude,
      );

      expect(result.dates.length, 1);
      expect(result.temperatureMaxes[0], 25.0);
    });

    test('should throw OpenMeteoApiException when response is not 200',
        () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(503);
      when(
        () => mockDio.get(
          '/forecast',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => mockResponse);

      expect(
        () => dataSource.getDailyForecast(
          latitude: tLatitude,
          longitude: tLongitude,
        ),
        throwsA(isA<OpenMeteoApiException>()),
      );
    });
  });
}
