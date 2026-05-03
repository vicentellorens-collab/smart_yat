import 'package:flutter/material.dart';
import 'package:smart_yat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/language_service.dart';
import '../../widgets/common_widgets.dart';
import '../../main.dart' show ttsService;

enum _HeyYatState {
  idle,
  listening,
  processing,
  result,
  saved,
}

class HeyYatScreen extends StatefulWidget {
  const HeyYatScreen({super.key});

  @override
  State<HeyYatScreen> createState() => _HeyYatScreenState();
}

class _HeyYatScreenState extends State<HeyYatScreen>
    with TickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  final AiService _ai = AiService();
  final TextEditingController _manualCtrl = TextEditingController();

  _HeyYatState _state = _HeyYatState.idle;
  bool _speechAvailable = false;
  String _transcript = '';
  AiClassificationResult? _result;
  String? _errorMsg;
  bool _showManualInput = false;
  bool _ttsEnabled = true;
  bool _processingQueue = false;
  ConnectivityService? _connectivityService;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 1.0, end: 1.18).animate(CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeInOut,
    ));
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectivityService = context.read<ConnectivityService>();
      _connectivityService!.addListener(_onConnectivityRestored);
    });
  }

  void _onConnectivityRestored() {
    if (_connectivityService?.isOnline == true) {
      _processPendingQueue();
    }
  }

  Future<void> _processPendingQueue() async {
    final provider = context.read<AppProvider>();
    final pending =
        provider.pendingVoiceMessages.where((m) => !m.processed).toList();
    if (pending.isEmpty) return;

    setState(() => _processingQueue = true);
    final inventoryItems =
        provider.inventory.map((i) => i.name).toList();
    await provider.processPendingMessages(
        (t) => _ai.classify(t, inventoryItems: inventoryItems));
    if (mounted) {
      setState(() => _processingQueue = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${pending.length} mensaje${pending.length != 1 ? "s" : ""} offline procesado${pending.length != 1 ? "s" : ""}'),
          ),
        );
    }
  }

  Future<void> _initSpeech() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechAvailable = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: (_) => _onSpeechError(),
      );
    }
    if (mounted) setState(() {});
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (_state == _HeyYatState.listening && _transcript.isNotEmpty) {
        _processTranscript(_transcript);
      } else if (_state == _HeyYatState.listening) {
        setState(() => _state = _HeyYatState.idle);
      }
    }
  }

  void _onSpeechError() {
    if (mounted) {
      setState(() {
        _state = _HeyYatState.idle;
        _errorMsg = 'Error de reconocimiento. Intenta de nuevo.';
      });
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _state = _HeyYatState.listening;
      _transcript = '';
      _result = null;
      _errorMsg = null;
    });
    _pulseCtrl.repeat(reverse: true);

    if (!_speechAvailable) {
      setState(() {
        _showManualInput = true;
        _state = _HeyYatState.idle;
      });
      return;
    }

    final speechLocale = context.read<LanguageService>().speechLocale
        .replaceAll('-', '_');
    await _speech.listen(
      onResult: _onResult,
      localeId: speechLocale,
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(partialResults: true),
    );
  }

  void _onResult(SpeechRecognitionResult result) {
    // Update transcript in real-time (partialResults: true shows progress)
    setState(() => _transcript = result.recognizedWords);
    // Do NOT stop on finalResult — let _onSpeechStatus handle completion
    // so the full pauseFor silence timer runs before cutting off.
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (_transcript.isNotEmpty) {
      _processTranscript(_transcript);
    } else {
      setState(() => _state = _HeyYatState.idle);
    }
  }

  Future<void> _processTranscript(String text) async {
    final isOnline = context.read<ConnectivityService>().isOnline;

    if (!isOnline) {
      // Queue for later
      final msg = PendingVoiceMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        transcript: text,
        recordedAt: DateTime.now(),
      );
      await context.read<AppProvider>().addPendingVoiceMessage(msg);
      if (_ttsEnabled) {
        final speechLocale = context.read<LanguageService>().speechLocale;
        await ttsService.setLanguage(speechLocale);
        await ttsService.speak('Guardado para procesar cuando haya conexión.');
      }
      setState(() {
        _state = _HeyYatState.idle;
        _transcript = '';
        _errorMsg = 'Sin conexión. Mensaje guardado en cola offline.';
      });
      return;
    }

    setState(() {
      _state = _HeyYatState.processing;
      _transcript = text;
    });
    _spinCtrl.repeat();

    try {
      final provider = context.read<AppProvider>();
      final inventoryItems =
          provider.inventory.map((i) => i.name).toList();
      final rawResult =
          await _ai.classify(text, inventoryItems: inventoryItems);

      // BUG-007: For CONSULTA_INVENTARIO, build the actual shopping list
      AiClassificationResult result = rawResult;
      if (rawResult.categoria == 'CONSULTA_INVENTARIO') {
        final shoppingList = provider.getShoppingListResponse();
        result = AiClassificationResult(
          categoria: rawResult.categoria,
          prioridad: rawResult.prioridad,
          datosExtraidos: {'lista_compra': shoppingList},
          respuestaUsuario: shoppingList,
        );
      }

      if (mounted) {
        setState(() {
          _result = result;
          _state = _HeyYatState.result;
        });
        if (_ttsEnabled) {
          final speechLocale = context.read<LanguageService>().speechLocale;
          await ttsService.setLanguage(speechLocale);
          await ttsService.speak(result.respuestaUsuario);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _HeyYatState.idle;
          _errorMsg = 'Error al clasificar. Comprueba tu conexión.';
        });
      }
    } finally {
      _spinCtrl.stop();
    }
  }

  Future<void> _confirm() async {
    if (_result == null) return;
    final provider = context.read<AppProvider>();

    final cmd = VoiceCommand(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transcript: _transcript,
      category: _result!.categoria,
      priority: _result!.prioridad,
      extractedData: _result!.datosExtraidos,
      userResponse: _result!.respuestaUsuario,
      timestamp: DateTime.now(),
    );

    await provider.processVoiceCommand(cmd, _result!);

    if (_ttsEnabled) {
      final speechLocale = context.read<LanguageService>().speechLocale;
      await ttsService.setLanguage(speechLocale);
      await ttsService.speak('Guardado correctamente.');
    }

    setState(() {
      _state = _HeyYatState.saved;
      _transcript = '';
      _result = null;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _state = _HeyYatState.idle);
  }

  void _cancel() {
    ttsService.stop();
    setState(() {
      _state = _HeyYatState.idle;
      _transcript = '';
      _result = null;
    });
  }

  @override
  void dispose() {
    _connectivityService?.removeListener(_onConnectivityRestored);
    _pulseCtrl.dispose();
    _spinCtrl.dispose();
    _speech.stop();
    _manualCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = context.watch<AppProvider>().pendingVoiceMessages
        .where((m) => !m.processed).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMain(pendingCount)),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildMain(int pendingCount) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title row with TTS toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.heyYat, style: AppTheme.displayCondensed(size: 22)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _ttsEnabled = !_ttsEnabled),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _ttsEnabled
                        ? AppTheme.accentDim
                        : AppTheme.surface01,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _ttsEnabled
                          ? AppTheme.accent
                          : AppTheme.borderSubtle,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _ttsEnabled ? Icons.volume_up : Icons.volume_off,
                        color: _ttsEnabled
                            ? AppTheme.accent
                            : AppTheme.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _ttsEnabled ? 'VOZ ON' : 'VOZ OFF',
                        style: AppTheme.label(
                          color: _ttsEnabled ? AppTheme.accent : AppTheme.textSecondary,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.heyYatSubtitle,
            style: AppTheme.label(),
          ),

          // Processing queue badge
          if (_processingQueue) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.accent),
                  ),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.heyYatProcessingOffline,
                      style: AppTheme.label(color: AppTheme.accent)),
                ],
              ),
            ),
          ] else if (pendingCount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.statusWarn.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.statusWarn.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off,
                      color: AppTheme.statusWarn, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.heyYatPendingMessages(pendingCount),
                    style: AppTheme.label(color: AppTheme.statusWarn),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Main state content
          _buildStateContent(),

          const SizedBox(height: 32),

          // Error message
          if (_errorMsg != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.statusAlert.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.statusAlert.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppTheme.statusAlert, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMsg!,
                        style: AppTheme.label(color: AppTheme.statusAlert)),
                  ),
                ],
              ),
            ),

          // Manual input toggle
          if (_state == _HeyYatState.idle) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _showManualInput = !_showManualInput),
              icon: Icon(
                  _showManualInput
                      ? Icons.keyboard_hide
                      : Icons.keyboard_alt_outlined,
                  size: 16),
              label: Text(
                  _showManualInput
                      ? AppLocalizations.of(context)!.heyYatHideKeyboard
                      : AppLocalizations.of(context)!.heyYatTypeManually,
                  style: AppTheme.label(color: AppTheme.textSecondary)),
              style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary),
            ),
            if (_showManualInput) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final text = _manualCtrl.text.trim();
                      if (text.isNotEmpty) {
                        _manualCtrl.clear();
                        _processTranscript(text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14)),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStateContent() {
    return switch (_state) {
      _HeyYatState.idle => _buildIdleState(),
      _HeyYatState.listening => _buildListeningState(),
      _HeyYatState.processing => _buildProcessingState(),
      _HeyYatState.result => _buildResultState(),
      _HeyYatState.saved => _buildSavedState(),
    };
  }

  Widget _buildIdleState() {
    return Column(
      children: [
        GestureDetector(
          onTap: _startListening,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.accent, width: 2),
            ),
            child: const Icon(Icons.mic_none, color: AppTheme.accent, size: 50),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _speechAvailable
              ? 'Pulsa y habla'
              : 'Micrófono no disponible',
          style: AppTheme.cardTitle(
              size: 14,
              color: _speechAvailable
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        const Text(
          '"el winch 3 vibra"  ·  "queda poca lejía"\n"al owner le gusta el sushi"',
          style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.6),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildListeningState() {
    return Column(
      children: [
        GestureDetector(
          onTap: _stopListening,
          child: ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.statusAlert.withValues(alpha: 0.15),
                border: Border.all(color: AppTheme.statusAlert, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.statusAlert.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.mic, color: AppTheme.statusAlert, size: 50),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(AppLocalizations.of(context)!.heyYatListening,
            style: AppTheme.sectionLabel(size: 13, color: AppTheme.statusAlert)),
        const SizedBox(height: 12),
        if (_transcript.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface01,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Text(
              _transcript,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
          )
        else
          Text(AppLocalizations.of(context)!.heyYatSpeakNow,
              style: AppTheme.label()),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _stopListening,
          child: const Text('Detener'),
        ),
      ],
    );
  }

  Widget _buildProcessingState() {
    return Column(
      children: [
        RotationTransition(
          turns: _spinCtrl,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.5), width: 3),
            ),
            child: const Icon(Icons.auto_awesome,
                color: AppTheme.accent, size: 36),
          ),
        ),
        const SizedBox(height: 20),
        Text(AppLocalizations.of(context)!.heyYatClassifying,
            style: AppTheme.sectionLabel(size: 13, color: AppTheme.accent)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface01,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Text('"$_transcript"',
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Widget _buildResultState() {
    if (_result == null) return const SizedBox.shrink();
    final r = _result!;
    return SingleChildScrollView(
      child: Column(
        children: [
          // Transcript
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface01,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRANSCRIPCIÓN', style: AppTheme.sectionLabel()),
                const SizedBox(height: 6),
                Text('"$_transcript"',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Classification card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface01,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CategoryIcon(r.categoria),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.categoria,
                              style: AppTheme.sectionLabel(size: 13, color: AppTheme.accent)),
                          Text(
                            'Prioridad: ${r.prioridad.toUpperCase()}',
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: AppTheme.borderSubtle),
                const SizedBox(height: 10),
                // Extracted data
                ...r.datosExtraidos.entries
                    .where((e) => e.value != null && e.value.toString().isNotEmpty)
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${e.key}: ',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  '${e.value}',
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentDim,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppTheme.accent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(r.respuestaUsuario,
                            style: AppTheme.label(size: 14, color: AppTheme.textPrimary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Confirm / Cancel buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _cancel,
                  icon: const Icon(Icons.close, size: 16),
                  label: Text(AppLocalizations.of(context)!.cancel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _confirm,
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: Text(AppLocalizations.of(context)!.heyYatConfirmed),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedState() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.accentDim,
            border: Border.all(color: AppTheme.accent, width: 2),
          ),
          child: const Icon(Icons.check, color: AppTheme.accent, size: 44),
        ),
        const SizedBox(height: 20),
        Text(AppLocalizations.of(context)!.heyYatConfirmed,
            style: AppTheme.displayCondensed(size: 20, color: AppTheme.accent)),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context)!.heyYatSavedInSystem,
            style: AppTheme.label()),
      ],
    );
  }

  Widget _buildHistory() {
    final commands = context.watch<AppProvider>().voiceCommands.take(5).toList();
    if (commands.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface01,
        border: const Border(top: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('RECIENTES', style: AppTheme.sectionLabel()),
          ),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              itemCount: commands.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cmd = commands[i];
                return GestureDetector(
                  onTap: () => _processTranscript(cmd.transcript),
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface01,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(cmd.category,
                                  style: const TextStyle(
                                      color: AppTheme.accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const Spacer(),
                            Text(timeAgo(cmd.timestamp),
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cmd.transcript,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
