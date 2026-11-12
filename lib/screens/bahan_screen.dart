import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Kebutuhan bahan disiapkan Admin/atasan dalam bentuk PDF.
/// Petugas hanya melihat atau mengunduhnya, tidak mengisi pengajuan.
class BahanScreen extends StatefulWidget {
  final String tugasId;
  const BahanScreen({super.key, required this.tugasId});

  @override
  State<BahanScreen> createState() => _BahanScreenState();
}

class _BahanScreenState extends State<BahanScreen> {
  late Future<Tugas> _future;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _future = TugasService.get(widget.tugasId);
  }

  void _reload() =>
      setState(() => _future = TugasService.get(widget.tugasId));

  Future<void> _mulai(Tugas t) async {
    setState(() => _loading = true);
    try {
      await TugasService.mulaiPengerjaan(t.id);
      if (mounted) {
        Navigator.of(context).pop('Pengerjaan dimulai. Semangat!');
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Gagal memulai pengerjaan: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kebutuhan Bahan')),
      body: FutureBuilder<Tugas>(
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
          final t = snap.data!;
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _reload(),
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
                            const SizedBox(height: 2),
                            Text(t.judul,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 15)),
                            if (t.tingkat != null) ...[
                              const SizedBox(height: 8),
                              Text('Tingkat kerusakan hasil survei: ${t.tingkat!.label}',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (t.bahanTersedia) ...[
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.dangerSoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.picture_as_pdf,
                                        color: AppColors.danger),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.dokumenBahanNama ??
                                              'Kebutuhan Bahan.pdf',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const Text('Disiapkan oleh Admin',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    bukaUrl(context, t.dokumenBahanUrl!),
                                icon: const Icon(Icons.open_in_new, size: 18),
                                label: const Text('Lihat / Unduh PDF'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Pastikan semua bahan sudah tersedia di lokasi sebelum memulai pengerjaan.',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                      ] else
                        AppCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(Icons.hourglass_bottom,
                                  size: 36, color: AppColors.warning),
                              const SizedBox(height: 10),
                              const Text('Menunggu Admin',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15)),
                              const SizedBox(height: 6),
                              const Text(
                                'Hasil survei sedang diperiksa. Admin/atasan akan menyiapkan kebutuhan bahan dan anggaran, lalu dokumennya muncul di sini.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _reload,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Periksa lagi'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (t.bahanTersedia && t.status == StatusTugas.bahan)
                BottomAction(
                  label: 'Bahan Siap, Mulai Pengerjaan',
                  icon: Icons.construction,
                  loading: _loading,
                  onPressed: () => _mulai(t),
                ),
            ],
          );
        },
      ),
    );
  }
}
