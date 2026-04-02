import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'manager_home.dart';
import 'crew_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  UserRole? _selectedRole;
  String? _selectedCrewId;
  bool _showCrewPicker = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      _showCrewPicker = role == UserRole.tripulante;
      _selectedCrewId = null;
      _nameController.clear();
    });
  }

  void _login() {
    final provider = context.read<AppProvider>();
    String name = _nameController.text.trim();

    if (_selectedRole == UserRole.tripulante && _selectedCrewId != null) {
      final member = provider.crew.firstWhere((c) => c.id == _selectedCrewId);
      name = member.name;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce tu nombre para continuar')),
      );
      return;
    }

    final user = AppUser(
      id: _selectedCrewId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      role: _selectedRole!,
    );
    provider.login(user);

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => _selectedRole == UserRole.gestor
          ? const ManagerHome()
          : const CrewHome(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final crew = context.watch<AppProvider>().crew;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Logo / Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent, width: 2),
                  color: AppTheme.panel,
                ),
                child: const Icon(Icons.sailing, color: AppTheme.accent, size: 44),
              ),
              const SizedBox(height: 20),
              Text('SMART YAT OS', style: AppTheme.orbitron(size: 22)),
              const SizedBox(height: 6),
              Text(
                'Sistema de Gestión Inteligente',
                style: GoogleFonts.exo2(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 48),

              // Role selector
              Text('SELECCIONA TU PERFIL',
                  style: AppTheme.orbitron(size: 11, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _RoleButton(
                      label: 'GESTOR',
                      sublabel: 'Capitán / Oficial',
                      icon: Icons.manage_accounts_outlined,
                      selected: _selectedRole == UserRole.gestor,
                      onTap: () => _selectRole(UserRole.gestor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoleButton(
                      label: 'TRIPULANTE',
                      sublabel: 'Crew',
                      icon: Icons.person_outlined,
                      selected: _selectedRole == UserRole.tripulante,
                      onTap: () => _selectRole(UserRole.tripulante),
                    ),
                  ),
                ],
              ),

              if (_selectedRole != null) ...[
                const SizedBox(height: 28),
                if (_showCrewPicker && crew.isNotEmpty) ...[
                  Text('¿QUIÉN ERES?',
                      style: AppTheme.orbitron(size: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 12),
                  ...crew.map((c) => _CrewTile(
                        member: c,
                        selected: _selectedCrewId == c.id,
                        onTap: () => setState(() => _selectedCrewId = c.id),
                      )),
                  const SizedBox(height: 12),
                  Text('o introduce tu nombre',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                ],
                if (!_showCrewPicker || _selectedCrewId == null) ...[
                  Text('TU NOMBRE',
                      style: AppTheme.orbitron(size: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 10),
                ],
                if (_selectedCrewId == null)
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Ej: Carlos Ruiz',
                      prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _login,
                    icon: const Icon(Icons.login),
                    label: const Text('ACCEDER'),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              Text(
                'v1.0.0 · Smart Yat OS',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent.withOpacity(0.15)
              : AppTheme.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? AppTheme.accent : AppTheme.textSecondary,
                size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: AppTheme.orbitron(
                    size: 12,
                    color: selected ? AppTheme.accent : AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text(sublabel,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _CrewTile extends StatelessWidget {
  final CrewMember member;
  final bool selected;
  final VoidCallback onTap;
  const _CrewTile(
      {required this.member, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent.withOpacity(0.12)
              : AppTheme.panel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.accent.withOpacity(0.2),
              child: Text(
                member.name[0],
                style: const TextStyle(
                    color: AppTheme.accent, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600)),
                Text(member.role,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, color: AppTheme.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
