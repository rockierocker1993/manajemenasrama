class Ijin {
  Ijin({
    required this.id,
    required this.namaSantri,
    required this.tanggalIjin,
    required this.tipeIjin,
    required this.alasan,
    required this.status,
  });

  final int id;
  final String namaSantri;
  final String tanggalIjin;
  final String tipeIjin;
  final String alasan;
  final String status;

  factory Ijin.fromJson(Map<String, dynamic> json) => Ijin(
        id: (json['id'] as num?)?.toInt() ?? 0,
        namaSantri: (json['nama_santri'] ?? json['namaSantri'] ?? '') as String,
        tanggalIjin: (json['tanggal_ijin'] ?? json['tanggalIjin'] ?? '') as String,
        tipeIjin: (json['tipe_ijin'] ?? json['tipeIjin'] ?? '') as String,
        alasan: (json['alasan'] ?? '') as String,
        status: (json['status'] ?? '') as String,
      );
}

