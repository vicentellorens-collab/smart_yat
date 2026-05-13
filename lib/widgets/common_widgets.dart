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
        Text(text.toUpperCase(), style: AppTheme.sectionLabel()),
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

  bool get _hasStatus => color != AppTheme.accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hasStatus
                ? (color == AppTheme.statusAlert
                    ? AppTheme.statusAlertBg
                    : AppTheme.statusWarnBg)
                : AppTheme.surface01,
            border: Border(
              left: BorderSide(
                color: _hasStatus ? color : AppTheme.borderSubtle,
                width: _hasStatus ? 3 : 1,
              ),
              top: const BorderSide(color: AppTheme.borderSubtle, width: 1),
              right: const BorderSide(color: AppTheme.borderSubtle, width: 1),
              bottom: const BorderSide(color: AppTheme.borderSubtle, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(value, style: AppTheme.displayCondensed(size: 34, color: color)),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.label(size: 12).copyWith(height: 1.15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
      TaskPriority.alta  => ('ALTA',  AppTheme.statusAlert),
      TaskPriority.media => ('MEDIA', AppTheme.statusWarn),
      TaskPriority.baja  => ('BAJA',  AppTheme.textTertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: AppTheme.sectionLabel(size: 13, color: color)),
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
      TaskStatus.pendiente  => ('Pendiente',   AppTheme.statusWarn),
      TaskStatus.enProgreso => ('En Progreso', AppTheme.accent),
      TaskStatus.completada => ('Completada',  AppTheme.textSecondary),
      TaskStatus.rechazada  => ('Rechazada',   AppTheme.statusAlert),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: AppTheme.sectionLabel(size: 13, color: color)),
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
    return switch (level) {
      AlertLevel.none    => Text('OK', style: AppTheme.mono(size: 13,
          color: AppTheme.textTertiary)),
      AlertLevel.expired => _solidBadge('VENCIDO', AppTheme.statusAlert),
      AlertLevel.days15  => _solidBadge('${days}d', AppTheme.statusAlert),
      AlertLevel.days30  => _outlineBadge('${days}d', AppTheme.statusWarn),
      AlertLevel.days60  => _outlineBadge('${days}d', AppTheme.statusWarn),
      AlertLevel.days90  => _outlineBadge('${days}d', AppTheme.statusWarn),
    };
  }

  Widget _solidBadge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(text, style: AppTheme.sectionLabel(size: 13,
        color: AppTheme.textInverse)),
  );

  Widget _outlineBadge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(3),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Text(text, style: AppTheme.sectionLabel(size: 13, color: color)),
  );
}

// ==================== INVENTORY STATUS BADGE ====================

class InventoryBadge extends StatelessWidget {
  final InventoryStatus status;
  const InventoryBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      InventoryStatus.ok => Text('OK', style: AppTheme.mono(size: 13,
          color: AppTheme.textTertiary)),
      InventoryStatus.bajo => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.statusWarnBg,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppTheme.statusWarn.withOpacity(0.5)),
        ),
        child: Text('BAJO', style: AppTheme.sectionLabel(size: 13,
            color: AppTheme.statusWarn)),
      ),
      InventoryStatus.sinStock => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.statusAlert,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text('SIN STOCK', style: AppTheme.sectionLabel(size: 13,
            color: AppTheme.textInverse)),
      ),
    };
  }
}

// ==================== CATEGORY ICON ====================

class CategoryIcon extends StatelessWidget {
  final String category;
  const CategoryIcon(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (category) {
      'INCIDENCIA' => (Icons.warning_amber_rounded, AppTheme.statusAlert),
      'INVENTARIO' => (Icons.inventory_2_outlined, AppTheme.statusWarn),
      'PREFERENCIA_OWNER' => (Icons.star_outline, const Color(0xFFa78bfa)),
      'EVENTO' => (Icons.event_outlined, AppTheme.accent),
      'CONSULTA' => (Icons.help_outline, AppTheme.textSecondary),
      'TAREA' => (Icons.task_alt_outlined, AppTheme.accent),
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
          Icon(icon, size: 48, color: AppTheme.textTertiary.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(message, style: AppTheme.label(size: 13,
              color: AppTheme.textTertiary), textAlign: TextAlign.center),
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
