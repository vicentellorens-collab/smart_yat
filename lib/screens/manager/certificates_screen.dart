import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_yat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

const _kCertNames = [
  'STCW Basic Safety Training (BST)',
  'STCW Advanced Fire Fighting',
  'STCW Medical First Aid',
  'STCW Medical Care on Board',
  'STCW Proficiency in Survival Craft (PSC)',
  'STCW Officer of the Watch (OOW)',
  'STCW Master (3000 GT)',
  'STCW Chief Mate (3000 GT)',
  'STCW GMDSS Radio Operator (GOC)',
  'STCW Security Awareness',
  'STCW Crowd Management',
  'STCW Passenger Safety',
  'STCW High Voltage',
  'STCW Ship Security Officer (SSO)',
  'STCW Able Seafarer Deck (ASD)',
  'ENG1 Medical Certificate',
  'MCA Officer of the Watch (OOW)',
  'MCA Chief Mate',
  'MCA Master',
  'Pasavante',
  'Certificado de Navegabilidad',
  'Seguro de Casco',
  'Certificado de Seguridad del Equipo',
  'Licencia de Radio GMDSS',
  'Certificado Sanitario',
  'Certificado de Arqueo',
  'Pabellón / Matrícula',
  'Certificado ISM (Gestión de Seguridad)',
  'Certificado ISPS',
  'Certificado MARPOL (Prevención Contaminación)',
  'Certificado Load Line',
  'Certificado SOLAS',
  'Seguro de Responsabilidad Civil',
  'Otro',
];

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _searchQuery = '';

  // Crew tab hierarchy state
  CrewMember? _selectedCrew;
  bool _showOrphans = false;
  String? _departmentFilter;

  bool get _inLevel2 => _selectedCrew != null || _showOrphans;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) {
        setState(() {
          _selectedCrew = null;
          _showOrphans = false;
        });
      }
    });
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

  int _certSortKey(Certificate c) {
    return switch (c.alertLevel) {
      AlertLevel.expired => 0,
      AlertLevel.days15 => 1,
      AlertLevel.days30 => 2,
      AlertLevel.days60 => 3,
      AlertLevel.days90 => 4,
      AlertLevel.none => 5,
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final l10n = AppLocalizations.of(context)!;
    final barcoCerts = _filter(
        p.certificates.where((c) => c.certCategory == 'barco').toList());
    final allTripCerts =
        p.certificates.where((c) => c.certCategory == 'tripulante').toList();

    return PopScope(
      canPop: !_inLevel2,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() {
            _selectedCrew = null;
            _showOrphans = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.certificates.toUpperCase()),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(102),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                  child: TextField(
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: l10n.searchCertificates,
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
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
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
                          Text(l10n.yachtCertificates.toUpperCase()),
                          if (barcoCerts
                              .where((c) => c.alertLevel != AlertLevel.none)
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
                          Text(l10n.crewCertificates.toUpperCase()),
                          if (allTripCerts
                              .where((c) => c.alertLevel != AlertLevel.none)
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
          onPressed: () => _showCertDialog(context, null, _selectedCrew),
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context)!.addCertificate),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildList(context, barcoCerts),
            _buildCrewCertsView(context, p),
          ],
        ),
      ),
    );
  }

  // Barco tab — unchanged flat list
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

  // Crew tab router
  Widget _buildCrewCertsView(BuildContext context, AppProvider p) {
    if (_showOrphans) return _buildOrphansLevel2(context, p);
    if (_selectedCrew != null) return _buildLevel2(context, p, _selectedCrew!);
    return _buildLevel1(context, p);
  }

  // Level 1: crew list with status badges
  Widget _buildLevel1(BuildContext context, AppProvider p) {
    final allTripCerts = p.certificates
        .where((c) => c.certCategory == 'tripulante')
        .toList();

    final Map<String, List<Certificate>> certsByCrewId = {};
    for (final cert in allTripCerts) {
      if (cert.crewMemberId != null) {
        certsByCrewId.putIfAbsent(cert.crewMemberId!, () => []).add(cert);
      }
    }
    final orphanCerts =
        allTripCerts.where((c) => c.crewMemberId == null).toList();

    var crewList = p.crew.where((member) {
      if (_departmentFilter != null &&
          member.department != _departmentFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return member.name.toLowerCase().contains(q) ||
            member.role.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    int crewGroupKey(CrewMember m) {
      final certs = certsByCrewId[m.id] ?? [];
      if (certs.any((c) =>
          c.alertLevel == AlertLevel.expired ||
          c.alertLevel == AlertLevel.days15 ||
          c.alertLevel == AlertLevel.days30)) return 0;
      if (certs.any((c) =>
          c.alertLevel == AlertLevel.days60 ||
          c.alertLevel == AlertLevel.days90)) return 1;
      return 2;
    }

    crewList.sort((a, b) {
      final gA = crewGroupKey(a);
      final gB = crewGroupKey(b);
      if (gA != gB) return gA.compareTo(gB);
      final aCount = (certsByCrewId[a.id] ?? [])
          .where((c) => c.alertLevel != AlertLevel.none)
          .length;
      final bCount = (certsByCrewId[b.id] ?? [])
          .where((c) => c.alertLevel != AlertLevel.none)
          .length;
      return bCount.compareTo(aCount);
    });

    final departments = p.crew
        .map((m) => m.department)
        .where((d) => d != null)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();

    if (crewList.isEmpty && orphanCerts.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        message: _searchQuery.isNotEmpty
            ? 'Sin resultados para "$_searchQuery"'
            : 'No hay certificados de tripulantes',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        if (departments.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _DeptChip(
                  label: 'Todos',
                  selected: _departmentFilter == null,
                  onTap: () => setState(() => _departmentFilter = null),
                ),
                ...departments.map((d) => _DeptChip(
                      label: d,
                      selected: _departmentFilter == d,
                      onTap: () => setState(() => _departmentFilter =
                          _departmentFilter == d ? null : d),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...crewList.map((member) => _CrewWithCertsTile(
              member: member,
              certs: certsByCrewId[member.id] ?? [],
              onTap: () => setState(() => _selectedCrew = member),
            )),
        if (orphanCerts.isNotEmpty) ...[
          if (crewList.isNotEmpty) const SizedBox(height: 4),
          _OrphanTile(
            count: orphanCerts.length,
            onTap: () => setState(() => _showOrphans = true),
          ),
        ],
      ],
    );
  }

  // Level 2: certificates for a specific crew member
  Widget _buildLevel2(BuildContext context, AppProvider p, CrewMember member) {
    var certs = p.certificates
        .where((c) =>
            c.certCategory == 'tripulante' && c.crewMemberId == member.id)
        .toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      certs = certs
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.issuer.toLowerCase().contains(q))
          .toList();
    }

    certs.sort((a, b) {
      final kA = _certSortKey(a);
      final kB = _certSortKey(b);
      if (kA != kB) return kA.compareTo(kB);
      return a.daysUntilExpiry.compareTo(b.daysUntilExpiry);
    });

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _selectedCrew = null),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios,
                    color: AppTheme.accent, size: 16),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.accentDim,
                  child: Text(
                    member.name.isNotEmpty
                        ? member.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: AppTheme.cardTitle(size: 14)),
                      Text(member.role, style: AppTheme.label(size: 12)),
                    ],
                  ),
                ),
                Text(
                  '${certs.length} cert${certs.length == 1 ? '' : 's'}',
                  style: AppTheme.label(
                      size: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: certs.isEmpty
              ? EmptyState(
                  icon: Icons.verified_outlined,
                  message: _searchQuery.isNotEmpty
                      ? 'Sin resultados para "$_searchQuery"'
                      : 'Sin certificados. Pulsa + para añadir uno.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: certs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CertCard(
                    cert: certs[i],
                    onEdit: () => _showCertDialog(context, certs[i]),
                    onDelete: () => context
                        .read<AppProvider>()
                        .deleteCertificate(certs[i].id),
                  ),
                ),
        ),
      ],
    );
  }

  // Level 2: orphan certs without a crew member assigned
  Widget _buildOrphansLevel2(BuildContext context, AppProvider p) {
    var certs = p.certificates
        .where((c) =>
            c.certCategory == 'tripulante' && c.crewMemberId == null)
        .toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      certs = certs
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.issuer.toLowerCase().contains(q))
          .toList();
    }

    certs.sort((a, b) {
      final kA = _certSortKey(a);
      final kB = _certSortKey(b);
      if (kA != kB) return kA.compareTo(kB);
      return a.daysUntilExpiry.compareTo(b.daysUntilExpiry);
    });

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _showOrphans = false),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios,
                    color: AppTheme.accent, size: 16),
                const SizedBox(width: 8),
                const Icon(Icons.person_off_outlined,
                    color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Sin asignar',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${certs.length} cert${certs.length == 1 ? '' : 's'}',
                  style: AppTheme.label(
                      size: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: certs.isEmpty
              ? EmptyState(
                  icon: Icons.verified_outlined,
                  message: _searchQuery.isNotEmpty
                      ? 'Sin resultados para "$_searchQuery"'
                      : 'Sin certificados sin asignar',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: certs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CertCard(
                    cert: certs[i],
                    onEdit: () => _showCertDialog(context, certs[i]),
                    onDelete: () => context
                        .read<AppProvider>()
                        .deleteCertificate(certs[i].id),
                  ),
                ),
        ),
      ],
    );
  }

  void _showCertDialog(BuildContext context,
      [Certificate? existing, CrewMember? preselectedCrew]) {
    final certNameCtrl = TextEditingController(text: existing?.name ?? '');
    bool showNameSugg = false;

    final issuerCtrl = TextEditingController(text: existing?.issuer);
    final typeCtrl = TextEditingController(text: existing?.type);
    DateTime expiryDate =
        existing?.expiryDate ?? DateTime.now().add(const Duration(days: 365));
    String certCategory = existing?.certCategory ??
        (preselectedCrew != null ? 'tripulante' : 'barco');
    String? selectedCrewId =
        existing?.crewMemberId ?? preselectedCrew?.id;
    String? selectedCrewName =
        existing?.crewMemberName ?? preselectedCrew?.name;
    String? attachmentPath = existing?.attachmentPath;
    final crew = context.read<AppProvider>().crew;
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => GestureDetector(
          onTap: () {
            if (showNameSugg) {
              setModalState(() => showNameSugg = false);
            }
          },
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                          existing == null
                              ? 'NUEVO CERTIFICADO'
                              : 'EDITAR CERTIFICADO',
                          style: AppTheme.sectionLabel(size: 13)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close,
                            color: AppTheme.textSecondary, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text('CATEGORÍA', style: AppTheme.sectionLabel()),
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
                        onTap: () =>
                            setModalState(() => certCategory = 'tripulante'),
                      ),
                    ],
                  ),

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
                    controller: certNameCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Nombre del certificado *',
                      hintText:
                          'Buscar o escribir nombre del certificado...',
                      hintStyle: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                      suffixIcon: Icon(
                        showNameSugg
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onTap: () =>
                        setModalState(() => showNameSugg = true),
                    onChanged: (v) =>
                        setModalState(() => showNameSugg = true),
                  ),

                  if (showNameSugg) ...[
                    const SizedBox(height: 2),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: AppTheme.panel,
                        border: Border.all(
                            color: AppTheme.accent.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                setModalState(() => showNameSugg = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: AppTheme.borderSubtle)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.close,
                                      size: 14,
                                      color: AppTheme.textSecondary),
                                  SizedBox(width: 6),
                                  Text('Cerrar sugerencias',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: ListView(
                              shrinkWrap: true,
                              children: _kCertNames
                                  .where((n) =>
                                      certNameCtrl.text.isEmpty ||
                                      n.toLowerCase().contains(
                                          certNameCtrl.text.toLowerCase()))
                                  .map((n) => InkWell(
                                        onTap: () {
                                          certNameCtrl.text = n;
                                          setModalState(
                                              () => showNameSugg = false);
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10),
                                          child: Text(n,
                                              style: const TextStyle(
                                                  color:
                                                      AppTheme.textPrimary,
                                                  fontSize: 13)),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

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
                        labelText: 'Tipo (Seguridad, Navegación...)'),
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
                            Border.all(color: AppTheme.borderSubtle),
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

                  const SizedBox(height: 16),
                  Text('ARCHIVO ADJUNTO', style: AppTheme.sectionLabel()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _AttachButton(
                          icon: Icons.document_scanner_outlined,
                          label: 'Escanear',
                          onTap: () async {
                            final file = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 90);
                            if (file != null) {
                              setModalState(
                                  () => attachmentPath = file.path);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AttachButton(
                          icon: Icons.photo_library_outlined,
                          label: 'Galería',
                          onTap: () async {
                            final file = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 90);
                            if (file != null) {
                              setModalState(
                                  () => attachmentPath = file.path);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AttachButton(
                          icon: Icons.attach_file,
                          label: 'Archivo',
                          onTap: () async {
                            final result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: [
                                'pdf',
                                'jpg',
                                'jpeg',
                                'png'
                              ],
                            );
                            if (result != null &&
                                result.files.single.path != null) {
                              setModalState(() => attachmentPath =
                                  result.files.single.path);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (attachmentPath != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentDim,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.accent.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: AppTheme.accent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              attachmentPath!
                                  .split('/')
                                  .last
                                  .split('\\')
                                  .last,
                              style: AppTheme.label(
                                  size: 13, color: AppTheme.accent),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setModalState(
                                () => attachmentPath = null),
                            child: const Icon(Icons.close,
                                color: AppTheme.textSecondary, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final certName = certNameCtrl.text.trim();
                        if (certName.isEmpty) return;
                        if (certCategory == 'tripulante' &&
                            selectedCrewId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecciona un tripulante'),
                              backgroundColor: AppTheme.statusWarn,
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
                            name: certName,
                            issuer: issuerCtrl.text.trim(),
                            type: typeCtrl.text.trim(),
                            expiryDate: expiryDate,
                            certCategory: certCategory,
                            crewMemberId: certCategory == 'tripulante'
                                ? selectedCrewId
                                : null,
                            crewMemberName: certCategory == 'tripulante'
                                ? selectedCrewName
                                : null,
                            attachmentPath: attachmentPath,
                          ));
                        } else {
                          existing.name = certName;
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
                          existing.attachmentPath = attachmentPath;
                          prov.updateCertificate(existing);
                        }
                        Navigator.pop(ctx);
                      },
                      child: Text(
                          existing == null ? 'CREAR' : 'GUARDAR'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small shared widgets ──────────────────────────────────────────────────────

class _AlertDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.statusWarn,
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
                color:
                    selected ? AppTheme.accent : AppTheme.borderSubtle),
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
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.accent, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
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

  Color get _accentColor {
    return switch (cert.alertLevel) {
      AlertLevel.expired || AlertLevel.days15 => AppTheme.statusAlert,
      AlertLevel.days30 ||
      AlertLevel.days60 ||
      AlertLevel.days90 =>
        AppTheme.statusWarn,
      AlertLevel.none => AppTheme.accent,
    };
  }

  Color get _bgColor {
    return switch (cert.alertLevel) {
      AlertLevel.expired || AlertLevel.days15 => AppTheme.statusAlertBg,
      AlertLevel.days30 ||
      AlertLevel.days60 ||
      AlertLevel.days90 =>
        AppTheme.statusWarnBg,
      AlertLevel.none => AppTheme.surface01,
    };
  }

  BoxBorder get _border {
    if (cert.alertLevel == AlertLevel.none) {
      return Border.all(color: AppTheme.borderSubtle);
    }
    return Border(
      left: BorderSide(color: _accentColor, width: 3),
      top: const BorderSide(color: AppTheme.borderSubtle, width: 1),
      right: const BorderSide(color: AppTheme.borderSubtle, width: 1),
      bottom: const BorderSide(color: AppTheme.borderSubtle, width: 1),
    );
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
          color: AppTheme.statusAlert.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            const Icon(Icons.delete_outline, color: AppTheme.statusAlert),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onEdit,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _bgColor,
              border: _border,
            ),
            child: Row(
              children: [
                Icon(Icons.verified_outlined,
                    color: _accentColor, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cert.name,
                          style: AppTheme.cardTitle(size: 14)),
                      const SizedBox(height: 2),
                      Text('${cert.issuer} · ${cert.type}',
                          style: AppTheme.label(size: 13)),
                      if (cert.certCategory == 'tripulante' &&
                          cert.crewMemberName != null) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.person_outline,
                              color: AppTheme.accent, size: 13),
                          const SizedBox(width: 4),
                          Text(cert.crewMemberName!,
                              style: AppTheme.label(
                                  size: 13, color: AppTheme.accent)),
                        ]),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Vence: ${formatDate(cert.expiryDate)}',
                              style: AppTheme.mono(
                                  size: 13,
                                  color: AppTheme.textSecondary)),
                          if (cert.attachmentPath != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.attach_file,
                                color: AppTheme.accent, size: 13),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                AlertBadge(cert.alertLevel, cert.daysUntilExpiry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Crew hierarchy widgets ────────────────────────────────────────────────────

class _CrewWithCertsTile extends StatelessWidget {
  final CrewMember member;
  final List<Certificate> certs;
  final VoidCallback onTap;

  const _CrewWithCertsTile({
    required this.member,
    required this.certs,
    required this.onTap,
  });

  Color get _statusColor {
    if (certs.any((c) =>
        c.alertLevel == AlertLevel.expired ||
        c.alertLevel == AlertLevel.days15 ||
        c.alertLevel == AlertLevel.days30)) return AppTheme.statusAlert;
    if (certs.any((c) =>
        c.alertLevel == AlertLevel.days60 ||
        c.alertLevel == AlertLevel.days90)) return AppTheme.statusWarn;
    return AppTheme.accent;
  }

  @override
  Widget build(BuildContext context) {
    final redCount = certs
        .where((c) =>
            c.alertLevel == AlertLevel.expired ||
            c.alertLevel == AlertLevel.days15 ||
            c.alertLevel == AlertLevel.days30)
        .length;
    final yellowCount = certs
        .where((c) =>
            c.alertLevel == AlertLevel.days60 ||
            c.alertLevel == AlertLevel.days90)
        .length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface01,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.accentDim,
                  child: Text(
                    member.name.isNotEmpty
                        ? member.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor,
                      border: Border.all(
                          color: AppTheme.surface01, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: AppTheme.cardTitle(size: 14)),
                  Text(member.role, style: AppTheme.label(size: 13)),
                ],
              ),
            ),
            if (redCount > 0)
              _StatusPill(count: redCount, color: AppTheme.statusAlert),
            if (yellowCount > 0) ...[
              if (redCount > 0) const SizedBox(width: 4),
              _StatusPill(count: yellowCount, color: AppTheme.statusWarn),
            ],
            if (redCount == 0 && yellowCount == 0 && certs.isNotEmpty)
              _StatusPill(count: certs.length, color: AppTheme.accent),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final int count;
  final Color color;
  const _StatusPill({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$count',
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _OrphanTile extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _OrphanTile({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface01,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_off_outlined,
                color: AppTheme.textSecondary, size: 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Sin asignar',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
            _StatusPill(count: count, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DeptChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DeptChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent.withValues(alpha: 0.15)
              : AppTheme.surface01,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  selected ? AppTheme.accent : AppTheme.borderSubtle),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
