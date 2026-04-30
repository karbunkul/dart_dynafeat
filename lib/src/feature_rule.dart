import 'package:dynafeat/src/operation.dart';

/// Represents a rule that determines a feature's value based on conditions.
///
/// If all [conditions] in a rule are met, the rule is considered a match
/// and its [value] is returned.
final class Rule<T extends Object> {
  /// Unique identifier for the rule.
  final String id;

  /// A list of conditions that must all be true for this rule to apply.
  final List<Condition> conditions;

  /// A short description of what this rule represents.
  final String? summary;

  /// The value to return if this rule matches.
  final T value;

  Rule({
    required this.id,
    required this.conditions,
    required this.summary,
    required this.value,
  });

  /// Set of context keys this rule depends on.
  late final Set<String> dependencies = {}
    ..addAll(conditions.map((e) => e.context));

  /// Evaluates the rule against the provided [context].
  ///
  /// Returns [value] if all conditions match, otherwise returns `null`.
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

  /// Imports a [Rule] from a [Map].
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

  /// Exports the [Rule] to a serializable [Map].
  Map<String, Object> export() {
    return {
      'id': id,
      if (summary != null) 'summary': summary!,
      'conditions': conditions.map((e) => e.export()).toList(),
      'value': value,
    };
  }
}

/// Represents a single requirement within a [Rule].
///
/// A [Condition] compares a value from the evaluation context (identified by [context])
/// with a predefined [value] using a specific [op] (Operation).
final class Condition<T extends Object> {
  /// The key in the context map to evaluate.
  final String context;

  /// The comparison operation to perform.
  final Operation op;

  /// The value to compare against.
  final Object value;

  const Condition._({
    required this.op,
    required this.context,
    required this.value,
  });

  /// Imports a [Condition] from a [Map].
  static Condition import(Map<String, dynamic> value) {
    final context = value['context'] as String;
    final rawOp = value['op'] as String? ?? 'eq';
    final op = Operation.from(rawOp);
    final conditionVal = value['value'];

    return Condition._(op: op, context: context, value: conditionVal);
  }

  /// Exports the [Condition] to a serializable [Map].
  Map<String, Object> export() {
    return {'context': context, 'op': op.op, 'value': value};
  }

  /// Creates an 'equals' condition.
  factory Condition.eq(String context, T value) {
    return Condition<T>._(context: context, op: Operation.eq, value: value);
  }

  /// Creates a 'not equals' condition.
  factory Condition.neq(String context, T value) {
    return Condition<T>._(context: context, op: Operation.neq, value: value);
  }

  /// Creates a 'starts with' condition (for strings).
  factory Condition.start(String context, T value) {
    return Condition<T>._(context: context, op: Operation.start, value: value);
  }

  /// Creates an 'ends with' condition (for strings).
  factory Condition.end(String context, T value) {
    return Condition<T>._(context: context, op: Operation.end, value: value);
  }
}
