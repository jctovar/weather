/// Base failure class for domain errors.
abstract class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Failure when network request fails.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure when cache data is not available.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure when location permission is denied.
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}
