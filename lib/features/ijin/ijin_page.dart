import 'package:flutter/material.dart';

import '../../core/api_error_handler.dart';
import '../../services/ijin_service.dart';
import '../../shared/models/ijin.dart';
import '../../shared/models/profile.dart';
import '../../shared/models/user_role.dart';
import '../../core/constants/app_colors.dart';

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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _tanggalCtrl = TextEditingController();
  final TextEditingController _alasanCtrl = TextEditingController();
  String _tipe = 'IJIN';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _tanggalCtrl.dispose();
    _alasanCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => _future = widget.service.list());
    await _future;
  }

  Future<void> _showCreateDialog() async {
    _namaCtrl.clear();
    _tanggalCtrl.text = '';
    _alasanCtrl.clear();
    _tipe = 'IJIN';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buat Ijin / Sakit'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Santri'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tanggalCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Tanggal Ijin'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) _tanggalCtrl.text = picked.toIso8601String().split('T').first;
                  },
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Tanggal wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _tipe,
                  items: const [
                    DropdownMenuItem(value: 'IJIN', child: Text('IJIN')),
                    DropdownMenuItem(value: 'SAKIT', child: Text('SAKIT')),
                  ],
                  onChanged: (v) => setState(() => _tipe = v ?? 'IJIN'),
                  decoration: const InputDecoration(labelText: 'Tipe Ijin'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _alasanCtrl,
                  decoration: const InputDecoration(labelText: 'Alasan'),
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Alasan wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          FilledButton.tonal(
            onPressed: () async {
              if (!(_formKey.currentState?.validate() ?? false)) return;
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => _creating = true);
      final body = {
        'nama_santri': _namaCtrl.text.trim(),
        'tanggal_ijin': _tanggalCtrl.text.trim(),
        'tipe_ijin': _tipe,
        'alasan': _alasanCtrl.text.trim(),
      };

      final res = await runApiCall(() async => await widget.service.create(body), context);
      setState(() => _creating = false);
      if (res != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ijin berhasil dibuat')));
        _reload();
      }
    }
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
    final res = await runApiCall(() async => await widget.service.approve(id: id, status: status), context);
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
                      onPressed: _creating ? null : _showCreateDialog,
                      icon: _creating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.add),
                      label: const Text('Buat'),
                      backgroundColor: AppColors.primary,
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
    final status = (item.status ?? '').toUpperCase();
    Color statusColor;
    IconData statusIcon;
    switch (status) {
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

    final typeIcon = (item.tipeIjin?.toUpperCase() == 'SAKIT') ? Icons.healing : Icons.event_note;

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
                Text('${item.tanggalIjin}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
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
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
              child: Chip(
                key: ValueKey(status),
                avatar: Icon(statusIcon, size: 16, color: statusColor),
                label: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
                backgroundColor: statusColor.withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            if (role == UserRole.pengurus && status == 'PENDING') ...[
              const SizedBox(height: 8),
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

