import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Lingkaran transparan dekoratif di latar gradasi.
class Bubble extends StatelessWidget {
  final double size;
  final double opacity;
  const Bubble(this.size, {super.key, this.opacity = 0.12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

/// Kumpulan bubble untuk ditaruh di dalam Stack.
List<Widget> bubbles() => const [
      Positioned(top: -30, right: -30, child: Bubble(140)),
      Positioned(top: 90, left: -40, child: Bubble(100, opacity: 0.09)),
      Positioned(top: 40, left: 60, child: Bubble(36, opacity: 0.14)),
    ];

/// Logo "JK" Jember Kita dalam kotak kaca.
class LogoBadge extends StatelessWidget {
  final double size;
  const LogoBadge({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      alignment: Alignment.center,
      child: Text(
        'JK',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          letterSpacing: -2,
        ),
      ),
    );
  }
}

/// Potongan bawah bergelombang untuk header gradasi.
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path()..lineTo(0, size.height - 40);
    p.quadraticBezierTo(
        size.width * 0.25, size.height + 10, size.width * 0.5, size.height - 30);
    p.quadraticBezierTo(
        size.width * 0.8, size.height - 75, size.width, size.height - 25);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Latar gradasi pink penuh layar dengan bubble.
class GradientBackdrop extends StatelessWidget {
  final Widget child;
  const GradientBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.main),
      child: Stack(
        children: [
          ...bubbles(),
          const Positioned(bottom: 60, right: 20, child: Bubble(90, opacity: 0.08)),
          child,
        ],
      ),
    );
  }
}

/// Kotak kaca (putih transparan) di atas latar gradasi.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}

/// Tombol pil bergradasi (atau putih) dengan bayangan.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool white;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.white = false,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final fg = white ? AppColors.primary : Colors.white;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: white ? null : AppGradients.main,
        color: white ? Colors.white : null,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: (white ? Colors.black : AppColors.primary)
                .withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: loading ? null : onPressed,
          child: Center(
            child: loading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: fg),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null && !_iconAfter) ...[
                        Icon(icon, color: fg, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(label,
                          style: TextStyle(
                              color: fg,
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                      if (icon != null && _iconAfter) ...[
                        const SizedBox(width: 8),
                        Icon(icon, color: fg, size: 18),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Ikon panah (aksi lanjut) di kanan teks; ikon lain di kiri.
  bool get _iconAfter =>
      icon == Icons.arrow_forward || icon == Icons.arrow_forward_rounded;
}

/// Kolom isian bergaya desain Jember Kita.
class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? action;
  final ValueChanged<String>? onSubmitted;

  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.action,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEDEAF3)),
    );
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: action,
      onSubmitted: onSubmitted,
      autocorrect: false,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F7FC),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9AA0B4)),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF9AA0B4),
                ),
                onPressed: onToggleObscure,
              ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

/// Kerangka layar login/daftar: header gradasi bergelombang + isi di bawahnya.
class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  decoration: const BoxDecoration(gradient: AppGradients.main),
                  child: Stack(children: bubbles()),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, top + 36, 20, 28),
              child: Column(
                children: [
                  const LogoBadge(size: 62),
                  const SizedBox(height: 12),
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12)),
                  const SizedBox(height: 70),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu putih besar bayangan lembut untuk formulir.
class FormCard extends StatelessWidget {
  final List<Widget> children;
  const FormCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

String timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  return '${diff.inDays} hari lalu';
}
