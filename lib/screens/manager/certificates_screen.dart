import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() =>
      _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _searchQuery = '';

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

  List<Certificate> _filter(List<Certificate> certs) {
    final sorted = [...certs]
      ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
    if (_searchQuery.isEmpty) return sorted;
    final q = _searchQuery.toLowerCase();
    return sorted.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.type.toLowerCase().contains(q) ||
          c.issuer.toLowerCase().contains(q) ||
          (c.crewMemberName?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final barcoCerts = _filter(
        p.certificates.where((c) => c.certCategory == 'barco').toList());
    final tripulanteCerts = _filter(p.certificates
        .where((c) => c.certCategory == 'tripulante')
        .toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('CERTIFICADOS'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(102),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: TextField(
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar certificado...',
                    hintStyle: const TextStyle(
                        color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textSecondary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppTheme.textSecondary,
                                size: 18),
                            onPressed: () =>
                                setState(() => _searchQuery = ''),
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                  onChanged: (v) =>
                      setState(() => _searchQuery = v),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabCtrl,
                labelColor: AppTheme.accent,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.accent,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sailing, size: 16),
                        const SizedBox(width: 6),
                        const Text('BARCO'),
                        if (barcoCerts
                            .where((c) =>
                                c.alertLevel != AlertLevel.none)
                            .isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _AlertDot(),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline, size: 16),
                        const SizedBox(width: 6),
                        const Text('TRIPULANTES'),
                        if (tripulanteCerts
                            .where((c) =>
                                c.alertLevel != AlertLevel.none)
                            .isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _AlertDot(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCertDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildList(context, barcoCerts),
          _buildList(context, tripulanteCerts),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Certificate> certs) {
    if (certs.isEmpty) {
      return EmptyState(
        icon: Icons.verified_outlined,
        message: _searchQuery.isNotEmpty
            ? 'Sin resultados para "$_searchQuery"'
            : 'No hay certificados en esta categoría',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: certs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _CertCard(
        cert: certs[i],
        onEdit: () => _showCertDialog(context, certs[i]),
        onDelete: () =>
            context.read<AppProvider>().deleteCertificate(certs[i].id),
      ),
    );
  }

  void _showCertDialog(BuildContext context, [Certificate? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final issuerCtrl = TextEditingController(text: existing?.issuer);
    final typeCtrl = TextEditingController(text: existing?.type);
    DateTime expiryDate =
        existing?.expiryDate ?? DateTime.now().add(const Duration(days: 365));
    String certCategory = existing?.certCategory ?? 'barco';
    String? selectedCrewId = existing?.crewMemberId;
    String? selectedCrewName = existing?.crewMemberName;
    final crew = context.read<AppProvider>().crew;

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
                        ? 'NUEVO CERTIFICADO'
                        : 'EDITAR CERTIFICADO',
                    style: AppTheme.orbitron(size: 14)),
                const SizedBox(height: 16),

                // Category selector
                Text('CATEGORÍA',
                    style: AppTheme.orbitron(
                        size: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _CatOption(
                      label: 'Del Barco',
                      icon: Icons.sailing,
                      selected: certCategory == 'barco',
                      onTap: () =>
                          setModalState(() => certCategory = 'barco'),
                    ),
                    const SizedBox(width: 10),
                    _CatOption(
                      label: 'Tripulante',
                      icon: Icons.person_outline,
                      selected: certCategory == 'tripulante',
                      onTap: () => setModalState(
                          () => certCategory = 'tripulante'),
                    ),
                  ],
                ),

                // Crew member selector (only for tripulante)
                if (certCategory == 'tripulante') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCrewId,
                    dropdownColor: AppTheme.panel,
                    style:
                        const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                        labelText: 'Tripulante *'),
                    items: crew
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setModalState(() {
                        selectedCrewId = v;
                        selectedCrewName = crew
                            .where((c) => c.id == v)
                            .map((c) => c.name)
                            .firstOrNull;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration:
                      const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: issuerCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration:
                      const InputDecoration(labelText: 'Emisor'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                      labelText:
                          'Tipo (Seguridad, Navegación...)'),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: expiryDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      builder: (ctx, child) => Theme(
                        data: AppTheme.darkTheme,
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setModalState(() => expiryDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: AppTheme.textSecondary, size: 18),
                        const SizedBox(width: 10),
                        Text('Vence: ${formatDate(expiryDate)}',
                            style: const TextStyle(
                                color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      if (certCategory == 'tripulante' &&
                          selectedCrewId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Selecciona un tripulante'),
                            backgroundColor:
                                AppTheme.warningColor,
                          ),
                        );
                        return;
                      }
                      final prov = context.read<AppProvider>();
                      if (existing == null) {
                        prov.addCertificate(Certificate(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          name: nameCtrl.text.trim(),
                          issuer: issuerCtrl.text.trim(),
                          type: typeCtrl.text.trim(),
                          expiryDate: expiryDate,
                          certCategory: certCategory,
                          crewMemberId: certCategory == 'tripulante'
                              ? selectedCrewId
                              : null,
                          crewMemberName:
                              certCategory == 'tripulante'
                                  ? selectedCrewName
                                  : null,
                        ));
                      } else {
                        existing.name = nameCtrl.text.trim();
                        existing.issuer = issuerCtrl.text.trim();
                        existing.type = typeCtrl.text.trim();
                        existing.expiryDate = expiryDate;
                        existing.certCategory = certCategory;
                        existing.crewMemberId =
                            certCategory == 'tripulante'
                                ? selectedCrewId
                                : null;
                        existing.crewMemberName =
                            certCategory == 'tripulante'
                                ? selectedCrewName
                                : null;
                        prov.updateCertificate(existing);
                      }
                      Navigator.pop(ctx);
                    },
                    child:
                        Text(existing == null ? 'CREAR' : 'GUARDAR'),
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

class _AlertDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.warningColor,
      ),
    );
  }
}

class _CatOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _CatOption(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accent.withOpacity(0.2)
                : AppTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected
                    ? AppTheme.accent
                    : AppTheme.dividerColor),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected
                      ? AppTheme.accent
                      : AppTheme.textSecondary,
                  size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: selected
                          ? AppTheme.accent
                          : AppTheme.textSecondary,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CertCard extends StatelessWidget {
  final Certificate cert;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CertCard({
    required this.cert,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _borderColor {
    return switch (cert.alertLevel) {
      AlertLevel.expired => AppTheme.errorColor,
      AlertLevel.days15 => AppTheme.errorColor,
      AlertLevel.days30 => AppTheme.warningColor,
      AlertLevel.days60 => AppTheme.warningColor,
      AlertLevel.days90 => const Color(0xFF60a5fa),
      AlertLevel.none => AppTheme.dividerColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(cert.id),
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
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.panel,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: _borderColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _borderColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.verified_outlined,
                    color: _borderColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cert.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${cert.issuer} · ${cert.type}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11)),
                    if (cert.certCategory == 'tripulante' &&
                        cert.crewMemberName != null) ...[
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.person_outline,
                            color: AppTheme.accent, size: 12),
                        const SizedBox(width: 4),
                        Text(cert.crewMemberName!,
                            style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 11)),
                      ]),
                    ],
                    const SizedBox(height: 4),
                    Text('Vence: ${formatDate(cert.expiryDate)}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11)),
                  ],
                ),
              ),
              AlertBadge(cert.alertLevel, cert.daysUntilExpiry),
            ],
          ),
        ),
      ),
    );
  }
}
