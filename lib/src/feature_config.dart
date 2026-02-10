import 'dart:convert';

import 'package:dynafeat/src/config_validator.dart';
import 'package:dynafeat/src/feature.dart';
import 'package:dynafeat/src/feature_context.dart';

import 'operation.dart';

/// Represents the root configuration for the Dynafeat system.
///
/// This class holds all global definitions, including available [context]
/// variables and the [features] themselves. It also manages the global
/// revision [rev] to handle configuration updates.
final class FeatureConfig {
  /// The global revision of the configuration.
  ///
  /// Used to determine if the local configuration needs an update
  /// when a new version is received from a server.
  final int rev;

  /// A list of context variables defined for this configuration.
  ///
  /// These variables are used in feature rules to evaluate conditions.
  final List<Context> context;

  /// A list of features available in this configuration.
  final List<Feature> features;

  /// Creates a new [FeatureConfig] instance.
  FeatureConfig({
    required this.rev,
    required this.features,
    this.context = const [],
  });

  /// Imports a [FeatureConfig] from a raw [Map].
  ///
  /// This factory is typically used when parsing JSON data received
  /// from a remote API or local storage.
  factory FeatureConfig.import(Map<String, dynamic> value) {
    final rev = value['rev'] as int;
    List<Context> context = [];

    if (value.containsKey('context')) {
      final data = value['context'] as List;
      for (final rec in data) {
        context.add(Context.import(rec));
      }
    }

    if (!value.containsKey('features')) {
      throw ArgumentError();
    }

    final data = value['features'] as List? ?? [];
    List<Feature> features = [];
    for (final rec in data) {
      features.add(Feature.import(rec));
    }

    return FeatureConfig(rev: rev, context: context, features: features);
  }

  /// Exports the current configuration to a serializable [Map].
  ///
  /// The resulting map follows the Dynafeat specification, suitable
  /// for JSON serialization.
  Map<String, dynamic> export() {
    return {
      'rev': rev,
      if (context.isNotEmpty)
        'context': context.map((e) => e.export()).toList(),
      'features': features.map((e) => e.export()).toList(),
    };
  }

  /// Converts the configuration to a JSON string.
  ///
  /// If [pretty] is set to true, the output will be formatted with
  /// two-space indentation for better readability.
  String toJson({bool pretty = false}) {
    if (pretty) {
      final encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(export());
    }
    return jsonEncode(export());
  }

  /// Validates the entire configuration for logical consistency.
  ///
  /// This includes checking for duplicate feature IDs, ensuring all
  /// context variables used in rules are defined, and verifying
  /// feature value types.
  ///
  /// Throws an [UnimplementedError] in the current version.
  void validate() {
    ConfigValidator(this).check();
  }
}
