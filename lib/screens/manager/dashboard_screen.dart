import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onActiveTasks;
  final VoidCallback onRejectedTasks;
  final VoidCallback onIncidents;
  final VoidCallback onCertificates;
  final VoidCallback onLowStock;
  final VoidCallback onDocScan;

  DashboardScreen({
    super.key,
    required this.onActiveTasks,
    required this.onRejectedTasks,
    required this.onIncidents,
    required this.onCertificates,
    required this.onLowStock,
    required this.onDocScan,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final user = p.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartYat'),
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
            Text('Buen dÃ­a, ${user?.name ?? 'CapitÃ¡n'}',
                style: AppTheme.orbitron(size: 14)),
            const SizedBox(height: 4),
            const Text(
              'Estado del yate en tiempo real',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pulsa un widget para ir al mÃ³dulo',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),

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
                  onTap: onActiveTasks,
                ),
                StatCard(
                  label: 'Tareas Rechazadas',
                  value: '${p.rejectedTasks}',
                  icon: Icons.cancel_outlined,
                  color: p.rejectedTasks > 0
                      ? AppTheme.errorColor
                      : AppTheme.successColor,
                  onTap: onRejectedTasks,
                ),
                StatCard(
                  label: 'Incidencias Abiertas',
                  value: '${p.openIncidents}',
                  icon: Icons.warning_amber_outlined,
                  color: p.openIncidents > 0
                      ? AppTheme.errorColor
                      : AppTheme.successColor,
                  onTap: onIncidents,
                ),
                StatCard(
                  label: 'Certs. con Alerta',
                  value: '${p.alertCertificates}',
                  icon: Icons.verified_outlined,
                  color: p.alertCertificates > 0
                      ? AppTheme.warningColor
                      : AppTheme.successColor,
                  onTap: onCertificates,
                ),
                StatCard(
                  label: 'Stock Bajo/Agotado',
                  value: '${p.lowStockItems}',
                  icon: Icons.inventory_2_outlined,
                  color: p.lowStockItems > 0
                      ? AppTheme.warningColor
                      : AppTheme.successColor,
                  onTap: onLowStock,
                ),
                StatCard(
                  label: 'Docs Escaneados',
                  value: '${p.scannedDocuments.length}',
                  icon: Icons.document_scanner_outlined,
                  color: AppTheme.accent,
                  onTap: onDocScan,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Urgent incidents
            if (p.incidents
                .where((i) => i.status == IncidentStatus.abierta)
                .isNotEmpty) ...[
              SectionTitle(
                'INCIDENCIAS ACTIVAS',
                trailing: TextButton(
                  onPressed: onIncidents,
                  child: const Text('Ver todas',
                      style: TextStyle(
                          color: AppTheme.accent, fontSize: 12)),
                ),
              ),
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
              SectionTitle(
                'CERTIFICADOS URGENTES',
                trailing: TextButton(
                  onPressed: onCertificates,
                  child: const Text('Ver todos',
                      style: TextStyle(
                          color: AppTheme.accent, fontSize: 12)),
                ),
              ),
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
              SectionTitle(
                'SIN STOCK',
                trailing: TextButton(
                  onPressed: onLowStock,
                  child: const Text('Ver todo',
                      style: TextStyle(
                          color: AppTheme.accent, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 10),
              ...p.inventory
                  .where((i) => i.status == InventoryStatus.sinStock)
                  .map((i) => _StockAlert(i)),
              const SizedBox(height: 20),
            ],

            // Recent tasks
            SectionTitle(
              'TAREAS RECIENTES',
              trailing: TextButton(
                onPressed: onActiveTasks,
                child: const Text('Ver todas',
                    style:
                        TextStyle(color: AppTheme.accent, fontSize: 12)),
              ),
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cert.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                if (cert.certCategory == 'tripulante' &&
                    cert.crewMemberName != null)
                  Text('Tripulante: ${cert.crewMemberName}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
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

