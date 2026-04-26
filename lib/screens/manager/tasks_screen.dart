import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class TasksScreen extends StatefulWidget {
  final TaskStatus? initialFilter;
  final int initialTab;

  const TasksScreen({
    super.key,
    this.initialFilter,
    this.initialTab = 0,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  TaskStatus? _filter;
  String _historySearch = '';
  String _historyDateFilter = 'all';

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _tabCtrl = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final rejectedTasks =
        p.tasks.where((t) => t.status == TaskStatus.rechazada).toList();

    // Active tasks: exclude rejected, hide completed > 48h
    List<Task> activeTasks;
    if (_filter == null) {
      activeTasks = p.tasks.where((t) {
        if (t.status == TaskStatus.rechazada) return false;
        if (t.status == TaskStatus.completada) {
          if (t.completedAt == null) return false;
          return DateTime.now().difference(t.completedAt!).inHours < 48;
        }
        return true;
      }).toList();
    } else if (_filter == TaskStatus.completada) {
      activeTasks = p.tasks.where((t) {
        if (t.status != TaskStatus.completada) return false;
        if (t.completedAt == null) return false;
        return DateTime.now().difference(t.completedAt!).inHours < 48;
      }).toList();
    } else {
      activeTasks = p.tasks.where((t) => t.status == _filter).toList();
    }

    // History: all completed tasks
    var historyTasks = p.tasks
        .where((t) => t.status == TaskStatus.completada)
        .toList()
      ..sort((a, b) {
        final at = a.completedAt ?? a.createdAt;
        final bt = b.completedAt ?? b.createdAt;
        return bt.compareTo(at);
      });

    if (_historySearch.isNotEmpty) {
      final q = _historySearch.toLowerCase();
      historyTasks = historyTasks
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              (t.assignedToName?.toLowerCase().contains(q) ?? false) ||
              t.description.toLowerCase().contains(q))
          .toList();
    }
    if (_historyDateFilter == 'week') {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      historyTasks = historyTasks
          .where((t) => (t.completedAt ?? t.createdAt).isAfter(cutoff))
          .toList();
    } else if (_historyDateFilter == 'month') {
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      historyTasks = historyTasks
          .where((t) => (t.completedAt ?? t.createdAt).isAfter(cutoff))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TAREAS'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accent,
          tabs: [
            const Tab(text: 'ACTIVAS'),
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
            const Tab(text: 'HISTORIAL'),
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
          // ── ACTIVAS tab ──
          Column(
            children: [
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  children: [
                    _FilterChip(
                        label: 'Todas',
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null)),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'Pendientes',
                        selected: _filter == TaskStatus.pendiente,
                        onTap: () => setState(
                            () => _filter = TaskStatus.pendiente)),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'En Progreso',
                        selected: _filter == TaskStatus.enProgreso,
                        onTap: () => setState(
                            () => _filter = TaskStatus.enProgreso)),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'Completadas (48h)',
                        selected: _filter == TaskStatus.completada,
                        onTap: () => setState(
                            () => _filter = TaskStatus.completada)),
                  ],
                ),
              ),
              Expanded(
                child: activeTasks.isEmpty
                    ? const EmptyState(
                        icon: Icons.task_alt_outlined,
                        message: 'No hay tareas en esta categoría')
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: activeTasks.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) =>
                            _TaskCard(activeTasks[i]),
                      ),
              ),
            ],
          ),

          // ── RECHAZADAS tab ──
          rejectedTasks.isEmpty
              ? const EmptyState(
                  icon: Icons.check_circle_outline,
                  message: 'Sin tareas rechazadas')
              : ListView.separated(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: rejectedTasks.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) =>
                      _RejectedTaskCard(rejectedTasks[i]),
                ),

          // ── HISTORIAL tab ──
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar en historial...',
                    hintStyle:
                        const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textSecondary),
                    suffixIcon: _historySearch.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppTheme.textSecondary),
                            onPressed: () =>
                                setState(() => _historySearch = ''),
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (v) =>
                      setState(() => _historySearch = v),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterChip(
                        label: 'Todo',
                        selected: _historyDateFilter == 'all',
                        onTap: () => setState(
                            () => _historyDateFilter = 'all')),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'Esta semana',
                        selected: _historyDateFilter == 'week',
                        onTap: () => setState(
                            () => _historyDateFilter = 'week')),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'Este mes',
                        selected: _historyDateFilter == 'month',
                        onTap: () => setState(
                            () => _historyDateFilter = 'month')),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: historyTasks.isEmpty
                    ? const EmptyState(
                        icon: Icons.history,
                        message: 'No hay tareas completadas')
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: historyTasks.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) =>
                            _HistoryTaskCard(historyTasks[i]),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTaskDialog(BuildContext context, [Task? existing]) {
    final titleCtrl =
        TextEditingController(text: existing?.title);
    final descCtrl =
        TextEditingController(text: existing?.description);
    TaskPriority priority =
        existing?.priority ?? TaskPriority.media;
    String? assignedId = existing?.assignedToId;
    String? assignedName = existing?.assignedToName;
    final crew = context.read<AppProvider>().crew;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  existing == null ? 'NUEVA TAREA' : 'EDITAR TAREA',
                  style: AppTheme.orbitron(size: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(
                    color: AppTheme.textPrimary),
                decoration:
                    const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: const TextStyle(
                    color: AppTheme.textPrimary),
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Prioridad:',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13)),
                  const SizedBox(width: 10),
                  ...TaskPriority.values.map((p) => GestureDetector(
                        onTap: () =>
                            setModalState(() => priority = p),
                        child: Container(
                          margin:
                              const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: priority == p
                                ? AppTheme.accent
                                    .withValues(alpha: 0.2)
                                : AppTheme.background,
                            borderRadius:
                                BorderRadius.circular(6),
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
              DropdownButtonFormField<String>(
                initialValue: assignedId,
                dropdownColor: AppTheme.panel,
                style: const TextStyle(
                    color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                    labelText:
                        'Asignar a tripulante (opcional)'),
                items: [
                  const DropdownMenuItem(
                      value: null,
                      child: Text('Sin asignar')),
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
                    final provider =
                        context.read<AppProvider>();
                    if (existing == null) {
                      provider.addTask(Task(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        priority: priority,
                        assignedToId: assignedId,
                        assignedToName: assignedName,
                        createdAt: DateTime.now(),
                      ));
                    } else {
                      existing.title = titleCtrl.text.trim();
                      existing.description =
                          descCtrl.text.trim();
                      existing.priority = priority;
                      existing.assignedToId = assignedId;
                      existing.assignedToName = assignedName;
                      provider.updateTask(existing);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(existing == null
                      ? 'CREAR TAREA'
                      : 'GUARDAR'),
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
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent.withValues(alpha: 0.2)
              : AppTheme.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                selected ? AppTheme.accent : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppTheme.accent
                : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
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
        child:
            const Icon(Icons.delete_outline, color: AppTheme.errorColor),
      ),
      onDismissed: (_) =>
          context.read<AppProvider>().deleteTask(task.id),
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
                            color: task.status ==
                                    TaskStatus.completada
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration:
                                task.status == TaskStatus.completada
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
                            color: AppTheme.textSecondary,
                            fontSize: 11)),
                    const SizedBox(width: 12),
                  ],
                  Text(timeAgo(task.createdAt),
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11)),
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
    final crew = context.read<AppProvider>().crew;
    String? assignedId = task.assignedToId;
    String? assignedName = task.assignedToName;
    final instrCtrl = TextEditingController(text: task.description);
    final checkCtrl = TextEditingController();
    final localChecklist = List<ChecklistItem>.from(task.checklist);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppTheme.orbitron(size: 15)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    PriorityBadge(task.priority),
                    const SizedBox(width: 8),
                    TaskStatusChip(task.status),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(task.description,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
                if (task.completedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppTheme.successColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Completada el ${DateFormat('dd/MM/yyyy \'a las\' HH:mm').format(task.completedAt!)}',
                        style: const TextStyle(
                            color: AppTheme.successColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text('ASIGNACIÓN',
                    style: AppTheme.orbitron(
                        size: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: assignedId,
                  dropdownColor: AppTheme.panel,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Asignar a tripulante',
                  ),
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
                const SizedBox(height: 10),
                TextField(
                  controller: instrCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Instrucciones / comentarios',
                  ),
                ),
                const SizedBox(height: 16),
                // ── CHECKLIST ──
                Row(
                  children: [
                    Text('CHECKLIST',
                        style: AppTheme.orbitron(
                            size: 11, color: AppTheme.textSecondary)),
                    const Spacer(),
                    Text(
                      '${localChecklist.where((i) => i.done).length}/${localChecklist.length}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...localChecklist.map((item) => Row(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Checkbox(
                            value: item.done,
                            activeColor: AppTheme.accent,
                            onChanged: (v) =>
                                setModalState(() => item.done = v ?? false),
                          ),
                        ),
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
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppTheme.textSecondary, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              setModalState(() => localChecklist.remove(item)),
                        ),
                      ],
                    )),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: checkCtrl,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Añadir elemento al checklist...',
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8),
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            setModalState(() {
                              localChecklist.add(ChecklistItem(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                text: v.trim(),
                              ));
                              checkCtrl.clear();
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppTheme.accent),
                      onPressed: () {
                        if (checkCtrl.text.trim().isNotEmpty) {
                          setModalState(() {
                            localChecklist.add(ChecklistItem(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              text: checkCtrl.text.trim(),
                            ));
                            checkCtrl.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (task.status == TaskStatus.pendiente ||
                    task.status == TaskStatus.enProgreso) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            task.assignedToId = assignedId;
                            task.assignedToName = assignedName;
                            task.description = instrCtrl.text.trim();
                            task.checklist = localChecklist;
                            context.read<AppProvider>().updateTask(task);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(assignedId != null
                                    ? 'Tarea asignada a $assignedName'
                                    : 'Tarea actualizada'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accent,
                            side: const BorderSide(color: AppTheme.accent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(task.assignedToId == null
                              ? 'Asignar'
                              : 'Reasignar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            task.status = TaskStatus.completada;
                            task.completedAt = DateTime.now();
                            task.assignedToId = assignedId;
                            task.assignedToName = assignedName;
                            task.checklist = localChecklist;
                            context.read<AppProvider>().updateTask(task);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Completada'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── HISTORY TASK CARD (read-only) ──

class _HistoryTaskCard extends StatelessWidget {
  final Task task;
  const _HistoryTaskCard(this.task);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.successColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppTheme.successColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(task.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough)),
              ),
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
          const SizedBox(height: 8),
          Row(
            children: [
              if (task.assignedToName != null) ...[
                const Icon(Icons.person_outline,
                    color: AppTheme.textSecondary, size: 13),
                const SizedBox(width: 4),
                Text(task.assignedToName!,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11)),
                const SizedBox(width: 12),
              ],
              if (task.completedAt != null) ...[
                const Icon(Icons.check,
                    color: AppTheme.successColor, size: 13),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(task.completedAt!),
                  style: const TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 11)),
              ],
              const Spacer(),
              if (task.completionComment != null &&
                  task.completionComment!.isNotEmpty)
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Comentario',
                          style: TextStyle(
                              color: AppTheme.textPrimary)),
                      content: Text(task.completionComment!,
                          style: const TextStyle(
                              color: AppTheme.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text('Cerrar'),
                        )
                      ],
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.comment_outlined,
                          color: AppTheme.textSecondary,
                          size: 13),
                      SizedBox(width: 4),
                      Text('Comentario',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── REJECTED TASK CARD ──

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
        border: Border.all(
            color: AppTheme.errorColor.withValues(alpha: 0.4)),
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
                color:
                    AppTheme.errorColor.withValues(alpha: 0.08),
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
                          color: AppTheme.errorColor,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (task.actionBy != null) ...[
            const SizedBox(height: 4),
            Text(
              'Rechazada el ${DateFormat('dd/MM/yyyy \'a las\' HH:mm').format(task.actionAt ?? task.createdAt)}'
              '${task.actionBy != null ? ' · ${task.actionBy}' : ''}',
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
                    side: const BorderSide(
                        color: AppTheme.accent),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8),
                    textStyle:
                        const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context
                      .read<AppProvider>()
                      .deleteTask(task.id),
                  icon: const Icon(Icons.delete_outline,
                      size: 14),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(
                        color: AppTheme.errorColor),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8),
                    textStyle:
                        const TextStyle(fontSize: 12),
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
          title: Text('Reasignar tarea',
              style: AppTheme.orbitron(size: 14)),
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
                style:
                    const TextStyle(color: AppTheme.textPrimary),
                decoration:
                    const InputDecoration(labelText: 'Asignar a'),
                items: crew
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                    .toList(),
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
              style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accent),
              child: const Text('Reasignar'),
            ),
          ],
        ),
      ),
    );
  }
}
