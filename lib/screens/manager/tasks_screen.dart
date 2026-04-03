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

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  TaskStatus? _filter;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final rejectedTasks = p.tasks
        .where((t) => t.status == TaskStatus.rechazada)
        .toList();
    final tasks = _filter == null
        ? p.tasks.where((t) => t.status != TaskStatus.rechazada).toList()
        : p.tasks.where((t) => t.status == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TAREAS'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accent,
          tabs: [
            const Tab(text: 'TODAS'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('RECHAZADAS'),
                  if (rejectedTasks.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${rejectedTasks.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // All tasks tab
          Column(
            children: [
              // Filter chips
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _FilterChip(
                        label: 'Todas',
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null)),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'Pendientes',
                        selected: _filter == TaskStatus.pendiente,
                        onTap: () =>
                            setState(() => _filter = TaskStatus.pendiente)),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'En Progreso',
                        selected: _filter == TaskStatus.enProgreso,
                        onTap: () =>
                            setState(() => _filter = TaskStatus.enProgreso)),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'Completadas',
                        selected: _filter == TaskStatus.completada,
                        onTap: () =>
                            setState(() => _filter = TaskStatus.completada)),
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

          // Rejected tasks tab
          rejectedTasks.isEmpty
              ? const EmptyState(
                  icon: Icons.check_circle_outline,
                  message: 'Sin tareas rechazadas')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: rejectedTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _RejectedTaskCard(rejectedTasks[i]),
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
                                ? AppTheme.accent.withValues(alpha: 0.2)
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
          color: selected ? AppTheme.accent.withValues(alpha: 0.2) : AppTheme.panel,
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
          color: AppTheme.errorColor.withValues(alpha: 0.2),
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

// ==================== REJECTED TASK CARD ====================

class _RejectedTaskCard extends StatelessWidget {
  final Task task;
  const _RejectedTaskCard(this.task);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel_outlined,
                  color: AppTheme.errorColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(task.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
              PriorityBadge(task.priority),
            ],
          ),
          if (task.rejectionReason != null &&
              task.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.errorColor, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task.rejectionReason!,
                      style: const TextStyle(
                          color: AppTheme.errorColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (task.actionBy != null) ...[
            const SizedBox(height: 4),
            Text(
              'Por: ${task.actionBy} · ${timeAgo(task.actionAt ?? task.createdAt)}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reassign(context, task),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Reasignar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    side: const BorderSide(color: AppTheme.accent),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.read<AppProvider>().deleteTask(task.id),
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(color: AppTheme.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _reassign(BuildContext context, Task task) {
    final crew = context.read<AppProvider>().crew;
    String? newAssignedId;
    String? newAssignedName;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Reasignar tarea', style: AppTheme.orbitron(size: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(task.title,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: newAssignedId,
                dropdownColor: AppTheme.panel,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                    labelText: 'Asignar a'),
                items: crew.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    )).toList(),
                onChanged: (v) {
                  setDialogState(() {
                    newAssignedId = v;
                    newAssignedName = crew
                        .where((c) => c.id == v)
                        .map((c) => c.name)
                        .firstOrNull;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (newAssignedId == null) return;
                task.status = TaskStatus.pendiente;
                task.assignedToId = newAssignedId;
                task.assignedToName = newAssignedName;
                task.rejectionReason = null;
                task.actionAt = null;
                task.actionBy = null;
                context.read<AppProvider>().updateTask(task);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tarea reasignada'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
              child: const Text('Reasignar'),
            ),
          ],
        ),
      ),
    );
  }
}
