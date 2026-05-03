import 'package:flutter/material.dart';
import 'package:smart_yat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class OwnerPreferencesScreen extends StatefulWidget {
  const OwnerPreferencesScreen({super.key});

  @override
  State<OwnerPreferencesScreen> createState() =>
      _OwnerPreferencesScreenState();
}

class _OwnerPreferencesScreenState extends State<OwnerPreferencesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = [
    (OwnerPreferenceType.comida, 'Comida'),
    (OwnerPreferenceType.bebida, 'Bebida'),
    (OwnerPreferenceType.temperatura, 'Clima'),
    (OwnerPreferenceType.musica, 'Música'),
    (OwnerPreferenceType.eventos, 'Eventos'),
    (OwnerPreferenceType.otro, 'Otro'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppProvider>().ownerPreferences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PREFERENCIAS OWNER'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accent,
          labelStyle: AppTheme.sectionLabel(size: 13),
          tabs: _tabs.map((t) => Tab(text: t.$2)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.add),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: _tabs.map((t) {
          final filtered =
              prefs.where((p) => p.type == t.$1).toList();
          if (filtered.isEmpty) {
            return EmptyState(
              icon: Icons.star_outline,
              message: 'Sin preferencias de ${t.$2.toLowerCase()}',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _PrefCard(
              pref: filtered[i],
              onDelete: () => context
                  .read<AppProvider>()
                  .deleteOwnerPreference(filtered[i].id),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    OwnerPreferenceType selectedType =
        _tabs[_tabCtrl.index].$1;
    bool isPositive = true;
    final detailCtrl = TextEditingController();

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
              Text('NUEVA PREFERENCIA',
                  style: AppTheme.sectionLabel(size: 13)),
              const SizedBox(height: 16),
              // Type selector
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tabs.map((t) {
                  final selected = selectedType == t.$1;
                  return GestureDetector(
                    onTap: () =>
                        setModalState(() => selectedType = t.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.accent.withOpacity(0.12)
                            : AppTheme.surface01,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: selected
                              ? AppTheme.accent.withOpacity(0.5)
                              : AppTheme.borderSubtle,
                        ),
                      ),
                      child: Text(t.$2,
                          style: AppTheme.sectionLabel(
                              size: 13,
                              color: selected ? AppTheme.accent : AppTheme.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Positive / Negative toggle
              Row(
                children: [
                  const Text('Tipo:',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(width: 12),
                  _ToggleBtn(
                    label: '👍 Le gusta',
                    selected: isPositive,
                    color: AppTheme.accent,
                    onTap: () => setModalState(() => isPositive = true),
                  ),
                  const SizedBox(width: 8),
                  _ToggleBtn(
                    label: '👎 No le gusta',
                    selected: !isPositive,
                    color: AppTheme.statusAlert,
                    onTap: () => setModalState(() => isPositive = false),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: detailCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Detalle / Descripción'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (detailCtrl.text.trim().isEmpty) return;
                    context.read<AppProvider>().addOwnerPreference(
                          OwnerPreference(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            type: selectedType,
                            detail: detailCtrl.text.trim(),
                            isPositive: isPositive,
                            createdAt: DateTime.now(),
                          ),
                        );
                    Navigator.pop(ctx);
                  },
                  child: Text(l10n.save.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrefCard extends StatelessWidget {
  final OwnerPreference pref;
  final VoidCallback onDelete;

  const _PrefCard({required this.pref, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(pref.id),
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
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface01,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                PrefTypeIcon(pref.type),
                const SizedBox(height: 6),
                Icon(
                  pref.isPositive
                      ? Icons.thumb_up_outlined
                      : Icons.thumb_down_outlined,
                  size: 14,
                  color: pref.isPositive
                      ? AppTheme.accent
                      : AppTheme.statusAlert,
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(pref.detail, style: AppTheme.cardTitle(size: 13)),
                      ),
                      if (pref.viaHeyYat)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.mic,
                                  color: AppTheme.accent, size: 9),
                              SizedBox(width: 2),
                              Text(
                                'Hey Yat',
                                style: TextStyle(
                                    color: AppTheme.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(formatDate(pref.createdAt),
                      style: AppTheme.mono(size: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? color : AppTheme.borderSubtle),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? color : AppTheme.textSecondary,
                fontSize: 13)),
      ),
    );
  }
}
