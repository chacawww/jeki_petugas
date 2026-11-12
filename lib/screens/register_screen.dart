import 'package:flutter/material.dart';

import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nama = TextEditingController();
  final _id = TextEditingController();
  final _hp = TextEditingController();
  final _password = TextEditingController();
  final _konfirmasi = TextEditingController();
  bool _hide1 = true;
  bool _hide2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _nama.dispose();
    _id.dispose();
    _hp.dispose();
    _password.dispose();
    _konfirmasi.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nama.text.trim().isEmpty ||
        _id.text.trim().isEmpty ||
        _hp.text.trim().isEmpty ||
        _password.text.isEmpty) {
      showSnack(context, 'Semua kolom wajib diisi.', error: true);
      return;
    }
    if (_password.text.length < 6) {
      showSnack(context, 'Password minimal 6 karakter.', error: true);
      return;
    }
    if (_password.text != _konfirmasi.text) {
      showSnack(context, 'Konfirmasi password tidak sama.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.register(
        nama: _nama.text,
        idPetugas: _id.text,
        noHp: _hp.text,
        password: _password.text,
      );
      // Tutup layar daftar; AuthGate sudah menampilkan layar utama.
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Buat Akun Baru',
      subtitle: 'Daftar sebagai petugas lapangan',
      children: [
        FormCard(
          children: [
            AuthField(
              controller: _nama,
              hint: 'Nama Lengkap',
              icon: Icons.person_outline,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AuthField(
              controller: _id,
              hint: 'ID Petugas / NIP',
              icon: Icons.badge_outlined,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AuthField(
              controller: _hp,
              hint: 'No. HP / WhatsApp',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AuthField(
              controller: _password,
              hint: 'Password',
              icon: Icons.lock_outline,
              obscure: _hide1,
              onToggleObscure: () => setState(() => _hide1 = !_hide1),
              action: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AuthField(
              controller: _konfirmasi,
              hint: 'Konfirmasi Password',
              icon: Icons.lock_outline,
              obscure: _hide2,
              onToggleObscure: () => setState(() => _hide2 = !_hide2),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GradientButton(
          label: 'Lanjut',
          icon: Icons.arrow_forward,
          loading: _loading,
          onPressed: _submit,
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sudah punya akun? ',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Text('Masuk',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ],
    );
  }
}
