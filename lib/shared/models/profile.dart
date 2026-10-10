import 'user_role.dart';

/// Application user record mapped from `public.app_user` rows.
class Profile {
  Profile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String username;
  final String fullName;
  final UserRole role;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: (json['id'] ?? '').toString(),
    username: (json['username'] ?? '') as String,
    fullName: (json['full_name'] ?? json['fullName'] ?? '') as String,
    role: UserRole.fromWire((json['role'] ?? 'SUPER_ADMIN') as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'full_name': fullName,
    'role': role.wireValue,
  };

  Profile copyWith({
    String? id,
    String? username,
    String? fullName,
    UserRole? role,
  }) => Profile(
    id: id ?? this.id,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    role: role ?? this.role,
  );
}
