import 'package:flutter_test/flutter_test.dart';
import 'package:manajemenasrama/shared/models/user_role.dart';

void main() {
  group('UserRole', () {
    test('superAdmin wireValue is uppercase enum value', () {
      expect(UserRole.superAdmin.wireValue, 'SUPER_ADMIN');
    });

    test('wireValue is uppercase enum name', () {
      expect(UserRole.pengurus.wireValue, 'PENGURUS');
      expect(UserRole.ustadzah.wireValue, 'USTADZAH');
    });

    test('labels match UI expectation', () {
      expect(UserRole.superAdmin.label, 'Super Admin');
      expect(UserRole.pengurus.label, 'Pengurus');
      expect(UserRole.ustadzah.label, 'Ustadzah');
    });

    test('fromWire is case-insensitive and tolerant', () {
      expect(UserRole.fromWire('SUPER_ADMIN'), UserRole.superAdmin);
      expect(UserRole.fromWire('PENGURUS'), UserRole.pengurus);
      expect(UserRole.fromWire('ustadzah'), UserRole.ustadzah);
      expect(UserRole.fromWire('Ustadzah'), UserRole.ustadzah);
    });

    test('fromWire falls back to pengurus on unknown', () {
      expect(UserRole.fromWire('bogus'), UserRole.superAdmin);
    });
  });
}

