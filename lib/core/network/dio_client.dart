import 'package:dio/dio.dart';

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
    LogInterceptor(
      request: false,
      requestHeader: false,
      responseBody: false,
      error: true,
    ),
  );

  return dio;
}
