import 'package:test/test.dart';
import 'package:dynafeat/src/operation.dart'; // Поправь путь под себя

void main() {
  group('Operation Tests', () {
    group('Equality Operations (eq, neq)', () {
      test('eq should work for String, num and bool', () {
        expect(Operation.eq.resolve(context: 'test', value: 'test'), isTrue);
        expect(Operation.eq.resolve(context: 10, value: 10), isTrue);
        expect(Operation.eq.resolve(context: true, value: true), isTrue);
        expect(Operation.eq.resolve(context: 'test', value: 'other'), isFalse);
      });

      test('neq should work for String, num and bool', () {
        expect(Operation.neq.resolve(context: 'a', value: 'b'), isTrue);
        expect(Operation.neq.resolve(context: 1, value: 2), isTrue);
        expect(Operation.neq.resolve(context: true, value: false), isTrue);
      });
    });

    group('String Operations (start, end, contains, pattern)', () {
      test('start/end should match string boundaries', () {
        expect(
          Operation.start.resolve(context: 'ios_v15', value: 'ios'),
          isTrue,
        );
        expect(Operation.end.resolve(context: 'ios_v15', value: 'v15'), isTrue);
        expect(
          Operation.start.resolve(context: 'ios_v15', value: 'v15'),
          isFalse,
        );
      });

      test('pattern should match regex', () {
        expect(
          Operation.pattern.resolve(
            context: 'user@gmail.com',
            value: r'@gmail\.com$',
          ),
          isTrue,
        );
        expect(
          Operation.pattern.resolve(
            context: 'user@mail.ru',
            value: r'@gmail\.com$',
          ),
          isFalse,
        );
      });
    });

    group('Collection Operations (any, contains)', () {
      test('any should check if context is in list', () {
        expect(
          Operation.any.resolve(context: 'prod', value: ['prod', 'stage']),
          isTrue,
        );
        expect(Operation.any.resolve(context: 3, value: [1, 2, 3]), isTrue);
        expect(Operation.any.resolve(context: 'test', value: ['dev']), isFalse);
      });

      test('contains should work as substring check', () {
        expect(
          Operation.contains.resolve(context: 'premium_user', value: 'premium'),
          isTrue,
        );
      });
    });

    group('Numeric Operations (range, less, greater)', () {
      test('range should check boundaries inclusive', () {
        expect(Operation.range.resolve(context: 20, value: [10, 30]), isTrue);
        expect(Operation.range.resolve(context: 10, value: [10, 30]), isTrue);
        expect(Operation.range.resolve(context: 31, value: [10, 30]), isFalse);
      });

      test('less/greater should compare numbers', () {
        expect(Operation.less.resolve(context: 5, value: 10), isTrue);
        expect(Operation.greater.resolve(context: 15, value: 10), isTrue);
      });
    });

    group('Payload Validation (Edge Cases)', () {
      test('should return false if payload type is invalid for operation', () {
        // Range ожидает List, а мы суем String
        expect(Operation.range.resolve(context: 20, value: '10-30'), isFalse);

        // Start ожидает String, а мы суем num
        expect(Operation.start.resolve(context: 'test', value: 123), isFalse);

        // Any ожидает непустой список
        expect(Operation.any.resolve(context: 'a', value: []), isFalse);
      });
    });
  });
}
