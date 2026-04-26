import 'package:dio/dio.dart';
import 'package:weather/core/network/dio_client.dart';
import 'package:weather/core/utils/app_logger.dart';
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
      : _dio = dio ?? createDioClient();

  final Dio _dio;

  Future<T> _fetch<T>({
    required String label,
    required Map<String, dynamic> queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      AppLogger.api(label);
      final response = await _dio.get('/forecast', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return fromJson(response.data as Map<String, dynamic>);
      } else {
        throw OpenMeteoApiException('Failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.error('Dio error $label: ${e.message}');
      throw OpenMeteoApiException('Network error: ${e.message}');
    } catch (e) {
      AppLogger.error('Unexpected error $label: $e');
      rethrow;
    }
  }

  /// Fetches current weather data.
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) => _fetch(
        label: 'Fetching current weather',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current':
              'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,weather_code,wind_speed_10m',
          'timezone': 'auto',
        },
        fromJson: WeatherModel.fromJson,
      );

  /// Fetches hourly forecast data.
  Future<HourlyForecastModel> getHourlyForecast({
    required double latitude,
    required double longitude,
  }) => _fetch(
        label: 'Fetching hourly forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'hourly':
              'temperature_2m,precipitation_probability,precipitation,weather_code,wind_speed_10m',
          'forecast_days': 2,
          'timezone': 'auto',
        },
        fromJson: HourlyForecastModel.fromJson,
      );

  /// Fetches daily forecast data.
  Future<DailyForecastModel> getDailyForecast({
    required double latitude,
    required double longitude,
  }) => _fetch(
        label: 'Fetching daily forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'daily':
              'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_sum,precipitation_probability_max',
          'forecast_days': 7,
          'timezone': 'auto',
        },
        fromJson: DailyForecastModel.fromJson,
      );
}
