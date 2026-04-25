import 'package:flutter_test/flutter_test.dart';
import 'package:weather/features/weather/data/models/weather_model.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';

void main() {
  group('WeatherModel', () {
    final tJson = {
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

    test('should parse from JSON correctly', () {
      final model = WeatherModel.fromJson(tJson);

      expect(model.temperature, 22.5);
      expect(model.apparentTemperature, 20.0);
      expect(model.humidity, 65);
      expect(model.precipitation, 0.0);
      expect(model.rain, 0.0);
      expect(model.weatherCode, 0);
      expect(model.windSpeed, 12.3);
      expect(model.isDay, true);
      expect(model.time, DateTime.parse('2024-01-15T12:00'));
    });

    test('should parse is_day=0 as false', () {
      final json = {
        'current': {
          ...tJson['current'] as Map<String, dynamic>,
          'is_day': 0,
        },
      };

      final model = WeatherModel.fromJson(json);
      expect(model.isDay, false);
    });

    test('should handle null values with defaults', () {
      final json = {
        'current': {
          'temperature_2m': null,
          'apparent_temperature': null,
          'relative_humidity_2m': null,
          'precipitation': null,
          'rain': null,
          'weather_code': null,
          'wind_speed_10m': null,
          'is_day': 1,
          'time': '2024-01-15T12:00',
        },
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temperature, 0.0);
      expect(model.apparentTemperature, 0.0);
      expect(model.humidity, 0);
      expect(model.precipitation, 0.0);
      expect(model.rain, 0.0);
      expect(model.weatherCode, 0);
      expect(model.windSpeed, 0.0);
    });

    test('should convert to domain entity', () {
      final model = WeatherModel.fromJson(tJson);
      final entity = model.toEntity();

      expect(entity, isA<Weather>());
      expect(entity.temperature, 22.5);
      expect(entity.apparentTemperature, 20.0);
      expect(entity.humidity, 65);
      expect(entity.precipitation, 0.0);
      expect(entity.rain, 0.0);
      expect(entity.weatherCode, 0);
      expect(entity.windSpeed, 12.3);
      expect(entity.isDay, true);
      expect(entity.time, DateTime.parse('2024-01-15T12:00'));
    });

    test('should parse string numbers correctly', () {
      final json = {
        'current': {
          'temperature_2m': '22.5',
          'apparent_temperature': '20.0',
          'relative_humidity_2m': '65',
          'precipitation': '0.0',
          'rain': '0.0',
          'weather_code': '0',
          'wind_speed_10m': '12.3',
          'is_day': 1,
          'time': '2024-01-15T12:00',
        },
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temperature, 22.5);
      expect(model.humidity, 65);
    });
  });
}
