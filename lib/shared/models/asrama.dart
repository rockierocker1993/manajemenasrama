class Asrama {
  Asrama({required this.id, required this.nama});

  final int id;
  final String nama;

  factory Asrama.fromJson(Map<String, dynamic> json) {
    return Asrama(
      id: (json['id'] as num).toInt(),
      nama: (json['nama'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nama': nama};
}
