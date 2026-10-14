import 'package:flutter/material.dart';

import '../../core/api_error_handler.dart';
import '../../shared/models/ijin.dart';
import '../../shared/models/base_response.dart';
import '../../services/ijin_service.dart';

class IjinFormPage extends StatefulWidget {
  const IjinFormPage({super.key, required this.service, this.existing});

  final IjinService service;
  final Ijin? existing;

  bool get isEdit => existing != null;

  @override
  State<IjinFormPage> createState() => _IjinFormPageState();
}

class _IjinFormPageState extends State<IjinFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama = TextEditingController(text: widget.existing?.namaSantri ?? '');
  late final TextEditingController _tanggal = TextEditingController(text: widget.existing?.tanggalIjin ?? '');
  late final TextEditingController _alasan = TextEditingController(text: widget.existing?.alasan ?? '');
  String _tipe = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tipe = widget.existing?.tipeIjin ?? 'IJIN';
  }

  @override
  void dispose() {
    _nama.dispose();
    _tanggal.dispose();
    _alasan.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final body = {
      'nama_santri': _nama.text.trim(),
      'tanggal_ijin': _tanggal.text.trim(),
      'tipe_ijin': _tipe,
      'alasan': _alasan.text.trim(),
    };

    final result = await runApiCall(() async {
      // For now only create is supported by service
      if (widget.isEdit) {
        // If update endpoint is available in the service in future, call it here.
        return await widget.service.create(body);
      }
      return await widget.service.create(body);
    }, context);

    setState(() => _saving = false);
    if (result == null) return; // error already shown

    final br = result as BaseResponse<dynamic>;
    final title = br.titleEn ?? br.titleId ?? 'Sukses';
    final msg = br.message ?? br.messageEn ?? br.messageId ?? '';

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? 'Edit Ijin' : 'Buat Ijin / Sakit')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nama,
                  decoration: const InputDecoration(labelText: 'Nama Santri', border: OutlineInputBorder()),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tanggal,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Tanggal Ijin', border: OutlineInputBorder()),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_tanggal.text) ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) _tanggal.text = picked.toIso8601String().split('T').first;
                  },
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Tanggal wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _tipe,
                  items: const [
                    DropdownMenuItem(value: 'IJIN', child: Text('IJIN')),
                    DropdownMenuItem(value: 'SAKIT', child: Text('SAKIT')),
                  ],
                  onChanged: (v) => setState(() => _tipe = v ?? 'IJIN'),
                  decoration: const InputDecoration(labelText: 'Tipe Ijin', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _alasan,
                  decoration: const InputDecoration(labelText: 'Alasan', border: OutlineInputBorder()),
                  maxLines: 4,
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Alasan wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send),
                    label: Text(widget.isEdit ? 'Simpan Perubahan' : 'Kirim'),
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

