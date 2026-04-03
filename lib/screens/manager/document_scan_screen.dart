import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../services/document_scan_service.dart';
import '../../widgets/common_widgets.dart';

class DocumentScanScreen extends StatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  State<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOCUMENTOS ESCANEADOS'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accent,
          tabs: const [
            Tab(text: 'ESCANEAR'),
            Tab(text: 'HISTORIAL'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ScanTab(onSaved: () => _tabCtrl.animateTo(1)),
          const _HistoryTab(),
        ],
      ),
    );
  }
}

// ==================== SCAN TAB ====================

class _ScanTab extends StatefulWidget {
  final VoidCallback onSaved;
  const _ScanTab({required this.onSaved});

  @override
  State<_ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<_ScanTab> {
  final _picker = ImagePicker();
  final _scanService = DocumentScanService();

  List<File> _images = [];
  bool _scanning = false;
  DocumentScanResult? _scanResult;

  // Editable fields
  final _typeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _status = 'Pendiente';
  DateTime? _issuedAt;
  DateTime? _expiresAt;

  @override
  void dispose() {
    _typeCtrl.dispose();
    _descCtrl.dispose();
    _holderCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(source: source, imageQuality: 80);
      if (xfile == null) return;
      setState(() => _images.add(File(xfile.path)));
    } catch (e) {
      _snack('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _scan() async {
    if (_images.isEmpty) {
      _snack('Añade al menos una imagen');
      return;
    }
    setState(() => _scanning = true);

    try {
      final result = await _scanService.scanDocument(_images);
      setState(() {
        _scanResult = result;
        _typeCtrl.text = result.type;
        _descCtrl.text = result.description;
        _holderCtrl.text = result.holderName ?? '';
        _status = result.status;
        _issuedAt = result.issuedAt;
        _expiresAt = result.expiresAt;
      });
    } catch (e) {
      _snack('Error al escanear: $e');
    } finally {
      setState(() => _scanning = false);
    }
  }

  Future<void> _save() async {
    if (_typeCtrl.text.trim().isEmpty) {
      _snack('El tipo de documento es obligatorio');
      return;
    }

    final provider = context.read<AppProvider>();
    final user = provider.currentUser;

    final doc = ScannedDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _typeCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      holderName: _holderCtrl.text.trim().isEmpty ? null : _holderCtrl.text.trim(),
      issuedAt: _issuedAt,
      expiresAt: _expiresAt,
      status: _status,
      imagePaths: _images.map((f) => f.path).toList(),
      scannedAt: DateTime.now(),
      scannedBy: user?.name ?? 'Gestor',
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    await provider.addScannedDocument(doc);
    _snack('Documento guardado');
    _reset();
    widget.onSaved();
  }

  void _reset() {
    setState(() {
      _images = [];
      _scanResult = null;
      _typeCtrl.clear();
      _descCtrl.clear();
      _holderCtrl.clear();
      _notesCtrl.clear();
      _status = 'Pendiente';
      _issuedAt = null;
      _expiresAt = null;
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Image picker
        Text('IMÁGENES DEL DOCUMENTO',
            style: AppTheme.orbitron(size: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 12),
        if (_images.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                if (i == _images.length) {
                  return _AddImageButton(onTap: _showImageSourceDialog);
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _images[i],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _images.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppTheme.errorColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        else
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.dividerColor, style: BorderStyle.solid),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: AppTheme.accent, size: 32),
                  SizedBox(height: 8),
                  Text('Añadir imagen',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Scan button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _scanning ? null : _scan,
            icon: _scanning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Text(_scanning ? 'Analizando con IA...' : 'ANALIZAR CON IA'),
          ),
        ),

        if (_scanResult != null || _typeCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('DATOS DEL DOCUMENTO',
              style:
                  AppTheme.orbitron(size: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),

          TextField(
            controller: _typeCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Tipo de documento *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Descripción'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _holderCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Titular'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),

          // Status selector
          Text('ESTADO',
              style:
                  AppTheme.orbitron(size: 10, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Válido', 'Caducado', 'Pendiente'].map((s) {
              final selected = _status == s;
              Color color;
              switch (s) {
                case 'Válido':
                  color = AppTheme.successColor;
                  break;
                case 'Caducado':
                  color = AppTheme.errorColor;
                  break;
                default:
                  color = AppTheme.warningColor;
              }
              return GestureDetector(
                onTap: () => setState(() => _status = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.2)
                        : AppTheme.panel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? color : AppTheme.dividerColor,
                    ),
                  ),
                  child: Text(s,
                      style: TextStyle(
                          color: selected ? color : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Date fields
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Emisión',
                  value: _issuedAt,
                  onChanged: (d) => setState(() => _issuedAt = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Caducidad',
                  value: _expiresAt,
                  onChanged: (d) => setState(() => _expiresAt = d),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Notas adicionales'),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('GUARDAR DOCUMENTO'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _reset,
              child: const Text('Limpiar'),
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_outlined, color: AppTheme.accent),
              title: const Text('Cámara',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppTheme.accent),
              title: const Text('Galería',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: const Icon(Icons.add, color: AppTheme.accent, size: 28),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final void Function(DateTime?) onChanged;
  const _DateField(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppTheme.accent,
                surface: AppTheme.panel,
              ),
            ),
            child: child!,
          ),
        );
        onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              value != null
                  ? DateFormat('dd/MM/yyyy').format(value!)
                  : 'Seleccionar',
              style: TextStyle(
                color:
                    value != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HISTORY TAB ====================

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final docs = context.watch<AppProvider>().scannedDocuments;

    if (docs.isEmpty) {
      return const EmptyState(
        icon: Icons.document_scanner_outlined,
        message: 'No hay documentos escaneados',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _DocCard(doc: docs[i]),
    );
  }
}

class _DocCard extends StatelessWidget {
  final ScannedDocument doc;
  const _DocCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (doc.status) {
      case 'Válido':
        statusColor = AppTheme.successColor;
        break;
      case 'Caducado':
        statusColor = AppTheme.errorColor;
        break;
      default:
        statusColor = AppTheme.warningColor;
    }

    return Dismissible(
      key: Key(doc.id),
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
      onDismissed: (_) =>
          context.read<AppProvider>().deleteScannedDocument(doc.id),
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
                const Icon(Icons.description_outlined,
                    color: AppTheme.accent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(doc.type,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(doc.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (doc.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(doc.description,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (doc.holderName != null) ...[
                  const Icon(Icons.person_outline,
                      color: AppTheme.textSecondary, size: 12),
                  const SizedBox(width: 4),
                  Text(doc.holderName!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                  const SizedBox(width: 12),
                ],
                if (doc.expiresAt != null) ...[
                  const Icon(Icons.event_outlined,
                      color: AppTheme.textSecondary, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Caduca: ${DateFormat('dd/MM/yyyy').format(doc.expiresAt!)}',
                    style: TextStyle(
                      color: doc.expiresAt!.isBefore(DateTime.now())
                          ? AppTheme.errorColor
                          : AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
                const Spacer(),
                Text(timeAgo(doc.scannedAt),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
