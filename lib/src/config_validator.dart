import 'package:dynafeat/dynafeat.dart';
import 'package:dynafeat/src/feature_type.dart';
import 'package:dynafeat/src/operation.dart';
import 'package:meta/meta.dart';

@internal
class ConfigValidator {
  final FeatureConfig _config;

  ConfigValidator(this._config);

  late final _context = <String, FeatureType>{
    for (final ctx in _config.context) ctx.id: ctx.type,
  };

  void check() {
    _checkContextDuplicates();
    _checkContextValues();
    _checkFeatures();
  }

  void _checkContextDuplicates() {
    final uniqueIds = _context.keys.toSet();
    if (uniqueIds.length != _config.context.length) {
      final items = <String>[];
      final duplicates = <String>[];
      for (final context in _config.context) {
        if (!items.contains(context.id)) {
          items.add(context.id);
        } else {
          duplicates.add(context.id);
        }
      }
      throw ArgumentError('Duplicate context IDs: ${duplicates.toSet()}');
    }
  }

  void _checkContextValues() {
    for (final context in _config.context) {
      if (context.hasValues()) {
        final values = context.values as Iterable;
        try {
          for (final val in values) {
            if (!context.type.validate(val as Object)) {
              throw ArgumentError(
                'Context "${context.id}" contains invalid value: $val',
              );
            }
          }
        } on TypeError {
          throw ArgumentError(
            'Context "${context.id}" has type mismatch in its values list',
          );
        }
      }
    }
  }

  void _checkFeatures() {
    for (final feature in _config.features) {
      // 1. Дефолтное значение
      if (!feature.type.validate(feature.value)) {
        throw ArgumentError(
          'Feature "${feature.id}" has type mismatch in value property',
        );
      }

      // 2. Значения в правилах
      for (final rule in feature.rules) {
        if (!feature.type.validate(rule.value)) {
          throw ArgumentError(
            'Rule "${rule.summary}" in feature "${feature.id}" returns incompatible type',
          );
        }

        // 3. Условия внутри правил
        for (final cond in rule.conditions) {
          final ctxType = _context[cond.context];

          if (ctxType == null) {
            throw ArgumentError(
              'Feature "${feature.id}" uses undefined context: "${cond.context}"',
            );
          }

          if (!cond.op.types.contains(ctxType)) {
            throw ArgumentError(
              'Operation "${cond.op.op}" in feature "${feature.id}" is incompatible with context "${cond.context}" (${ctxType.id})',
            );
          }
        }
      }
    }
  }
}
