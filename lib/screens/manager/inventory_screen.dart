import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  InventoryStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    var items = p.inventory;
    if (_filter != null) {
      items = items.where((i) => i.status == _filter).toList();
    }
    // Sort: sinStock → bajo → ok
    items = [...items]..sort((a, b) {
        const order = {
          InventoryStatus.sinStock: 0,
          InventoryStatus.bajo: 1,
          InventoryStatus.ok: 2
        };
        return (order[a.status] ?? 2).compareTo(order[b.status] ?? 2);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('INVENTARIO')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
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
                _FChip(
                    label: 'Todo',
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null)),
                const SizedBox(width: 8),
                _FChip(
                    label: 'Sin Stock',
                    color: AppTheme.errorColor,
                    selected: _filter == InventoryStatus.sinStock,
                    onTap: () =>
                        setState(() => _filter = InventoryStatus.sinStock)),
                const SizedBox(width: 8),
                _FChip(
                    label: 'Stock Bajo',
                    color: AppTheme.warningColor,
                    selected: _filter == InventoryStatus.bajo,
                    onTap: () =>
                        setState(() => _filter = InventoryStatus.bajo)),
                const SizedBox(width: 8),
                _FChip(
                    label: 'OK',
                    color: AppTheme.successColor,
                    selected: _filter == InventoryStatus.ok,
                    onTap: () => setState(() => _filter = InventoryStatus.ok)),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    message: 'Sin elementos en esta categoría')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ItemCard(
                      item: items[i],
                      onTap: () => _showItemDialog(context, items[i]),
                      onDelete: () =>
                          context.read<AppProvider>().deleteInventoryItem(items[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showItemDialog(BuildContext context, [InventoryItem? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final categoryCtrl = TextEditingController(text: existing?.category);
    final qtyCtrl = TextEditingController(
        text: existing?.quantity.toString() ?? '');
    final unitCtrl = TextEditingController(text: existing?.unit ?? '');
    final minCtrl =
        TextEditingController(text: existing?.minLevel.toString() ?? '');
    final locCtrl = TextEditingController(text: existing?.location ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'NUEVO ARTÍCULO' : 'EDITAR ARTÍCULO',
                  style: AppTheme.orbitron(size: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: categoryCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration:
                          const InputDecoration(labelText: 'Categoría'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(labelText: 'Unidad'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Cantidad actual'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Mínimo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration:
                    const InputDecoration(labelText: 'Ubicación (opcional)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final prov = context.read<AppProvider>();
                    final qty = double.tryParse(qtyCtrl.text) ?? 0;
                    final min = double.tryParse(minCtrl.text) ?? 0;
                    if (existing == null) {
                      prov.addInventoryItem(InventoryItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text.trim(),
                        category: categoryCtrl.text.trim().isEmpty
                            ? 'General'
                            : categoryCtrl.text.trim(),
                        quantity: qty,
                        unit: unitCtrl.text.trim().isEmpty
                            ? 'unid'
                            : unitCtrl.text.trim(),
                        minLevel: min,
                        location: locCtrl.text.trim().isEmpty
                            ? null
                            : locCtrl.text.trim(),
                      ));
                    } else {
                      existing.name = nameCtrl.text.trim();
                      existing.category = categoryCtrl.text.trim().isEmpty
                          ? 'General'
                          : categoryCtrl.text.trim();
                      existing.quantity = qty;
                      existing.unit = unitCtrl.text.trim().isEmpty
                          ? 'unid'
                          : unitCtrl.text.trim();
                      existing.minLevel = min;
                      existing.location = locCtrl.text.trim().isEmpty
                          ? null
                          : locCtrl.text.trim();
                      prov.updateInventoryItem(existing);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(existing == null ? 'AÑADIR' : 'GUARDAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.accent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.2) : AppTheme.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? c : AppTheme.dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? c : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      InventoryStatus.ok => AppTheme.successColor,
      InventoryStatus.bajo => AppTheme.warningColor,
      InventoryStatus.sinStock => AppTheme.errorColor,
    };

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            const Icon(Icons.delete_outline, color: AppTheme.errorColor),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: item.status != InventoryStatus.ok
                    ? statusColor.withOpacity(0.4)
                    : AppTheme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(item.category,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11)),
                        if (item.location != null) ...[
                          const Text(' · ',
                              style:
                                  TextStyle(color: AppTheme.textSecondary)),
                          Text(item.location!,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.quantity.toStringAsFixed(item.quantity == item.quantity.truncate() ? 0 : 1)} ${item.unit}',
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text('mín. ${item.minLevel} ${item.unit}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 10)),
                  const SizedBox(height: 4),
                  InventoryBadge(item.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
