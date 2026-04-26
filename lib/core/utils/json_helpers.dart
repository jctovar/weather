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

/// Validates that [value] is a non-null [Map<String, dynamic>].
/// Throws [FormatException] with [field] context otherwise.
Map<String, dynamic> requireMap(dynamic value, String field) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Expected Map for "$field", got ${value.runtimeType}');
}

/// Validates that [value] is a non-null [List<dynamic>].
/// Throws [FormatException] with [field] context otherwise.
List<dynamic> requireList(dynamic value, String field) {
  if (value is List<dynamic>) return value;
  throw FormatException('Expected List for "$field", got ${value.runtimeType}');
}
