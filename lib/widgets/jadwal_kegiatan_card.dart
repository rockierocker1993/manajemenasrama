import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/jadwal_kegiatan_list.dart';

class JadwalKegiatanCard extends StatelessWidget {
  final List<JadwalKegiatanList> jadwal;
  final VoidCallback? onTap;

  const JadwalKegiatanCard({super.key, required this.jadwal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final today = DateTime.now().weekday;

    final todaySchedules = jadwal.where((item) {
      if (item.status != true) return false;

      return item.hari?.any((day) => int.tryParse(day.toString()) == today) ??
          false;
    }).toList();

    int minutes(String? time) {
      if (time == null || !time.contains(':')) return 0;

      final parts = time.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      return hour * 60 + minute;
    }

    final currentMinutes = now.hour * 60 + now.minute;

    todaySchedules.sort(
      (a, b) => minutes(a.jamAwal).compareTo(minutes(b.jamAwal)),
    );

    final upcoming = todaySchedules
        .where((item) => minutes(item.jamAkhir) > currentMinutes)
        .toList();

    final nextSchedule = upcoming.isNotEmpty ? upcoming.first : null;

    bool isOngoing(JadwalKegiatanList item) {
      return currentMinutes >= minutes(item.jamAwal) &&
          currentMinutes < minutes(item.jamAkhir);
    }

    final ongoingCount = todaySchedules.where(isOngoing).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jadwal Kegiatan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Agenda kegiatan hari ini',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.event_available_rounded,
                color: Colors.white70,
                size: 25,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Total kegiatan
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${todaySchedules.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10, bottom: 5),
                child: Text(
                  'kegiatan hari ini',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status kegiatan
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                Icons.play_circle_outline_rounded,
                '$ongoingCount berlangsung',
              ),
              _buildBadge(
                Icons.schedule_rounded,
                '${upcoming.length} belum selesai',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Agenda berikutnya
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: nextSchedule == null
                ? Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          todaySchedules.isEmpty
                              ? 'Belum ada kegiatan terjadwal hari ini.'
                              : 'Semua kegiatan hari ini telah selesai.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isOngoing(nextSchedule)
                                ? Icons.play_circle_fill_rounded
                                : Icons.upcoming_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isOngoing(nextSchedule)
                                  ? 'SEDANG BERLANGSUNG'
                                  : 'AGENDA BERIKUTNYA',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        nextSchedule.nama ?? 'Tanpa nama',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        nextSchedule.kategori ?? 'Umum',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Jam kegiatan
                      _buildDetailRow(
                        Icons.access_time_rounded,
                        '${nextSchedule.jamAwal ?? '-'} - '
                        '${nextSchedule.jamAkhir ?? '-'}',
                      ),

                      // Asrama
                      if (nextSchedule.jadwalKegiatanAsrama?.isNotEmpty ==
                          true) ...[
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          Icons.apartment_rounded,
                          nextSchedule.jadwalKegiatanAsrama!.join(', '),
                        ),
                      ],

                      // Ustadzah / pembimbing
                      if (nextSchedule.jadwalKegiatanUsers?.isNotEmpty ==
                          true) ...[
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          Icons.people_outline_rounded,
                          nextSchedule.jadwalKegiatanUsers!.join(', '),
                        ),
                      ],
                    ],
                  ),
          ),

          // Daftar kegiatan hari ini
          if (todaySchedules.length > 1) ...[
            const SizedBox(height: 22),

            const Text(
              'AGENDA HARI INI',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 14),

            ...todaySchedules.take(3).map((item) {
              final ongoing = isOngoing(item);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Jam mulai
                    Container(
                      width: 62,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.jamAwal ?? '--:--',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Nama dan kategori
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nama ?? 'Tanpa nama',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.kategori ?? 'Umum',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (ongoing) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.lightGreenAccent.withValues(
                            alpha: 0.18,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Berlangsung',
                          style: TextStyle(
                            color: Colors.lightGreenAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],

          // Tombol lihat semua
          if (onTap != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lihat semua jadwal saya',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
