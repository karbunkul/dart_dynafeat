import 'package:dynafeat/src/feature_config.dart';
import 'package:meta/meta.dart';

/// Internal resolver responsible for evaluating feature values based on the provided configuration.
///
/// It uses a simple LRU-like (Least Recently Used) caching mechanism to optimize
/// repeated resolutions with the same context.
@immutable
@internal
final class FeatureResolver {
  /// Creates a new [FeatureResolver] with a [config] and an optional [cacheCount].
  ///
  /// The [cacheCount] defaults to 10 entries.
  FeatureResolver({required FeatureConfig config, int cacheCount = 10})
    : _config = config,
      _cacheCount = cacheCount;

  /// Internal storage for cached resolution results.
  final Map<String, Object> _cache = {};

  /// The active feature configuration.
  final FeatureConfig _config;

  /// Maximum number of entries allowed in the cache.
  final int _cacheCount;

  /// Resolves the value of a feature by its [featureId] using an optional [context].
  ///
  /// The process follows these steps:
  /// 1. Checks if the result is already in the cache.
  /// 2. Finds the feature in the configuration.
  /// 3. If the feature has no rules, returns the default value.
  /// 4. If a context is provided, evaluates rules in order until a match is found.
  /// 5. Falls back to the feature's default value if no rules match.
  ///
  /// Throws a [StateError] if the [featureId] is not found.
  T resolve<T extends Object>({
    required String featureId,
    Map<String, Object>? context,
  }) {
    final cacheKey = _cacheKey(featureId, context);
    final cached = _fromCache(cacheKey);

    if (cached != null) {
      return cached as T;
    }

    // Find the feature by ID.
    // Consider adding orElse for custom error handling in the future.
    final feature = _config.features.firstWhere((e) => e.id == featureId);

    // If no rules are defined, return and cache the default value.
    if (!feature.hasRules()) {
      _addToCache(cacheKey, feature.value);
      return feature.value as T;
    }

    // Evaluate rules if context is available.
    if (context != null) {
      for (final rule in feature.rules) {
        final res = rule.resolve(context);

        if (res != null) {
          _addToCache(cacheKey, res);
          return res as T;
        }
      }
    }

    // Fallback to the default feature value.
    final value = feature.value as T;
    _addToCache(cacheKey, value);
    return value;
  }

  /// Adds a [value] to the cache with the given [key].
  ///
  /// If the cache exceeds [_cacheCount], the oldest entry is removed.
  void _addToCache(String key, Object value) {
    if (_cache.length >= _cacheCount) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Generates a unique cache key based on the [featureId] and [context] entries.
  String _cacheKey(String featureId, Map<String, Object>? context) {
    final payload = context?.entries.fold('', (prev, element) {
      return '$prev${element.key}-${element.value.toString()}';
    });

    return '$featureId|$payload';
  }

  /// Retrieves an object from the cache by its [key].
  Object? _fromCache(String key) {
    return _cache[key];
  }
}
