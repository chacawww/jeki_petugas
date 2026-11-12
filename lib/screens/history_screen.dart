import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'history_detail_screen.dart';

/// Riwayat = tugas yang sudah dikonfirmasi selesai oleh Admin.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Tugas>> _future;

  @override
  void initState() {
    super.initState();
    _future = TugasService.list(hanyaSelesai: true);
  }

  void _reload() =>
      setState(() => _future = TugasService.list(hanyaSelesai: true));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text('Riwayat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: FutureBuilder<List<Tugas>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return ErrorState(
                      message: 'Gagal memuat riwayat.\n${snap.error}',
                      onRetry: _reload);
                }
                final data = snap.data!;
                if (data.isEmpty) {
                  return const Center(
                    child: Text('Belum ada pekerjaan selesai.',
                        style: TextStyle(color: AppColors.textMuted)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final t = data[i];
                      return AppCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                HistoryDetailScreen(tugasId: t.id),
                          ),
                        ),
                        child: Row(
                          children: [
                            NetImage(
                                url: t.fotoSesudahUrl ?? t.fotoUrl,
                                width: 56,
                                height: 56,
                                radius: 12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.judul,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14)),
                                  const SizedBox(height: 3),
                                  Text(t.alamat ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      StatusChip.status(t.status),
                                      const Spacer(),
                                      Text(
                                        t.selesaiAt == null
                                            ? t.kode
                                            : _fmt(t.selesaiAt!),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    const bln = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${bln[d.month - 1]} ${d.year}';
  }
}
