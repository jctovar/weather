import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/features/weather/data/datasources/local_cache_datasource.dart';
import 'package:weather/features/weather/data/models/weather_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Hive.init('.hive_test');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('LocalCacheDataSource', () {
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

    setUp(() async {
      final box = await Hive.openBox<String>(AppConstants.weatherBoxName);
      await box.clear();
    });

    tearDown(() async {
      if (Hive.isBoxOpen(AppConstants.weatherBoxName)) {
        await Hive.box<String>(AppConstants.weatherBoxName).clear();
      }
    });

    test('should save and retrieve current weather from Hive', () async {
      final dataSource = LocalCacheDataSource();
      await dataSource.init();
      await dataSource.saveCurrentWeather(tWeatherModel);

      final result = await dataSource.getCurrentWeather();

      expect(result, isNotNull);
      expect(result!.temperature, 22.5);
      expect(result.apparentTemperature, 20.0);
      expect(result.humidity, 65);
    });

    test('should return null when cache is empty', () async {
      final dataSource = LocalCacheDataSource();
      await dataSource.init();

      final result = await dataSource.getCurrentWeather();

      expect(result, isNull);
    });

    test('should return null when cache is expired', () async {
      final box = Hive.box<String>(AppConstants.weatherBoxName);

      final expiredTimestamp = DateTime.now().subtract(
        const Duration(seconds: 3601),
      );
      final expiredData = {
        'timestamp': expiredTimestamp.toIso8601String(),
        'data': {
          'current': {
            'temperature_2m': 20.0,
            'apparent_temperature': 18.0,
            'relative_humidity_2m': 50,
            'precipitation': 0.0,
            'rain': 0.0,
            'weather_code': 0,
            'wind_speed_10m': 10.0,
            'is_day': 1,
            'time': '2024-01-15T12:00',
          },
        },
      };

      await box.put(
        AppConstants.currentWeatherKey,
        jsonEncode(expiredData),
      );

      final dataSource = LocalCacheDataSource();
      await dataSource.init();

      final result = await dataSource.getCurrentWeather();

      expect(result, isNull);
    });

    test('should clear current weather', () async {
      final dataSource = LocalCacheDataSource();
      await dataSource.init();
      await dataSource.saveCurrentWeather(tWeatherModel);

      await dataSource.clearCurrentWeather();

      final result = await dataSource.getCurrentWeather();
      expect(result, isNull);
    });

    test('should clear all cache', () async {
      final dataSource = LocalCacheDataSource();
      await dataSource.init();
      await dataSource.saveCurrentWeather(tWeatherModel);

      await dataSource.clearAll();

      final result = await dataSource.getCurrentWeather();
      expect(result, isNull);
    });
  });
}
