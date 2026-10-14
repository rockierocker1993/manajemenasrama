import 'package:flutter/material.dart';

import '../../core/api_error_handler.dart';
import '../../services/ijin_service.dart';
import '../../shared/models/ijin.dart';
import '../../shared/models/profile.dart';
import '../../shared/models/user_role.dart';
import '../../core/constants/app_colors.dart';
import './ijin_form_page.dart';
import '../../core/utils/common_utils.dart';

class IjinPage extends StatefulWidget {
  const IjinPage({super.key, required this.service, required this.currentProfile});

  final IjinService service;
  final Profile currentProfile;

  @override
  State<IjinPage> createState() => _IjinPageState();
}

class _IjinPageState extends State<IjinPage> {
  late Future<List<Ijin>> _future;
  bool _creating = false;
  int? _processingId;

  // form is handled in separate page `IjinFormPage`

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _reload() async {
    final future = widget.service.list();
    setState(() {
      _future = future;
    });
    await future;
  }

  Future<void> _openForm({Ijin? existing}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => IjinFormPage(service: widget.service, existing: existing),
      ),
    );
    if (changed == true) _reload();
  }

  Future<void> _approve(int id, String status) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin mengubah status menjadi $status?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          FilledButton.tonal(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ya')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _processingId = id);
    final res = await runApiCall(() async => await widget.service.approve(id: id, status: status), context);
    setState(() => _processingId = null);
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status diubah: $status')));
      _reload();
    }
  }

  // ...existing code...

  @override
  Widget build(BuildContext context) {
    final role = widget.currentProfile.role;
    final canCreate = role == UserRole.ustadzah || role == UserRole.pengurus;

    return Scaffold(
      appBar: AppBar(title: const Text('Ijin & Sakit')),
      floatingActionButton: canCreate
                      ? FloatingActionButton.extended(
                                      onPressed: _creating ? null : () => _openForm(),
                      icon: _creating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.add),
                      label: const Text('Buat'),
                    )
          : null,
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Ijin>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snap.hasError) return ListView(children: [Padding(padding: const EdgeInsets.all(20), child: Text('Gagal memuat: ${snap.error}'))]);
            final items = snap.data ?? [];
            if (items.isEmpty) return ListView(children: const [SizedBox(height: 120), Center(child: Text('Belum ada ijin'))]);
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (_, i) => _buildItem(items[i], role),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(Ijin item, UserRole role) {
    final statusRaw = item.status.toUpperCase();
    // map backend status to UI label (Indonesian)
    String statusLabel;
    switch (statusRaw) {
      case 'APPROVED':
        statusLabel = 'Disetujui';
        break;
      case 'REJECTED':
        statusLabel = 'Ditolak';
        break;
      case 'PENDING':
      default:
        statusLabel = 'Menunggu Persetujuan';
        break;
    }

    Color statusColor;
    IconData statusIcon;
    switch (statusRaw) {
      case 'APPROVED':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'REJECTED':
        statusColor = AppColors.danger;
        statusIcon = Icons.cancel;
        break;
      case 'PENDING':
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_top;
        break;
    }

    final typeIcon = (item.tipeIjin.toUpperCase() == 'SAKIT') ? Icons.healing : Icons.event_note;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary,
          child: Icon(typeIcon, color: AppColors.white, size: 18),
        ),
        title: Text(item.namaSantri, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('${formatTanggalEffektif(item.tanggalIjin)}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(width: 12),
                Icon(Icons.label, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(item.tipeIjin, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.alasan, style: const TextStyle(fontSize: 14)),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
              child: Chip(
                key: ValueKey(statusRaw),
                avatar: Icon(statusIcon, size: 16, color: statusColor),
                label: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
                backgroundColor: statusColor.withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            if (role == UserRole.pengurus && statusRaw == 'PENDING') ...[
              const SizedBox(width: 8),
              if (_processingId == item.id)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
                  onSelected: (v) => _approve(item.id, v),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'APPROVED',
                      child: Row(children: const [Icon(Icons.check, color: Colors.green), SizedBox(width: 8), Text('Setujui')]),
                    ),
                    PopupMenuItem(
                      value: 'REJECTED',
                      child: Row(children: const [Icon(Icons.close, color: Colors.red), SizedBox(width: 8), Text('Tolak')]),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

