import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';

void main() {
  group('LabelEntity', () {
    final testLabel = LabelEntity(
      id: 1,
      createdAt: DateTime(2026),
      name: 'Staff Pick',
      color: '#71A202',
    );

    test('creates with correct values', () {
      expect(testLabel.id, 1);
      expect(testLabel.createdAt, DateTime(2026));
      expect(testLabel.name, 'Staff Pick');
      expect(testLabel.color, '#71A202');
    });

    test('props contains all fields', () {
      expect(testLabel.props, [
        1,
        DateTime(2026),
        'Staff Pick',
        '#71A202',
      ]);
    });

    test('equatable works - same values are equal', () {
      final same = LabelEntity(
        id: 1,
        createdAt: DateTime(2026),
        name: 'Staff Pick',
        color: '#71A202',
      );
      expect(testLabel, same);
    });

    test('equatable works - different values are not equal', () {
      final different = LabelEntity(
        id: 2,
        createdAt: DateTime(2026),
        name: 'Featured',
        color: '#E53935',
      );
      expect(testLabel, isNot(different));
    });
  });
}
