import 'package:flutter/material.dart';
import 'package:smart_yat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class MyTasksScreen extends StatelessWidget {
  final String crewId;
  const MyTasksScreen({super.key, required this.crewId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          decoration: const BoxDecoration(
            color: AppTheme.surface01,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border(
              left: BorderSide(color: AppTheme.accent, width: 3),
              top: BorderSide(color: AppTheme.borderSubtle, width: 1),
              right: BorderSide(color: AppTheme.borderSubtle, width: 1),
              bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.today_outlined,
                  color: AppTheme.accent, size: 22),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HOY', style: AppTheme.sectionLabel(size: 13, color: AppTheme.accent)),
                  Text(
                    '${active.length} tarea${active.length != 1 ? "s" : ""} pendiente${active.length != 1 ? "s" : ""}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (active.isEmpty && done.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: EmptyState(
              icon: Icons.check_circle_outline,
              message: l10n.noActiveTasks,
            ),
          ),

        if (active.isNotEmpty) ...[
          SectionTitle('${l10n.filterPending.toUpperCase()} (${active.length})'),
          const SizedBox(height: 10),
          ...active.map((t) => _ActiveTaskCard(task: t)),
          const SizedBox(height: 24),
        ],

        if (done.isNotEmpty) ...[
          SectionTitle('${l10n.taskHistory.toUpperCase()} (${done.length})'),
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
        color: task.priority == TaskPriority.alta
            ? AppTheme.statusAlertBg
            : AppTheme.surface01,
        borderRadius: BorderRadius.circular(10),
        border: task.priority == TaskPriority.alta
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
              Expanded(
                child: Text(task.title, style: AppTheme.cardTitle(size: 15)),
              ),
              PriorityBadge(task.priority),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(task.description, style: AppTheme.label(size: 13)),
          ],
          if (task.checklist.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.checklist, color: AppTheme.accent, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Checklist (${task.checklist.where((i) => i.done).length}/${task.checklist.length})',
                  style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...task.checklist.map((item) => InkWell(
                  onTap: () {
                    item.done = !item.done;
                    context.read<AppProvider>().updateTask(task);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          item.done
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: item.done
                              ? AppTheme.accent
                              : AppTheme.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.text,
                            style: TextStyle(
                              color: item.done
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                              fontSize: 13,
                              decoration: item.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reject(context, task),
                  icon: const Icon(Icons.close, size: 16),
                  label: Text(AppLocalizations.of(context)!.reject),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.statusAlert,
                    side: const BorderSide(color: AppTheme.statusAlert),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _complete(context, task),
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(AppLocalizations.of(context)!.markAsCompleted),
                  style: ElevatedButton.styleFrom(
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

  void _complete(BuildContext context, Task task) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.markAsCompleted, style: AppTheme.sectionLabel(size: 13)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.instructions,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final comment = ctrl.text.trim();
              if (comment.isEmpty) return;
              context.read<AppProvider>().completeTask(task.id, comment);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _reject(BuildContext context, Task task) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.reject, style: AppTheme.sectionLabel(size: 13)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.rejectReason,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final reason = ctrl.text.trim();
              if (reason.isEmpty) return;
              context.read<AppProvider>().rejectTask(task.id, reason);
              Navigator.pop(context);
            },
            style:
                TextButton.styleFrom(foregroundColor: AppTheme.statusAlert),
            child: Text(l10n.confirm),
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
        color: task.status == TaskStatus.rechazada
            ? AppTheme.statusAlertBg
            : AppTheme.surface01,
        borderRadius: BorderRadius.circular(10),
        border: task.status == TaskStatus.rechazada
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
              Icon(
                task.status == TaskStatus.completada
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: task.status == TaskStatus.completada
                    ? AppTheme.textSecondary
                    : AppTheme.statusAlert,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.title,
                  style: AppTheme.label(size: 13),
                ),
              ),
              TaskStatusChip(task.status),
            ],
          ),
          if (task.completedAt != null &&
              task.status == TaskStatus.completada) ...[
            const SizedBox(height: 4),
            Text(
              'Completada el ${DateFormat('dd/MM/yyyy \'a las\' HH:mm').format(task.completedAt!)}',
              style: AppTheme.mono(size: 13, color: AppTheme.textSecondary),
            ),
          ],
          if (task.actionAt != null &&
              task.status == TaskStatus.rechazada) ...[
            const SizedBox(height: 4),
            Text(
              'Rechazada el ${DateFormat('dd/MM/yyyy \'a las\' HH:mm').format(task.actionAt!)}',
              style: const TextStyle(
                  color: AppTheme.statusAlert, fontSize: 13),
            ),
          ],
          if (task.completionComment != null && task.completionComment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.comment_outlined,
                    color: AppTheme.textSecondary, size: 13),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.completionComment!,
                    style: AppTheme.label(size: 13),
                  ),
                ),
              ],
            ),
          ],
          if (task.rejectionReason != null && task.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppTheme.statusAlert, size: 13),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.rejectionReason!,
                    style: const TextStyle(
                        color: AppTheme.statusAlert, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
