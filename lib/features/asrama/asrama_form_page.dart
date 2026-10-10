import 'package:flutter/material.dart';

import '../../core/api_error_handler.dart';
import '../../shared/models/asrama.dart';
import '../../shared/models/base_response.dart';
import '../../services/asrama_service.dart';

class AsramaFormPage extends StatefulWidget {
  const AsramaFormPage({super.key, required this.service, this.existing});

  final AsramaService service;
  final Asrama? existing;

  bool get isEdit => existing != null;

  @override
  State<AsramaFormPage> createState() => _AsramaFormPageState();
}

class _AsramaFormPageState extends State<AsramaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama = TextEditingController(
    text: widget.existing?.nama ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _nama.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final result = await runApiCall(() async {
      if (widget.isEdit) {
        return await widget.service.update(
          id: widget.existing!.id,
          nama: _nama.text.trim(),
        );
      }
      return await widget.service.create(nama: _nama.text.trim());
    }, context);

    setState(() => _saving = false);
    if (result == null) return; // error already shown

    // result is BaseResponse
    final br = result as BaseResponse<dynamic>;
    final title = br.titleEn ?? br.titleId ?? 'Sukses';
    final msg = br.message ?? br.messageEn ?? br.messageId ?? '';

    // Show success dialog (caller requested success popup handled manually)
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Asrama' : 'Tambah Asrama'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nama,
                  decoration: const InputDecoration(
                    labelText: 'Nama Asrama',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
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
                      widget.isEdit ? 'Simpan Perubahan' : 'Buat Asrama',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
