import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/common_utils.dart';
import '../../shared/models/jadwal_kegiatan_by_day_list.dart';
import '../../services/jadwal_kegiatan_service.dart';

class JadwalKegiatanByDayPage extends StatefulWidget {
  const JadwalKegiatanByDayPage({super.key, required this.service});

  final JadwalKegiatanService service;

  @override
  State<JadwalKegiatanByDayPage> createState() =>
      _JadwalKegiatanByDayPageState();
}

class _JadwalKegiatanByDayPageState extends State<JadwalKegiatanByDayPage> {
  late Future<JadwalKegiatanByDay> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.meByDay();
  }

  Future<void> _reload() async {
    setState(() {
      _future = widget.service.meByDay();
    });
    await _future;
  }

  int _minutes(String? time) {
    if (time == null || !time.contains(':')) return 0;
    final parts = time.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return h * 60 + m;
  }

  String _safe(String? v) {
    if (v == null) return '-';
    final t = v.toString().trim();
    if (t.isEmpty) return '-';
    return t;
  }

  Widget _buildItem(JadwalKegiatanByDayList item) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: AppColors.textPrimary,
    );
    final metaStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.black54,
      fontSize: 13,
    );
    final descStyle = theme.textTheme.bodyMedium?.copyWith(
      color: Colors.black87,
      fontSize: 13,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _safe(item.nama),
              style: titleStyle,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 14,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 6),
                    Text(_safe(item.kategori), style: metaStyle),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 6),
                    Text('${_safe(item.jamAwal)} - ${_safe(item.jamAkhir)}', style: metaStyle),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.deskripsi != null && item.deskripsi!.trim().isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 14,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_safe(item.deskripsi), style: descStyle)),
                ],
              ),
              const SizedBox(height: 2),
            ],
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.apartment_rounded, size: 14, color: Colors.black45),
              const SizedBox(width: 8),
              Expanded(child: Text(_safe(item.jadwalKegiatanAsrama), style: metaStyle)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(String title, List<JadwalKegiatanByDayList> items) {
    final sorted = List<JadwalKegiatanByDayList>.from(items);
    sorted.sort((a, b) => _minutes(a.jamAwal).compareTo(_minutes(b.jamAwal)));

    final theme = Theme.of(context);
    final dayTitleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );
    final countStyle = theme.textTheme.bodySmall?.copyWith(color: Colors.black54);

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      collapsedBackgroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          Text(title, style: dayTitleStyle),
          const SizedBox(width: 8),
          Text('(${sorted.length} kegiatan)', style: countStyle),
        ],
      ),
      children: [
        if (sorted.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('Tidak ada jadwal kegiatan', style: countStyle),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(children: sorted.map(_buildItem).toList()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Jadwal Kegiatan Saya'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<JadwalKegiatanByDay>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 56,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat jadwal kegiatan: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _reload,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final data = snapshot.data!;
            final allEmpty =
                data.senin.isEmpty &&
                data.selasa.isEmpty &&
                data.rabu.isEmpty &&
                data.kamis.isEmpty &&
                data.jumat.isEmpty &&
                data.sabtu.isEmpty &&
                data.minggu.isEmpty;

            if (allEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 72,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada jadwal kegiatan untuk semua hari',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _reload,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDay('Senin', data.senin),
                _buildDay('Selasa', data.selasa),
                _buildDay('Rabu', data.rabu),
                _buildDay('Kamis', data.kamis),
                _buildDay("Jum'at", data.jumat),
                _buildDay('Sabtu', data.sabtu),
                _buildDay('Minggu', data.minggu),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
