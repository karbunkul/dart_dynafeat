import 'package:dynafeat/src/feature_rule.dart';
import 'package:dynafeat/src/feature_type.dart';

final class Feature<T extends Object> {
  final String id;
  final String summary;
  final FeatureType type;
  final List<Rule<T>> rules;
  // final int? rev;
  final T value;

  const Feature._({
    required this.id,
    required this.summary,
    required this.type,
    // required this.rev,
    required this.value,
    this.rules = const [],
  });

  bool validate() => type.validate(value);

  bool hasRules() => rules.isNotEmpty;
  // bool hasRev() => rev != null;

  static Feature import(Map<String, dynamic> value) {
    final id = value['id'] as String;
    final summary = value['summary'] as String;
    final rawType = value['type'] as String? ?? 'string';
    final type = FeatureType.from(rawType);
    final rev = value['rev'] as int?;
    final featureVal = value['value'] as Object;
    final rules = value['rules'] as List?;

    return Feature._(
      id: id,
      summary: summary,
      type: type,
      // rev: rev,
      value: featureVal,
      rules: rules?.map((e) => Rule.import(e)).toList() ?? [],
    );
  }

  Map<String, Object> export() {
    return {
      'id': id,
      'type': type.id,
      'summary': summary,
      // if (hasRev()) 'rev': rev!,
      if (hasRules()) 'rules': rules.map((e) => e.export()).toList(),
      'value': value,
    };
  }

  static Feature<String> string({
    required String id,
    required String summary,
    required String value,
    List<Rule<String>>? rules,
    int? rev,
  }) {
    return Feature<String>._(
      id: id,
      summary: summary,
      value: value,
      type: FeatureType.string,
      // rev: rev,
    );
  }

  static Feature<num> number({
    required String id,
    required String summary,
    required num value,
    List<Rule<num>>? rules,
    int? rev,
  }) {
    return Feature<num>._(
      id: id,
      summary: summary,
      value: value,
      type: FeatureType.number,
      // rev: rev,
      rules: rules ?? [],
    );
  }

  static Feature<bool> boolean({
    required String id,
    required String summary,
    required bool value,
    List<Rule<bool>>? rules,
    int? rev,
  }) {
    return Feature<bool>._(
      id: id,
      summary: summary,
      value: value,
      type: FeatureType.boolean,
      // rev: rev,
    );
  }
}
