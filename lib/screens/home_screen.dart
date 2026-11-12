import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onSeeAll;
  const HomeScreen({super.key, required this.onSeeAll});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<({Petugas profil, StatistikPetugas stat, List<Tugas> tugas})>
      _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({Petugas profil, StatistikPetugas stat, List<Tugas> tugas})>
      _load() async {
    final results = await Future.wait([
      AuthService.profile(),
      TugasService.statistik(),
      TugasService.list(hanyaSelesai: false),
    ]);
    return (
      profil: results[0] as Petugas,
      stat: results[1] as StatistikPetugas,
      tugas: results[2] as List<Tugas>,
    );
  }

  void _reload() => setState(() => _future = _load());

  String _salam() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Future<void> _buka(Tugas t) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(tugasId: t.id)),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return ErrorState(
              message: 'Gagal memuat beranda.\n${snap.error}',
              onRetry: _reload);
        }
        final d = snap.data!;
        final utama = d.tugas.isEmpty ? null : d.tugas.first;
        final lainnya = d.tugas.skip(1).take(3).toList();
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(profil: d.profil, stat: d.stat, salam: _salam()),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgresCard(stat: d.stat),
                    SectionTitle(
                      'Tugas Prioritas',
                      trailing: TextButton(
                        onPressed: widget.onSeeAll,
                        child: const Text('MENDESAK',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    if (utama == null)
                      const _Kosong()
                    else
                      _TugasUtama(tugas: utama, onTap: () => _buka(utama)),
                    if (lainnya.isNotEmpty) ...[
                      SectionTitle(
                        'Tugas Lainnya',
                        trailing: TextButton(
                          onPressed: widget.onSeeAll,
                          child: const Text('Lihat semua'),
                        ),
                      ),
                      for (final t in lainnya)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TaskCard(tugas: t, onChanged: _reload),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Header gradasi: sapaan, status shift, dan ringkasan angka.
class _Header extends StatelessWidget {
  final Petugas profil;
  final StatistikPetugas stat;
  final String salam;
  const _Header({
    required this.profil,
    required this.stat,
    required this.salam,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: AppGradients.main,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          ...bubbles(),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 16, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LogoBadge(size: 44),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle,
                              size: 8, color: Color(0xFF86EFAC)),
                          SizedBox(width: 6),
                          Text('SHIFT AKTIF',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text('$salam,',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(profil.nama,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Unit Reaksi Cepat • ${profil.kode}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Stat(
                        value: stat.menunggu,
                        label: 'Baru',
                        icon: Icons.fiber_new_rounded),
                    const SizedBox(width: 10),
                    _Stat(
                        value: stat.diproses,
                        label: 'Dikerjakan',
                        icon: Icons.build_rounded),
                    const SizedBox(width: 10),
                    _Stat(
                        value: stat.selesai,
                        label: 'Selesai',
                        icon: Icons.check_circle_rounded),
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

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  const _Stat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  color: AppColors.primarySoft, shape: BoxShape.circle),
              child: Icon(icon, size: 15, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text('$value',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Bilah progres penyelesaian tugas.
class _ProgresCard extends StatelessWidget {
  final StatistikPetugas stat;
  const _ProgresCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final persen = stat.persenSelesai;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Penyelesaian Tugas',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text('${persen.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: persen / 100,
                minHeight: 8,
                backgroundColor: AppColors.primarySoft,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text('${stat.selesai} dari ${stat.total} tugas sudah selesai',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Kartu besar untuk tugas dengan prioritas tertinggi.
class _TugasUtama extends StatelessWidget {
  final Tugas tugas;
  final VoidCallback onTap;
  const _TugasUtama({required this.tugas, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lanjut = tugas.status != StatusTugas.menunggu;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tugas.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(tugas.kode,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              StatusChip.status(tugas.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(tugas.alamat ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text('Dilaporkan ${timeAgo(tugas.createdAt)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
              const Spacer(),
              StatusChip.priority(tugas.prioritas),
            ],
          ),
          const SizedBox(height: 16),
          GradientButton(
            label: lanjut ? 'Lanjutkan' : 'Mulai',
            icon: Icons.play_arrow_rounded,
            height: 48,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _Kosong extends StatelessWidget {
  const _Kosong();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.task_alt, size: 44, color: AppColors.primary),
            SizedBox(height: 10),
            Text('Semua tugas beres!',
                style: TextStyle(fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text('Belum ada tugas aktif untuk saat ini.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
