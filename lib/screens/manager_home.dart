import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../services/connectivity_service.dart';
import 'login_screen.dart';
import 'manager/dashboard_screen.dart';
import 'manager/tasks_screen.dart';
import 'manager/crew_screen.dart';
import 'manager/certificates_screen.dart';
import 'manager/inventory_screen.dart';
import 'manager/owner_preferences_screen.dart';
import 'manager/document_scan_screen.dart';

class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    TasksScreen(),
    CrewScreen(),
    CertificatesScreen(),
    InventoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    final isOnline = context.watch<ConnectivityService>().isOnline;

    return Scaffold(
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
                        user?.name.isNotEmpty == true ? user!.name[0] : 'G',
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
                Text(user?.name ?? 'Gestor',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const Text('Gestor / Capitán',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Divider(color: AppTheme.dividerColor),
          ListTile(
            leading: const Icon(Icons.star_outline, color: AppTheme.accent),
            title: const Text('Preferencias Owner',
                style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const OwnerPreferencesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.document_scanner_outlined, color: AppTheme.accent),
            title: const Text('Escanear Documento',
                style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DocumentScanScreen()));
            },
          ),
          const Divider(color: AppTheme.dividerColor),
          ListTile(
            leading:
                const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text('Cerrar Sesión',
                style: TextStyle(color: AppTheme.errorColor)),
            onTap: () {
              context.read<AppProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible:
                  context.watch<AppProvider>().openIncidents > 0,
              label: Text(
                  '${context.watch<AppProvider>().openIncidents}'),
              child: const Icon(Icons.dashboard_outlined),
            ),
            selectedIcon: const Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: context.watch<AppProvider>().activeTasks > 0,
              label:
                  Text('${context.watch<AppProvider>().activeTasks}'),
              child: const Icon(Icons.task_alt_outlined),
            ),
            selectedIcon: const Icon(Icons.task_alt),
            label: 'Tareas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Tripulación',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible:
                  context.watch<AppProvider>().alertCertificates > 0,
              label: Text(
                  '${context.watch<AppProvider>().alertCertificates}'),
              child: const Icon(Icons.verified_outlined),
            ),
            selectedIcon: const Icon(Icons.verified),
            label: 'Certificados',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible:
                  context.watch<AppProvider>().lowStockItems > 0,
              label:
                  Text('${context.watch<AppProvider>().lowStockItems}'),
              child: const Icon(Icons.inventory_2_outlined),
            ),
            selectedIcon: const Icon(Icons.inventory_2),
            label: 'Inventario',
          ),
        ],
      ),
    );
  }
}
