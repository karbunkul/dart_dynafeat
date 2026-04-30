import 'package:dynafeat/src/feature_rule.dart';
import 'package:dynafeat/src/feature_type.dart';

/// Represents a single feature flag definition.
///
/// A [Feature] consists of a unique [id], a [summary] for documentation,
/// its data [type], a default [value], and a list of [rules] for dynamic evaluation.
final class Feature<T extends Object> {
  /// Unique identifier for the feature.
  final String id;

  /// A short description of the feature's purpose.
  final String summary;

  /// The data type of the feature's value.
  final FeatureType type;

  /// A list of rules that can override the default value based on context.
  final List<Rule<T>> rules;

  /// The default value for this feature if no rules match.
  final T value;

  const Feature._({
    required this.id,
    required this.summary,
    required this.type,
    required this.value,
    this.rules = const [],
  });

  /// Validates if the default [value] matches the feature's [type].
  bool validate() => type.validate(value);

  /// Returns true if the feature has any associated rules.
  bool hasRules() => rules.isNotEmpty;

  /// Imports a [Feature] from a raw [Map], typically from JSON.
  ///
  /// Automatically determines the feature's type and parses its rules.
  static Feature import(Map<String, dynamic> value) {
    final id = value['id'] as String;
    final summary = value['summary'] as String;
    final rawType = value['type'] as String? ?? 'string';
    final type = FeatureType.from(rawType);
    final featureVal = value['value'] as Object;
    final rules = value['rules'] as List?;

    return Feature._(
      id: id,
      summary: summary,
      type: type,
      value: featureVal,
      rules: rules?.map((e) => Rule.import(e)).toList() ?? [],
    );
  }

  /// Exports the feature to a serializable [Map].
  Map<String, Object> export() {
    return {
      'id': id,
      'type': type.id,
      'summary': summary,
      if (hasRules()) 'rules': rules.map((e) => e.export()).toList(),
      'value': value,
    };
  }

  /// Creates a string-based feature.
  ///
  /// Example:
  /// ```dart
  /// final feature = Feature.string(
  ///   id: 'api_url',
  ///   summary: 'The base API URL',
  ///   value: 'https://api.example.com',
  /// );
  /// ```
  static Feature<String> string({
    required String id,
    required String summary,
    required String value,
    List<Rule<String>>? rules,
  }) {
    return Feature<String>._(
      id: id,
      summary: summary,
      value: value,
      type: FeatureType.string,
      rules: rules ?? [],
    );
  }

  /// Creates a number-based feature (integer or double).
  static Feature<num> number({
    required String id,
    required String summary,
    required num value,
    List<Rule<num>>? rules,
  }) {
    return Feature<num>._(
      id: id,
      summary: summary,
      value: value,
      type: FeatureType.number,
      rules: rules ?? [],
    );
  }

  /// Creates a boolean feature flag.
  static Feature<bool> boolean({
    required String id,
    required String summary,
    required bool value,
    List<Rule<bool>>? rules,
  }) {
    return Feature<bool>._(
      id: id,
      summary: summary,
      value: value,
      type: FeatureType.boolean,
      rules: rules ?? [],
    );
  }
}
