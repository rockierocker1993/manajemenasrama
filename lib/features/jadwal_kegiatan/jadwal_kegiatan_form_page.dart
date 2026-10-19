import 'package:flutter/material.dart';
import 'package:manajemenasrama/shared/models/jadwal_kegiatan_list.dart';

import '../../core/api_error_handler.dart';
import '../../shared/models/jadwal_kegiatan.dart';
import '../../services/jadwal_kegiatan_service.dart';

// local day labels (kept here to avoid circular imports)
const List<String> kDaysLabels = [
  'SENIN',
  'SELASA',
  'RABU',
  'KAMIS',
  "JUM'AT",
  'SABTU',
  'MINGGU',
];

/// Form page for creating / editing Jadwal Kegiatan.
/// Follows the same structure and patterns as `user_form_page.dart`.
class JadwalKegiatanFormPage extends StatefulWidget {
  const JadwalKegiatanFormPage({
    super.key,
    required this.service,
    this.existing,
    required this.sampleUsers,
    required this.sampleAsrama,
    required this.sampleNames,
    required this.sampleCategories,
  });

  final JadwalKegiatanService service;
  final JadwalKegiatanList? existing;
  final List<Map<String, dynamic>> sampleUsers;
  final List<Map<String, dynamic>> sampleAsrama;
  final List<String> sampleNames;
  final List<String> sampleCategories;

  bool get isEdit => existing != null;

  @override
  State<JadwalKegiatanFormPage> createState() => _JadwalKegiatanFormPageState();
}

