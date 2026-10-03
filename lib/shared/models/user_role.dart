/// Role of an application user.
enum UserRole {
  superAdmin('SUPER_ADMIN', 'Super Admin'),
  pengurus('PENGURUS', 'Pengurus'),
  ustadzah('USTADZAH', 'Ustadzah');

  const UserRole(this.wireValue, this.label);

  /// Wire format sent to / received from the backend.
  final String wireValue;

  /// Human-readable label (also the on-wire value).
  final String label;

  static UserRole fromWire(String value) {
    final v = value.trim().toUpperCase();
    return UserRole.values.firstWhere(
      (r) => r.wireValue == v || r.label.toUpperCase() == v,
      orElse: () => UserRole.superAdmin,
    );
  }
}

