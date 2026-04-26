import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/core/utils/app_logger.dart';
import 'package:weather/features/weather/data/models/daily_forecast_model.dart';
import 'package:weather/features/weather/data/models/hourly_forecast_model.dart';
import 'package:weather/features/weather/data/models/weather_model.dart';

/// Exception thrown when cache operations fail.
class CacheException implements Exception {
  const CacheException(this.message);

  final String message;
}

/// Local cache data source using Hive.
class LocalCacheDataSource {
  LocalCacheDataSource();

  Box<String>? _box;

  /// Initializes the Hive box for caching.
  Future<void> init() async {
    try {
      _box = Hive.isBoxOpen(AppConstants.weatherBoxName)
          ? Hive.box<String>(AppConstants.weatherBoxName)
          : await Hive.openBox<String>(AppConstants.weatherBoxName);
      AppLogger.cache('Cache initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize cache: $e');
      rethrow;
    }
  }

  /// Gets cached weather data if available and not expired.
  Future<WeatherModel?> getCurrentWeather() async {
    try {
      final data = _box?.get(AppConstants.currentWeatherKey);
      if (data == null) return null;

      final cached = jsonDecode(data) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cached['timestamp'] as String);

      if (DateTime.now().difference(timestamp).inSeconds >
          AppConstants.cacheTtlSeconds) {
        AppLogger.cache('Current weather expired, clearing');
        await clearCurrentWeather();
        return null;
      }

      return WeatherModel.fromJson(
        cached['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error reading cache: $e');
      return null;
    }
  }

  /// Saves weather data to cache.
  Future<void> saveCurrentWeather(WeatherModel weather) async {
    try {
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'current': {
            'temperature_2m': weather.temperature,
            'apparent_temperature': weather.apparentTemperature,
            'relative_humidity_2m': weather.humidity,
            'precipitation': weather.precipitation,
            'rain': weather.rain,
            'weather_code': weather.weatherCode,
            'wind_speed_10m': weather.windSpeed,
            'is_day': weather.isDay ? 1 : 0,
            'time': weather.time.toIso8601String(),
          },
        },
      };

      await _box?.put(
        AppConstants.currentWeatherKey,
        jsonEncode(data),
      );
      AppLogger.cache('Current weather cached (${weather.temperature}°C)');
    } catch (e) {
      AppLogger.error('Error saving to cache: $e');
      throw CacheException('Failed to save weather data: $e');
    }
  }

  /// Clears cached current weather.
  Future<void> clearCurrentWeather() async {
    await _box?.delete(AppConstants.currentWeatherKey);
  }

  /// Gets cached hourly forecast if available and not expired.
  Future<HourlyForecastModel?> getHourlyForecast() async {
    try {
      final data = _box?.get(AppConstants.hourlyForecastKey);
      if (data == null) return null;

      final cached = jsonDecode(data) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cached['timestamp'] as String);

      if (DateTime.now().difference(timestamp).inSeconds >
          AppConstants.cacheTtlSeconds) {
        AppLogger.cache('Hourly forecast expired, clearing');
        await clearHourlyForecast();
        return null;
      }

      return HourlyForecastModel.fromJson(
        cached['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error reading hourly forecast cache: $e');
      return null;
    }
  }

  /// Saves hourly forecast to cache.
  Future<void> saveHourlyForecast(HourlyForecastModel forecast) async {
    try {
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'hourly': {
            'time': forecast.times.map((e) => e.toIso8601String()).toList(),
            'temperature_2m': forecast.temperatures,
            'precipitation_probability': forecast.precipitationProbabilities,
            'precipitation': forecast.precipitations,
            'weather_code': forecast.weatherCodes,
            'wind_speed_10m': forecast.windSpeeds,
          },
        },
      };

      await _box?.put(
        AppConstants.hourlyForecastKey,
        jsonEncode(data),
      );
      AppLogger.cache('Hourly forecast cached (${forecast.times.length} entries)');
    } catch (e) {
      AppLogger.error('Error saving hourly forecast to cache: $e');
      throw CacheException('Failed to save hourly forecast: $e');
    }
  }

  /// Clears cached hourly forecast.
  Future<void> clearHourlyForecast() async {
    await _box?.delete(AppConstants.hourlyForecastKey);
  }

  /// Gets cached daily forecast if available and not expired.
  Future<DailyForecastModel?> getDailyForecast() async {
    try {
      final data = _box?.get(AppConstants.dailyForecastKey);
      if (data == null) return null;

      final cached = jsonDecode(data) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cached['timestamp'] as String);

      if (DateTime.now().difference(timestamp).inSeconds >
          AppConstants.cacheTtlSeconds) {
        AppLogger.cache('Daily forecast expired, clearing');
        await clearDailyForecast();
        return null;
      }

      return DailyForecastModel.fromJson(
        cached['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Error reading daily forecast cache: $e');
      return null;
    }
  }

  /// Saves daily forecast to cache.
  Future<void> saveDailyForecast(DailyForecastModel forecast) async {
    try {
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'daily': {
            'time': forecast.dates.map((e) => e.toIso8601String()).toList(),
            'weather_code': forecast.weatherCodes,
            'temperature_2m_max': forecast.temperatureMaxes,
            'temperature_2m_min': forecast.temperatureMins,
            'sunrise': forecast.sunrises.map((e) => e.toIso8601String()).toList(),
            'sunset': forecast.sunsets.map((e) => e.toIso8601String()).toList(),
            'uv_index_max': forecast.uvIndexMaxes,
            'precipitation_sum': forecast.precipitationSums,
            'precipitation_probability_max':
                forecast.precipitationProbabilityMaxes,
          },
        },
      };

      await _box?.put(
        AppConstants.dailyForecastKey,
        jsonEncode(data),
      );
      AppLogger.cache('Daily forecast cached (${forecast.dates.length} days)');
    } catch (e) {
      AppLogger.error('Error saving daily forecast to cache: $e');
      throw CacheException('Failed to save daily forecast: $e');
    }
  }

  /// Clears cached daily forecast.
  Future<void> clearDailyForecast() async {
    await _box?.delete(AppConstants.dailyForecastKey);
  }

  /// Clears all cached data.
  Future<void> clearAll() async {
    await _box?.clear();
    AppLogger.cache('All cache cleared');
  }
}
