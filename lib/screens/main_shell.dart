import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'task_list_screen.dart';

/// Kerangka utama dengan bottom navigation: Beranda, Tugas, Riwayat, Profil.
class MainShell extends StatefulWidget {
  /// Tab aktif. Bisa diubah dari layar lain, mis. "Lihat Status Tugas".
  static final ValueNotifier<int> tab = ValueNotifier(0);

  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    MainShell.tab.value = 0;
    MainShell.tab.addListener(_onTab);
  }

  @override
  void dispose() {
    MainShell.tab.removeListener(_onTab);
    super.dispose();
  }

  // Muat ulang data setiap pindah tab agar selalu terbaru.
  void _onTab() => setState(() => _refreshKey++);

  void goTo(int i) => MainShell.tab.value = i;

  @override
  Widget build(BuildContext context) {
    final index = MainShell.tab.value;
    final pages = <Widget>[
      HomeScreen(key: ValueKey('home$_refreshKey'), onSeeAll: () => goTo(1)),
      TaskListScreen(key: ValueKey('tasks$_refreshKey')),
      HistoryScreen(key: ValueKey('history$_refreshKey')),
      ProfileScreen(key: ValueKey('profile$_refreshKey')),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: goTo,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.primarySoft,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: AppColors.primary),
                  label: 'Beranda'),
              NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon:
                      Icon(Icons.assignment, color: AppColors.primary),
                  label: 'Tugas'),
              NavigationDestination(
                  icon: Icon(Icons.history),
                  selectedIcon: Icon(Icons.history, color: AppColors.primary),
                  label: 'Riwayat'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.primary),
                  label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
