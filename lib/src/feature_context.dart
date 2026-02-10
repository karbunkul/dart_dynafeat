import 'feature_type.dart';

/// Represents a contextual variable used to evaluate feature rules.
///
/// A [Context] defines a property (like 'platform', 'version', or 'is_internal')
/// that can be used in rules to provide dynamic values for features.
final class Context<T> {
  /// Unique identifier for the context variable.
  final String id;

  /// A short description explaining the purpose of this context.
  final String summary;

  /// The data type of the context values.
  final FeatureType type;

  /// Optional revision number for tracking changes.
  // final int? rev;

  /// A list of predefined or allowed values for this context (optional).
  final List<T>? values;

  const Context._({
    required this.id,
    required this.summary,
    required this.type,
    required this.values,
    // this.rev,
  });

  /// Creates a [String] based context.
  ///
  /// Example: `Context.string(id: 'env', summary: 'Environment', values: ['prod', 'dev'])`
  static Context<String> string({
    required String id,
    required String summary,
    List<String>? values,
    int? rev,
  }) {
    return Context<String>._(
      id: id,
      summary: summary,
      type: FeatureType.string,
      // rev: rev,
      values: values,
    );
  }

  /// Creates a [num] based context (integer or double).
  static Context<num> number({
    required String id,
    required String summary,
    List<num>? values,
    int? rev,
  }) {
    return Context<num>._(
      id: id,
      summary: summary,
      type: FeatureType.number,
      // rev: rev,
      values: values,
    );
  }

  /// Creates a [bool] based context.
  ///
  /// Note: Boolean contexts typically don't require a [values] list.
  static Context<bool> boolean({
    required String id,
    required String summary,
    int? rev,
  }) {
    return Context<bool>._(
      id: id,
      summary: summary,
      type: FeatureType.boolean,
      // rev: rev,
      values: [],
    );
  }

  /// Imports a [Context] from a [Map], typically from JSON.
  ///
  /// Automatically determines the specific generic type based on the 'type' field.
  static Context import(Map<String, dynamic> value) {
    final type = FeatureType.from(value['type'] ?? 'string');
    final id = value['id'];
    final summary = value['summary'];
    final values = value['values'] as List?;
    final rev = value['rev'];

    return switch (type) {
      FeatureType.string => Context.string(
        id: id,
        rev: rev,
        summary: summary,
        values: values?.cast<String>(),
      ),
      FeatureType.number => Context.number(
        id: id,
        rev: rev,
        summary: summary,
        values: values?.cast<int>(),
      ),
      FeatureType.boolean => Context.boolean(
        id: id,
        rev: rev,
        summary: summary,
      ),
    };
  }

  /// Exports the [Context] to a serializable [Map].
  Map<String, Object> export() {
    return {
      'id': id,
      'summary': summary,
      'type': type.id, // Using the internal identifier for export
      // if (hasRev()) 'rev': rev!,
      if (hasValues()) 'values': values!,
    };
  }

  /// Returns true if there are predefined values associated with this context.
  bool hasValues() {
    return values?.isNotEmpty == true;
  }

  /// Returns true if a revision number is assigned.
  // bool hasRev() => rev != null;
}