class _JadwalKegiatanFormPageState extends State<JadwalKegiatanFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Backing values for nama/kategori. The Autocomplete provides its own
  // TextEditingController via fieldViewBuilder; we keep a reference to it
  // (_fieldNamaController/_fieldKategoriController) when available. If not
  // available (early in init) we store values in `_nama`/`_kategori` and
  // sync later.
  String _nama = '';
  late final TextEditingController _deskripsiController =
      TextEditingController();
  String _kategori = '';

  TextEditingController? _fieldNamaController;
  TextEditingController? _fieldKategoriController;

  List<String> _hari = [];
  TimeOfDay? _jamAwal;
  TimeOfDay? _jamAkhir;
  DateTime? _tanggalAwal;
  DateTime? _tanggalAkhir;
  String _tipe = 'UMUM';

  List<Map<String, dynamic>> _selectedUsers = [];
  List<Map<String, dynamic>> _selectedAsrama = [];

  bool _saving = false;
  bool _loadingInit = false;

  @override
  void initState() {
    super.initState();
    _initFromExisting();
  }

  Future<void> _initFromExisting() async {
    final m = widget.existing;
    if (m == null) return;
    // If partial object was passed, fetch full data by id
    setState(() => _loadingInit = true);
    final full = await runApiCall(
      () async => widget.service.getById(m.id),
      context,
    );
    _applyModel(full!);
    if (mounted) setState(() => _loadingInit = false);
    return;
  }

  void _applyModel(JadwalKegiatan m) {
    _nama = m.nama;
    _deskripsiController.text = m.deskripsi ?? '';
    _kategori = m.kategori ?? '';
    // If Autocomplete field controllers are already available, sync them now
    if (_fieldNamaController != null) _fieldNamaController!.text = _nama;
    if (_fieldKategoriController != null)
      _fieldKategoriController!.text = _kategori;
    _hari = m.hari?.toList() ?? [];
    if (m.jamAwal != null) {
      final parts = m.jamAwal!.split(':');
      if (parts.length >= 2)
        _jamAwal = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
    }
    if (m.jamAkhir != null) {
      final parts = m.jamAkhir!.split(':');
      if (parts.length >= 2)
        _jamAkhir = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
    }
    if (m.tanggalAwalEfektif != null)
      _tanggalAwal = DateTime.tryParse(m.tanggalAwalEfektif!);
    if (m.tanggalAkhirEfektif != null)
      _tanggalAkhir = DateTime.tryParse(m.tanggalAkhirEfektif!);
    _tipe = m.tipeKegiatan ?? 'UMUM';
    _selectedUsers =
        m.jadwalKegiatanUsers
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];
    _selectedAsrama =
        m.jadwalKegiatanAsrama
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final body = {
      'nama': (_fieldNamaController?.text ?? _nama).trim(),
      if (_deskripsiController.text.trim().isNotEmpty)
        'deskripsi': _deskripsiController.text.trim(),
      if ((_fieldKategoriController?.text ?? _kategori).trim().isNotEmpty)
        'kategori': (_fieldKategoriController?.text ?? _kategori).trim(),
      'hari': _hari,
      'jam_awal': _jamAwal != null
          ? '${_jamAwal!.hour.toString().padLeft(2, '0')}:${_jamAwal!.minute.toString().padLeft(2, '0')}'
          : null,
      'jam_akhir': _jamAkhir != null
          ? '${_jamAkhir!.hour.toString().padLeft(2, '0')}:${_jamAkhir!.minute.toString().padLeft(2, '0')}'
          : null,
      'tanggal_awal_efektif': _tanggalAwal != null
          ? _tanggalAwal!.toIso8601String().split('T').first
          : null,
      'tanggal_akhir_efektif': _tanggalAkhir != null
          ? _tanggalAkhir!.toIso8601String().split('T').first
          : null,
      'tipe_kegiatan': _tipe,
      if (_selectedUsers.isNotEmpty)
        'jadwal_kegiatan_user_ids': _selectedUsers
            .map((e) {
              final raw = (e['id'] ?? '').toString();
              final parsed = int.tryParse(raw);
              return parsed ?? raw;
            })
            .toList(),
      if (_selectedAsrama.isNotEmpty)
        'jadwal_kegiatan_asrama_ids': _selectedAsrama
            .map((e) {
              final raw = (e['id'] ?? '').toString();
              final parsed = int.tryParse(raw);
              return parsed ?? raw;
            })
            .toList(),
    };

    final result = await runApiCall(() async {
      if (widget.isEdit) {
        return await widget.service.update(id: widget.existing!.id, body: body);
      }
      return await widget.service.create(body);
    }, context);

    if (!mounted) return;
    if (result == null) {
      setState(() => _saving = false);
      return;
    }

    // Show backend message or generic success
    final br = result as dynamic; // BaseResponse expected
    final msg = br.message ?? br.titleEn ?? br.titleId;
    if (msg != null && msg.toString().isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg.toString())));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit ? 'Perubahan disimpan' : 'Data berhasil disimpan',
          ),
        ),
      );
    }

    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Jadwal' : 'Tambah Jadwal'),
      ),
      body: SafeArea(
        child: _loadingInit
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama (combobox/autocomplete behaviour via Autocomplete)
                      Autocomplete<String>(
                        optionsBuilder: (textEditingValue) {
                          final input = textEditingValue.text
                              .trim()
                              .toLowerCase();
                          if (input.isEmpty) return widget.sampleNames;
                          return widget.sampleNames.where(
                            (opt) => opt.toLowerCase().contains(input),
                          );
                        },
                        onSelected: (s) {
                          _nama = s;
                          if (_fieldNamaController != null)
                            _fieldNamaController!.text = s;
                        },
                        fieldViewBuilder:
                            (
                              context,
                              fieldTextEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              // Keep a reference to the field controller so we can read the
                              // current text when saving. Do not mutate controller.text here.
                              _fieldNamaController ??=
                                  fieldTextEditingController;
                              // If we have a saved value from init, ensure controller shows it.
                              if (_fieldNamaController!.text.isEmpty &&
                                  _nama.isNotEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!mounted) return;
                                  if ((_fieldNamaController?.text ?? '') !=
                                      _nama)
                                    _fieldNamaController?.text = _nama;
                                });
                              }
                              return TextFormField(
                                controller: fieldTextEditingController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Nama',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Nama wajib diisi'
                                    : null,
                              );
                            },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _deskripsiController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Autocomplete<String>(
                        optionsBuilder: (textEditingValue) {
                          final input = textEditingValue.text
                              .trim()
                              .toLowerCase();
                          if (input.isEmpty) return widget.sampleCategories;
                          return widget.sampleCategories.where(
                            (opt) => opt.toLowerCase().contains(input),
                          );
                        },
                        onSelected: (s) {
                          _kategori = s;
                          if (_fieldKategoriController != null)
                            _fieldKategoriController!.text = s;
                        },
                        fieldViewBuilder:
                            (
                              context,
                              fieldTextEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              _fieldKategoriController ??=
                                  fieldTextEditingController;
                              if (_fieldKategoriController!.text.isEmpty &&
                                  _kategori.isNotEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!mounted) return;
                                  if ((_fieldKategoriController?.text ?? '') !=
                                      _kategori)
                                    _fieldKategoriController?.text = _kategori;
                                });
                              }
                              return TextFormField(
                                controller: fieldTextEditingController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Kategori',
                                  border: OutlineInputBorder(),
                                ),
                              );
                            },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        children: List.generate(kDaysLabels.length, (i) {
                          final day = (i + 1).toString();
                          final selected = _hari.contains(day);
                          return FilterChip(
                            label: Text(kDaysLabels[i]),
                            selected: selected,
                            onSelected: (s) => setState(() {
                              if (s) {
                                if (!_hari.contains(day)) _hari.add(day);
                              } else {
                                _hari.removeWhere((d) => d == day);
                              }
                            }),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Jam awal: ${_formatTime(_jamAwal)}'),
                          ),
                          TextButton(
                            onPressed: () => _pickTime(true),
                            child: const Text('Pilih'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Jam akhir: ${_formatTime(_jamAkhir)}'),
                          ),
                          TextButton(
                            onPressed: () => _pickTime(false),
                            child: const Text('Pilih'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tanggal awal: ${_tanggalAwal != null ? _tanggalAwal!.toIso8601String().split('T').first : '-'}',
                            ),
                          ),
                          TextButton(
                            onPressed: () => _pickDate(true),
                            child: const Text('Pilih'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tanggal akhir: ${_tanggalAkhir != null ? _tanggalAkhir!.toIso8601String().split('T').first : '-'}',
                            ),
                          ),
                          TextButton(
                            onPressed: () => _pickDate(false),
                            child: const Text('Pilih'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _tipe,
                        decoration: const InputDecoration(
                          labelText: 'Tipe Kegiatan',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'UMUM', child: Text('UMUM')),
                          DropdownMenuItem(
                            value: 'USTADZAH',
                            child: Text('USTADZAH'),
                          ),
                          DropdownMenuItem(
                            value: 'ASRAMA',
                            child: Text('ASRAMA'),
                          ),
                          DropdownMenuItem(
                            value: 'USTADZAH & ASRAMA',
                            child: Text('USTADZAH & ASRAMA'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _tipe = v ?? 'UMUM'),
                      ),
                      const SizedBox(height: 12),
                      if (_tipe == 'USTADZAH' ||
                          _tipe == 'USTADZAH & ASRAMA') ...[
                        const Text('Ustadzah'),
                        Wrap(
                          spacing: 6,
                          children: _selectedUsers
                              .map(
                                (u) => Chip(
                                  label: Text(u['full_name']),
                                  onDeleted: () => setState(
                                    () => _selectedUsers.removeWhere(
                                      (e) => e['id'] == u['id'],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Tambah Ustadzah',
                            border: OutlineInputBorder(),
                          ),
                          items: widget.sampleUsers
                              .map((u) => DropdownMenuItem(
                                    value: (u['id'] ?? '').toString(),
                                    child: Text((u['full_name'] ?? '').toString()),
                                  ))
                              .toList(),
                          onChanged: (id) {
                            if (id == null) return;
                            final sel = widget.sampleUsers.firstWhere(
                              (e) => (e['id'] ?? '').toString() == id,
                            );
                            if (!_selectedUsers.any(
                              (e) => (e['id'] ?? '').toString() == (sel['id'] ?? '').toString(),
                            ))
                              setState(() => _selectedUsers.add(sel));
                          },
                        ),
                      ],
                      if (_tipe == 'ASRAMA' ||
                          _tipe == 'USTADZAH & ASRAMA') ...[
                        const SizedBox(height: 12),
                        const Text('Asrama'),
                        Wrap(
                          spacing: 6,
                          children: _selectedAsrama
                              .map(
                                (a) => Chip(
                                  label: Text(a['nama']),
                                  onDeleted: () => setState(
                                    () => _selectedAsrama.removeWhere(
                                      (e) => e['id'] == a['id'],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Tambah Asrama',
                            border: OutlineInputBorder(),
                          ),
                          items: widget.sampleAsrama
                              .map((a) => DropdownMenuItem(
                                    value: (a['id'] ?? '').toString(),
                                    child: Text((a['nama'] ?? '').toString()),
                                  ))
                              .toList(),
                          onChanged: (id) {
                            if (id == null) return;
                            final sel = widget.sampleAsrama.firstWhere(
                              (e) => (e['id'] ?? '').toString() == id,
                            );
                            if (!_selectedAsrama.any(
                              (e) => (e['id'] ?? '').toString() == (sel['id'] ?? '').toString(),
                            ))
                              setState(() => _selectedAsrama.add(sel));
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
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
                            widget.isEdit ? 'Simpan Perubahan' : 'Buat Jadwal',
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

  String _formatTime(TimeOfDay? t) => t == null ? '-' : t.format(context);

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_jamAwal ?? TimeOfDay.now())
          : (_jamAkhir ?? TimeOfDay.now()),
    );
    if (picked == null) return;
    setState(() {
      if (isStart)
        _jamAwal = picked;
      else
        _jamAkhir = picked;
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _tanggalAwal : _tanggalAkhir) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart)
        _tanggalAwal = picked;
      else
        _tanggalAkhir = picked;
    });
  }
}
