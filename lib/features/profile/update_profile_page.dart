import 'package:flutter/material.dart';

import '../../core/validators/password_validator.dart';
import '../../shared/models/profile.dart';
import '../../shared/models/base_response.dart';
import '../../services/user_service.dart';
import '../../core/api_error_handler.dart';

/// Page allowing the current user to view and update their profile.
class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key, required this.service});

  final UserService service;

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username = TextEditingController();
  late final TextEditingController _fullName = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _obscure = true;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _username.dispose();
    _fullName.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
    });
    try {
      final p = await widget.service.me();
      if (!mounted) return;
      setState(() {
        _profile = p;
        _username.text = p.username;
        _fullName.text = p.fullName;
      });
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Gagal memuat profil'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String? _validateUsername(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Username wajib diisi';
    if (s.length < 3) return 'Minimal 3 karakter';
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(s)) return 'Ada karakter tidak valid';
    return null;
  }

  String? _validateFullName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Nama lengkap wajib diisi';
    if (s.length < 2) return 'Minimal 2 karakter';
    return null;
  }

  String? _validatePassword(String? v) {
    // Optional: only validate if user entered a new password
    if (v == null || v.isEmpty) return null;
    return PasswordValidator.validate(v);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final result = await runApiCall(() async {
      return await widget.service.updateMe(
        username: _username.text.trim(),
        fullName: _fullName.text.trim(),
        password: _password.text.isEmpty ? null : _password.text,
      );
    }, context);

    if (!mounted) return;
    setState(() => _saving = false);

    if (result == null) return; // runApiCall handled errors

    final br = result as BaseResponse<dynamic>;
    final msg = br.message ?? br.titleEn ?? br.titleId ?? 'Profil tersimpan';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    // Keep the user on the page; the UserService already replaced the token when present.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
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
                        labelText: 'Password Baru (opsional)',
                        helperText:
                            'Kosongkan jika tidak ingin mengubah password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: _validatePassword,
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
                        label: const Text('Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

