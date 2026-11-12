import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/task_detail_screen.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Kartu tugas yang dipakai di Beranda, Daftar Tugas, dan Riwayat.
class TaskCard extends StatelessWidget {
  final Tugas tugas;
  final VoidCallback? onChanged;
  final bool riwayat;

  const TaskCard({
    super.key,
    required this.tugas,
    this.onChanged,
    this.riwayat = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TaskDetailScreen(tugasId: tugas.id),
        ));
        onChanged?.call();
      },
      child: Row(
        children: [
          NetImage(url: tugas.fotoUrl, width: 56, height: 56, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tugas.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        tugas.alamat ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    StatusChip.status(tugas.status),
                    const SizedBox(width: 6),
                    if (!riwayat) StatusChip.priority(tugas.prioritas),
                    const Spacer(),
                    Text(tugas.kode,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
