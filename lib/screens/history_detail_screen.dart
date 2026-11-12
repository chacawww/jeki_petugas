import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String tugasId;
  const HistoryDetailScreen({super.key, required this.tugasId});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late Future<Tugas> _future;

  @override
  void initState() {
    super.initState();
    _future = TugasService.get(widget.tugasId);
  }

  void _reload() =>
      setState(() => _future = TugasService.get(widget.tugasId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Riwayat')),
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Row(
                children: [
                  StatusChip.status(t.status),
                  const Spacer(),
                  Text(t.kode,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 10),
              Text(t.judul,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(t.alamat ?? '-',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted)),
              const SectionTitle('Dokumentasi Pekerjaan'),
              Row(
                children: [
                  Expanded(child: _Foto('Sebelum', t.fotoSebelumUrl)),
                  const SizedBox(width: 10),
                  Expanded(child: _Foto('Sesudah', t.fotoSesudahUrl)),
                ],
              ),
              if (t.fotoPendukungUrl != null) ...[
                const SizedBox(height: 10),
                _Foto('Pendukung', t.fotoPendukungUrl, height: 120),
              ],
              const SectionTitle('Ringkasan'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row('Tanggal pengerjaan',
                        t.tanggalPengerjaan == null
                            ? '-'
                            : fmtTanggal(t.tanggalPengerjaan!)),
                    _Row('Dikonfirmasi Admin',
                        t.selesaiAt == null ? '-' : fmtTanggal(t.selesaiAt!)),
                    _Row('Tingkat kerusakan', t.tingkat?.label ?? '-'),
                    const Divider(height: 20),
                    const Text('Deskripsi hasil',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      (t.catatanHasil ?? '').isEmpty ? '-' : t.catatanHasil!,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    if ((t.catatanAdmin ?? '').isNotEmpty) ...[
                      const Divider(height: 20),
                      const Text('Catatan Admin',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(t.catatanAdmin!,
                          style: const TextStyle(fontSize: 13, height: 1.4)),
                    ],
                  ],
                ),
              ),
              if (t.bahanTersedia) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => bukaUrl(context, t.dokumenBahanUrl!),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Lihat dokumen bahan'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Foto extends StatelessWidget {
  final String label;
  final String? url;
  final double height;
  const _Foto(this.label, this.url, {this.height = 130});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NetImage(url: url, height: height, width: double.infinity),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted)),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted))),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
