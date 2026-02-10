import 'package:test/test.dart';
import 'package:dynafeat/src/feature_type.dart'; // Путь к твоему файлу

void main() {
  group('FeatureType Tests', () {
    group('Factory from()', () {
      test('should parse exact matches correctly', () {
        expect(FeatureType.from('string'), FeatureType.string);
        expect(FeatureType.from('num'), FeatureType.number);
        expect(FeatureType.from('bool'), FeatureType.boolean);
      });

      test('should be case-insensitive and handle whitespace', () {
        expect(FeatureType.from('  STRING  '), FeatureType.string);
        expect(FeatureType.from('Num'), FeatureType.number);
        expect(FeatureType.from('BOOL'), FeatureType.boolean);
      });

      test('should fallback to string for unknown values', () {
        expect(FeatureType.from('unknown'), FeatureType.string);
        expect(FeatureType.from(''), FeatureType.string);
      });
    });

    group('validate() logic', () {
      test('string type validation', () {
        final type = FeatureType.string;
        expect(type.validate('hello'), isTrue);
        expect(type.validate(123), isFalse);
        expect(type.validate(true), isFalse);
      });

      test('number type validation', () {
        final type = FeatureType.number;
        expect(type.validate(10), isTrue);
        expect(type.validate(10.5), isTrue);
        expect(type.validate('10'), isFalse);
      });

      test('boolean type validation', () {
        final type = FeatureType.boolean;
        expect(type.validate(true), isTrue);
        expect(type.validate(false), isTrue);
        expect(type.validate('true'), isFalse);
      });
    });

    group('Properties', () {
      test('id should match serialization requirements', () {
        expect(FeatureType.string.id, 'string');
        expect(FeatureType.number.id, 'num');
        expect(FeatureType.boolean.id, 'bool');
      });
    });
  });
}
