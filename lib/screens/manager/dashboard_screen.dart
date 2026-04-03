import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final user = p.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCrew'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accent.withOpacity(0.2),
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0] : 'G',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.accent,
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Greeting
            Text('Buen día, ${user?.name ?? 'Capitán'}',
                style: AppTheme.orbitron(size: 14)),
            const SizedBox(height: 4),
            Text(
              'Estado del yate en tiempo real',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                StatCard(
                  label: 'Tareas Activas',
                  value: '${p.activeTasks}',
                  icon: Icons.task_alt_outlined,
                  color: AppTheme.accent,
                ),
                StatCard(
                  label: 'Tareas Rechazadas',
                  value: '${p.rejectedTasks}',
                  icon: Icons.cancel_outlined,
                  color: p.rejectedTasks > 0
                      ? AppTheme.errorColor
                      : AppTheme.successColor,
                ),
                StatCard(
                  label: 'Incidencias Abiertas',
                  value: '${p.openIncidents}',
                  icon: Icons.warning_amber_outlined,
                  color: p.openIncidents > 0
                      ? AppTheme.errorColor
                      : AppTheme.successColor,
                ),
                StatCard(
                  label: 'Certs. con Alerta',
                  value: '${p.alertCertificates}',
                  icon: Icons.verified_outlined,
                  color: p.alertCertificates > 0
                      ? AppTheme.warningColor
                      : AppTheme.successColor,
                ),
                StatCard(
                  label: 'Stock Bajo/Agotado',
                  value: '${p.lowStockItems}',
                  icon: Icons.inventory_2_outlined,
                  color: p.lowStockItems > 0
                      ? AppTheme.warningColor
                      : AppTheme.successColor,
                ),
                StatCard(
                  label: 'Docs Escaneados',
                  value: '${p.scannedDocuments.length}',
                  icon: Icons.document_scanner_outlined,
                  color: AppTheme.accent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Urgent incidents
            if (p.incidents
                .where((i) => i.status == IncidentStatus.abierta)
                .isNotEmpty) ...[
              const SectionTitle('INCIDENCIAS ACTIVAS'),
              const SizedBox(height: 10),
              ...p.incidents
                  .where((i) => i.status == IncidentStatus.abierta)
                  .take(3)
                  .map((inc) => _IncidentTile(inc)),
              const SizedBox(height: 20),
            ],

            // Expiring certs
            if (p.certificates
                .where((c) =>
                    c.alertLevel == AlertLevel.days15 ||
                    c.alertLevel == AlertLevel.expired)
                .isNotEmpty) ...[
              const SectionTitle('CERTIFICADOS URGENTES'),
              const SizedBox(height: 10),
              ...p.certificates
                  .where((c) =>
                      c.alertLevel == AlertLevel.days15 ||
                      c.alertLevel == AlertLevel.expired)
                  .map((c) => _CertAlert(c)),
              const SizedBox(height: 20),
            ],

            // Low stock
            if (p.inventory
                .where((i) => i.status == InventoryStatus.sinStock)
                .isNotEmpty) ...[
              const SectionTitle('SIN STOCK'),
              const SizedBox(height: 10),
              ...p.inventory
                  .where((i) => i.status == InventoryStatus.sinStock)
                  .map((i) => _StockAlert(i)),
              const SizedBox(height: 20),
            ],

            // Recent tasks
            const SectionTitle('TAREAS RECIENTES'),
            const SizedBox(height: 10),
            ...p.tasks
                .where((t) =>
                    t.status == TaskStatus.pendiente ||
                    t.status == TaskStatus.enProgreso)
                .take(4)
                .map((t) => _TaskTile(t)),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _IncidentTile extends StatelessWidget {
  final Incident inc;
  const _IncidentTile(this.inc);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppTheme.errorColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inc.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                if (inc.location != null)
                  Text(inc.location!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          PriorityBadge(inc.priority),
        ],
      ),
    );
  }
}

class _CertAlert extends StatelessWidget {
  final Certificate cert;
  const _CertAlert(this.cert);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warningColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined,
              color: AppTheme.warningColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(cert.name,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
          AlertBadge(cert.alertLevel, cert.daysUntilExpiry),
        ],
      ),
    );
  }
}

class _StockAlert extends StatelessWidget {
  final InventoryItem item;
  const _StockAlert(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined,
              color: AppTheme.errorColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.name,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
          InventoryBadge(item.status),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  const _TaskTile(this.task);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                if (task.assignedToName != null)
                  Text(task.assignedToName!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TaskStatusChip(task.status),
        ],
      ),
    );
  }
}
