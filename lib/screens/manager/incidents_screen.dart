import 'package:flutter/material.dart';
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
    final open =
        p.incidents.where((i) => i.status != IncidentStatus.resuelta).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('INCIDENCIAS')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: open.isEmpty
          ? const EmptyState(
              icon: Icons.check_circle_outline,
              message: 'No hay incidencias abiertas')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: open.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _IncidentCard(incident: open[i]),
            ),
    );
  }

  void _showAddDialog(BuildContext context) {
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
              Text('NUEVA INCIDENCIA', style: AppTheme.orbitron(size: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Descripción'),
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
                  const Text('Prioridad:',
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
                                    : AppTheme.dividerColor),
                          ),
                          child: Text(
                            p.name.toUpperCase(),
                            style: TextStyle(
                                fontSize: 11,
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
                  child: const Text('CREAR'),
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
    final statusColor = switch (incident.status) {
      IncidentStatus.abierta => AppTheme.errorColor,
      IncidentStatus.asignada => AppTheme.accent,
      IncidentStatus.enProgreso => AppTheme.warningColor,
      IncidentStatus.resuelta => AppTheme.successColor,
    };
    final statusLabel = switch (incident.status) {
      IncidentStatus.abierta => 'ABIERTA',
      IncidentStatus.asignada => 'ASIGNADA',
      IncidentStatus.enProgreso => 'EN PROGRESO',
      IncidentStatus.resuelta => 'RESUELTA',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: statusColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(incident.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (incident.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(incident.description,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
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
                      color: AppTheme.textSecondary, size: 12),
                  const SizedBox(width: 2),
                  Text(incident.location!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ]),
              const Spacer(),
              Text('Por ${incident.reportedBy}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
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
                      fontSize: 12,
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
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Asignar a...'),
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
                      foregroundColor: AppTheme.warningColor,
                      side: const BorderSide(color: AppTheme.warningColor),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('En Progreso'),
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
                      foregroundColor: AppTheme.successColor,
                      side: const BorderSide(color: AppTheme.successColor),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Resolver'),
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
                      foregroundColor: AppTheme.successColor,
                      side: const BorderSide(color: AppTheme.successColor),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Resolver'),
                  ),
                ),
            ],
          ),
        ],
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
              Text('ASIGNAR INCIDENCIA', style: AppTheme.orbitron(size: 14)),
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
                    const InputDecoration(labelText: 'Asignar a tripulante'),
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
                    color: AppTheme.textSecondary, fontSize: 11),
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
                  child: const Text('ASIGNAR Y CREAR TAREA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
