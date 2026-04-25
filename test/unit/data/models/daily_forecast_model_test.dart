import 'package:flutter_test/flutter_test.dart';
import 'package:weather/features/weather/data/models/daily_forecast_model.dart';
import 'package:weather/features/weather/domain/entities/daily_forecast.dart';

void main() {
  group('DailyForecastModel', () {
    final tJson = {
      'daily': {
        'time': ['2024-01-15T00:00', '2024-01-16T00:00'],
        'weather_code': [0, 1],
        'temperature_2m_max': [25.0, 26.0],
        'temperature_2m_min': [15.0, 16.0],
        'sunrise': ['2024-01-15T07:30', '2024-01-16T07:30'],
        'sunset': ['2024-01-15T18:45', '2024-01-16T18:45'],
        'uv_index_max': [5.0, 6.0],
        'precipitation_sum': [0.0, 2.0],
        'precipitation_probability_max': [10.0, 30.0],
      },
    };

    test('should parse from JSON correctly', () {
      final model = DailyForecastModel.fromJson(tJson);

      expect(model.dates.length, 2);
      expect(model.dates[0], DateTime.parse('2024-01-15T00:00'));
      expect(model.weatherCodes, [0, 1]);
      expect(model.temperatureMaxes, [25.0, 26.0]);
      expect(model.temperatureMins, [15.0, 16.0]);
      expect(model.sunrises[0], DateTime.parse('2024-01-15T07:30'));
      expect(model.sunsets[0], DateTime.parse('2024-01-15T18:45'));
      expect(model.uvIndexMaxes, [5.0, 6.0]);
      expect(model.precipitationSums, [0.0, 2.0]);
      expect(model.precipitationProbabilityMaxes, [10.0, 30.0]);
    });

    test('should convert to entity list', () {
      final model = DailyForecastModel.fromJson(tJson);
      final entities = model.toEntityList();

      expect(entities.length, 2);
      expect(entities[0], isA<DailyForecast>());
      expect(entities[0].date, DateTime.parse('2024-01-15T00:00'));
      expect(entities[0].weatherCode, 0);
      expect(entities[0].temperatureMax, 25.0);
      expect(entities[0].temperatureMin, 15.0);
      expect(entities[0].sunrise, DateTime.parse('2024-01-15T07:30'));
      expect(entities[0].sunset, DateTime.parse('2024-01-15T18:45'));
      expect(entities[0].uvIndexMax, 5.0);
      expect(entities[0].precipitationSum, 0.0);
      expect(entities[0].precipitationProbabilityMax, 10.0);
    });

    test('should handle empty daily data', () {
      final json = {
        'daily': {
          'time': <String>[],
          'weather_code': <int>[],
          'temperature_2m_max': <double>[],
          'temperature_2m_min': <double>[],
          'sunrise': <String>[],
          'sunset': <String>[],
          'uv_index_max': <double>[],
          'precipitation_sum': <double>[],
          'precipitation_probability_max': <double>[],
        },
      };

      final model = DailyForecastModel.fromJson(json);
      final entities = model.toEntityList();

      expect(entities, isEmpty);
    });

    test('should handle string numbers in JSON', () {
      final json = {
        'daily': {
          'time': ['2024-01-15T00:00'],
          'weather_code': ['0'],
          'temperature_2m_max': ['25.0'],
          'temperature_2m_min': ['15.0'],
          'sunrise': ['2024-01-15T07:30'],
          'sunset': ['2024-01-15T18:45'],
          'uv_index_max': ['5.0'],
          'precipitation_sum': ['0.0'],
          'precipitation_probability_max': ['10.0'],
        },
      };

      final model = DailyForecastModel.fromJson(json);

      expect(model.temperatureMaxes[0], 25.0);
      expect(model.weatherCodes[0], 0);
    });
  });
}
