int parseInt(dynamic value, [int? fallback]) {
  if (value == null) {
    if (fallback != null) return fallback;
    throw TypeError();
  }
  if (value is int) return value;
  if (value is String) return int.parse(value);
  throw TypeError();
}
