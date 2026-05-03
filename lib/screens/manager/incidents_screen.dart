import 'package:flutter/material.dart';
import 'package:smart_yat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final l10n = AppLocalizations.of(context)!;
    final open =
        p.incidents.where((i) => i.status != IncidentStatus.resuelta).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.incidents.toUpperCase())),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.newIncident),
      ),
      body: open.isEmpty
          ? EmptyState(
              icon: Icons.check_circle_outline,
              message: l10n.openIncidents)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: open.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _IncidentCard(incident: open[i]),
            ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    TaskPriority priority = TaskPriority.media;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.newIncident.toUpperCase(), style: AppTheme.sectionLabel(size: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(labelText: l10n.taskTitle),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.taskDescription),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration:
                    const InputDecoration(labelText: 'Ubicación (opcional)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('${l10n.priority}:',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(width: 10),
                  ...TaskPriority.values.map((p) => GestureDetector(
                        onTap: () => setModalState(() => priority = p),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: priority == p
                                ? AppTheme.accent.withOpacity(0.2)
                                : AppTheme.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: priority == p
                                    ? AppTheme.accent
                                    : AppTheme.borderSubtle),
                          ),
                          child: Text(
                            p.name.toUpperCase(),
                            style: TextStyle(
                                fontSize: 13,
                                color: priority == p
                                    ? AppTheme.accent
                                    : AppTheme.textSecondary),
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final user = context.read<AppProvider>().currentUser;
                    context.read<AppProvider>().addIncident(Incident(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          location: locCtrl.text.trim().isEmpty
                              ? null
                              : locCtrl.text.trim(),
                          priority: priority,
                          reportedBy: user?.name ?? 'Gestor',
                          reportedAt: DateTime.now(),
                        ));
                    Navigator.pop(ctx);
                  },
                  child: Text(l10n.create.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;
  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final bool isActive = incident.status != IncidentStatus.resuelta;
    final statusColor = switch (incident.status) {
      IncidentStatus.abierta => AppTheme.statusAlert,
      IncidentStatus.asignada => AppTheme.accent,
      IncidentStatus.enProgreso => AppTheme.statusWarn,
      IncidentStatus.resuelta => AppTheme.textSecondary,
    };
    final statusLabel = switch (incident.status) {
      IncidentStatus.abierta => 'ABIERTA',
      IncidentStatus.asignada => 'ASIGNADA',
      IncidentStatus.enProgreso => 'EN PROGRESO',
      IncidentStatus.resuelta => 'RESUELTA',
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.statusAlertBg : AppTheme.surface01,
          border: isActive
              ? const Border(
                  left: BorderSide(color: AppTheme.statusAlert, width: 3),
                  top: BorderSide(color: AppTheme.borderSubtle, width: 1),
                  right: BorderSide(color: AppTheme.borderSubtle, width: 1),
                  bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
                )
              : Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: statusColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(incident.title, style: AppTheme.cardTitle(size: 14)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(statusLabel,
                    style: AppTheme.sectionLabel(size: 13, color: statusColor)),
              ),
            ],
          ),
          if (incident.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(incident.description,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              PriorityBadge(incident.priority),
              const SizedBox(width: 8),
              if (incident.location != null)
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      color: AppTheme.textSecondary, size: 13),
                  const SizedBox(width: 2),
                  Text(incident.location!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ]),
              const Spacer(),
              Text('Por ${incident.reportedBy}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
          if (incident.assignedToName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, color: AppTheme.accent, size: 13),
                const SizedBox(width: 4),
                Text(
                  'Asignada a: ${incident.assignedToName}',
                  style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (incident.status == IncidentStatus.abierta)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showAssignSheet(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: const BorderSide(color: AppTheme.accent),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: AppTheme.label(),
                    ),
                    child: Text(AppLocalizations.of(context)!.assignTo),
                  ),
                ),
              if (incident.status == IncidentStatus.asignada) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      incident.status = IncidentStatus.enProgreso;
                      context.read<AppProvider>().updateIncident(incident);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.statusWarn,
                      side: const BorderSide(color: AppTheme.statusWarn),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: AppTheme.label(),
                    ),
                    child: Text(AppLocalizations.of(context)!.inProgressIncident),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      incident.status = IncidentStatus.resuelta;
                      context.read<AppProvider>().updateIncident(incident);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: const BorderSide(color: AppTheme.accent),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: AppTheme.label(),
                    ),
                    child: Text(AppLocalizations.of(context)!.resolve),
                  ),
                ),
              ],
              if (incident.status == IncidentStatus.enProgreso)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      incident.status = IncidentStatus.resuelta;
                      context.read<AppProvider>().updateIncident(incident);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: const BorderSide(color: AppTheme.accent),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: AppTheme.label(),
                    ),
                    child: Text(AppLocalizations.of(context)!.resolve),
                  ),
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  void _showAssignSheet(BuildContext context) {
    final crew = context.read<AppProvider>().crew;
    CrewMember? selectedCrew;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.assignTo.toUpperCase(), style: AppTheme.sectionLabel(size: 13)),
              const SizedBox(height: 4),
              Text(
                incident.title,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CrewMember>(
                value: selectedCrew,
                decoration:
                    InputDecoration(labelText: AppLocalizations.of(context)!.assignTo),
                dropdownColor: AppTheme.panel,
                items: crew
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary)),
                        ))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedCrew = v),
              ),
              const SizedBox(height: 8),
              Text(
                'Se creará automáticamente una tarea urgente para el tripulante.',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedCrew == null
                      ? null
                      : () {
                          final p = context.read<AppProvider>();
                          incident.status = IncidentStatus.asignada;
                          incident.assignedToId = selectedCrew!.id;
                          incident.assignedToName = selectedCrew!.name;
                          p.updateIncident(incident);
                          p.addTask(Task(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title: 'INCIDENCIA: ${incident.title}',
                            description: incident.description.isNotEmpty
                                ? incident.description
                                : incident.title,
                            assignedToId: selectedCrew!.id,
                            assignedToName: selectedCrew!.name,
                            priority: TaskPriority.alta,
                            createdAt: DateTime.now(),
                          ));
                          Navigator.pop(ctx);
                        },
                  child: Text(AppLocalizations.of(context)!.assign.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
