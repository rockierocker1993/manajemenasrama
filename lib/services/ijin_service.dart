import '../core/backend/backend_api_client.dart';
import '../services/auth_service.dart';
import '../shared/models/ijin.dart';
import '../shared/models/base_response.dart';

class IjinService {
  IjinService({AuthService? authService, BackendApiClient? apiClient})
      : _authService = authService ?? AuthService(),
        _apiOverride = apiClient {
    _api = _apiOverride ?? BackendApiClient(bearerTokenProvider: () async => _authService.currentSession?.accessToken);
  }

  final AuthService _authService;
  final BackendApiClient? _apiOverride;
  late final BackendApiClient _api;

  Future<List<Ijin>> list() async {
    final raw = await _api.getJson('/api/ijin');
    List itemsRaw;
    if (raw is Map<String, dynamic>) {
      final br = BaseResponse<List<dynamic>>.fromJson(raw, (d) => (d as List).cast());
      if (br.status == false) throw Exception(br.message ?? 'Gagal memuat ijin');
      itemsRaw = br.data ?? <dynamic>[];
    } else {
      itemsRaw = (raw as List? ?? <dynamic>[]);
    }

    return itemsRaw.cast<Map<String, dynamic>>().map(Ijin.fromJson).toList(growable: false);
  }

  Future<BaseResponse<dynamic>> create(Map<String, dynamic> body) async {
    final res = await _api.postJson('/api/ijin', body);
    final br = BaseResponse<dynamic>.fromJson(res, (d) => d);
    if (br.status == false) throw Exception(br.message ?? 'Gagal membuat ijin');
    return br;
  }

  Future<BaseResponse<dynamic>> approve({required int id, required String status}) async {
    final res = await _api.putJson('/api/ijin/approval/$id', {'status': status});
    final br = BaseResponse<dynamic>.fromJson(res, (d) => d);
    if (br.status == false) throw Exception(br.message ?? 'Gagal mengubah status ijin');
    return br;
  }
}

