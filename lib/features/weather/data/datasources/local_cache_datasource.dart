import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/core/utils/app_logger.dart';
import 'package:weather/features/weather/data/models/daily_forecast_model.dart';
import 'package:weather/features/weather/data/models/hourly_forecast_model.dart';
import 'package:weather/features/weather/data/models/weather_model.dart';
import 'package:flutter/foundation.dart';

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

  // ── Generic helpers ───────────────────────────────────────────

  Future<T?> _get<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
    String label,
  ) async {
    try {
      final data = _box?.get(key);
      if (data == null) return null;

      final cached =
          await compute(jsonDecode, data) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cached['timestamp'] as String);

      if (DateTime.now().difference(timestamp).inSeconds >
          AppConstants.cacheTtlSeconds) {
        AppLogger.cache('$label expired, clearing');
        await _box?.delete(key);
        return null;
      }

      return fromJson(cached['data'] as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Error reading $label cache: $e');
      return null;
    }
  }

  Future<void> _save(
    String key,
    Map<String, dynamic> data,
    String logMessage,
  ) async {
    try {
      final payload = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      };
      final encoded = await compute(jsonEncode, payload);
      await _box?.put(key, encoded);
      AppLogger.cache(logMessage);
    } catch (e) {
      AppLogger.error('Error saving to cache: $e');
      throw CacheException('Failed to save: $e');
    }
  }

  // ── Current weather ───────────────────────────────────────────

  Future<WeatherModel?> getCurrentWeather() => _get(
        AppConstants.currentWeatherKey,
        WeatherModel.fromJson,
        'Current weather',
      );

  Future<void> saveCurrentWeather(WeatherModel weather) => _save(
        AppConstants.currentWeatherKey,
        {
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
        'Current weather cached (${weather.temperature}°C)',
      );

  Future<void> clearCurrentWeather() async {
    await _box?.delete(AppConstants.currentWeatherKey);
  }

  // ── Hourly forecast ───────────────────────────────────────────

  Future<HourlyForecastModel?> getHourlyForecast() => _get(
        AppConstants.hourlyForecastKey,
        HourlyForecastModel.fromJson,
        'Hourly forecast',
      );

  Future<void> saveHourlyForecast(HourlyForecastModel forecast) => _save(
        AppConstants.hourlyForecastKey,
        {
          'hourly': {
            'time': forecast.times.map((e) => e.toIso8601String()).toList(),
            'temperature_2m': forecast.temperatures,
            'precipitation_probability': forecast.precipitationProbabilities,
            'precipitation': forecast.precipitations,
            'weather_code': forecast.weatherCodes,
            'wind_speed_10m': forecast.windSpeeds,
          },
        },
        'Hourly forecast cached (${forecast.times.length} entries)',
      );

  Future<void> clearHourlyForecast() async {
    await _box?.delete(AppConstants.hourlyForecastKey);
  }

  // ── Daily forecast ────────────────────────────────────────────

  Future<DailyForecastModel?> getDailyForecast() => _get(
        AppConstants.dailyForecastKey,
        DailyForecastModel.fromJson,
        'Daily forecast',
      );

  Future<void> saveDailyForecast(DailyForecastModel forecast) => _save(
        AppConstants.dailyForecastKey,
        {
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
        'Daily forecast cached (${forecast.dates.length} days)',
      );

  Future<void> clearDailyForecast() async {
    await _box?.delete(AppConstants.dailyForecastKey);
  }

  // ── Last known location (for background tasks) ──────────────

  /// Persists the last known coordinates for background use.
  Future<void> saveLastLocation(double latitude, double longitude) async {
    try {
      await _box?.put(
        AppConstants.lastLocationKey,
        jsonEncode({'lat': latitude, 'lon': longitude}),
      );
      AppLogger.cache('Last location saved');
    } catch (e) {
      AppLogger.error('Error saving last location: $e');
    }
  }

  /// Reads the last known coordinates from cache.
  ({double lat, double lon})? getLastLocation() {
    try {
      final data = _box?.get(AppConstants.lastLocationKey);
      if (data == null) return null;
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      return (
        lat: (decoded['lat'] as num).toDouble(),
        lon: (decoded['lon'] as num).toDouble(),
      );
    } catch (e) {
      AppLogger.error('Error reading last location: $e');
      return null;
    }
  }

  // ── All cache ─────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _box?.clear();
    AppLogger.cache('All cache cleared');
  }
}
