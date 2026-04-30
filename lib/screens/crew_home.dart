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

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.switch_account, color: AppTheme.accent),
              title: const Text('Cambiar de usuario',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _changeUser();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.logout, color: AppTheme.errorColor),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Navigator.pop(context);
                _changeUser();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accent.withValues(alpha: 0.2),
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'T',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Tripulante',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline
                              ? const Color(0xFF10b981)
                              : const Color(0xFFef4444),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'En línea' : 'Sin conexión',
                        style: TextStyle(
                          color: isOnline
                              ? const Color(0xFF10b981)
                              : const Color(0xFFef4444),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Opciones',
            onPressed: () => _showUserMenu(context),
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
