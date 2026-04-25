import 'package:flutter_test/flutter_test.dart';
import 'package:weather/core/error/failures.dart';

void main() {
  group('Failure', () {
    test('NetworkFailure has correct message', () {
      const failure = NetworkFailure('No internet');
      expect(failure.message, 'No internet');
      expect(failure.toString(), 'No internet');
    });

    test('CacheFailure has correct message', () {
      const failure = CacheFailure('Cache corrupted');
      expect(failure.message, 'Cache corrupted');
      expect(failure.toString(), 'Cache corrupted');
    });

    test('LocationFailure has correct message', () {
      const failure = LocationFailure('Permission denied');
      expect(failure.message, 'Permission denied');
      expect(failure.toString(), 'Permission denied');
    });
  });
}
