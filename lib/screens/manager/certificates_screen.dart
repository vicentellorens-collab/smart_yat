import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    // Sort by urgency: expired first, then by days remaining
    final sorted = [...p.certificates]..sort((a, b) {
        final da = a.daysUntilExpiry;
        final db = b.daysUntilExpiry;
        return da.compareTo(db);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('CERTIFICADOS')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCertDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
      body: sorted.isEmpty
          ? const EmptyState(
              icon: Icons.verified_outlined,
              message: 'No hay certificados registrados')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _CertCard(
                cert: sorted[i],
                onEdit: () => _showCertDialog(context, sorted[i]),
                onDelete: () =>
                    context.read<AppProvider>().deleteCertificate(sorted[i].id),
              ),
            ),
    );
  }

  void _showCertDialog(BuildContext context, [Certificate? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final issuerCtrl = TextEditingController(text: existing?.issuer);
    final typeCtrl = TextEditingController(text: existing?.type);
    DateTime expiryDate =
        existing?.expiryDate ?? DateTime.now().add(const Duration(days: 365));

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
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: issuerCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Emisor'),
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
                      border: Border.all(color: AppTheme.dividerColor),
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
                        ));
                      } else {
                        existing.name = nameCtrl.text.trim();
                        existing.issuer = issuerCtrl.text.trim();
                        existing.type = typeCtrl.text.trim();
                        existing.expiryDate = expiryDate;
                        prov.updateCertificate(existing);
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(existing == null ? 'CREAR' : 'GUARDAR'),
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
            border: Border.all(color: _borderColor.withOpacity(0.5)),
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
