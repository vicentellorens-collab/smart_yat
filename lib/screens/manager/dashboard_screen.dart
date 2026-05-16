import 'package:flutter/material.dart';
import 'package:smart_yat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onActiveTasks;
  final VoidCallback onIncidents;
  final VoidCallback onCertificates;
  final VoidCallback onLowStock;

  const DashboardScreen({
    super.key,
    required this.onActiveTasks,
    required this.onIncidents,
    required this.onCertificates,
    required this.onLowStock,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final user = p.currentUser;
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Greeting
          Text(
            'Buen día, ${user?.name ?? 'Capitán'}',
            style: AppTheme.displayCondensed(size: 22),
          ),
          const SizedBox(height: 16),

          // Stats grid — 2×2
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              StatCard(
                label: l10n.activeTasks,
                value: '${p.activeTasks}',
                icon: Icons.task_alt_outlined,
                color: AppTheme.accent,
                onTap: onActiveTasks,
              ),
              StatCard(
                label: l10n.openIncidents,
                value: '${p.openIncidents}',
                icon: Icons.warning_amber_outlined,
                color: p.openIncidents > 0 ? AppTheme.statusAlert : AppTheme.accent,
                onTap: onIncidents,
              ),
              StatCard(
                label: l10n.certificateAlerts,
                value: '${p.alertCertificates}',
                icon: Icons.verified_outlined,
                color: p.alertCertificates > 0 ? AppTheme.statusWarn : AppTheme.accent,
                onTap: onCertificates,
              ),
              StatCard(
                label: l10n.lowStock,
                value: '${p.lowStockItems}',
                icon: Icons.inventory_2_outlined,
                color: p.lowStockItems > 0 ? AppTheme.statusWarn : AppTheme.accent,
                onTap: onLowStock,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Upcoming events — placeholder hasta Bloque 2
          SectionTitle(
            'Próximos eventos',
            trailing: Text(
              'Ver todos',
              style: AppTheme.label(color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface01,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Text(
              'No hay eventos próximos. Próximamente podrás añadirlos desde HEY YAT.',
              style: AppTheme.label(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Urgent incidents
          if (p.incidents
              .where((i) => i.status == IncidentStatus.abierta)
              .isNotEmpty) ...[
            SectionTitle(
              l10n.activeIncidents,
              trailing: TextButton(
                onPressed: onIncidents,
                child: Text(l10n.viewAll,
                    style: AppTheme.label(color: AppTheme.accent)),
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
              l10n.urgentCertificates,
              trailing: TextButton(
                onPressed: onCertificates,
                child: Text(l10n.viewAll,
                    style: AppTheme.label(color: AppTheme.accent)),
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
              l10n.noStock,
              trailing: TextButton(
                onPressed: onLowStock,
                child: Text(l10n.viewAll,
                    style: AppTheme.label(color: AppTheme.accent)),
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
            l10n.recentTasks,
            trailing: TextButton(
              onPressed: onActiveTasks,
              child: Text(l10n.viewAll,
                  style: AppTheme.label(color: AppTheme.accent)),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.statusAlertBg,
            border: Border(
              left: BorderSide(color: AppTheme.statusAlert, width: 3),
              top: BorderSide(color: AppTheme.borderSubtle, width: 1),
              right: BorderSide(color: AppTheme.borderSubtle, width: 1),
              bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppTheme.statusAlert, size: 20),
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
                              color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              PriorityBadge(inc.priority),
            ],
          ),
        ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.statusWarnBg,
            border: Border(
              left: BorderSide(color: AppTheme.statusWarn, width: 3),
              top: BorderSide(color: AppTheme.borderSubtle, width: 1),
              right: BorderSide(color: AppTheme.borderSubtle, width: 1),
              bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_outlined,
                  color: AppTheme.statusWarn, size: 20),
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
                              color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              AlertBadge(cert.alertLevel, cert.daysUntilExpiry),
            ],
          ),
        ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.statusAlertBg,
            border: Border(
              left: BorderSide(color: AppTheme.statusAlert, width: 3),
              top: BorderSide(color: AppTheme.borderSubtle, width: 1),
              right: BorderSide(color: AppTheme.borderSubtle, width: 1),
              bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: AppTheme.statusAlert, size: 20),
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
        ),
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
        color: AppTheme.surface01,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: AppTheme.cardTitle(size: 13)),
                if (task.assignedToName != null)
                  Text(task.assignedToName!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
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
