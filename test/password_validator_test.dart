import 'package:flutter_test/flutter_test.dart';
import 'package:manajemenasrama/core/validators/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    test('accepts the example chelRE@1da', () {
      expect(PasswordValidator.validate('chelRE@1da'), isNull);
    });

    test('rejects empty', () {
      expect(PasswordValidator.validate(null), isNotNull);
      expect(PasswordValidator.validate(''), isNotNull);
    });

    test('rejects too short', () {
      expect(PasswordValidator.validate('aB1@a'), contains('minimal'));
    });

    test('rejects missing uppercase', () {
      expect(PasswordValidator.validate('abcde1@a'), contains('besar'));
    });

    test('rejects missing lowercase', () {
      expect(PasswordValidator.validate('ABCDE1@A'), contains('kecil'));
    });

    test('rejects missing digit', () {
      expect(PasswordValidator.validate('Abcdefg@'), contains('angka'));
    });

    test('rejects missing special char', () {
      expect(PasswordValidator.validate('Abcdefg1'), contains('spesial'));
    });

    test('rejects whitespace', () {
      expect(PasswordValidator.validate('Abcd 1@a'), contains('spasi'));
    });
  });
}

