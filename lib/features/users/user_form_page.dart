import 'package:flutter/material.dart';

import '../../core/validators/password_validator.dart';
import '../../shared/models/profile.dart';
import '../../shared/models/user_role.dart';
import '../../shared/models/base_response.dart';
import '../../services/user_service.dart';
import '../../core/api_error_handler.dart';

/// Create / edit a user.
///
/// Returns `true` via `Navigator.pop` when the list should refresh.
class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key, required this.service, this.existing});

  final UserService service;
  final Profile? existing;

  bool get isEdit => existing != null;

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username = TextEditingController(
    text: widget.existing?.username ?? '',
  );
  late final TextEditingController _fullName = TextEditingController(
    text: widget.existing?.fullName ?? '',
  );
  final TextEditingController _password = TextEditingController();
  // Default new users to 'pengurus' (allowed create options). If editing,
  // preserve the existing role.
  late UserRole _role = widget.existing?.role ?? UserRole.pengurus;

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
    // Use the generic API runner which shows a popup on error. Success
    // notifications are handled manually below (no popup on success).
    final result = await runApiCall(() async {
      if (widget.isEdit) {
        return await widget.service.update(
          id: widget.existing!.id,
          username: _username.text,
          fullName: _fullName.text,
          role: _role,
          password: _password.text.isEmpty ? null : _password.text,
        );
      }
      return await widget.service.create(
        username: _username.text,
        fullName: _fullName.text,
        password: _password.text,
        role: _role,
      );
    }, context);

    if (!mounted) return;
    if (result == null) {
      // Error already shown by runApiCall. Just stop saving state.
      setState(() => _saving = false);
      return;
    }

    // On success, show message from backend when present, otherwise default.
    final br = result as BaseResponse<dynamic>;
    final msg = br.message ?? br.titleEn ?? br.titleId;
    if (msg != null && msg.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit ? 'Perubahan disimpan' : 'Pengguna dibuat',
          ),
        ),
      );
    }

    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    // If editing an existing Super Admin, the dropdown should be disabled
    // and only show the Super Admin value. For non-super-admin (or when
    // creating a new user) only allow Pengurus and Ustadzah choices.
    final bool isSuperAdminExisting =
        widget.isEdit && widget.existing?.role == UserRole.superAdmin;

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
                  helperText: 'Min. 8 karakter, kombinasi huruf besar, kecil, angka & simbol',
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
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
                // If editing a Super Admin, only show that value and disable
                // changes. Otherwise, only show Pengurus and Ustadzah.
                items:
                    (isSuperAdminExisting
                            ? [UserRole.superAdmin]
                            : [UserRole.pengurus, UserRole.ustadzah])
                        .map(
                          (r) =>
                              DropdownMenuItem(value: r, child: Text(r.label)),
                        )
                        .toList(),
                onChanged: isSuperAdminExisting
                    ? null
                    : (v) => setState(() => _role = v ?? _role),
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
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    widget.isEdit ? 'Simpan Perubahan' : 'Buat Pengguna',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
