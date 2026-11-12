import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';
import 'bahan_screen.dart';
import 'progress_screen.dart';
import 'survey_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String tugasId;
  const TaskDetailScreen({super.key, required this.tugasId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<Tugas> _future;

  @override
  void initState() {
    super.initState();
    _future = TugasService.get(widget.tugasId);
  }

  void _reload() =>
      setState(() => _future = TugasService.get(widget.tugasId));

  Future<void> _go(Widget page) async {
    final msg = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    if (msg != null) showSnack(context, msg);
    _reload();
  }

  String? _label(Tugas t) {
    switch (t.status) {
      case StatusTugas.menunggu:
        return 'Mulai Survei';
      case StatusTugas.survei:
        return 'Lanjutkan Survei';
      case StatusTugas.bahan:
        return 'Lihat Kebutuhan Bahan';
      case StatusTugas.dikerjakan:
      case StatusTugas.revisi:
        return 'Perbarui Progres & Kirim Hasil';
      case StatusTugas.diperiksa:
      case StatusTugas.selesai:
        return null;
    }
  }

  Future<void> _action(Tugas t) async {
    switch (t.status) {
      case StatusTugas.menunggu:
        try {
          await TugasService.mulaiSurvei(t.id);
        } catch (e) {
          if (mounted) showSnack(context, 'Gagal memulai survei: $e', error: true);
          return;
        }
        await _go(SurveyScreen(tugas: t));
        break;
      case StatusTugas.survei:
        await _go(SurveyScreen(tugas: t));
        break;
      case StatusTugas.bahan:
        await _go(BahanScreen(tugasId: t.id));
        break;
      case StatusTugas.dikerjakan:
      case StatusTugas.revisi:
        await _go(ProgressScreen(tugasId: t.id));
        break;
      case StatusTugas.diperiksa:
      case StatusTugas.selesai:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          FutureBuilder<Tugas>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ErrorState(
                    message: 'Gagal memuat tugas.\n${snap.error}',
                    onRetry: _reload);
              }
              return _Content(
                tugas: snap.data!,
                label: _label(snap.data!),
                onAction: () => _action(snap.data!),
                onReload: _reload,
              );
            },
          ),
          // Tombol kembali melayang di atas foto.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 3,
                shadowColor: Colors.black26,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Tugas tugas;
  final String? label;
  final VoidCallback onAction;
  final VoidCallback onReload;

  const _Content({
    required this.tugas,
    required this.label,
    required this.onAction,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final t = tugas;
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Foto/hero di belakang.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 300,
                child: _Hero(url: t.fotoUrl),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 250),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusChip.status(t.status),
                              const SizedBox(width: 6),
                              StatusChip.priority(t.prioritas),
                              const Spacer(),
                              Text(t.kode,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(t.judul,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 14),
                          _InfoCard(tugas: t),
                          if (t.status == StatusTugas.revisi) ...[
                            const SizedBox(height: 14),
                            _Banner(
                              icon: Icons.replay,
                              color: AppColors.danger,
                              bg: AppColors.dangerSoft,
                              title: 'Admin meminta perbaikan',
                              text: t.catatanAdmin ??
                                  'Silakan periksa kembali hasil pekerjaan.',
                            ),
                          ],
                          if (t.status == StatusTugas.diperiksa) ...[
                            const SizedBox(height: 14),
                            const _Banner(
                              icon: Icons.hourglass_bottom,
                              color: AppColors.warning,
                              bg: AppColors.warningSoft,
                              title: 'Menunggu pemeriksaan',
                              text:
                                  'Laporan hasil sudah dikirim. Admin akan memeriksa dan mengonfirmasi penyelesaian.',
                            ),
                            // Hanya untuk mode tampilan: simulasi keputusan Admin.
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      await TugasService.simulasiSelesai(t.id);
                                      onReload();
                                    },
                                    child: const Text('Simulasi: Selesai'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      await TugasService.simulasiRevisi(t.id);
                                      onReload();
                                    },
                                    child: const Text('Simulasi: Revisi'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SectionTitle('Laporan Pelapor'),
                          AppCard(
                            child: Text(
                              (t.deskripsi == null || t.deskripsi!.isEmpty)
                                  ? 'Tidak ada deskripsi.'
                                  : t.deskripsi!,
                              style:
                                  const TextStyle(fontSize: 13, height: 1.5),
                            ),
                          ),
                          if (t.tingkat != null) ...[
                            const SectionTitle('Hasil Survei'),
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Tingkat kerusakan: ${t.tingkat!.label}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                  if ((t.kondisiAktual ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(t.kondisiAktual!,
                                        style: const TextStyle(
                                            fontSize: 13, height: 1.4)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SectionTitle('Alur Pekerjaan'),
                          AppCard(child: _Alur(status: t.status)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (label != null)
          BottomAction(
            label: label!,
            icon: Icons.arrow_forward,
            onPressed: onAction,
          ),
      ],
    );
  }
}

/// Foto laporan; bila belum ada, tampil latar gradasi dengan ikon.
class _Hero extends StatelessWidget {
  final String? url;
  const _Hero({this.url});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _HeroPlaceholder(),
      );
    }
    return const _HeroPlaceholder();
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.main),
      child: Stack(
        children: [
          ...bubbles(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(Icons.add_road,
                  size: 84, color: Colors.white.withValues(alpha: 0.65)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lokasi (dengan tombol arah), waktu lapor, dan kategori.
class _InfoCard extends StatelessWidget {
  final Tugas tugas;
  const _InfoCard({required this.tugas});

  @override
  Widget build(BuildContext context) {
    final t = tugas;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          _Row(
            icon: Icons.place,
            label: 'Lokasi',
            value: t.alamat ?? '-',
            trailing: t.punyaKoordinat
                ? TextButton(
                    onPressed: () => bukaUrl(context,
                        'https://www.google.com/maps/search/?api=1&query=${t.lat},${t.lng}'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(0, 32),
                      backgroundColor: AppColors.primarySoft,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Buka Arah →',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  )
                : null,
          ),
          const Divider(height: 1, color: AppColors.border),
          _Row(
            icon: Icons.access_time,
            label: 'Dilaporkan',
            value: timeAgo(t.createdAt),
          ),
          if (t.kategori != null) ...[
            const Divider(height: 1, color: AppColors.border),
            _Row(
              icon: Icons.category_outlined,
              label: 'Kategori',
              value: t.kategori!,
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 1),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Garis waktu tahapan pekerjaan sesuai status tugas.
class _Alur extends StatelessWidget {
  final StatusTugas status;
  const _Alur({required this.status});

  static const _langkah = [
    'Ditugaskan Admin',
    'Survei Lokasi',
    'Bahan Disiapkan Admin',
    'Pengerjaan',
    'Pemeriksaan Admin',
    'Selesai',
  ];

  int get _aktif {
    switch (status) {
      case StatusTugas.menunggu:
        return 0;
      case StatusTugas.survei:
        return 1;
      case StatusTugas.bahan:
        return 2;
      case StatusTugas.dikerjakan:
      case StatusTugas.revisi:
        return 3;
      case StatusTugas.diperiksa:
        return 4;
      case StatusTugas.selesai:
        return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cur = _aktif;
    final semua = status == StatusTugas.selesai;
    return Column(
      children: [
        for (var i = 0; i < _langkah.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _dot(done: i < cur || semua, current: i == cur && !semua),
                  if (i != _langkah.length - 1)
                    Container(
                      width: 2,
                      height: 26,
                      color:
                          i < cur || semua ? AppColors.primary : AppColors.border,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  _langkah[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: i == cur && !semua
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: i > cur && !semua
                        ? AppColors.textMuted
                        : AppColors.text,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _dot({required bool done, required bool current}) {
    if (done) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
            color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: current ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: current
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String text;

  const _Banner({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(text, style: const TextStyle(fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
