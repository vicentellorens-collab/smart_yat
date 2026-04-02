import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class MyTasksScreen extends StatelessWidget {
  final String crewId;
  const MyTasksScreen({super.key, required this.crewId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final allTasks = p.tasks
        .where((t) => t.assignedToId == crewId)
        .toList()
      ..sort((a, b) {
        const statusOrder = {
          TaskStatus.pendiente: 0,
          TaskStatus.enProgreso: 1,
          TaskStatus.completada: 2,
          TaskStatus.rechazada: 3,
        };
        return (statusOrder[a.status] ?? 4)
            .compareTo(statusOrder[b.status] ?? 4);
      });

    final active = allTasks
        .where((t) =>
            t.status == TaskStatus.pendiente ||
            t.status == TaskStatus.enProgreso)
        .toList();
    final done = allTasks
        .where((t) =>
            t.status == TaskStatus.completada ||
            t.status == TaskStatus.rechazada)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.today_outlined,
                  color: AppTheme.accent, size: 22),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HOY',
                      style: AppTheme.orbitron(
                          size: 12, color: AppTheme.accent)),
                  Text(
                    '${active.length} tarea${active.length != 1 ? "s" : ""} pendiente${active.length != 1 ? "s" : ""}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (active.isEmpty && done.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: EmptyState(
              icon: Icons.check_circle_outline,
              message: 'No tienes tareas asignadas.\n¡Buen trabajo!',
            ),
          ),

        if (active.isNotEmpty) ...[
          SectionTitle('PENDIENTES (${active.length})'),
          const SizedBox(height: 10),
          ...active.map((t) => _ActiveTaskCard(task: t)),
          const SizedBox(height: 24),
        ],

        if (done.isNotEmpty) ...[
          SectionTitle('HISTORIAL (${done.length})'),
          const SizedBox(height: 10),
          ...done.map((t) => _DoneTaskCard(task: t)),
        ],
      ],
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final Task task;
  const _ActiveTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.priority == TaskPriority.alta
              ? AppTheme.errorColor.withOpacity(0.5)
              : AppTheme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(task.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
              PriorityBadge(task.priority),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(task.description,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reject(context, task),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Rechazar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(color: AppTheme.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    task.status = TaskStatus.completada;
                    task.completedAt = DateTime.now();
                    context.read<AppProvider>().updateTask(task);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Tarea completada'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Completar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _reject(BuildContext context, Task task) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Rechazar tarea', style: AppTheme.orbitron(size: 14)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Motivo del rechazo',
            hintText: 'Ej: Falta material, no es mi área...',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              task.status = TaskStatus.rechazada;
              task.rejectionReason =
                  ctrl.text.trim().isEmpty ? 'Sin motivo' : ctrl.text.trim();
              context.read<AppProvider>().updateTask(task);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tarea rechazada'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            style:
                TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

class _DoneTaskCard extends StatelessWidget {
  final Task task;
  const _DoneTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.panel.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            task.status == TaskStatus.completada
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: task.status == TaskStatus.completada
                ? AppTheme.successColor
                : AppTheme.errorColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                decoration: task.status == TaskStatus.completada
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          TaskStatusChip(task.status),
        ],
      ),
    );
  }
}
