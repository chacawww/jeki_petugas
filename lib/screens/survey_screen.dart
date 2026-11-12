import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/photo_picker.dart';

/// Survei lokasi: kondisi aktual, tingkat kerusakan, deskripsi, foto.
/// Hasilnya dikirim ke Admin sebagai bahan perencanaan bahan & anggaran.
class SurveyScreen extends StatefulWidget {
  final Tugas tugas;
  const SurveyScreen({super.key, required this.tugas});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _kondisi = TextEditingController();
  final _catatan = TextEditingController();
  Tingkat? _tingkat;
  XFile? _foto;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Isi ulang bila survei sebelumnya sudah pernah disimpan.
    _kondisi.text = widget.tugas.kondisiAktual ?? '';
    _catatan.text = widget.tugas.catatanSurvei ?? '';
    _tingkat = widget.tugas.tingkat;
  }

  @override
  void dispose() {
    _kondisi.dispose();
    _catatan.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_foto == null) {
      showSnack(context, 'Foto dokumentasi survei wajib diunggah.', error: true);
      return;
    }
    if (_tingkat == null) {
      showSnack(context, 'Pilih tingkat kerusakan.', error: true);
      return;
    }
    if (_kondisi.text.trim().isEmpty) {
      showSnack(context, 'Isi kondisi aktual di lapangan.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await TugasService.kirimSurvei(
        widget.tugas.id,
        kondisiAktual: _kondisi.text.trim(),
        tingkat: _tingkat!,
        catatan: _catatan.text.trim(),
        foto: _foto,
      );
      if (mounted) Navigator.of(context).pop('Survei terkirim ke Admin.');
    } catch (e) {
      if (mounted) showSnack(context, 'Gagal mengirim survei: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tugas;
    return Scaffold(
      appBar: AppBar(title: const Text('Survei Lokasi')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      NetImage(url: t.fotoUrl, width: 48, height: 48, radius: 10),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.kode,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                            Text(t.judul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionTitle('Bukti Visual'),
                PhotoPicker(
                  label: 'Ambil / Unggah Foto Kerusakan',
                  value: _foto,
                  onPicked: (f) => setState(() => _foto = f),
                ),
                const SectionTitle('Kondisi Aktual'),
                TextField(
                  controller: _kondisi,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        'Gambarkan kondisi sebenarnya di lapangan (ukuran, kedalaman, dampak)',
                  ),
                ),
                const SectionTitle('Tingkat Kerusakan'),
                Row(
                  children: [
                    for (final tk in Tingkat.values) ...[
                      Expanded(child: _TingkatOption(
                        tingkat: tk,
                        selected: _tingkat == tk,
                        onTap: () => setState(() => _tingkat = tk),
                      )),
                      if (tk != Tingkat.values.last) const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SectionTitle('Deskripsi / Catatan Lapangan'),
                TextField(
                  controller: _catatan,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Tambahkan catatan lain yang perlu diketahui Admin',
                  ),
                ),
              ],
            ),
          ),
          BottomAction(
            label: 'Kirim Survei',
            icon: Icons.send,
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _TingkatOption extends StatelessWidget {
  final Tingkat tingkat;
  final bool selected;
  final VoidCallback onTap;

  const _TingkatOption({
    required this.tingkat,
    required this.selected,
    required this.onTap,
  });

  Color get _color {
    switch (tingkat) {
      case Tingkat.ringan:
        return AppColors.success;
      case Tingkat.sedang:
        return AppColors.warning;
      case Tingkat.berat:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _color : AppColors.border),
        ),
        child: Center(
          child: Text(
            tingkat.label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: selected ? Colors.white : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
