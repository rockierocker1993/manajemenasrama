import 'package:flutter/material.dart';

// Note: avoid calling intl initializeDateFormatting here to keep this util
// synchronous and side-effect free. We format months manually in Indonesian.

// Common utility helpers used across the app.

const List<String> kCommonDayLabels = [
  'SENIN',
  'SELASA',
  'RABU',
  'KAMIS',
  "JUM'AT",
  'SABTU',
  'MINGGU',
];

/// Parse a flexible date string produced by backend into a [DateTime].
/// Supports ISO (YYYY-MM-DD), dd-MM-yyyy, d-M-yyyy and slash-separated variants.
DateTime? parseDateFlexible(String? input) {
  if (input == null) return null;
  // Try ISO first
  try {
    final iso = DateTime.tryParse(input);
    if (iso != null) return iso;
  } catch (_) {}

  // Try DD-MM-YYYY or D-M-YYYY
  final partsDash = input.split('-');
  if (partsDash.length == 3) {
    try {
      final a = int.parse(partsDash[0]);
      final b = int.parse(partsDash[1]);
      final c = int.parse(partsDash[2]);
      // If first part looks like year (>= 1000) treat as YYYY-MM-DD
      if (a >= 1000) return DateTime(a, b, c);
      return DateTime(c, b, a);
    } catch (_) {}
  }

  // Try slash-separated
  final partsSlash = input.split('/');
  if (partsSlash.length == 3) {
    try {
      final a = int.parse(partsSlash[0]);
      final b = int.parse(partsSlash[1]);
      final c = int.parse(partsSlash[2]);
      return DateTime(c, b, a);
    } catch (_) {}
  }

  return null;
}

/// Format a [DateTime] to an ISO-like yyyy-MM-dd string. Returns '-' for null.
String formatDateIso(DateTime? d) =>
    d == null ? '-' : d.toIso8601String().split('T').first;

/// Format [TimeOfDay]. If [context] is provided uses Material localization
/// (TimeOfDay.format). Otherwise returns "HH:mm".
String formatTimeOfDay(TimeOfDay? t, [BuildContext? context]) {
  if (t == null) return '-';
  if (context != null) return t.format(context);
  final hh = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  return '	$hh:$mm'.trim();
}

/// Show a simple confirmation dialog and return true when confirmed.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  String title = 'Konfirmasi',
  required String content,
  String confirmText = 'Hapus',
  String cancelText = 'Batal',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelText),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Parse `hari` field which may be: null, List, or comma-separated string,
/// returning a list of string tokens (e.g. ['1','2']).
List<String> parseHari(dynamic raw) {
  if (raw == null) return <String>[];
  if (raw is List) return raw.map((e) => e.toString()).toList();
  final s = raw.toString();
  if (s.contains(','))
    return s
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  return [s.trim()];
}

/// Convert list of hari numbers (as strings) to readable labels using [kCommonDayLabels].
String hariListToLabels(List<String>? hari) {
  if (hari == null || hari.isEmpty) return '-';
  return hari
      .map((d) {
        final idx = int.tryParse(d.toString()) ?? 0;
        if (idx >= 1 && idx <= kCommonDayLabels.length)
          return kCommonDayLabels[idx - 1];
        return d.toString();
      })
      .join(', ');
}

/// Extract list of ids from a list of maps: [{ 'id': 1}, ...]
List<int> extractIdsFromList(List<dynamic>? raw) {
  if (raw == null) return <int>[];
  final out = <int>[];
  for (final e in raw) {
    try {
      final id = e is Map ? e['id'] : null;
      if (id is int)
        out.add(id);
      else if (id is String) {
        final v = int.tryParse(id);
        if (v != null) out.add(v);
      }
    } catch (_) {}
  }
  return out;
}

/// Safely parse an integer from dynamic input.
int? safeInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

// Add other small helpers here as needed.

String formatTanggalEffektif(String? tanggal) {
  if (tanggal == null || tanggal.isEmpty) return '-';

  try {
    // Try to parse using our flexible parser first (handles ISO and other formats)
    final dt = parseDateFlexible(tanggal) ?? DateTime.tryParse(tanggal);
    if (dt == null) return tanggal;

    const idMonths = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final day = dt.day.toString().padLeft(2, '0');
    final monthName = idMonths[dt.month - 1];
    final year = dt.year.toString();
    return '$day $monthName $year';
  } catch (e) {
    debugPrint("error formatTanggalEffektif: $e");
    return tanggal;
  }
}
