import 'package:dynafeat/src/feature_type.dart';

/// Defines logical operations used to compare context variables with rule values.
///
/// Each operation specifies which [FeatureType]s it supports and provides
/// its own resolution logic.
enum Operation {
  /// Checks if context value is strictly equal to the rule value.
  eq(
    op: 'eq',
    types: [FeatureType.string, FeatureType.number, FeatureType.boolean],
  ),

  /// Checks if context value is not equal to the rule value.
  neq(
    op: 'neq',
    types: [FeatureType.string, FeatureType.number, FeatureType.boolean],
  ),

  /// Checks if the context string contains the rule value as a substring.
  contains(op: 'contains', types: [FeatureType.string]),

  /// Checks if the context value exists within a list of values.
  any(op: 'any', types: [FeatureType.string, FeatureType.number]),

  /// Checks if the context string starts with the rule value.
  start(op: 'start', types: [FeatureType.string]),

  /// Checks if the context string ends with the rule value.
  end(op: 'end', types: [FeatureType.string]),

  /// Matches the context string against a regular expression pattern.
  pattern(op: 'pattern', types: [FeatureType.string]),

  /// Checks if a number falls within a range: `[min, max]` (inclusive).
  range(op: 'range', types: [FeatureType.number]),

  /// Checks if the context number is strictly less than the rule value.
  less(op: 'less', types: [FeatureType.number]),

  /// Checks if the context number is strictly greater than the rule value.
  greater(op: 'greater', types: [FeatureType.number]);

  /// The string identifier used for serialization (e.g., in JSON).
  final String op;

  /// The list of [FeatureType]s that are compatible with this operation.
  final List<FeatureType> types;

  const Operation({required this.op, required this.types});

  /// Evaluates the operation against a [context] value and a rule [value].
  ///
  /// Returns `true` if the condition is met, `false` otherwise.
  /// If the [value] payload is invalid for the operation, it returns `false`.
  bool resolve({required Object context, required Object value}) {
    final isValid = _validatePayload(value);
    if (!isValid) return false;

    return switch (this) {
      Operation.eq => context == value,
      Operation.neq => context != value,
      Operation.contains => _opContains(context, value),
      Operation.any => _opAny(context, value),
      Operation.start => _opStart(context, value),
      Operation.end => _opEnd(context, value),
      Operation.pattern => _opPattern(context, value),
      Operation.range => _opRange(context, value),
      Operation.less => _opLess(context, value),
      Operation.greater => _opGreater(context, value),
    };
  }

  /// Creates a [Operation] from a string [value].
  ///
  /// Performs a case-insensitive search and trims whitespace.
  /// Defaults to [Operation.eq] if no match is found.
  factory Operation.from(String value) {
    return values.firstWhere(
      (e) => e.op == value.trim().toLowerCase(),
      orElse: () => eq,
    );
  }

  /// Internal guard to ensure the [value] provided in the rule matches
  /// the expected format for the current [Operation].
  bool _validatePayload(Object value) {
    return switch (this) {
      Operation.eq => value is String || value is num || value is bool,
      Operation.neq => value is String || value is num || value is bool,
      Operation.contains => value is String,
      Operation.any =>
        value is List &&
            value.isNotEmpty &&
            (value.every((e) => e is String) || value.every((e) => e is num)),
      Operation.start => value is String,
      Operation.end => value is String,
      Operation.pattern => value is String,
      Operation.range =>
        value is List && value.every((e) => e is num) && value.length == 2,
      Operation.less => value is num,
      Operation.greater => value is num,
    };
  }

  // --- Implementation Details ---

  bool _opStart(Object context, Object value) {
    final str = context as String;
    final castValue = value as String;
    return str.startsWith(castValue);
  }

  bool _opEnd(Object context, Object value) {
    final str = context as String;
    final castValue = value as String;
    return str.endsWith(castValue);
  }

  bool _opPattern(Object context, Object value) {
    return RegExp(value as String).hasMatch(context as String);
  }

  bool _opContains(Object context, Object value) {
    return context.toString().contains(value.toString());
  }

  bool _opAny(Object context, Object value) {
    return (value as List).contains(context);
  }

  bool _opRange(Object context, Object value) {
    final list = value as List;
    final numContext = context as num;
    return numContext >= (list[0] as num) && numContext <= (list[1] as num);
  }

  bool _opLess(Object context, Object value) {
    return (context as num) < (value as num);
  }

  bool _opGreater(Object context, Object value) {
    return (context as num) > (value as num);
  }
}
