import '../core/backend/backend_api_client.dart';
import '../shared/models/profile.dart';
import '../shared/models/user_role.dart';
import 'auth_service.dart';

/// CRUD operations for backend users.
class UserService {
  UserService({AuthService? authService, BackendApiClient? apiClient})
    : _authService = authService ?? AuthService(),
      _apiOverride = apiClient {
    _api =
        _apiOverride ??
        BackendApiClient(
          bearerTokenProvider: () async =>
              _authService.currentSession?.accessToken,
        );
  }

  final AuthService _authService;
  final BackendApiClient? _apiOverride;
  late final BackendApiClient _api;

  Future<List<Profile>> list() async {
    final data = await _api.getJson('/api/users');
    final items = (data is Map<String, dynamic> && data['data'] is List)
        ? data['data'] as List
        : (data as List? ?? const []);
    return items
        .cast<Map<String, dynamic>>()
        .map(Profile.fromJson)
        .toList(growable: false);
  }

  Future<Profile> me() async {
    final data = await _api.getJson('/api/users/me');
    final payload =
        data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return Profile.fromJson(payload);
  }

  Future<bool> create({
    required String username,
    required String fullName,
    required String password,
    required UserRole role,
  }) async {
    if (username.trim().isEmpty ||
        password.isEmpty ||
        fullName.trim().isEmpty) {
      throw AppAuthException(
        'Username, password, dan nama lengkap wajib diisi',
      );
    }

    try {
      final res = await _api.postJson('/api/auth/register', {
        'username': username.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'role': role.wireValue,
      });

      // Some backends return a 200 with a payload containing a `status`
      // boolean. Treat an explicit `status: false` as failure so callers
      // (UI) don't assume success when the operation actually failed.
      if (res is Map<String, dynamic>) {
        // If backend explicitly marks status as false, treat as failure.
        if (res.containsKey('status') && res['status'] == false) {
          throw AppAuthException(
              (res['message'] ?? 'Registrasi gagal').toString());
        }

        // Some backends return a 200 with data: null when operation failed.
        if (res.containsKey('data') && res['data'] == null) {
          throw AppAuthException((res['message'] ?? 'Registrasi gagal').toString());
        }
      }
      return true;
    } on BackendApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  Future<void> update({
    required String id,
    required String username,
    required String fullName,
    required UserRole role,
    String? password,
  }) async {
    await _api.putJson('/api/users/$id', {
      'username': username.trim(),
      'full_name': fullName.trim(),
      'role': role.wireValue,
      if (password != null && password.isNotEmpty) 'password': password,
    });
  }

  Future<void> delete(String username) => _api.delete('/api/users/$username');
}
