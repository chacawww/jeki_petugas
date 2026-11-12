import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Kartu putih dengan border pink tipis, dipakai di hampir semua layar.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Chip kecil berwarna untuk status/prioritas.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.background,
  });

  factory StatusChip.status(StatusTugas s) {
    switch (s) {
      case StatusTugas.menunggu:
        return StatusChip(
            label: s.label,
            color: AppColors.warning,
            background: AppColors.warningSoft);
      case StatusTugas.survei:
        return StatusChip(
            label: s.label,
            color: AppColors.info,
            background: AppColors.infoSoft);
      case StatusTugas.bahan:
        return StatusChip(
            label: s.label,
            color: AppColors.primary,
            background: AppColors.primarySoft);
      case StatusTugas.dikerjakan:
        return StatusChip(
            label: s.label,
            color: AppColors.info,
            background: AppColors.infoSoft);
      case StatusTugas.diperiksa:
        return StatusChip(
            label: s.label,
            color: AppColors.warning,
            background: AppColors.warningSoft);
      case StatusTugas.revisi:
        return StatusChip(
            label: s.label,
            color: AppColors.danger,
            background: AppColors.dangerSoft);
      case StatusTugas.selesai:
        return StatusChip(
            label: s.label,
            color: AppColors.success,
            background: AppColors.successSoft);
    }
  }

  factory StatusChip.priority(Prioritas p) {
    switch (p) {
      case Prioritas.tinggi:
        return StatusChip(
            label: p.label,
            color: AppColors.danger,
            background: AppColors.dangerSoft);
      case Prioritas.sedang:
        return StatusChip(
            label: p.label,
            color: AppColors.warning,
            background: AppColors.warningSoft);
      case Prioritas.rendah:
        return StatusChip(
            label: p.label,
            color: AppColors.success,
            background: AppColors.successSoft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Foto dari URL dengan placeholder bila kosong/gagal.
class NetImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final double radius;

  const NetImage({
    super.key,
    this.url,
    this.height,
    this.width,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: width,
      color: AppColors.primarySoft,
      child: const Icon(Icons.image_outlined, color: AppColors.primary),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: (url == null || url!.isEmpty)
          ? placeholder
          : Image.network(
              url!,
              height: height,
              width: width,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Tombol utama yang menempel di bawah layar.
class BottomAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const BottomAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, size: 18),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

String fmtTanggal(DateTime d) => DateFormat('d MMMM yyyy', 'id_ID').format(d);

/// Membuka URL (PDF bahan, Google Maps) di aplikasi luar.
Future<void> bukaUrl(BuildContext context, String url) async {
  if (url.startsWith('demo:')) {
    showSnack(context, 'Mode tampilan: dokumen contoh, belum ada file PDF.');
    return;
  }
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    showSnack(context, 'Tidak bisa membuka tautan.', error: true);
  }
}

void showSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.danger : AppColors.text,
      behavior: SnackBarBehavior.floating,
    ));
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}
