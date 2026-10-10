import '../core/backend/backend_api_client.dart';
import '../shared/models/asrama.dart';
import '../shared/models/base_response.dart';
import 'auth_service.dart';

/// CRUD operations for Asrama (dormitories).
class AsramaService {
  AsramaService({AuthService? authService, BackendApiClient? apiClient})
      : _authService = authService ?? AuthService(),
        _apiOverride = apiClient {
    _api = _apiOverride ??
        BackendApiClient(
          bearerTokenProvider: () async => _authService.currentSession?.accessToken,
        );
  }

  final AuthService _authService;
  final BackendApiClient? _apiOverride;
  late final BackendApiClient _api;

  /// List all asrama. Supports both wrapped response ({ data: [...] }) and raw array.
  Future<List<Asrama>> list() async {
    final raw = await _api.getJson('/api/asrama');

    List itemsRaw;
    if (raw is Map<String, dynamic>) {
      final br = BaseResponse<List<dynamic>>.fromJson(raw, (d) => (d as List).cast());
      if (br.status == false) throw Exception(br.message ?? 'Gagal memuat asrama');
      itemsRaw = br.data ?? <dynamic>[];
    } else {
      itemsRaw = (raw as List? ?? <dynamic>[]);
    }

    return itemsRaw.cast<Map<String, dynamic>>().map(Asrama.fromJson).toList(growable: false);
  }

  /// Get single asrama by id.
  Future<Asrama> getById(dynamic id) async {
    final raw = await _api.getJson('/api/asrama/$id');
    if (raw is Map<String, dynamic>) {
      final br = BaseResponse<Map<String, dynamic>>.fromJson(raw, (d) => Map<String, dynamic>.from(d as Map));
      if (br.status == false) throw Exception(br.message ?? 'Gagal memuat asrama');
      final payload = br.data ?? <String, dynamic>{};
      return Asrama.fromJson(payload);
    }
    return Asrama.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  /// Create new asrama. Returns BaseResponse containing created asrama in data.
  Future<BaseResponse<Asrama>> create({required String nama}) async {
    final res = await _api.postJson('/api/asrama', {'nama': nama});
    final br = BaseResponse<Map<String, dynamic>>.fromJson(res, (d) => Map<String, dynamic>.from(d as Map));
    if (!br.isSuccess) throw Exception(br.message ?? 'Gagal membuat asrama');
    if (br.data == null) throw Exception(br.message ?? 'Gagal membuat asrama');
    final asrama = Asrama.fromJson(br.data!);
    return BaseResponse<Asrama>(
      responseCode: br.responseCode,
      status: br.status,
      messageId: br.messageId,
      messageEn: br.messageEn,
      titleId: br.titleId,
      titleEn: br.titleEn,
      message: br.message,
      data: asrama,
    );
  }

  /// Update asrama by id. Returns BaseResponse with updated asrama in data.
  Future<BaseResponse<Asrama>> update({required dynamic id, required String nama}) async {
    final res = await _api.putJson('/api/asrama/$id', {'nama': nama});
    final br = BaseResponse<Map<String, dynamic>>.fromJson(res, (d) => Map<String, dynamic>.from(d as Map));
    if (br.status == false) throw Exception(br.message ?? 'Gagal memperbarui asrama');
    if (br.data == null) throw Exception(br.message ?? 'Gagal memperbarui asrama');
    final asrama = Asrama.fromJson(br.data!);
    return BaseResponse<Asrama>(
      responseCode: br.responseCode,
      status: br.status,
      messageId: br.messageId,
      messageEn: br.messageEn,
      titleId: br.titleId,
      titleEn: br.titleEn,
      message: br.message,
      data: asrama,
    );
  }

  /// Delete asrama by id. Returns BaseResponse (data likely null) or null for 204.
  Future<BaseResponse<dynamic>?> delete(dynamic id) async {
    final res = await _api.delete('/api/asrama/$id');
    if (res == null) return null;
    final br = BaseResponse<dynamic>.fromJson(res, (d) => d);
    if (br.status == false) throw Exception(br.message ?? 'Gagal menghapus asrama');
    return br;
  }
}

