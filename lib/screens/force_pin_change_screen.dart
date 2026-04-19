import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'manager_home.dart';
import 'crew_home.dart';

class ForcePinChangeScreen extends StatefulWidget {
  final AppUser user;
  const ForcePinChangeScreen({super.key, required this.user});

  @override
  State<ForcePinChangeScreen> createState() => _ForcePinChangeScreenState();
}

class _ForcePinChangeScreenState extends State<ForcePinChangeScreen> {
  String _newPin = '';
  String _confirmPin = '';
  bool _confirming = false;
  String? _error;

  void _onDigit(String digit) {
    setState(() => _error = null);
    if (!_confirming) {
      if (_newPin.length >= 6) return;
      setState(() => _newPin += digit);
      if (_newPin.length >= 4) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _confirming = true);
        });
      }
    } else {
      if (_confirmPin.length >= 6) return;
      setState(() => _confirmPin += digit);
      if (_confirmPin.length >= 4) _tryChange();
    }
  }

  void _onDelete() {
    setState(() {
      if (!_confirming) {
        if (_newPin.isNotEmpty) _newPin = _newPin.substring(0, _newPin.length - 1);
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      }
    });
  }

  void _tryChange() {
    if (_newPin == '0000') {
      setState(() {
        _error = 'El nuevo PIN no puede ser 0000';
        _confirmPin = '';
        _newPin = '';
        _confirming = false;
      });
      return;
    }
    if (_newPin != _confirmPin) {
      setState(() {
        _error = 'Los PINs no coinciden. Inténtalo de nuevo.';
        _confirmPin = '';
        _newPin = '';
        _confirming = false;
      });
      return;
    }
    final provider = context.read<AppProvider>();
    provider.resetCrewPin(widget.user.id, _newPin);
    final updated = provider.users.firstWhere(
      (u) => u.id == widget.user.id,
      orElse: () => widget.user,
    );
    provider.login(updated);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => widget.user.role == UserRole.gestor
          ? const ManagerHome()
          : const CrewHome(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final current = _confirming ? _confirmPin : _newPin;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppTheme.warningColor.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security,
                          color: AppTheme.warningColor, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Es tu primer acceso. Por seguridad, debes cambiar tu PIN.',
                          style: TextStyle(
                              color: AppTheme.warningColor, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  _confirming
                      ? 'CONFIRMA EL NUEVO PIN'
                      : 'INTRODUCE EL NUEVO PIN',
                  style: AppTheme.orbitron(size: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _confirming
                      ? 'Repite el PIN para confirmarlo'
                      : 'Elige un PIN de 4-6 dígitos (no puede ser 0000)',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < current.length
                            ? AppTheme.accent
                            : AppTheme.dividerColor,
                        border: Border.all(
                          color: i < current.length
                              ? AppTheme.accent
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                        color: AppTheme.errorColor, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                _buildNumPad(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumPad() {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Column(
      children: rows
          .map((row) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  if (key.isEmpty) return const SizedBox(width: 80, height: 64);
                  if (key == 'del') {
                    return _PinKey(
                      child: const Icon(Icons.backspace_outlined,
                          color: AppTheme.textSecondary, size: 22),
                      onTap: _onDelete,
                    );
                  }
                  return _PinKey(
                    child: Text(key,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w500)),
                    onTap: () => _onDigit(key),
                  );
                }).toList(),
              ))
          .toList(),
    );
  }
}

class _PinKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PinKey({required this.child, required this.onTap});

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
