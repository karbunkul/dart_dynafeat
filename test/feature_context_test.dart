import 'package:dynafeat/src/feature_type.dart';
import 'package:test/test.dart';
import 'package:dynafeat/dynafeat.dart';

void main() {
  group('Context Tests', () {
    group('Factory Constructors', () {
      test('string context should have correct type and values', () {
        final ctx = Context.string(
          id: 'os',
          summary: 'Operating System',
          values: ['ios', 'android'],
        );
        expect(ctx.type, FeatureType.string);
        expect(ctx.values, contains('ios'));
        expect(ctx.hasValues(), isTrue);
      });

      test('boolean context should have empty values list', () {
        final ctx = Context.boolean(id: 'is_beta', summary: 'Beta user');
        expect(ctx.type, FeatureType.boolean);
        expect(ctx.hasValues(), isFalse);
      });
    });

    group('Import/Export', () {
      test('should export correctly with all fields', () {
        final ctx = Context.number(
          id: 'version',
          summary: 'App version',
          rev: 10,
          values: [1, 2, 3],
        );

        final map = ctx.export();

        expect(map['id'], 'version');
        expect(map['type'], 'num');
        expect(map['values'], [1, 2, 3]);
      });

      test('import should create correct context from map', () {
        final raw = {
          'id': 'flavor',
          'summary': 'Build flavor',
          'type': 'string',
          'values': ['dev', 'prod'],
          'rev': 1,
        };

        final ctx = Context.import(raw);

        expect(ctx.id, 'flavor');
        expect(ctx.type, FeatureType.string);
        // expect(ctx.rev, 1);
        expect(ctx.values, equals(['dev', 'prod']));
      });

      test('import should fallback to string type if type is missing', () {
        final raw = {
          'id': 'user_id',
          'summary': 'User identifier',
          // type is missing
        };

        final ctx = Context.import(raw);
        expect(ctx.type, FeatureType.string);
      });
    });

    // group('Edge Cases', () {
    //   test('hasRev should be false when rev is null', () {
    //     final ctx = Context.boolean(id: 'test', summary: 'test');
    //     expect(ctx.hasRev(), isFalse);
    //     expect(ctx.export().containsKey('rev'), isFalse);
    //   });
    // });
  });
}
