import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/models/profile.dart';
import '../../shared/models/user_role.dart';
import '../../services/user_service.dart';
import 'user_form_page.dart';

/// List of application users with create / edit / delete actions.
class UsersPage extends StatefulWidget {
  const UsersPage({super.key, required this.userService});

  final UserService userService;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final UserService _service = widget.userService;
  late Future<List<Profile>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  Future<void> _reload() async {
    final future = _service.list();
    setState(() {
      _future = future;
    });
    await future;
  }

  Future<void> _openForm({Profile? existing}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => UserFormPage(service: _service, existing: existing),
      ),
    );
    if (changed == true) _reload();
  }

  Future<void> _confirmDelete(Profile user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus pengguna?'),
        content: Text('"${user.fullName}" akan dihapus permanen.'),
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
    try {
      await _service.delete(user.username);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pengguna dihapus')));
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Profile>>(
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
            final users = snap.data ?? const <Profile>[];
            if (users.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(child: Text('Belum ada pengguna')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: users.length,
              separatorBuilder: (_, _) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final u = users[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: u.role == UserRole.pengurus
                        ? AppColors.primary
                        : AppColors.accent,
                    child: Text(
                      u.fullName.isNotEmpty
                          ? u.fullName.characters.first.toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(u.fullName),
                  subtitle: Text('@${u.username}  •  ${u.role.label}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _openForm(existing: u);
                      if (v == 'delete') _confirmDelete(u);
                    },
                    itemBuilder: (_) =>
                        u.role.label == UserRole.superAdmin.label
                        ? const []
                        : const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                  ),
                  onTap: () => _openForm(existing: u),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
