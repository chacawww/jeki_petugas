import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'main_shell.dart';

/// Layar setelah laporan hasil pekerjaan berhasil dikirim.
class SuccessScreen extends StatelessWidget {
  final String nomor;
  const SuccessScreen({super.key, required this.nomor});

  void _kembali(BuildContext context, int tab) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    MainShell.tab.value = tab;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GradientBackdrop(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    child: Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.22),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 46),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text('Laporan Berhasil Dikirim! 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(
                    'Terima kasih, pekerjaanmu sudah dikirim. Laporan hasil kamu sedang menunggu pemeriksaan Admin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('NOMOR TUGAS',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(nomor,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _Stepper(),
                  const Spacer(flex: 4),
                  GradientButton(
                    label: 'Lihat Status Tugas',
                    icon: Icons.arrow_forward,
                    white: true,
                    onPressed: () => _kembali(context, 1),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _kembali(context, 0),
                    child: Text('Kembali ke Beranda',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12)),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tahap: Dikirim (aktif) → Diperiksa → Selesai.
class _Stepper extends StatelessWidget {
  const _Stepper();

  @override
  Widget build(BuildContext context) {
    Widget dot(bool active) => Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: active ? 1 : 0.4),
          ),
        );
    Widget line() => Container(
          width: 36,
          height: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: Colors.white.withValues(alpha: 0.35),
        );
    Widget label(String t, bool active) => Text(t,
        style: TextStyle(
            color: Colors.white.withValues(alpha: active ? 1 : 0.65),
            fontSize: 11,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(true),
        const SizedBox(width: 6),
        label('Dikirim', true),
        line(),
        dot(false),
        const SizedBox(width: 6),
        label('Diperiksa', false),
        line(),
        dot(false),
        const SizedBox(width: 6),
        label('Selesai', false),
      ],
    );
  }
}
