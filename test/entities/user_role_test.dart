import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

void main() {
  group('UserRole enum', () {
    test('has four values: user, scan, admin, suspended', () {
      expect(UserRole.values.length, 4);
      expect(UserRole.user, isNotNull);
      expect(UserRole.scan, isNotNull);
      expect(UserRole.admin, isNotNull);
      expect(UserRole.suspended, isNotNull);
    });

    test('name returns lowercase string value', () {
      expect(UserRole.user.name, 'user');
      expect(UserRole.scan.name, 'scan');
      expect(UserRole.admin.name, 'admin');
      expect(UserRole.suspended.name, 'suspended');
    });

    test('fromString returns correct enum for valid role strings', () {
      expect(UserRole.fromString('user'), UserRole.user);
      expect(UserRole.fromString('scan'), UserRole.scan);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('suspended'), UserRole.suspended);
    });

    test('fromString returns UserRole.user for unknown role strings', () {
      expect(UserRole.fromString('superadmin'), UserRole.user);
      expect(UserRole.fromString(''), UserRole.user);
      expect(UserRole.fromString(null), UserRole.user);
    });

    test('isComparable with == operator works correctly', () {
      expect(UserRole.admin == UserRole.admin, isTrue);
      expect(UserRole.admin == UserRole.user, isFalse);
      expect(UserRole.scan == UserRole.scan, isTrue);
    });
  });
}
