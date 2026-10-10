import 'package:flutter/material.dart';

import '../../core/api_error_handler.dart';
import '../../shared/models/asrama.dart';
import '../../services/asrama_service.dart';
import 'asrama_form_page.dart';

class AsramaPage extends StatefulWidget {
  const AsramaPage({super.key, required this.service});

  final AsramaService service;

  @override
  State<AsramaPage> createState() => _AsramaPageState();
}

class _AsramaPageState extends State<AsramaPage> {
  late Future<List<Asrama>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.list();
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
        builder: (_) => AsramaFormPage(service: widget.service, existing: existing),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title: $msg')));
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Asrama'),
      ),
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
                      child: Text('Gagal memuat: ${snap.error}', textAlign: TextAlign.center),
                    ),
                  ),
                ],
              );
            }
            final items = snap.data ?? const <Asrama>[];
            if (items.isEmpty) {
              return ListView(children: const [SizedBox(height: 160), Center(child: Text('Belum ada asrama'))]);
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
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
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

