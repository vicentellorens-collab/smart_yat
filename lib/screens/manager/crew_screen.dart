import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class CrewScreen extends StatelessWidget {
  const CrewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('TRIPULACIÓN')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Añadir'),
      ),
      body: p.crew.isEmpty
          ? const EmptyState(
              icon: Icons.group_outlined,
              message: 'No hay tripulantes registrados')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: p.crew.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final member = p.crew[i];
                final activeTasks = p.getTasksForCrew(member.id).length;
                return _CrewCard(
                  member: member,
                  activeTasks: activeTasks,
                  onTap: () => _showMemberTasks(context, member, p),
                  onDelete: () => _confirmDelete(context, member, p),
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NUEVO TRIPULANTE', style: AppTheme.orbitron(size: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Cargo (ej: Marinero, Cocinero...)'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  context.read<AppProvider>().addCrewMember(CrewMember(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text.trim(),
                        role: roleCtrl.text.trim().isEmpty
                            ? 'Tripulante'
                            : roleCtrl.text.trim(),
                      ));
                  Navigator.pop(ctx);
                },
                child: const Text('AÑADIR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberTasks(
      BuildContext context, CrewMember member, AppProvider p) {
    final tasks = p.getTasksForCrew(member.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.accent.withOpacity(0.2),
                    child: Text(member.name[0],
                        style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name,
                          style: AppTheme.orbitron(size: 13)),
                      Text(member.role,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('TAREAS ACTIVAS (${tasks.length})',
                  style: AppTheme.orbitron(
                      size: 11, color: AppTheme.textSecondary)),
              const SizedBox(height: 10),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Sin tareas activas',
                      style: TextStyle(color: AppTheme.textSecondary)),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: ctrl,
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = tasks[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(t.title,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13)),
                            ),
                            const SizedBox(width: 8),
                            PriorityBadge(t.priority),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, CrewMember member, AppProvider p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Eliminar tripulante',
            style: AppTheme.orbitron(size: 14)),
        content: Text('¿Eliminar a ${member.name}?',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              p.deleteCrewMember(member.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _CrewCard extends StatelessWidget {
  final CrewMember member;
  final int activeTasks;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CrewCard({
    required this.member,
    required this.activeTasks,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.accent.withOpacity(0.15),
              child: Text(
                member.name[0],
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(member.role,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: activeTasks > 0
                        ? AppTheme.accent.withOpacity(0.15)
                        : AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$activeTasks tarea${activeTasks != 1 ? "s" : ""}',
                    style: TextStyle(
                        color: activeTasks > 0
                            ? AppTheme.accent
                            : AppTheme.successColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline,
                      color: AppTheme.textSecondary, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
