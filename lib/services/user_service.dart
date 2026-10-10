import '../core/backend/backend_api_client.dart';
import '../shared/models/profile.dart';
import '../shared/models/base_response.dart';
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
    final raw = await _api.getJson('/api/users');

    // Support both wrapped responses ({ data: [...] }) and raw arrays.
    List itemsRaw;
    if (raw is Map<String, dynamic>) {
      final br = BaseResponse<List<dynamic>>.fromJson(
        raw,
        (d) => (d as List).cast(),
      );
      itemsRaw = br.data ?? <dynamic>[];
      if (br.status == false) {
        throw Exception(br.message ?? 'Gagal memuat pengguna');
      }
    } else {
      itemsRaw = (raw as List? ?? <dynamic>[]);
    }

    return itemsRaw
        .cast<Map<String, dynamic>>()
        .map(Profile.fromJson)
        .toList(growable: false);
  }

  Future<Profile> me() async {
    final raw = await _api.getJson('/api/users/me');
    if (raw is Map<String, dynamic>) {
      final br = BaseResponse<Map<String, dynamic>>.fromJson(
        raw,
        (d) => Map<String, dynamic>.from(d as Map),
      );
      if (br.status == false)
        throw Exception(br.message ?? 'Gagal memuat profil');
      final payload = br.data ?? <String, dynamic>{};
      return Profile.fromJson(payload);
    }
    return Profile.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<BaseResponse<dynamic>> create({
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

      final br = BaseResponse<dynamic>.fromJson(res, (d) => d);
      if (!br.isSuccess) {
        throw AppAuthException(br.message ?? 'Registrasi gagal');
      }
      return br;
    } on BackendApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  Future<BaseResponse<dynamic>> update({
    required String id,
    required String username,
    required String fullName,
    required UserRole role,
    String? password,
  }) async {
    final res = await _api.putJson('/api/users/$id', {
      'username': username.trim(),
      'full_name': fullName.trim(),
      'role': role.wireValue,
      if (password != null && password.isNotEmpty) 'password': password,
    });

    final br = BaseResponse<dynamic>.fromJson(res, (d) => d);
    if (br.status == false) {
      throw Exception(br.message ?? 'Gagal memperbarui pengguna');
    }
    return br;
  }

  Future<BaseResponse<dynamic>?> delete(String username) async {
    final res = await _api.delete('/api/users/$username');
    if (res == null) return null;
    final br = BaseResponse<dynamic>.fromJson(res, (d) => d);
    if (br.status == false)
      throw Exception(br.message ?? 'Gagal menghapus pengguna');
    return br;
  }
}
