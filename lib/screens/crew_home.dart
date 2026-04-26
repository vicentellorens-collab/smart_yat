import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../services/connectivity_service.dart';
import 'login_screen.dart';
import 'crew/my_tasks_screen.dart';
import 'crew/hey_yat_screen.dart';

class CrewHome extends StatefulWidget {
  const CrewHome({super.key});

  @override
  State<CrewHome> createState() => _CrewHomeState();
}

class _CrewHomeState extends State<CrewHome> {
  int _currentIndex = 0;

  void _changeUser() {
    context.read<AppProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    final isOnline = context.watch<ConnectivityService>().isOnline;

    final screens = [
      MyTasksScreen(crewId: user?.id ?? ''),
      const HeyYatScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(user?.name ?? 'Tripulante'),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline
                    ? const Color(0xFF10b981)
                    : const Color(0xFFef4444),
              ),
            ),
          ],
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: const [],
      ),
      drawer: NavigationDrawer(
        backgroundColor: AppTheme.panel,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.accent.withValues(alpha: 0.2),
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0] : 'T',
                        style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline
                            ? const Color(0xFF10b981)
                            : const Color(0xFFef4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(user?.name ?? 'Tripulante',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const Text('Tripulante',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Divider(color: AppTheme.dividerColor),
          ListTile(
            leading:
                const Icon(Icons.switch_account, color: AppTheme.accent),
            title: const Text('Cambiar de usuario',
                style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              _changeUser();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text('Cerrar Sesión',
                style: TextStyle(color: AppTheme.errorColor)),
            onTap: () {
              Navigator.pop(context);
              _changeUser();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline)
            Material(
              color: const Color(0xFFef4444),
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Text('Sin conexión · Modo offline',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: context
                      .watch<AppProvider>()
                      .getTasksForCrew(user?.id ?? '')
                      .isNotEmpty,
              label: Text(
                '${context.watch<AppProvider>().getTasksForCrew(user?.id ?? '').length}',
              ),
              child: const Icon(Icons.assignment_outlined),
            ),
            selectedIcon: const Icon(Icons.assignment),
            label: 'Mis Tareas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.mic_outlined),
            selectedIcon: Icon(Icons.mic),
            label: 'Hey Yat',
          ),
        ],
      ),
    );
  }
}
