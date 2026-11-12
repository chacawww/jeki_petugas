import 'package:flutter/material.dart';

import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _id = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _id.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_id.text.trim().isEmpty || _password.text.isEmpty) {
      showSnack(context, 'ID Petugas dan kata sandi wajib diisi.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.signIn(_id.text, _password.text);
      // AuthGate otomatis pindah ke layar utama.
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Masuk ke Akun',
      subtitle: 'Masuk untuk mengerjakan tugas lapangan',
      children: [
        FormCard(
          children: [
            AuthField(
              controller: _id,
              hint: 'ID Petugas / Email',
              icon: Icons.badge_outlined,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AuthField(
              controller: _password,
              hint: 'Password',
              icon: Icons.lock_outline,
              obscure: _hide,
              onToggleObscure: () => setState(() => _hide = !_hide),
              onSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showSnack(
                    context, 'Hubungi Admin untuk mengatur ulang kata sandi.'),
                child: const Text('Lupa Password?',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GradientButton(label: 'Masuk', loading: _loading, onPressed: _submit),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Belum punya akun? ',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text('Daftar',
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
