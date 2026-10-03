import '../core/backend/backend_api_client.dart';
import '../shared/models/app_user.dart';
import '../shared/models/user_role.dart';
import 'auth_service.dart';

/// CRUD operations for backend users.
class UserService {
  UserService({
    AuthService? authService,
    BackendApiClient? apiClient,
  })  : _authService = authService ?? AuthService(),
        _apiOverride = apiClient {
    _api = _apiOverride ?? BackendApiClient(
      bearerTokenProvider: () async => _authService.currentSession?.accessToken,
    );
  }

  final AuthService _authService;
  final BackendApiClient? _apiOverride;
  late final BackendApiClient _api;

  Future<List<AppUser>> list() async {
    final data = await _api.getJson('/api/users');
    final items = (data is Map<String, dynamic> && data['data'] is List)
        ? data['data'] as List
        : (data as List? ?? const []);
    return items
        .cast<Map<String, dynamic>>()
        .map(AppUser.fromJson)
        .toList(growable: false);
  }

  Future<AppUser> getById(String id) async {
    final data = await _api.getJson('/api/users/$id');
    final payload = data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return AppUser.fromJson(payload);
  }

  Future<void> create({
    required String username,
    required String fullName,
    required String password,
    required UserRole role,
  }) async {
    await _authService.register(
      username: username,
      password: password,
      fullName: fullName,
      role: role.wireValue,
    );
  }

  Future<void> update({
    required String id,
    required String username,
    required String fullName,
    required UserRole role,
    String? password,
  }) async {
    await _api.putJson(
      '/api/users/$id',
      {
        'username': username.trim(),
        'full_name': fullName.trim(),
        'role': role.wireValue,
        if (password != null && password.isNotEmpty) 'password': password,
      },
    );
  }

  Future<void> delete(String id) => _api.delete('/api/users/$id');
}
