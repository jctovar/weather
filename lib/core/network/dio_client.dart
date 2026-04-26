import 'package:dio/dio.dart';
import 'package:weather/core/utils/app_logger.dart';

/// Configures and returns a Dio instance for Open-Meteo API.
Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.open-meteo.com/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.api('${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.info('✅ ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.error('❌ ${error.response?.statusCode ?? 'N/A'} ${error.requestOptions.uri}: ${error.message}');
        handler.next(error);
      },
    ),
  );

  return dio;
}
