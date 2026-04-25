import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:weather/core/network/dio_client.dart';
import 'package:weather/features/weather/data/models/daily_forecast_model.dart';
import 'package:weather/features/weather/data/models/hourly_forecast_model.dart';
import 'package:weather/features/weather/data/models/weather_model.dart';

/// Exception thrown when API request fails.
class OpenMeteoApiException implements Exception {
  const OpenMeteoApiException(this.message);

  final String message;
}

/// Data source for fetching weather data from Open-Meteo API.
class OpenMeteoApiDataSource {
  OpenMeteoApiDataSource({Dio? dio})
      : _dio = dio ?? createDioClient(),
        _logger = Logger();

  final Dio _dio;
  final Logger _logger;

  /// Fetches current weather data.
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      _logger.d('Fetching current weather for ($latitude, $longitude)');

      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current':
              'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,weather_code,wind_speed_10m',
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw OpenMeteoApiException(
          'Failed to fetch weather: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Dio error fetching weather: ${e.message}');
      throw OpenMeteoApiException('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error fetching weather: $e');
      rethrow;
    }
  }

  /// Fetches hourly forecast data.
  Future<HourlyForecastModel> getHourlyForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      _logger.d('Fetching hourly forecast for ($latitude, $longitude)');

      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'hourly':
              'temperature_2m,precipitation_probability,precipitation,weather_code,wind_speed_10m',
          'forecast_days': 2,
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200) {
        return HourlyForecastModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw OpenMeteoApiException(
          'Failed to fetch hourly forecast: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Dio error fetching hourly forecast: ${e.message}');
      throw OpenMeteoApiException('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error fetching hourly forecast: $e');
      rethrow;
    }
  }

  /// Fetches daily forecast data.
  Future<DailyForecastModel> getDailyForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      _logger.d('Fetching daily forecast for ($latitude, $longitude)');

      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'daily':
              'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_sum,precipitation_probability_max',
          'forecast_days': 7,
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200) {
        return DailyForecastModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw OpenMeteoApiException(
          'Failed to fetch daily forecast: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Dio error fetching daily forecast: ${e.message}');
      throw OpenMeteoApiException('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error fetching daily forecast: $e');
      rethrow;
    }
  }
}
