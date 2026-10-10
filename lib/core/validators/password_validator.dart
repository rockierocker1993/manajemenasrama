/// Validates passwords against the project policy.
///
/// Policy (example conforming password: `chelRE@1da`):
///   * Minimum 8 characters
///   * At least one lowercase letter
///   * At least one uppercase letter
///   * At least one digit
///   * At least one special character (non-alphanumeric)
///   * No whitespace
class PasswordValidator {
  static const int minLength = 8;

  /// Returns `null` when the password is valid, otherwise a localized
  /// (Indonesian) message suitable for a form field.
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }
    if (value.contains(RegExp(r'\s'))) {
      return 'Password tidak boleh mengandung spasi';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Harus mengandung huruf kecil';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Harus mengandung huruf besar';
    }
    if (!value.contains(RegExp(r'\d'))) {
      return 'Harus mengandung angka';
    }
    if (!value.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'Harus mengandung karakter spesial (!@#\$%^&* dst.)';
    }
    return null;
  }

  static bool isValid(String? value) => validate(value) == null;
}
