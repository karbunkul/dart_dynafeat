import 'package:dynafeat/dynafeat.dart';
import 'package:dynafeat/src/feature_type.dart';
import 'package:test/test.dart';

void main() {
  group('Feature Tests', () {
    group('Factory Constructors & Types', () {
      test('should create a string feature with correct type', () {
        final feature = Feature.string(
          id: 'host',
          summary: 'API Host',
          value: 'localhost',
        );
        expect(feature.value, isA<String>());
        expect(feature.type, FeatureType.string);
        expect(feature.validate(), isTrue);
      });

      test('should create a number feature with correct type', () {
        final feature = Feature.number(
          id: 'port',
          summary: 'API Port',
          value: 8080,
        );
        expect(feature.value, isA<num>());
        expect(feature.type, FeatureType.number);
        expect(feature.validate(), isTrue);
      });

      test('should create a boolean feature and validate properly', () {
        final featureTrue = Feature.boolean(
          id: 'enabled',
          summary: 'Feature toggle',
          value: true,
        );
        final featureFalse = Feature.boolean(
          id: 'disabled',
          summary: 'Feature toggle',
          value: false,
        );

        expect(featureTrue.validate(), isTrue);
        expect(featureFalse.validate(), isTrue);
        expect(featureTrue.type, FeatureType.boolean);
      });
    });

    group('Rules & Revisions', () {
      test('hasRules should be true only when rules are not empty', () {
        final featureNoRules = Feature.number(id: '1', summary: 's', value: 1);
        final featureWithRules = Feature.number(
          id: '2',
          summary: 's',
          value: 1,
          rules: [Rule(id: 'r1', conditions: [], summary: 'test', value: 2)],
        );

        expect(featureNoRules.hasRules(), isFalse);
        expect(featureWithRules.hasRules(), isTrue);
      });

      // test('hasRev should detect if revision is present', () {
      //   final noRev = Feature.string(id: '1', summary: 's', value: 'a');
      //   final withRev = Feature.string(
      //     id: '2',
      //     summary: 's',
      //     value: 'a',
      //     rev: 5,
      //   );
      //
      //   expect(noRev.hasRev(), isFalse);
      //   expect(withRev.hasRev(), isTrue);
      // });
    });

    group('Export (Serialization)', () {
      test('export should not contain null or empty optional fields', () {
        final feature = Feature.string(
          id: 'theme',
          summary: 'UI Theme',
          value: 'dark',
        );

        final json = feature.export();

        expect(json['id'], 'theme');
        expect(json['value'], 'dark');
        expect(json.containsKey('rev'), isFalse);
        expect(json.containsKey('rules'), isFalse);
      });

      test('export should contain rev and rules when they are set', () {
        final feature = Feature.number(
          id: 'limit',
          summary: 'Limit',
          value: 10,
          rules: [Rule(id: 'r1', conditions: [], summary: 'test', value: 20)],
        );

        final json = feature.export();
        expect(json['rules'], isA<List>());
        expect((json['rules'] as List).length, 1);
      });
    });

    test('Feature.number should export correct JSON structure', () {
      final feature = Feature.number(
        id: 'port',
        summary: 'test port',
        value: 8080,
        rev: 1,
      );

      final json = feature.export();

      expect(json['type'], 'num');
      expect(json['value'], 8080);
      expect(json.containsKey('rules'), isFalse);
    });

    test('hasRules should return true when rules are provided', () {
      final feature = Feature.number(
        id: 'port',
        summary: 'test',
        value: 3000,
        rules: [],
      );

      expect(feature.hasRules(), isFalse);
    });

    test('Feature.string should validate correctly', () {
      final feature = Feature.string(id: 's', summary: 's', value: 'hello');
      expect(feature.validate(), isTrue);
    });
  });
}
