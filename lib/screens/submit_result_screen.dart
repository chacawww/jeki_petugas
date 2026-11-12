import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/photo_picker.dart';
import 'success_screen.dart';

/// Laporan hasil pekerjaan: foto sebelum & sesudah, deskripsi,
/// tanggal penyelesaian, dan dokumentasi pendukung.
class SubmitResultScreen extends StatefulWidget {
  final Tugas tugas;
  const SubmitResultScreen({super.key, required this.tugas});

  @override
  State<SubmitResultScreen> createState() => _SubmitResultScreenState();
}

class _SubmitResultScreenState extends State<SubmitResultScreen> {
  final _catatan = TextEditingController();
  XFile? _sebelum;
  XFile? _sesudah;
  XFile? _pendukung;
  DateTime _tanggal = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _catatan.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _tanggal = d);
  }

  Future<void> _submit() async {
    if (_sebelum == null || _sesudah == null) {
      showSnack(context, 'Foto sebelum dan sesudah perbaikan wajib diunggah.',
          error: true);
      return;
    }
    if (_catatan.text.trim().isEmpty) {
      showSnack(context, 'Isi deskripsi hasil pekerjaan.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await TugasService.kirimHasil(
        widget.tugas.id,
        fotoSebelum: _sebelum!,
        fotoSesudah: _sesudah!,
        fotoPendukung: _pendukung,
        catatan: _catatan.text.trim(),
        tanggal: _tanggal,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => SuccessScreen(nomor: widget.tugas.kode)),
      );
    } catch (e) {
      if (mounted) showSnack(context, 'Gagal mengirim laporan: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tugas;
    return Scaffold(
      appBar: AppBar(title: const Text('Kirim Hasil')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.kode,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      Text(t.judul,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SectionTitle('Dokumentasi Pekerjaan'),
                Row(
                  children: [
                    Expanded(
                      child: PhotoPicker(
                        label: 'Sebelum',
                        hint: 'Foto kondisi awal',
                        value: _sebelum,
                        onPicked: (f) => setState(() => _sebelum = f),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PhotoPicker(
                        label: 'Sesudah',
                        hint: 'Foto hasil akhir',
                        value: _sesudah,
                        onPicked: (f) => setState(() => _sesudah = f),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                PhotoPicker(
                  label: 'Dokumentasi pendukung (opsional)',
                  value: _pendukung,
                  height: 90,
                  onPicked: (f) => setState(() => _pendukung = f),
                ),
                const SectionTitle('Deskripsi Hasil Pekerjaan'),
                TextField(
                  controller: _catatan,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'Jelaskan pekerjaan yang dilakukan, bahan yang terpakai, dan kendala bila ada',
                  ),
                ),
                const SectionTitle('Tanggal Penyelesaian'),
                InkWell(
                  onTap: _pilihTanggal,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                    child: Text(fmtTanggal(_tanggal)),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Setelah dikirim, Admin akan memeriksa hasil pekerjaan. Tugas dinyatakan selesai setelah dikonfirmasi Admin.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BottomAction(
            label: 'Kirimkan ke Admin',
            icon: Icons.send,
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
