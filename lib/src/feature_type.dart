/// Defines the supported data types for features within the Dynafeat ecosystem.
///
/// Each type includes its serializable string representation and
/// validation logic to ensure runtime type safety.
enum FeatureType {
  /// A plain text string value.
  string('string'),

  /// A numeric value (integer or double).
  number('num'),

  /// A boolean flag.
  boolean('bool');

  /// The string identifier used for serialization and configuration matching.
  final String id;

  const FeatureType(this.id);

  /// Creates a [FeatureType] from a string [value].
  ///
  /// Performs a case-insensitive search and trims whitespace.
  /// Defaults to [FeatureType.string] if no match is found.
  factory FeatureType.from(String value) {
    return values.firstWhere(
      (e) => e.id == value.trim().toLowerCase(),
      orElse: () => string,
    );
  }

  /// Validates whether the given [value] matches this [FeatureType].
  ///
  /// * [string] checks if value is [String].
  /// * [number] checks if value is [num].
  /// * [boolean] checks if value is [bool].
  bool validate(Object value) {
    return switch (this) {
      FeatureType.string => value is String,
      FeatureType.number => value is num,
      FeatureType.boolean => value is bool,
    };
  }
}
