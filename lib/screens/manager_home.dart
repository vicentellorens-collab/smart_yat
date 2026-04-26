import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/connectivity_service.dart';
import 'login_screen.dart';
import 'manager/dashboard_screen.dart';
import 'manager/tasks_screen.dart';
import 'manager/crew_screen.dart';
import 'manager/certificates_screen.dart';
import 'manager/inventory_screen.dart';
import 'manager/document_scan_screen.dart';
import 'manager/incidents_screen.dart';
import 'crew/hey_yat_screen.dart';

class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  int _currentIndex = 0;

  // Navigation state for dashboard → screen
  Key _tasksKey = const Key('tasks-init');
  int _tasksInitialTab = 0;
  Key _inventoryKey = const Key('inventory-init');
  InventoryStatus? _inventoryInitialFilter;

  void _goToTasks({int tab = 0}) {
    setState(() {
      _tasksInitialTab = tab;
      _tasksKey = UniqueKey();
      _currentIndex = 1;
    });
  }

  void _goToInventory({InventoryStatus? filter}) {
    setState(() {
      _inventoryInitialFilter = filter;
      _inventoryKey = UniqueKey();
      _currentIndex = 4;
    });
  }

  void _switchProfile() {
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
      DashboardScreen(
        onActiveTasks: () => _goToTasks(tab: 0),
        onRejectedTasks: () => _goToTasks(tab: 1),
        onIncidents: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IncidentsScreen()),
        ),
        onCertificates: () => setState(() => _currentIndex = 3),
        onLowStock: () => _goToInventory(filter: InventoryStatus.bajo),
        onDocScan: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DocumentScanScreen()),
        ),
      ),
      TasksScreen(
        key: _tasksKey,
        initialTab: _tasksInitialTab,
      ),
      const CrewScreen(),
      const CertificatesScreen(),
      InventoryScreen(
        key: _inventoryKey,
        initialFilter: _inventoryInitialFilter,
      ),
      const HeyYatScreen(),
    ];

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
                      backgroundColor:
                          AppTheme.accent.withValues(alpha: 0.2),
                      child: Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0]
                            : 'G',
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
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Divider(color: AppTheme.dividerColor),
          ListTile(
            leading: const Icon(Icons.document_scanner_outlined,
                color: AppTheme.accent),
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
          ListTile(
            leading:
                const Icon(Icons.warning_amber_outlined, color: AppTheme.accent),
            title: const Text('Incidencias',
                style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const IncidentsScreen()));
            },
          ),
          const Divider(color: AppTheme.dividerColor),
          ListTile(
            leading:
                const Icon(Icons.switch_account, color: AppTheme.accent),
            title: const Text('Cambiar de usuario',
                style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              _switchProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
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
              isLabelVisible:
                  context.watch<AppProvider>().activeTasks > 0,
              label: Text('${context.watch<AppProvider>().activeTasks}'),
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
              label: Text(
                  '${context.watch<AppProvider>().lowStockItems}'),
              child: const Icon(Icons.inventory_2_outlined),
            ),
            selectedIcon: const Icon(Icons.inventory_2),
            label: 'Inventario',
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
