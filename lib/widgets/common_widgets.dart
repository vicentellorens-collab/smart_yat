import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/models.dart';

// ==================== SECTION TITLE ====================

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: AppTheme.orbitron(size: 13)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ==================== STAT CARD ====================

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
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
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.orbitron(size: 22, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PRIORITY BADGE ====================

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const PriorityBadge(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      TaskPriority.alta => ('ALTA', AppTheme.errorColor),
      TaskPriority.media => ('MEDIA', AppTheme.warningColor),
      TaskPriority.baja => ('BAJA', AppTheme.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ==================== STATUS CHIP ====================

class TaskStatusChip extends StatelessWidget {
  final TaskStatus status;
  const TaskStatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TaskStatus.pendiente => ('Pendiente', AppTheme.warningColor),
      TaskStatus.enProgreso => ('En Progreso', AppTheme.accent),
      TaskStatus.completada => ('Completada', AppTheme.successColor),
      TaskStatus.rechazada => ('Rechazada', AppTheme.errorColor),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ==================== ALERT LEVEL BADGE ====================

class AlertBadge extends StatelessWidget {
  final AlertLevel level;
  final int days;
  const AlertBadge(this.level, this.days, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (level) {
      AlertLevel.expired => ('VENCIDO', AppTheme.errorColor),
      AlertLevel.days15 => ('${days}d', AppTheme.errorColor),
      AlertLevel.days30 => ('${days}d', AppTheme.warningColor),
      AlertLevel.days60 => ('${days}d', AppTheme.warningColor),
      AlertLevel.days90 => ('${days}d', const Color(0xFF60a5fa)),
      AlertLevel.none => ('OK', AppTheme.successColor),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ==================== INVENTORY STATUS BADGE ====================

class InventoryBadge extends StatelessWidget {
  final InventoryStatus status;
  const InventoryBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      InventoryStatus.ok => ('OK', AppTheme.successColor),
      InventoryStatus.bajo => ('BAJO', AppTheme.warningColor),
      InventoryStatus.sinStock => ('SIN STOCK', AppTheme.errorColor),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ==================== CATEGORY ICON ====================

class CategoryIcon extends StatelessWidget {
  final String category;
  const CategoryIcon(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (category) {
      'INCIDENCIA' => (Icons.warning_amber_rounded, AppTheme.errorColor),
      'INVENTARIO' => (Icons.inventory_2_outlined, AppTheme.warningColor),
      'PREFERENCIA_OWNER' => (Icons.star_outline, const Color(0xFFa78bfa)),
      'EVENTO' => (Icons.event_outlined, AppTheme.accent),
      'CONSULTA' => (Icons.help_outline, AppTheme.textSecondary),
      'TAREA' => (Icons.task_alt_outlined, AppTheme.successColor),
      _ => (Icons.help_outline, AppTheme.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

// ==================== PREFERENCE TYPE ICON ====================

class PrefTypeIcon extends StatelessWidget {
  final OwnerPreferenceType type;
  const PrefTypeIcon(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      OwnerPreferenceType.comida => (Icons.restaurant_outlined, const Color(0xFFf97316)),
      OwnerPreferenceType.bebida => (Icons.wine_bar_outlined, const Color(0xFFa78bfa)),
      OwnerPreferenceType.temperatura => (Icons.thermostat_outlined, AppTheme.accent),
      OwnerPreferenceType.musica => (Icons.music_note_outlined, const Color(0xFF34d399)),
      OwnerPreferenceType.eventos => (Icons.celebration_outlined, const Color(0xFFfbbf24)),
      OwnerPreferenceType.otro => (Icons.info_outline, AppTheme.textSecondary),
    };
    return Icon(icon, color: color, size: 20);
  }
}

// ==================== EMPTY STATE ====================

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppTheme.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==================== DATE FORMATTER ====================

String formatDate(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);
String formatDateTime(DateTime dt) => DateFormat('dd/MM HH:mm').format(dt);
String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}min';
  if (diff.inHours < 24) return 'hace ${diff.inHours}h';
  return 'hace ${diff.inDays}d';
}
