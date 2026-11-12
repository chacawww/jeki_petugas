import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/photo_picker.dart';
import 'submit_result_screen.dart';

/// Pembaruan progres selama pengerjaan: catatan, foto, dan kendala.
/// Dari sini Petugas mengirim laporan hasil akhir.
class ProgressScreen extends StatefulWidget {
  final String tugasId;
  const ProgressScreen({super.key, required this.tugasId});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<({Tugas tugas, List<Progres> progres})> _future;
  final _catatan = TextEditingController();
  bool _kendala = false;
  XFile? _foto;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _catatan.dispose();
    super.dispose();
  }

  Future<({Tugas tugas, List<Progres> progres})> _load() async {
    final r = await Future.wait([
      TugasService.get(widget.tugasId),
      TugasService.progres(widget.tugasId),
    ]);
    return (tugas: r[0] as Tugas, progres: r[1] as List<Progres>);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _simpan() async {
    if (_catatan.text.trim().isEmpty) {
      showSnack(context, 'Isi catatan progres.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await TugasService.tambahProgres(
        widget.tugasId,
        catatan: _catatan.text.trim(),
        kendala: _kendala,
        foto: _foto,
      );
      _catatan.clear();
      setState(() {
        _kendala = false;
        _foto = null;
      });
      _reload();
      if (mounted) showSnack(context, 'Progres tersimpan.');
    } catch (e) {
      if (mounted) showSnack(context, 'Gagal menyimpan: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _kirimHasil(Tugas t) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SubmitResultScreen(tugas: t)),
    );
    if (!mounted) return;
    // Bila laporan sudah terkirim, tutup layar ini agar Detail ter-refresh.
    final terbaru = await TugasService.get(widget.tugasId);
    if (!mounted) return;
    if (terbaru.status == StatusTugas.diperiksa) {
      Navigator.of(context).pop();
    } else {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progres Pengerjaan')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ErrorState(
                message: 'Gagal memuat data.\n${snap.error}',
                onRetry: _reload);
          }
          final t = snap.data!.tugas;
          final progres = snap.data!.progres;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.kode,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted)),
                                Text(t.judul,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          StatusChip.status(t.status),
                        ],
                      ),
                    ),
                    if (t.status == StatusTugas.revisi) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.dangerSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Catatan Admin',
                                style: TextStyle(
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              t.catatanAdmin ??
                                  'Hasil belum sesuai, mohon diperbaiki.',
                              style: const TextStyle(fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (t.bahanTersedia) ...[
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () => bukaUrl(context, t.dokumenBahanUrl!),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: const Text('Buka dokumen bahan'),
                      ),
                    ],
                    const SectionTitle('Tambah Progres'),
                    TextField(
                      controller: _catatan,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Apa yang sudah dikerjakan hari ini?',
                      ),
                    ),
                    const SizedBox(height: 10),
                    PhotoPicker(
                      label: 'Foto dokumentasi (opsional)',
                      value: _foto,
                      height: 100,
                      onPicked: (f) => setState(() => _foto = f),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ini adalah kendala di lapangan',
                          style: TextStyle(fontSize: 13)),
                      value: _kendala,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _kendala = v),
                    ),
                    OutlinedButton(
                      onPressed: _saving ? null : _simpan,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Simpan Progres'),
                    ),
                    const SectionTitle('Riwayat Progres'),
                    if (progres.isEmpty)
                      const Text('Belum ada catatan progres.',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted))
                    else
                      for (final p in progres)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (p.fotoUrl != null) ...[
                                  NetImage(
                                      url: p.fotoUrl,
                                      width: 56,
                                      height: 56,
                                      radius: 10),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          if (p.kendala)
                                            const StatusChip(
                                                label: 'Kendala',
                                                color: AppColors.danger,
                                                background:
                                                    AppColors.dangerSoft),
                                          if (p.kendala)
                                            const SizedBox(width: 6),
                                          Text(fmtTanggal(p.createdAt),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textMuted)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(p.catatan,
                                          style: const TextStyle(
                                              fontSize: 13, height: 1.4)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
              BottomAction(
                label: 'Kirim Laporan Hasil',
                icon: Icons.arrow_forward,
                onPressed: () => _kirimHasil(t),
              ),
            ],
          );
        },
      ),
    );
  }
}
