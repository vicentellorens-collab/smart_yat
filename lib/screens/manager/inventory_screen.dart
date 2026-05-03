import 'package:flutter/material.dart';
import 'package:smart_yat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

const _kUnits = ['L', 'uds', 'kg', 'g', 'm', 'cajas', 'packs', 'botellas', 'Otro'];

class InventoryScreen extends StatefulWidget {
  final InventoryStatus? initialFilter;
  const InventoryScreen({super.key, this.initialFilter});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  InventoryStatus? _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    var items = p.inventory;
    if (_filter != null) {
      items = items.where((i) => i.status == _filter).toList();
    }
    items = [...items]..sort((a, b) {
        const order = {
          InventoryStatus.sinStock: 0,
          InventoryStatus.bajo: 1,
          InventoryStatus.ok: 2
        };
        return (order[a.status] ?? 2).compareTo(order[b.status] ?? 2);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.inventory.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: AppLocalizations.of(context)!.shoppingList,
            onPressed: () => _showShoppingList(context, p),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(context),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addItem),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FChip(
                    label: AppLocalizations.of(context)!.filterAll,
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null)),
                const SizedBox(width: 8),
                _FChip(
                    label: AppLocalizations.of(context)!.outOfStock,
                    color: AppTheme.statusAlert,
                    selected: _filter == InventoryStatus.sinStock,
                    onTap: () =>
                        setState(() => _filter = InventoryStatus.sinStock)),
                const SizedBox(width: 8),
                _FChip(
                    label: AppLocalizations.of(context)!.lowStockAlert,
                    color: AppTheme.statusWarn,
                    selected: _filter == InventoryStatus.bajo,
                    onTap: () =>
                        setState(() => _filter = InventoryStatus.bajo)),
                const SizedBox(width: 8),
                _FChip(
                    label: 'OK',
                    color: AppTheme.accent,
                    selected: _filter == InventoryStatus.ok,
                    onTap: () =>
                        setState(() => _filter = InventoryStatus.ok)),
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
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ItemCard(
                      item: items[i],
                      onTap: () => _showItemDialog(context, items[i]),
                      onDelete: () => context
                          .read<AppProvider>()
                          .deleteInventoryItem(items[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showShoppingList(BuildContext context, AppProvider p) {
    final items = [...p.inventory
        .where((i) => i.status != InventoryStatus.ok)]
      ..sort((a, b) {
        const ord = {InventoryStatus.sinStock: 0, InventoryStatus.bajo: 1};
        return (ord[a.status] ?? 2).compareTo(ord[b.status] ?? 2);
      });
    final checked = <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, ctrl) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.shoppingList.toUpperCase(),
                        style: AppTheme.sectionLabel(size: 13)),
                    const Spacer(),
                    Text(
                      '${checked.length}/${items.length} pedidos',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.borderSubtle),
              if (items.isEmpty)
                const Expanded(
                  child: EmptyState(
                    icon: Icons.shopping_cart_outlined,
                    message: 'No hay artículos con stock bajo',
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final isChecked = checked.contains(item.id);
                      final color = item.status == InventoryStatus.sinStock
                          ? AppTheme.statusAlert
                          : AppTheme.statusWarn;
                      return GestureDetector(
                        onTap: () => setSheetState(() {
                          if (isChecked) {
                            checked.remove(item.id);
                          } else {
                            checked.add(item.id);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isChecked
                                ? AppTheme.accentDim
                                : AppTheme.surface01,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isChecked
                                  ? AppTheme.accent.withOpacity(0.3)
                                  : color.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isChecked
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isChecked
                                    ? AppTheme.accent
                                    : color,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        color: isChecked
                                            ? AppTheme.textSecondary
                                            : AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        decoration: isChecked
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      '${item.category}${item.location != null ? " · ${item.location}" : ""}',
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  InventoryBadge(item.status),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity.toStringAsFixed(0)} / mín ${item.minLevel.toStringAsFixed(0)} ${item.unit}',
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  void _showItemDialog(BuildContext context, [InventoryItem? existing]) {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: existing?.name);
    final categoryCtrl =
        TextEditingController(text: existing?.category);
    final qtyCtrl = TextEditingController(
        text: existing?.quantity.toString() ?? '');
    final minCtrl =
        TextEditingController(text: existing?.minLevel.toString() ?? '');
    final locCtrl = TextEditingController(text: existing?.location ?? '');
    final customUnitCtrl = TextEditingController();

    // Determine initial unit selection
    String? selectedUnit;
    if (existing?.unit != null) {
      selectedUnit = _kUnits.contains(existing!.unit) ? existing.unit : 'Otro';
      if (selectedUnit == 'Otro') {
        customUnitCtrl.text = existing.unit;
      }
    }

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
                Text(
                    existing == null
                        ? l10n.addItem.toUpperCase()
                        : l10n.edit.toUpperCase(),
                    style: AppTheme.sectionLabel(size: 13)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration:
                      InputDecoration(labelText: l10n.itemName),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: categoryCtrl,
                        style: const TextStyle(
                            color: AppTheme.textPrimary),
                        decoration:
                            const InputDecoration(labelText: 'Categoría'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Unit dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUnit,
                        dropdownColor: AppTheme.panel,
                        style: const TextStyle(
                            color: AppTheme.textPrimary),
                        decoration:
                            InputDecoration(labelText: l10n.unit),
                        items: _kUnits
                            .map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setModalState(() => selectedUnit = v),
                      ),
                    ),
                  ],
                ),
                // Custom unit field when "Otro" is selected
                if (selectedUnit == 'Otro') ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: customUnitCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                        labelText: 'Unidad personalizada'),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        style: const TextStyle(
                            color: AppTheme.textPrimary),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: l10n.quantity),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: minCtrl,
                        style: const TextStyle(
                            color: AppTheme.textPrimary),
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(labelText: l10n.minimumLevel),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                      labelText: 'Ubicación (opcional)'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      final prov = context.read<AppProvider>();
                      final qty =
                          double.tryParse(qtyCtrl.text) ?? 0;
                      final min =
                          double.tryParse(minCtrl.text) ?? 0;
                      // Resolve unit
                      String unit;
                      if (selectedUnit == 'Otro') {
                        unit = customUnitCtrl.text.trim().isEmpty
                            ? 'uds'
                            : customUnitCtrl.text.trim();
                      } else {
                        unit = selectedUnit ?? 'uds';
                      }
                      if (existing == null) {
                        prov.addInventoryItem(InventoryItem(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          name: nameCtrl.text.trim(),
                          category:
                              categoryCtrl.text.trim().isEmpty
                                  ? 'General'
                                  : categoryCtrl.text.trim(),
                          quantity: qty,
                          unit: unit,
                          minLevel: min,
                          location: locCtrl.text.trim().isEmpty
                              ? null
                              : locCtrl.text.trim(),
                        ));
                      } else {
                        existing.name = nameCtrl.text.trim();
                        existing.category =
                            categoryCtrl.text.trim().isEmpty
                                ? 'General'
                                : categoryCtrl.text.trim();
                        existing.quantity = qty;
                        existing.unit = unit;
                        existing.minLevel = min;
                        existing.location =
                            locCtrl.text.trim().isEmpty
                                ? null
                                : locCtrl.text.trim();
                        prov.updateInventoryItem(existing);
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(
                        existing == null ? l10n.add.toUpperCase() : l10n.save.toUpperCase()),
                  ),
                ),
              ],
            ),
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
          color: selected ? c.withOpacity(0.12) : AppTheme.surface01,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: selected ? c.withOpacity(0.5) : AppTheme.borderSubtle),
        ),
        child: Text(label,
            style: AppTheme.sectionLabel(size: 13, color: selected ? c : AppTheme.textSecondary)),
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
    final (bgColor, border) = switch (item.status) {
      InventoryStatus.sinStock => (
          AppTheme.statusAlertBg,
          const Border(
            left: BorderSide(color: AppTheme.statusAlert, width: 3),
            top: BorderSide(color: AppTheme.borderSubtle, width: 1),
            right: BorderSide(color: AppTheme.borderSubtle, width: 1),
            bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
          ) as BoxBorder,
        ),
      InventoryStatus.bajo => (
          AppTheme.statusWarnBg,
          const Border(
            left: BorderSide(color: AppTheme.statusWarn, width: 3),
            top: BorderSide(color: AppTheme.borderSubtle, width: 1),
            right: BorderSide(color: AppTheme.borderSubtle, width: 1),
            bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
          ) as BoxBorder,
        ),
      InventoryStatus.ok => (
          AppTheme.surface01,
          Border.all(color: AppTheme.borderSubtle) as BoxBorder,
        ),
    };
    final qtyColor = switch (item.status) {
      InventoryStatus.sinStock => AppTheme.statusAlert,
      InventoryStatus.bajo => AppTheme.statusWarn,
      InventoryStatus.ok => AppTheme.accent,
    };

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.statusAlert.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.statusAlert),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: border,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppTheme.cardTitle(size: 14)),
                    const SizedBox(height: 3),
                    Text(
                      item.location != null
                          ? '${item.category} · ${item.location}'
                          : item.category,
                      style: AppTheme.label(size: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.quantity.toStringAsFixed(item.quantity == item.quantity.truncate() ? 0 : 1)} ${item.unit}',
                    style: AppTheme.mono(size: 15, color: qtyColor, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text('mín. ${item.minLevel} ${item.unit}',
                      style: AppTheme.mono(size: 13, color: AppTheme.textSecondary)),
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
