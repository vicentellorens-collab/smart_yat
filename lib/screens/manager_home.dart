import 'package:flutter/material.dart';
import 'package:smart_yat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/connectivity_service.dart';
import '../services/language_service.dart';
import '../widgets/smartyat_logo.dart';
import 'login_screen.dart';
import 'settings/language_screen.dart';
import 'manager/dashboard_screen.dart';
import 'manager/tasks_screen.dart';
import 'manager/crew_screen.dart';
import 'manager/certificates_screen.dart';
import 'manager/inventory_screen.dart';
import 'manager/incidents_screen.dart';
import 'crew/hey_yat_screen.dart';

class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  // Nav order: Dashboard(0) Tasks(1) Incidents(2) Certificates(3) Inventory(4)
  int _currentIndex = 0;
  bool _showCrewScreen = false;

  Key _tasksKey = const Key('tasks-init');
  int _tasksInitialTab = 0;
  Key _inventoryKey = const Key('inventory-init');
  InventoryStatus? _inventoryInitialFilter;

  void _goToTasks({int tab = 0}) {
    setState(() {
      _tasksInitialTab = tab;
      _tasksKey = UniqueKey();
      _currentIndex = 1;
      _showCrewScreen = false;
    });
  }

  void _goToInventory({InventoryStatus? filter}) {
    setState(() {
      _inventoryInitialFilter = filter;
      _inventoryKey = UniqueKey();
      _currentIndex = 4;
      _showCrewScreen = false;
    });
  }

  void _switchProfile() async {
    context.read<AppProvider>().logout();
    await context.read<LanguageService>().resetToDeviceLanguage();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _logout() async {
    context.read<AppProvider>().logout();
    await context.read<LanguageService>().resetToDeviceLanguage();
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final isOnline = context.watch<ConnectivityService>().isOnline;

    final screens = [
      DashboardScreen(
        onActiveTasks: () => _goToTasks(tab: 0),
        onIncidents: () => setState(() {
          _currentIndex = 2;
          _showCrewScreen = false;
        }),
        onCertificates: () => setState(() {
          _currentIndex = 3;
          _showCrewScreen = false;
        }),
        onLowStock: () => _goToInventory(filter: InventoryStatus.bajo),
      ),
      TasksScreen(
        key: _tasksKey,
        initialTab: _tasksInitialTab,
      ),
      const IncidentsScreen(),
      const CertificatesScreen(),
      InventoryScreen(
        key: _inventoryKey,
        initialFilter: _inventoryInitialFilter,
      ),
    ];

    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.dashboard,
      l10n.tasks,
      l10n.incidents,
      l10n.certificates,
      l10n.inventory,
    ];

    return PopScope(
      canPop: !_showCrewScreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _showCrewScreen) {
          setState(() => _showCrewScreen = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menú',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (provider.yachtConfig?.name.isNotEmpty == true)
                    Text(
                      provider.yachtConfig!.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    _showCrewScreen ? l10n.crew : titles[_currentIndex],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
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
                        style: AppTheme.label(
                            size: 13, color: AppTheme.statusAlert)),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_outlined),
            tooltip: 'HEY YAT',
            onPressed: _openHeyYat,
          ),
        ],
      ),
      drawer: _buildDrawer(context, user),
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
          Expanded(
            child: _showCrewScreen
                ? const CrewScreen()
                : screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1, color: AppTheme.borderSubtle),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() {
              _currentIndex = i;
              _showCrewScreen = false;
            }),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: l10n.dashboard,
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: provider.activeTasks > 0,
                  label: Text('${provider.activeTasks}'),
                  child: const Icon(Icons.task_alt_outlined),
                ),
                selectedIcon: const Icon(Icons.task_alt),
                label: l10n.tasks,
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: provider.openIncidents > 0,
                  label: Text('${provider.openIncidents}'),
                  child: const Icon(Icons.warning_amber_outlined),
                ),
                selectedIcon: const Icon(Icons.warning_amber),
                label: l10n.incidents,
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: provider.alertCertificates > 0,
                  label: Text('${provider.alertCertificates}'),
                  child: const Icon(Icons.verified_outlined),
                ),
                selectedIcon: const Icon(Icons.verified),
                label: l10n.certificates,
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: provider.lowStockItems > 0,
                  label: Text('${provider.lowStockItems}'),
                  child: const Icon(Icons.inventory_2_outlined),
                ),
                selectedIcon: const Icon(Icons.inventory_2),
                label: l10n.inventory,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppUser? user) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: AppTheme.surface01,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmartYatLogo(width: 120),
                  if (user != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    if (user.yachtName != null)
                      Text(user.yachtName!, style: AppTheme.label()),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tripulación
            ListTile(
              leading:
                  const Icon(Icons.group_outlined, color: AppTheme.accent),
              title: Text(l10n.crew,
                  style: const TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _showCrewScreen = true);
              },
            ),

            // Calendario (placeholder — Bloque 2)
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined,
                  color: AppTheme.accent),
              title: const Text('Calendario',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente')),
                );
              },
            ),

            // Lista de compras (placeholder)
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined,
                  color: AppTheme.accent),
              title: const Text('Lista de compras',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente')),
                );
              },
            ),

            // Historial de tareas (placeholder)
            ListTile(
              leading: const Icon(Icons.history, color: AppTheme.accent),
              title: const Text('Historial de tareas',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente')),
                );
              },
            ),

            const Divider(color: AppTheme.borderSubtle),

            // Idioma
            ListTile(
              leading:
                  const Icon(Icons.language, color: AppTheme.accent),
              title: const Text('Language / Idioma',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LanguageScreen()),
                );
              },
            ),

            // Cambiar de usuario
            ListTile(
              leading: const Icon(Icons.switch_account,
                  color: AppTheme.accent),
              title: const Text('Cambiar de usuario',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _switchProfile();
              },
            ),

            const Divider(color: AppTheme.borderSubtle),

            // Cerrar sesión — corregido: usa resetToDeviceLanguage()
            ListTile(
              leading:
                  const Icon(Icons.logout, color: AppTheme.statusAlert),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: AppTheme.statusAlert)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
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
