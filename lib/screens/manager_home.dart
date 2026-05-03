import 'package:flutter/material.dart';
import 'package:smart_yat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/connectivity_service.dart';
import '../services/language_service.dart';
import 'login_screen.dart';
import 'settings/language_screen.dart';
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
    context.read<LanguageService>().resetToDefault();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _openHeyYat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _HeyYatPage()),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface02,
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
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined,
                  color: AppTheme.accent),
              title: const Text('Escanear documento',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DocumentScanScreen()),
                );
              },
            ),
            const Divider(color: AppTheme.borderSubtle, height: 1),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.accent),
              title: const Text('Language / Idioma',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguageScreen()),
                );
              },
            ),
            const Divider(color: AppTheme.borderSubtle, height: 1),
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
              leading:
                  const Icon(Icons.logout, color: AppTheme.statusAlert),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: AppTheme.statusAlert)),
              onTap: () {
                Navigator.pop(context);
                context.read<AppProvider>().logout();
                context.read<LanguageService>().resetToDefault();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
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
      DashboardScreen(
        onActiveTasks: () => _goToTasks(tab: 0),
        onRejectedTasks: () => _goToTasks(tab: 1),
        onIncidents: () => setState(() => _currentIndex = 3),
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
      const IncidentsScreen(),
      const CertificatesScreen(),
      InventoryScreen(
        key: _inventoryKey,
        initialFilter: _inventoryInitialFilter,
      ),
    ];

    // AppBar titles per screen
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.dashboard,
      l10n.tasks,
      l10n.crew,
      l10n.incidents,
      l10n.certificates,
      l10n.inventory,
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(titles[_currentIndex]),
            const SizedBox(width: 8),
            if (!isOnline)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.statusAlert.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off,
                        color: AppTheme.statusAlert, size: 13),
                    const SizedBox(width: 4),
                    Text('Offline',
                        style: AppTheme.label(size: 13, color: AppTheme.statusAlert)),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          // HEY YAT shortcut always visible in AppBar
          IconButton(
            icon: const Icon(Icons.mic_outlined),
            tooltip: 'HEY YAT',
            onPressed: _openHeyYat,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Más opciones',
            onPressed: () => _showMoreMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline)
            Material(
              color: AppTheme.statusAlert,
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
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1, color: AppTheme.borderSubtle),
          NavigationBar(
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
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible:
                  context.watch<AppProvider>().activeTasks > 0,
              label:
                  Text('${context.watch<AppProvider>().activeTasks}'),
              child: const Icon(Icons.task_alt_outlined),
            ),
            selectedIcon: const Icon(Icons.task_alt),
            label: l10n.tasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.group_outlined),
            selectedIcon: const Icon(Icons.group),
            label: l10n.crew,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible:
                  context.watch<AppProvider>().openIncidents > 0,
              label: Text(
                  '${context.watch<AppProvider>().openIncidents}'),
              child: const Icon(Icons.warning_amber_outlined),
            ),
            selectedIcon: const Icon(Icons.warning_amber),
            label: l10n.incidents,
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
            label: l10n.certificates,
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
            label: l10n.inventory,
          ),
        ],
      ),
        ],
      ),
    );
  }
}

/// Wrapper para abrir HeyYat como pantalla completa desde el gestor
class _HeyYatPage extends StatelessWidget {
  const _HeyYatPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HEY YAT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const HeyYatScreen(),
    );
  }
}
