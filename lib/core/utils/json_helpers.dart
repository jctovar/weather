/// JSON parsing helpers for Open-Meteo API responses.
library;

/// Safely converts a dynamic value to double.
/// Returns 0.0 if null or unparseable.
double jsonToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  try {
    return double.parse(value.toString());
  } catch (_) {
    return 0.0;
  }
}

/// Safely converts a dynamic value to int.
/// Returns 0 if null or unparseable.
int jsonToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  try {
    return int.parse(value.toString());
  } catch (_) {
    return 0;
  }
}
