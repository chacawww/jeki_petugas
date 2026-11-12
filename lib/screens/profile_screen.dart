import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<({Petugas profil, StatistikPetugas stat})> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({Petugas profil, StatistikPetugas stat})> _load() async {
    final r = await Future.wait([
      AuthService.profile(),
      TugasService.statistik(),
    ]);
    return (profil: r[0] as Petugas, stat: r[1] as StatistikPetugas);
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Kamu harus masuk lagi untuk melihat tugas.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) await AuthService.signOut();
  }

  void _segeraHadir() =>
      showSnack(context, 'Mode tampilan: fitur ini belum aktif.');

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
              message: 'Gagal memuat profil.\n${snap.error}',
              onRetry: () => setState(() => _future = _load()));
        }
        final p = snap.data!.profil;
        final s = snap.data!.stat;
        final top = MediaQuery.of(context).padding.top;
        final inisial = p.nama.isNotEmpty ? p.nama[0].toUpperCase() : '?';
        final headerH = top + 250;
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: headerH + 50,
              child: Stack(
                children: [
                  // Header gradasi
                  Container(
                    height: headerH,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.main,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                    child: Stack(
                      children: [
                        ...bubbles(),
                        Padding(
                          padding: EdgeInsets.only(top: top + 20),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Colors.white.withValues(alpha: 0.3),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white,
                                    backgroundImage: p.avatarUrl != null
                                        ? NetworkImage(p.avatarUrl!)
                                        : null,
                                    child: p.avatarUrl == null
                                        ? Text(inisial,
                                            style: const TextStyle(
                                                fontSize: 34,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primary))
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(p.nama,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(p.email ?? '-',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                        fontSize: 12)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified,
                                          size: 14, color: Color(0xFF86EFAC)),
                                      const SizedBox(width: 6),
                                      Text('Petugas Terverifikasi • ${p.kode}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700)),
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
                  // Kartu statistik menimpa batas header
                  Positioned(
                    left: 16,
                    right: 16,
                    top: headerH - 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            _Angka('${s.total}', 'Total Tugas',
                                AppColors.primary),
                            const VerticalDivider(
                                width: 1, color: AppColors.border),
                            _Angka('${s.selesai}', 'Selesai',
                                AppColors.success),
                            const VerticalDivider(
                                width: 1, color: AppColors.border),
                            _Angka('${s.diproses + s.menunggu}',
                                'Dalam Proses', AppColors.warning),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                children: [
                  _Menu(
                    icon: Icons.person_outline,
                    title: 'Edit Profil',
                    subtitle: 'Ubah data diri Anda',
                    onTap: _segeraHadir,
                  ),
                  _Menu(
                    icon: Icons.menu_book_outlined,
                    title: 'Panduan Kerja',
                    subtitle: 'SOP perbaikan & keselamatan kerja',
                    onTap: _segeraHadir,
                  ),
                  _Menu(
                    icon: Icons.headset_mic_outlined,
                    title: 'Hubungi Admin',
                    subtitle: 'Layanan bantuan 24/7',
                    onTap: _segeraHadir,
                  ),
                  _Menu(
                    icon: Icons.logout,
                    title: 'Keluar',
                    subtitle: 'Logout dari akun ini',
                    danger: true,
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Angka extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Angka(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _Menu({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: danger ? AppColors.dangerSoft : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  size: 20,
                  color: danger ? AppColors.danger : AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: danger ? AppColors.danger : AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
