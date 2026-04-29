import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/core/network/dio_client.dart';

/// Provider for a singleton Dio instance.
final dioProvider = Provider<Dio>((ref) {
  return createDioClient();
});
