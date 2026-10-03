import 'package:flutter/material.dart';

import '../../core/backend/backend_api_client.dart';
import '../../core/validators/password_validator.dart';
import '../../shared/models/app_user.dart';
import '../../shared/models/user_role.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

/// Create / edit a user.
///
/// Returns `true` via `Navigator.pop` when the list should refresh.
class UserFormPage extends StatefulWidget {
  const UserFormPage({
    super.key,
    required this.service,
    this.existing,
  });

  final UserService service;
  final AppUser? existing;

  bool get isEdit => existing != null;

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username =
      TextEditingController(text: widget.existing?.username ?? '');
  late final TextEditingController _fullName =
      TextEditingController(text: widget.existing?.fullName ?? '');
  final TextEditingController _password = TextEditingController();
  late UserRole _role = widget.existing?.role ?? UserRole.superAdmin;

  bool _obscure = true;
  bool _saving = false;

  @override
  void dispose() {
    _username.dispose();
    _fullName.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateUsername(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Username wajib diisi';
    if (s.length < 3) return 'Minimal 3 karakter';
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(s)) {
      return 'Hanya huruf, angka, titik, underscore, dan dash';
    }
    return null;
  }

  String? _validateFullName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Nama lengkap wajib diisi';
    if (s.length < 2) return 'Minimal 2 karakter';
    return null;
  }

  String? _validatePassword(String? v) {
    // On edit, empty password = keep existing.
    if (widget.isEdit && (v == null || v.isEmpty)) return null;
    return PasswordValidator.validate(v);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      if (widget.isEdit) {
        await widget.service.update(
          id: widget.existing!.id,
          username: _username.text,
          fullName: _fullName.text,
          role: _role,
          password: _password.text.isEmpty ? null : _password.text,
        );
      } else {
        await widget.service.create(
          username: _username.text,
          fullName: _fullName.text,
          password: _password.text,
          role: _role,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEdit ? 'Perubahan disimpan' : 'Pengguna dibuat')),
      );
      Navigator.of(context).pop(true);
    } on BackendApiException catch (e) {
      final msg = e.message.toLowerCase();
      final friendly = msg.contains('duplicate') || msg.contains('unique')
          ? 'Username sudah digunakan'
          : e.message;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendly)));
    } on AppAuthException catch (e) {
      final msg = e.message.toLowerCase();
      final friendly =
          msg.contains('already') || msg.contains('registered') || msg.contains('exists')
              ? 'Username sudah digunakan'
              : e.message;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendly)));
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Pengguna' : 'Tambah Pengguna'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(),
                ),
                validator: _validateUsername,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _validateFullName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: widget.isEdit
                      ? 'Password (kosongkan jika tidak diubah)'
                      : 'Password',
                  helperText:
                      'Min. 8 karakter, kombinasi huruf besar, kecil, angka & simbol',
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v ?? _role),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(widget.isEdit ? 'Simpan Perubahan' : 'Buat Pengguna'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
