import 'package:manajemenasrama/shared/models/jadwal_kegiatan_list.dart';

import '../core/backend/backend_api_client.dart';
import '../shared/models/base_response.dart';
import '../shared/models/jadwal_kegiatan.dart';
import 'auth_service.dart';

class JadwalKegiatanService {
  JadwalKegiatanService({AuthService? authService, BackendApiClient? apiClient})
      : _authService = authService ?? AuthService(),
        _apiOverride = apiClient {
    _api = _apiOverride ?? BackendApiClient(bearerTokenProvider: () async => _authService.currentSession?.accessToken);
  }

  final AuthService _authService;
  final BackendApiClient? _apiOverride;
  late final BackendApiClient _api;

  Future<List<JadwalKegiatanList>> list() async {
    final raw = await _api.getJson('/api/jadwal-kegiatan');
    List itemsRaw;
    if (raw is Map<String, dynamic>) {
      final br = BaseResponse<List<dynamic>>.fromJson(raw, (d) => (d as List).cast());
      if (br.status == false) throw Exception(br.message ?? 'Gagal memuat jadwal kegiatan');
      itemsRaw = br.data ?? <dynamic>[];
    } else {
      itemsRaw = (raw as List? ?? <dynamic>[]);
    }
    return itemsRaw.cast<Map<String, dynamic>>().map(JadwalKegiatanList.fromJson).toList(growable: false);
  }

  Future<JadwalKegiatan> getById(dynamic id) async {
    final raw = await _api.getJson('/api/jadwal-kegiatan/$id');
    if (raw is Map<String, dynamic>) {
      final br = BaseResponse<Map<String, dynamic>>.fromJson(raw, (d) => Map<String, dynamic>.from(d as Map));
      if (br.status == false) throw Exception(br.message ?? 'Gagal memuat jadwal kegiatan');
      final payload = br.data ?? <String, dynamic>{};
      return JadwalKegiatan.fromJson(payload);
    }
    return JadwalKegiatan.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<BaseResponse<JadwalKegiatan>> create(Map<String, dynamic> body) async {
    final res = await _api.postJson('/api/jadwal-kegiatan', body);
    final br = BaseResponse<Map<String, dynamic>>.fromJson(res, (d) => Map<String, dynamic>.from(d as Map));
    if (!br.isSuccess) throw Exception(br.message ?? 'Gagal membuat jadwal kegiatan');
    if (br.data == null) throw Exception(br.message ?? 'Gagal membuat jadwal kegiatan');
    final model = JadwalKegiatan.fromJson(br.data!);
    return BaseResponse<JadwalKegiatan>(
      responseCode: br.responseCode,
      status: br.status,
      messageId: br.messageId,
      messageEn: br.messageEn,
      titleId: br.titleId,
      titleEn: br.titleEn,
      message: br.message,
      data: model,
    );
  }

  Future<BaseResponse<JadwalKegiatan>> update({required dynamic id, required Map<String, dynamic> body}) async {
    final res = await _api.putJson('/api/jadwal-kegiatan/$id', body);
    final br = BaseResponse<Map<String, dynamic>>.fromJson(res, (d) => Map<String, dynamic>.from(d as Map));
    if (br.status == false) throw Exception(br.message ?? 'Gagal memperbarui jadwal kegiatan');
    if (br.data == null) throw Exception(br.message ?? 'Gagal memperbarui jadwal kegiatan');
    final model = JadwalKegiatan.fromJson(br.data!);
    return BaseResponse<JadwalKegiatan>(
      responseCode: br.responseCode,
      status: br.status,
      messageId: br.messageId,
      messageEn: br.messageEn,
      titleId: br.titleId,
      titleEn: br.titleEn,
      message: br.message,
      data: model,
    );
  }

  Future<BaseResponse<dynamic>?> delete(dynamic id) async {
    final res = await _api.delete('/api/jadwal-kegiatan/$id');
    if (res == null) return null;
    final br = BaseResponse<dynamic>.fromJson(res, (d) => d);
    if (br.status == false) throw Exception(br.message ?? 'Gagal menghapus jadwal kegiatan');
    return br;
  }

  Future<void> toggleActive(dynamic id, bool active) async {
    await _api.putJson('/api/jadwal-kegiatan/active-deactive/$id/$active', {});
  }

  Future<List<JadwalKegiatanList>> meToday() async {
    final raw = await _api.getJson('/api/jadwal-kegiatan/me/today');
    List itemsRaw;
    if (raw is Map<String, dynamic>) {
      final br = BaseResponse<List<dynamic>>.fromJson(raw, (d) => (d as List).cast());
      if (br.status == false) throw Exception(br.message ?? 'Gagal memuat jadwal kegiatan');
      itemsRaw = br.data ?? <dynamic>[];
    } else {
      itemsRaw = (raw as List? ?? <dynamic>[]);
    }
    return itemsRaw.cast<Map<String, dynamic>>().map(JadwalKegiatanList.fromJson).toList(growable: false);
  }

}

