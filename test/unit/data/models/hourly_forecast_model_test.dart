import 'package:flutter_test/flutter_test.dart';
import 'package:weather/features/weather/data/models/hourly_forecast_model.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';

void main() {
  group('HourlyForecastModel', () {
    final tJson = {
      'hourly': {
        'time': ['2024-01-15T12:00', '2024-01-15T13:00'],
        'temperature_2m': [20.0, 21.0],
        'precipitation_probability': [10.0, 20.0],
        'precipitation': [0.0, 0.5],
        'weather_code': [0, 1],
        'wind_speed_10m': [10.0, 12.0],
      },
    };

    test('should parse from JSON correctly', () {
      final model = HourlyForecastModel.fromJson(tJson);

      expect(model.times.length, 2);
      expect(model.times[0], DateTime.parse('2024-01-15T12:00'));
      expect(model.temperatures, [20.0, 21.0]);
      expect(model.precipitationProbabilities, [10.0, 20.0]);
      expect(model.precipitations, [0.0, 0.5]);
      expect(model.weatherCodes, [0, 1]);
      expect(model.windSpeeds, [10.0, 12.0]);
    });

    test('should convert to entity list', () {
      final model = HourlyForecastModel.fromJson(tJson);
      final entities = model.toEntityList();

      expect(entities.length, 2);
      expect(entities[0], isA<HourlyForecast>());
      expect(entities[0].time, DateTime.parse('2024-01-15T12:00'));
      expect(entities[0].temperature, 20.0);
      expect(entities[0].precipitationProbability, 10.0);
      expect(entities[0].precipitation, 0.0);
      expect(entities[0].weatherCode, 0);
      expect(entities[0].windSpeed, 10.0);
    });

    test('should handle empty hourly data', () {
      final json = {
        'hourly': {
          'time': <String>[],
          'temperature_2m': <double>[],
          'precipitation_probability': <double>[],
          'precipitation': <double>[],
          'weather_code': <int>[],
          'wind_speed_10m': <double>[],
        },
      };

      final model = HourlyForecastModel.fromJson(json);
      final entities = model.toEntityList();

      expect(entities, isEmpty);
    });

    test('should handle string numbers in JSON', () {
      final json = {
        'hourly': {
          'time': ['2024-01-15T12:00'],
          'temperature_2m': ['20.0'],
          'precipitation_probability': ['10.0'],
          'precipitation': ['0.0'],
          'weather_code': ['0'],
          'wind_speed_10m': ['10.0'],
        },
      };

      final model = HourlyForecastModel.fromJson(json);

      expect(model.temperatures[0], 20.0);
      expect(model.weatherCodes[0], 0);
    });
  });
}
