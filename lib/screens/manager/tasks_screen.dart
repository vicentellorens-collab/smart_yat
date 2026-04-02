import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final tasks = _filter == null
        ? p.tasks
        : p.tasks.where((t) => t.status == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('TAREAS')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(label: 'Todas', selected: _filter == null,
                    onTap: () => setState(() => _filter = null)),
                const SizedBox(width: 8),
                _FilterChip(label: 'Pendientes',
                    selected: _filter == TaskStatus.pendiente,
                    onTap: () => setState(() => _filter = TaskStatus.pendiente)),
                const SizedBox(width: 8),
                _FilterChip(label: 'En Progreso',
                    selected: _filter == TaskStatus.enProgreso,
                    onTap: () => setState(
                        () => _filter = TaskStatus.enProgreso)),
                const SizedBox(width: 8),
                _FilterChip(label: 'Completadas',
                    selected: _filter == TaskStatus.completada,
                    onTap: () => setState(
                        () => _filter = TaskStatus.completada)),
                const SizedBox(width: 8),
                _FilterChip(label: 'Rechazadas',
                    selected: _filter == TaskStatus.rechazada,
                    onTap: () => setState(
                        () => _filter = TaskStatus.rechazada)),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const EmptyState(
                    icon: Icons.task_alt_outlined,
                    message: 'No hay tareas en esta categoría')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _TaskCard(tasks[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog(BuildContext context, [Task? existing]) {
    final titleCtrl = TextEditingController(text: existing?.title);
    final descCtrl = TextEditingController(text: existing?.description);
    TaskPriority priority = existing?.priority ?? TaskPriority.media;
    String? assignedId = existing?.assignedToId;
    String? assignedName = existing?.assignedToName;
    final crew = context.read<AppProvider>().crew;

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
              Text(existing == null ? 'NUEVA TAREA' : 'EDITAR TAREA',
                  style: AppTheme.orbitron(size: 14)),
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
              // Priority
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
                                  : AppTheme.dividerColor,
                            ),
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
              const SizedBox(height: 12),
              // Assign to crew
              DropdownButtonFormField<String>(
                initialValue: assignedId,
                dropdownColor: AppTheme.panel,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                    labelText: 'Asignar a tripulante (opcional)'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Sin asignar')),
                  ...crew.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      )),
                ],
                onChanged: (v) {
                  setModalState(() {
                    assignedId = v;
                    assignedName = crew
                        .where((c) => c.id == v)
                        .map((c) => c.name)
                        .firstOrNull;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final provider = context.read<AppProvider>();
                    if (existing == null) {
                      provider.addTask(Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        priority: priority,
                        assignedToId: assignedId,
                        assignedToName: assignedName,
                        createdAt: DateTime.now(),
                      ));
                    } else {
                      existing.title = titleCtrl.text.trim();
                      existing.description = descCtrl.text.trim();
                      existing.priority = priority;
                      existing.assignedToId = assignedId;
                      existing.assignedToName = assignedName;
                      provider.updateTask(existing);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(existing == null ? 'CREAR TAREA' : 'GUARDAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withOpacity(0.2) : AppTheme.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard(this.task);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
      ),
      onDismissed: (_) => context.read<AppProvider>().deleteTask(task.id),
      child: GestureDetector(
        onTap: () => _showTaskDetails(context, task),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(task.title,
                        style: TextStyle(
                            color: task.status == TaskStatus.completada
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: task.status == TaskStatus.completada
                                ? TextDecoration.lineThrough
                                : null)),
                  ),
                  const SizedBox(width: 8),
                  PriorityBadge(task.priority),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(task.description,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  if (task.assignedToName != null) ...[
                    const Icon(Icons.person_outline,
                        color: AppTheme.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text(task.assignedToName!,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                    const SizedBox(width: 12),
                  ],
                  Text(timeAgo(task.createdAt),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                  const Spacer(),
                  TaskStatusChip(task.status),
                ],
              ),
              if (task.rejectionReason != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.errorColor, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Rechazada: ${task.rejectionReason}',
                        style: const TextStyle(
                            color: AppTheme.errorColor, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: AppTheme.orbitron(size: 15)),
            const SizedBox(height: 8),
            Text(task.description,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              children: [
                PriorityBadge(task.priority),
                const SizedBox(width: 8),
                TaskStatusChip(task.status),
              ],
            ),
            if (task.assignedToName != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(task.assignedToName!,
                      style: const TextStyle(color: AppTheme.textPrimary)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (task.status == TaskStatus.pendiente ||
                task.status == TaskStatus.enProgreso) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    task.status = TaskStatus.completada;
                    task.completedAt = DateTime.now();
                    context.read<AppProvider>().updateTask(task);
                    Navigator.pop(context);
                  },
                  child: const Text('Marcar Completada'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
