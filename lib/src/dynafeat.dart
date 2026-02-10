import 'package:dynafeat/src/feature.dart';
import 'package:dynafeat/src/feature_config.dart';
import 'package:dynafeat/src/feature_context.dart';
import 'package:dynafeat/src/feature_resolver.dart';
import 'package:meta/meta.dart';

/// The main entry point for the Dynafeat library.
///
/// This class acts as a facade, providing a simple API to access feature flags
/// and manage their resolution logic.
@immutable
base class Dynafeat {
  /// The underlying configuration containing contexts and features.
  final FeatureConfig _config;

  /// Maximum number of items to keep in the resolution cache.
  final int _cacheCount;

  /// Creates a [Dynafeat] instance from raw components.
  ///
  /// [rev] represents the configuration revision.
  /// [context] is a list of available context definitions.
  /// [features] is a list of features with their rules and default values.
  /// [cacheCount] defines how many resolution results should be cached (default is 10).
  Dynafeat({
    required int rev,
    required List<Context> context,
    required List<Feature> features,
    int cacheCount = 10,
  }) : _config = FeatureConfig(rev: rev, context: context, features: features),
       _cacheCount = cacheCount;

  /// Internal resolver instance, lazily initialized on the first access.
  late final _resolver = FeatureResolver(
    config: _config,
    cacheCount: _cacheCount,
  );

  /// Retrieves the value of a feature identified by [id].
  ///
  /// You can optionally provide a [context] map to evaluate specific rules.
  /// The type [T] must match the actual type of the feature's value.
  ///
  /// Example:
  /// ```dart
  /// final port = dynafeat.feature<int>('api_port', context: {'env': 'prod'});
  /// ```
  T feature<T extends Object>(String id, {Map<String, Object>? context}) {
    return _resolver.resolve<T>(featureId: id, context: context);
  }

  /// Validates the current configuration for consistency.
  ///
  /// Checks for issues like duplicate IDs or missing context definitions.
  void validate() {
    _config.validate();
  }

  /// Creates a [Dynafeat] instance directly from a [FeatureConfig] object.
  ///
  /// This is useful when loading configuration from a JSON source.
  factory Dynafeat.from(FeatureConfig value) {
    return Dynafeat(
      rev: value.rev,
      context: value.context,
      features: value.features,
    );
  }
}
