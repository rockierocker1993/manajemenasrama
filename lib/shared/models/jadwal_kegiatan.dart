class JadwalKegiatan {
  JadwalKegiatan({
    this.id,
    required this.nama,
    this.deskripsi,
    this.kategori,
    this.hari,
    this.jamAwal,
    this.jamAkhir,
    this.tanggalAwalEfektif,
    this.tanggalAkhirEfektif,
    this.status,
    this.tipeKegiatan,
    this.jadwalKegiatanUsersString,
    this.jadwalKegiatanUsers,
    this.jadwalKegiatanAsramaString,
    this.jadwalKegiatanAsrama,
  });

  final int? id;
  final String nama;
  final String? deskripsi;
  final String? kategori;
  final List<String>? hari;
  final String? jamAwal;
  final String? jamAkhir;
  final String? tanggalAwalEfektif;
  final String? tanggalAkhirEfektif;
  final bool? status;
  final String? tipeKegiatan;
  final String? jadwalKegiatanUsersString;
  final List<Map<String, dynamic>>? jadwalKegiatanUsers;
  final String? jadwalKegiatanAsramaString;
  final List<Map<String, dynamic>>? jadwalKegiatanAsrama;

  factory JadwalKegiatan.fromJson(Map<String, dynamic> json) {
    return JadwalKegiatan(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
      kategori: json['kategori']?.toString(),
      hari: () {
        final raw = json['hari'];
        if (raw == null) return null;
        if (raw is List) return raw.map((e) => e.toString()).toList();
        final s = raw.toString();
        if (s.contains(',')) return s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        // single value as string separated by commas or single token
        return [s];
      }(),
      jamAwal: json['jam_awal']?.toString(),
      jamAkhir: json['jam_akhir']?.toString(),
      tanggalAwalEfektif: json['tanggal_awal_efektif']?.toString(),
      tanggalAkhirEfektif: json['tanggal_akhir_efektif']?.toString(),
      status: json.containsKey('status') ? (json['status'] == true) : null,
      tipeKegiatan: json['tipe_kegiatan']?.toString(),
      jadwalKegiatanUsersString: json['jadwal_kegiatan_users']?.toString(),
      jadwalKegiatanUsers: () {
        final raw = json['jadwal_kegiatan_users'];
        if (raw == null) return null;
        if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        // if backend returns comma-separated names
        final s = raw.toString();
        final parts = s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        return parts.map((name) => <String, dynamic>{'full_name': name}).toList();
      }(),
      jadwalKegiatanAsramaString: json['jadwal_kegiatan_asrama']?.toString(),
      jadwalKegiatanAsrama: () {
        final raw = json['jadwal_kegiatan_asrama'];
        if (raw == null) return null;
        if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        final s = raw.toString();
        final parts = s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        return parts.map((name) => <String, dynamic>{'nama': name}).toList();
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = {};
    if (id != null) out['id'] = id;
    out['nama'] = nama;
    if (deskripsi != null) out['deskripsi'] = deskripsi;
    if (kategori != null) out['kategori'] = categoriaOrNull(kategori);
    if (hari != null) out['hari'] = hari;
    if (jamAwal != null) out['jam_awal'] = jamAwal;
    if (jamAkhir != null) out['jam_akhir'] = jamAkhir;
    if (tanggalAwalEfektif != null) out['tanggal_awal_efektif'] = tanggalAwalEfektif;
    if (tanggalAkhirEfektif != null) out['tanggal_akhir_efektif'] = tanggalAkhirEfektif;
    if (status != null) out['status'] = status;
    if (tipeKegiatan != null) out['tipe_kegiatan'] = tipeKegiatan;

    if (jadwalKegiatanUsers != null) {
      final ids = jadwalKegiatanUsers!.map((e) => e['id']).where((id) => id != null).toList();
      if (ids.isNotEmpty) out['jadwal_kegiatan_user_ids'] = ids;
    }

    if (jadwalKegiatanAsrama != null) {
      final ids = jadwalKegiatanAsrama!.map((e) => e['id']).where((id) => id != null).toList();
      if (ids.isNotEmpty) out['jadwal_kegiatan_asrama_ids'] = ids;
    }

    return out;
  }

  // helper copied inline to avoid unused import issues
  dynamic categoriaOrNull(String? v) => v;
}

