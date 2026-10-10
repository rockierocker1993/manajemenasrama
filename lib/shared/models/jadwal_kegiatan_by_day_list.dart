class JadwalKegiatanByDayList {
  JadwalKegiatanByDayList({
    this.nama,
    this.hari,
    this.jamAwal,
    this.jamAkhir,
    this.deskripsi,
    this.kategori,
    this.tanggalAwalEfektif,
    this.jadwalKegiatanAsrama,
    this.jadwalKegiatanUsers,
    this.tanggalAkhirEfektif,
  });

  final String? nama;
  final String? hari;
  final String? jamAwal;
  final String? jamAkhir;
  final String? deskripsi;
  final String? kategori;
  final String? tanggalAwalEfektif;
  final String? jadwalKegiatanAsrama;
  final String? jadwalKegiatanUsers;
  final String? tanggalAkhirEfektif;

  factory JadwalKegiatanByDayList.fromJson(Map<String, dynamic> json) {
    return JadwalKegiatanByDayList(
      nama: json['nama']?.toString(),
      hari: json['hari']?.toString(),
      jamAwal: json['jam_awal']?.toString(),
      jamAkhir: json['jam_akhir']?.toString(),
      deskripsi: json['deskripsi']?.toString(),
      kategori: json['kategori']?.toString(),
      tanggalAwalEfektif: json['tanggal_awal_efektif']?.toString(),
      jadwalKegiatanAsrama: json['jadwal_kegiatan_asrama']?.toString(),
      jadwalKegiatanUsers: json['jadwal_kegiatan_users']?.toString(),
      tanggalAkhirEfektif: json['tanggal_akhir_efektif']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (nama != null) 'nama': nama,
      if (hari != null) 'hari': hari,
      if (jamAwal != null) 'jam_awal': jamAwal,
      if (jamAkhir != null) 'jam_akhir': jamAkhir,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (kategori != null) 'kategori': kategori,
      if (tanggalAwalEfektif != null)
        'tanggal_awal_efektif': tanggalAwalEfektif,
      if (jadwalKegiatanAsrama != null)
        'jadwal_kegiatan_asrama': jadwalKegiatanAsrama,
      if (jadwalKegiatanUsers != null)
        'jadwal_kegiatan_users': jadwalKegiatanUsers,
      if (tanggalAkhirEfektif != null)
        'tanggal_akhir_efektif': tanggalAkhirEfektif,
    };
  }
}

class JadwalKegiatanByDay {
  JadwalKegiatanByDay({
    required this.senin,
    required this.selasa,
    required this.rabu,
    required this.kamis,
    required this.jumat,
    required this.sabtu,
    required this.minggu,
  });

  final List<JadwalKegiatanByDayList> senin;
  final List<JadwalKegiatanByDayList> selasa;
  final List<JadwalKegiatanByDayList> rabu;
  final List<JadwalKegiatanByDayList> kamis;
  final List<JadwalKegiatanByDayList> jumat;
  final List<JadwalKegiatanByDayList> sabtu;
  final List<JadwalKegiatanByDayList> minggu;

  factory JadwalKegiatanByDay.fromJson(Map<String, dynamic> json) {
    List<JadwalKegiatanByDayList> parseList(dynamic raw) {
      if (raw == null) return <JadwalKegiatanByDayList>[];
      if (raw is List) {
        return raw
            .cast<Map<String, dynamic>>()
            .map(JadwalKegiatanByDayList.fromJson)
            .toList(growable: false);
      }
      return <JadwalKegiatanByDayList>[];
    }

    return JadwalKegiatanByDay(
      senin: parseList(json['senin']),
      selasa: parseList(json['selasa']),
      rabu: parseList(json['rabu']),
      kamis: parseList(json['kamis']),
      jumat: parseList(json['jumat']),
      sabtu: parseList(json['sabtu']),
      minggu: parseList(json['minggu']),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> toList(List<JadwalKegiatanByDayList> l) =>
        l.map((e) => e.toJson()).toList();
    return {
      'senin': toList(senin),
      'selasa': toList(selasa),
      'rabu': toList(rabu),
      'kamis': toList(kamis),
      'jumat': toList(jumat),
      'sabtu': toList(sabtu),
      'minggu': toList(minggu),
    };
  }
}
