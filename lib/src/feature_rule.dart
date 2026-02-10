import 'package:dynafeat/src/operation.dart';

final class Rule<T extends Object> {
  final String id;
  final List<Condition> conditions;
  final String? summary;
  // final int? rev;
  final T value;

  Rule({
    required this.id,
    required this.conditions,
    required this.summary,
    required this.value,
    // this.rev,
  });

  late final Set<String> dependencies = {}
    ..addAll(conditions.map((e) => e.context));

  T? resolve(Map<String, Object> context) {
    int matches = 0;

    for (final condition in conditions) {
      final payload = context[condition.context];
      if (payload != null) {
        final res = condition.op.resolve(
          context: payload,
          value: condition.value,
        );

        if (res) {
          matches++;
        }
      }
    }

    if (matches == conditions.length) {
      return value;
    }

    return null;
  }

  static Rule import(Map<String, dynamic> value) {
    final id = value['id'];
    final summary = value['summary'];
    final ruleVal = value['value'] as Object;
    final conditions = value['conditions'] as List?;

    return Rule(
      id: id,
      conditions: conditions?.map((e) => Condition.import(e)).toList() ?? [],
      summary: summary,
      value: ruleVal,
    );
  }

  Map<String, Object> export() {
    return {
      'id': id,
      if (summary != null) 'summary': summary!,
      // if (rev != null) 'rev': rev!,
      'conditions': conditions.map((e) => e.export()).toList(),
      'value': value,
    };
  }
}

final class Condition<T extends Object> {
  final String context;
  final Operation op;
  final Object value;

  const Condition._({
    required this.op,
    required this.context,
    required this.value,
  });

  static Condition import(Map<String, dynamic> value) {
    final context = value['context'] as String;
    final rawOp = value['op'] as String? ?? 'eq';
    final op = Operation.from(rawOp);
    final conditionVal = value['value'];

    return Condition._(op: op, context: context, value: conditionVal);
  }

  Map<String, Object> export() {
    return {'context': context, 'op': op.op, 'value': value};
  }

  factory Condition.eq(String context, T value) {
    return Condition<T>._(context: context, op: Operation.eq, value: value);
  }

  factory Condition.neq(String context, T value) {
    return Condition<T>._(context: context, op: Operation.neq, value: value);
  }

  factory Condition.start(String context, T value) {
    return Condition<T>._(context: context, op: Operation.start, value: value);
  }

  factory Condition.end(String context, T value) {
    return Condition<T>._(context: context, op: Operation.end, value: value);
  }
}
