import 'package:flutter/material.dart';
import 'package:manajemenasrama/shared/models/jadwal_kegiatan_list.dart';

import '../../shared/models/jadwal_kegiatan.dart';
import '../../services/jadwal_kegiatan_service.dart';
import '../../services/auth_service.dart';
import '../../core/utils/common_utils.dart';
import 'jadwal_kegiatan_form_page.dart';

// Top-level day labels so both page and dialog can use them
const List<String> kDaysLabels = [
  'SENIN',
  'SELASA',
  'RABU',
  'KAMIS',
  "JUM'AT",
  'SABTU',
  'MINGGU',
];

/// Simple CRUD page for Jadwal Kegiatan with dynamic form behavior and tag inputs.
class JadwalKegiatanPage extends StatefulWidget {
  const JadwalKegiatanPage({super.key, this.service});

  final JadwalKegiatanService? service;

  @override
  State<JadwalKegiatanPage> createState() => _JadwalKegiatanPageState();
}

class _JadwalKegiatanPageState extends State<JadwalKegiatanPage> {
  late final JadwalKegiatanService _service =
      widget.service ?? JadwalKegiatanService(authService: AuthService());

  late Future<List<JadwalKegiatanList>> _future;

  // Hardcoded sample options for users and asrama as requested
  final List<Map<String, dynamic>> _sampleUsers = const [
    {'id': 2, 'full_name': 'missi khumairo'},
    {'id': 10, 'full_name': 'Missi Khumairo'},
  ];

  final List<Map<String, dynamic>> _sampleAsrama = const [
    {'id': 3, 'nama': 'test12345'},
    {'id': 4, 'nama': 'Asrama B'},
  ];

  // Sample activity names and categories (kept separate so they can be replaced by API data later)
  final List<String> _sampleActivityNames = const [
    'Kegiatan Tadarus',
    'Kegiatan Olahraga',
    'Kegiatan Belajar',
  ];

  final List<String> _sampleCategories = const [
    'IBADAH',
    'PENDIDIKAN',
    'SOSIAL',
  ];

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  Future<void> _reload() async {
    final f = _service.list();
    setState(() {
      _future = f;
    });
    await f;
  }

  Future<void> _handleDelete(JadwalKegiatanList it) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus jadwal?'),
        content: Text('"${it.nama}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _service.delete(it.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));

      await _reload();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

  Future<void> _handleToggleActive(JadwalKegiatanList it) async {
    final isActive = it.status == true;
    final action = isActive ? 'Nonaktifkan' : 'Aktifkan';

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$action Jadwal'),
        content: Text(
          '"${it.nama}" akan diubah menjadi ${isActive ? 'nonaktif' : 'aktif'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _service.toggleActive(it.id, !isActive);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jadwal berhasil diubah menjadi ${isActive ? 'nonaktif' : 'aktif'}',
          ),
        ),
      );

      await _reload();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal $action jadwal: $e')));
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openForm({JadwalKegiatanList? existing}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => JadwalKegiatanFormPage(
          service: _service,
          existing: existing,
          sampleUsers: _sampleUsers,
          sampleAsrama: _sampleAsrama,
          sampleNames: _sampleActivityNames,
          sampleCategories: _sampleCategories,
        ),
      ),
    );

    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Kegiatan')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<JadwalKegiatanList>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Gagal memuat: ${snapshot.error}'),
                    ),
                  ),
                ],
              );
            }
            final list = snapshot.data ?? <JadwalKegiatanList>[];
            if (list.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(child: Text('Belum ada jadwal kegiatan')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, i) {
                final it = list[i];
                final days = hariListToLabels(parseHari(it.hari));
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    shape: const Border(),
                    collapsedShape: const Border(),

                    // Header yang tetap terlihat saat collapse
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: Icon(
                        Icons.event_note_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      it.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        '${it.kategori ?? '-'} • '
                        '${it.jamAwal ?? '-'} – ${it.jamAkhir ?? '-'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          it.status == true
                              ? Icons.check_circle_outline
                              : Icons.pause_circle_outline,
                          size: 19,
                          color: it.status == true
                              ? Colors.green
                              : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.expand_more),
                      ],
                    ),

                    // Detail yang terlihat ketika expand
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      _buildInfoRow(
                        Icons.calendar_view_week_rounded,
                        'Hari: $days',
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.date_range_rounded,
                        'Tanggal efektif: '
                        '${formatTanggalEffektif(it.tanggalAwalEfektif)} – '
                        '${formatTanggalEffektif(it.tanggalAkhirEfektif)}',
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.people_outline_rounded,
                        'Ustadzah: ${it.jadwalKegiatanUsers ?? '-'}',
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.apartment_rounded,
                        'Asrama: ${it.jadwalKegiatanAsrama ?? '-'}',
                      ),
                      const SizedBox(height: 16),

                      // Tombol aksi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _openForm(existing: it),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _handleDelete(it),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Hapus'),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: it.status == true
                                ? 'Nonaktifkan'
                                : 'Aktifkan',
                            onPressed: () => _handleToggleActive(it),
                            icon: Icon(
                              it.status == true
                                  ? Icons.toggle_on_outlined
                                  : Icons.toggle_off_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
