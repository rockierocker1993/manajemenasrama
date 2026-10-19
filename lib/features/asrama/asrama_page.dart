import 'package:flutter/material.dart';
import 'package:manajemenasrama/services/auth_service.dart';
import 'package:manajemenasrama/services/jadwal_kegiatan_service.dart';
import 'package:manajemenasrama/services/user_service.dart';
import '../../shared/models/user_role.dart';

import '../../core/api_error_handler.dart';
import '../../shared/models/asrama.dart';
import '../../services/asrama_service.dart';
import 'asrama_form_page.dart';
import 'package:manajemenasrama/features/jadwal_kegiatan/jadwal_kegiatan_asrama_by_day_page.dart' as byday_page;


class AsramaPage extends StatefulWidget {
  const AsramaPage({super.key, required this.service});

  final AsramaService service;

  @override
  State<AsramaPage> createState() => _AsramaPageState();
}

class _AsramaPageState extends State<AsramaPage> {
  late Future<List<Asrama>> _future;
  UserRole? _currentRole;

  @override
  void initState() {
    super.initState();
    _future = widget.service.list();
    _loadProfileRole();
  }

  Future<void> _loadProfileRole() async {
    try {
      final auth = AuthService();
      await auth.init();
      final userService = UserService(authService: auth);
      final profile = await userService.me();
      if (!mounted) return;
      setState(() => _currentRole = profile.role);
    } catch (_) {
      // ignore fetch role errors; default will be null which shows full menu
    }
  }

  Future<void> _reload() async {
    final future = widget.service.list();
    setState(() {
      _future = future;
    });
    await future;
  }

  Future<void> _openForm({Asrama? existing}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AsramaFormPage(service: widget.service, existing: existing),
      ),
    );
    if (changed == true) _reload();
  }

  Future<void> _confirmDelete(Asrama a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Asrama?'),
        content: Text('Asrama "${a.nama}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final res = await runApiCall(() => widget.service.delete(a.id), context);
    if (res == null) return; // error shown by runApiCall

    // show success from backend when available
    final title = res.titleEn ?? res.titleId ?? 'Sukses';
    final msg = res.message ?? res.messageEn ?? res.messageId ?? '';
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$title: $msg')));
      _reload();
    }
  }

  Future<void> _openJadwalKegiatan(Asrama a) async {
    final auth = AuthService();
    await auth.init();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => byday_page.JadwalKegiatanAsramaByDayPage(
          service: JadwalKegiatanService(authService: auth),
          asramaId: a.id,
          asramaName: a.nama,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Asrama')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Asrama>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Gagal memuat: ${snap.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }
            final items = snap.data ?? const <Asrama>[];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(child: Text('Belum ada asrama')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final a = items[i];
                return ListTile(
                  title: Text(a.nama),
                  subtitle: Text('ID: ${a.id}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _openForm(existing: a);
                      if (v == 'delete') _confirmDelete(a);
                      if (v == 'jadwalKegiatan') _openJadwalKegiatan(a);
                    },
                    itemBuilder: (_) {
                      final List<PopupMenuEntry<String>> items = [];
                      // If current role is USTADZAH, only show 'Jadwal Kegiatan'
                      if (_currentRole == UserRole.ustadzah) {
                        items.add(const PopupMenuItem(value: 'jadwalKegiatan', child: Text('Jadwal Kegiatan')));
                        return items;
                      }
                      // default: show edit, delete and jadwal
                      items.add(const PopupMenuItem(value: 'edit', child: Text('Edit')));
                      items.add(const PopupMenuItem(value: 'delete', child: Text('Hapus')));
                      items.add(const PopupMenuItem(value: 'jadwalKegiatan', child: Text('Jadwal Kegiatan')));
                      return items;
                    },
                  ),
                  onTap: () => _openForm(existing: a),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
