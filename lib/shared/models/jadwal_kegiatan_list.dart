class JadwalKegiatanList {
  JadwalKegiatanList({
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
    this.jadwalKegiatanUsers,
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
  final List<String>? jadwalKegiatanUsers;
  final List<String>? jadwalKegiatanAsrama;

  factory JadwalKegiatanList.fromJson(Map<String, dynamic> json) {
    return JadwalKegiatanList(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
      kategori: json['kategori']?.toString(),
      hari: () {
        final raw = json['hari'];
        if (raw == null) return null;
        if (raw is List) return raw.map((e) => e.toString()).toList();
        final s = raw.toString();
        if (s.contains(','))
          return s
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        // single value as string separated by commas or single token
        return [s];
      }(),
      jamAwal: json['jam_awal']?.toString(),
      jamAkhir: json['jam_akhir']?.toString(),
      tanggalAwalEfektif: json['tanggal_awal_efektif']?.toString(),
      tanggalAkhirEfektif: json['tanggal_akhir_efektif']?.toString(),
      status: json.containsKey('status') ? (json['status'] == true) : null,
      jadwalKegiatanUsers: () {
        final raw = json['jadwal_kegiatan_users'];
        if (raw == null) return null;
        if (raw is List) return raw.map((e) => e.toString()).toList();
        final s = raw.toString();
        if (s.contains(','))
          return s
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        // single value as string separated by commas or single token
        return [s];
      }(),
      jadwalKegiatanAsrama: () {
        final raw = json['jadwal_kegiatan_asrama'];
        if (raw == null) return null;
        if (raw is List) return raw.map((e) => e.toString()).toList();
        final s = raw.toString();
        if (s.contains(','))
          return s
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        // single value as string separated by commas or single token
        return [s];
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
    if (tanggalAwalEfektif != null)
      out['tanggal_awal_efektif'] = tanggalAwalEfektif;
    if (tanggalAkhirEfektif != null)
      out['tanggal_akhir_efektif'] = tanggalAkhirEfektif;
    if (status != null) out['status'] = status;
    if (jadwalKegiatanUsers != null)
      out['jadwal_kegiatan_users'] = jadwalKegiatanUsers;
    if (jadwalKegiatanAsrama != null)
      out['jadwal_kegiatan_asrama'] = jadwalKegiatanAsrama;
    return out;
  }

  // helper copied inline to avoid unused import issues
  dynamic categoriaOrNull(String? v) => v;
}
