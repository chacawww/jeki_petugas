import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/services.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(const JekiApp());
}

class JekiApp extends StatelessWidget {
  const JekiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JEKI Petugas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}

/// Menampilkan Login atau layar utama sesuai status login contoh.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService.loggedIn,
      builder: (context, loggedIn, _) =>
          loggedIn ? const MainShell() : const LoginScreen(),
    );
  }
}
