import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import 'manager_home.dart';
import 'crew_home.dart';
import 'force_pin_change_screen.dart';

enum _LoginMode { welcome, register, login }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _LoginMode _mode = _LoginMode.welcome;

  void _goToRegister() => setState(() => _mode = _LoginMode.register);
  void _goToLogin() => setState(() => _mode = _LoginMode.login);
  void _goToWelcome() => setState(() => _mode = _LoginMode.welcome);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_mode) {
          _LoginMode.welcome => _WelcomeView(
              onRegister: _goToRegister,
              onLogin: _goToLogin,
            ),
          _LoginMode.register => _RegisterView(onBack: _goToWelcome),
          _LoginMode.login => _LoginView(onBack: _goToWelcome),
        },
      ),
    );
  }
}

// ==================== WELCOME ====================

class _WelcomeView extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  const _WelcomeView({required this.onRegister, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final hasUsers = context.watch<AppProvider>().users.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accent, width: 2),
              color: AppTheme.panel,
            ),
            child: const Center(child: _YachtLogo(size: 62, color: AppTheme.accent)),
          ),
          const SizedBox(height: 28),
          Text('SmartCrew', style: AppTheme.orbitron(size: 28)),
          const SizedBox(height: 10),
          Text(
            'Enhance your crew.',
            style: GoogleFonts.exo2(
              color: AppTheme.textSecondary,
              fontSize: 15,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          if (hasUsers) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLogin,
                child: const Text('ACCEDER'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRegister,
              child: Text(
                'Registrar nuevo yate',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRegister,
                child: const Text('CONFIGURAR YATE'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onLogin,
              child: Text(
                'Ya tengo cuenta',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'v2.0.0 · SmartCrew',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ==================== REGISTER ====================

class _RegisterView extends StatefulWidget {
  final VoidCallback onBack;
  const _RegisterView({required this.onBack});

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _nameCtrl = TextEditingController();
  final _yachtCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _yachtCtrl.dispose();
    _emailCtrl.dispose();
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final yacht = _yachtCtrl.text.trim();
    final pin = _pinCtrl.text.trim();
    final confirm = _confirmPinCtrl.text.trim();

    if (name.isEmpty || yacht.isEmpty || pin.isEmpty) {
      _snack('Completa todos los campos obligatorios');
      return;
    }
    if (pin.length != 4) {
      _snack('El PIN debe tener exactamente 4 dígitos');
      return;
    }
    if (pin != confirm) {
      _snack('Los PINs no coinciden');
      return;
    }

    setState(() => _loading = true);
    final provider = context.read<AppProvider>();
    final error = await provider.registerAdmin(
      name: name,
      pin: pin,
      yachtName: yacht,
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
    );
    setState(() => _loading = false);

    if (error != null) {
      _snack(error);
      return;
    }

    _snack('Yate registrado correctamente. Ahora accede con tu PIN.');
    widget.onBack();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.accent),
                onPressed: widget.onBack,
              ),
              const SizedBox(width: 8),
              Text('REGISTRAR YATE', style: AppTheme.orbitron(size: 16)),
            ],
          ),
          const SizedBox(height: 24),
          Text('DATOS DEL ADMINISTRADOR',
              style: AppTheme.orbitron(size: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Tu nombre *',
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Email (opcional)',
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          Text('DATOS DEL YATE',
              style: AppTheme.orbitron(size: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 14),
          TextField(
            controller: _yachtCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Nombre del yate *',
              prefixIcon: Icon(Icons.sailing, color: AppTheme.textSecondary),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          Text('PIN DE ACCESO',
              style: AppTheme.orbitron(size: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 14),
          TextField(
            controller: _pinCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'PIN (exactamente 4 dígitos) *',
              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPinCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Confirmar PIN *',
              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('REGISTRAR'),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== LOGIN ====================

class _LoginView extends StatefulWidget {
  final VoidCallback onBack;
  const _LoginView({required this.onBack});

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  AppUser? _selectedUser;
  String _pin = '';
  String? _error;

  void _selectUser(AppUser user) {
    setState(() {
      _selectedUser = user;
      _pin = '';
      _error = null;
    });
  }

  void _onNumpad(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length >= 4) {
      _tryLogin();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _tryLogin() {
    if (_selectedUser == null) return;
    final provider = context.read<AppProvider>();

    if (_selectedUser!.accountStatus == AccountStatus.blocked) {
      setState(() => _error = 'Cuenta bloqueada. Contacta al administrador.');
      _pin = '';
      return;
    }

    if (_selectedUser!.accountExpiresAt != null &&
        _selectedUser!.accountExpiresAt!.isBefore(DateTime.now())) {
      setState(() => _error = 'Cuenta expirada. Contacta al administrador.');
      _pin = '';
      return;
    }

    final verified = AuthService.verifyPin(_pin, _selectedUser!.pin);
    if (!verified) {
      setState(() {
        _error = 'PIN incorrecto';
        _pin = '';
      });
      return;
    }

    provider.login(_selectedUser!);
    if (_selectedUser!.mustChangePIN) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ForcePinChangeScreen(user: _selectedUser!),
      ));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => _selectedUser!.role == UserRole.gestor
            ? const ManagerHome()
            : const CrewHome(),
      ));
    }
  }

  void _showAdminRecovery(BuildContext context) {
    final yachtCtrl = TextEditingController();
    final pin1Ctrl = TextEditingController();
    final pin2Ctrl = TextEditingController();
    bool verified = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RECUPERAR PIN ADMIN',
                  style: AppTheme.orbitron(size: 14)),
              const SizedBox(height: 8),
              if (!verified) ...[
                const Text(
                  'Para verificar tu identidad, introduce el nombre del yate tal como lo registraste.',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: yachtCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Nombre del yate',
                    prefixIcon: Icon(Icons.sailing,
                        color: AppTheme.textSecondary),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final enteredName =
                          yachtCtrl.text.trim().toLowerCase();
                      final storedName =
                          (_selectedUser!.yachtName ?? '').toLowerCase();
                      if (enteredName.isEmpty ||
                          enteredName != storedName) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Nombre de yate incorrecto'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                        return;
                      }
                      setModalState(() => verified = true);
                    },
                    child: const Text('VERIFICAR'),
                  ),
                ),
              ] else ...[
                const Text(
                  'Verificación correcta. Define tu nuevo PIN de 4 dígitos.',
                  style: TextStyle(
                      color: AppTheme.successColor, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pin1Ctrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Nuevo PIN (4 dígitos)',
                    prefixIcon: Icon(Icons.lock_outline,
                        color: AppTheme.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pin2Ctrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Confirmar nuevo PIN',
                    prefixIcon: Icon(Icons.lock_outline,
                        color: AppTheme.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final p1 = pin1Ctrl.text.trim();
                      final p2 = pin2Ctrl.text.trim();
                      if (p1.length != 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'El PIN debe tener exactamente 4 dígitos'),
                            backgroundColor: AppTheme.warningColor,
                          ),
                        );
                        return;
                      }
                      if (p1 != p2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Los PINs no coinciden'),
                            backgroundColor: AppTheme.warningColor,
                          ),
                        );
                        return;
                      }
                      await context
                          .read<AppProvider>()
                          .resetCrewPin(_selectedUser!.id, p1);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        setState(() {
                          _pin = '';
                          _error = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'PIN actualizado. Ahora accede con tu nuevo PIN.'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    },
                    child: const Text('GUARDAR NUEVO PIN'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AppProvider>().users;

    if (_selectedUser == null) {
      return _buildUserPicker(users);
    }
    return _buildPinPad();
  }

  Widget _buildUserPicker(List<AppUser> users) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.accent),
                onPressed: widget.onBack,
              ),
              const SizedBox(width: 8),
              Text('ACCEDER', style: AppTheme.orbitron(size: 16)),
            ],
          ),
          const SizedBox(height: 24),
          Text('SELECCIONA TU PERFIL',
              style: AppTheme.orbitron(size: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          if (users.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No hay usuarios registrados.\nRegistra un yate primero.',
                  style: TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...users.map((u) => _UserTile(
                  user: u,
                  onTap: () => _selectUser(u),
                )),
        ],
      ),
    );
  }

  Widget _buildPinPad() {
    final user = _selectedUser!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.accent),
                onPressed: () => setState(() {
                  _selectedUser = null;
                  _pin = '';
                  _error = null;
                }),
              ),
              const SizedBox(width: 8),
              Text('INTRODUCE TU PIN', style: AppTheme.orbitron(size: 14)),
            ],
          ),
          const SizedBox(height: 32),
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.accent.withValues(alpha: 0.2),
            child: Text(
              user.name[0],
              style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(user.name,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          Text(
            user.role == UserRole.gestor ? 'Gestor / Capitán' : 'Tripulante',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 32),
          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length
                      ? AppTheme.accent
                      : AppTheme.dividerColor,
                  border: Border.all(
                    color: i < _pin.length ? AppTheme.accent : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: AppTheme.errorColor, fontSize: 12)),
          ],
          const SizedBox(height: 32),
          // Numpad
          _NumPad(
            onDigit: _onNumpad,
            onDelete: _onDelete,
          ),
          if (_selectedUser!.isAdmin) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _showAdminRecovery(context),
              child: const Text(
                '¿Olvidaste tu PIN?',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback onTap;
  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBlocked = user.accountStatus == AccountStatus.blocked;
    final isExpired = user.accountExpiresAt != null &&
        user.accountExpiresAt!.isBefore(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBlocked || isExpired
                ? AppTheme.errorColor.withValues(alpha: 0.4)
                : AppTheme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.accent.withValues(alpha: 0.2),
              child: Text(
                user.name[0],
                style: const TextStyle(
                    color: AppTheme.accent, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text(
                    user.role == UserRole.gestor ? 'Gestor' : 'Tripulante',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isBlocked)
              _StatusBadge('BLOQUEADO', AppTheme.errorColor)
            else if (isExpired)
              _StatusBadge('EXPIRADO', AppTheme.warningColor)
            else
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _NumPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  const _NumPad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 80, height: 64);
            }
            if (key == 'del') {
              return _NumPadKey(
                child: const Icon(Icons.backspace_outlined,
                    color: AppTheme.textSecondary, size: 22),
                onTap: onDelete,
              );
            }
            return _NumPadKey(
              child: Text(key,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w500)),
              onTap: () => onDigit(key),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _NumPadKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _NumPadKey({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 64,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ==================== YACHT LOGO ====================

class _YachtLogo extends StatelessWidget {
  final double size;
  final Color color;
  const _YachtLogo({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.65),
      painter: _YachtPainter(color),
    );
  }
}

class _YachtPainter extends CustomPainter {
  final Color color;
  _YachtPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = color..style = PaintingStyle.fill;
    final mast = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.038
      ..strokeCap = StrokeCap.round;

    // Hull — trapezoidal base
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.02, h * 0.72)
        ..lineTo(w * 0.00, h * 0.88)
        ..lineTo(w * 1.00, h * 0.88)
        ..lineTo(w * 0.94, h * 0.72)
        ..close(),
      fill,
    );

    // Main superstructure
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.06, h * 0.72)
        ..lineTo(w * 0.06, h * 0.54)
        ..lineTo(w * 0.83, h * 0.54)
        ..lineTo(w * 0.91, h * 0.72)
        ..close(),
      fill,
    );

    // Bridge deck
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.10, h * 0.54)
        ..lineTo(w * 0.10, h * 0.38)
        ..lineTo(w * 0.60, h * 0.38)
        ..lineTo(w * 0.67, h * 0.54)
        ..close(),
      fill,
    );

    // Top deck
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.14, h * 0.38)
        ..lineTo(w * 0.14, h * 0.26)
        ..lineTo(w * 0.44, h * 0.26)
        ..lineTo(w * 0.50, h * 0.38)
        ..close(),
      fill,
    );

    // Mast
    canvas.drawLine(
        Offset(w * 0.32, h * 0.26), Offset(w * 0.32, h * 0.05), mast);

    // Radar arm
    canvas.drawLine(
        Offset(w * 0.22, h * 0.13), Offset(w * 0.42, h * 0.13), mast);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
