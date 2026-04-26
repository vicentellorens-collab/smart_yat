import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';

class AiService {
  static const String _baseSystemPrompt = '''Eres el asistente inteligente del yate Smart Yat OS. Tu tarea es clasificar mensajes de voz de la tripulación y extraer información relevante.

Clasifica SIEMPRE el mensaje en UNA de estas categorías:
- INCIDENCIA: Problema técnico, avería, fallo en equipamiento del barco
- INVENTARIO: Nivel de stock bajo, necesidad de reposición de productos o materiales. IMPORTANTE: usa matching semántico, no literal. Si el usuario menciona un producto con sinónimos, plurales, variaciones o descripciones indirectas que coincidan con algún item del inventario, clasifica como INVENTARIO.
- EVENTO: Actividad planificada, comida especial, reunión, visita o celebración
- CONSULTA: Pregunta sobre información existente en el sistema
- TAREA: Trabajo a realizar que no encaja en las categorías anteriores

Responde ÚNICAMENTE con un objeto JSON válido (sin texto adicional antes ni después):
{
  "categoria": "INCIDENCIA|INVENTARIO|EVENTO|CONSULTA|TAREA",
  "prioridad": "alta|media|baja",
  "datos_extraidos": {},
  "respuesta_usuario": "Mensaje corto de confirmación en español"
}

Campos por categoría:
- INCIDENCIA: datos_extraidos = {"descripcion": "...", "ubicacion": "...", "urgencia": "alta|media|baja"}
- INVENTARIO: datos_extraidos = {"producto": "...", "nivel": "bajo|sin_stock|ok", "cantidad_aproximada": "..."}
- EVENTO: datos_extraidos = {"tipo_evento": "...", "detalle": "...", "cuando": "..."}
- CONSULTA: datos_extraidos = {"sobre": "...", "pregunta_resumida": "..."}
- TAREA: datos_extraidos = {"descripcion": "...", "urgencia": "alta|media|baja"}

Prioridad alta: incidencias urgentes, stock crítico, eventos inmediatos.
Prioridad media: mayoría de casos.
Prioridad baja: información general, consultas.''';

  String _buildSystemPrompt(List<String>? inventoryItems) {
    if (inventoryItems == null || inventoryItems.isEmpty) {
      return _baseSystemPrompt;
    }
    final itemsList = inventoryItems.map((i) => '  - $i').join('\n');
    return '$_baseSystemPrompt\n\nITEMS ACTUALES EN EL INVENTARIO DEL YATE:\n$itemsList\n\nSi el usuario menciona cualquiera de estos items o algo semanticamente relacionado (sinónimos, variaciones, descripciones), clasifica como INVENTARIO y usa el nombre exacto del item en datos_extraidos.producto. Ejemplos: "no queda aceite para los motores" → INVENTARIO (producto: ACEITE MOTOR), "se acabó la lejía" → INVENTARIO.';
  }

  Future<AiClassificationResult> classify(String transcript,
      {List<String>? inventoryItems}) async {
    if (ApiConfig.anthropicApiKey == 'YOUR_API_KEY_HERE') {
      return _mockClassify(transcript, inventoryItems: inventoryItems);
    }
    final systemPrompt = _buildSystemPrompt(inventoryItems);
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.anthropicBaseUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': ApiConfig.anthropicApiKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': ApiConfig.claudeModel,
              'max_tokens': 512,
              'system': systemPrompt,
              'messages': [
                {'role': 'user', 'content': transcript}
              ],
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text = data['content'][0]['text'] as String;
        final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (match != null) {
          final parsed = jsonDecode(match.group(0)!) as Map<String, dynamic>;
          return AiClassificationResult.fromJson(parsed);
        }
      }
    } catch (_) {
      // fall through to mock
    }
    return _mockClassify(transcript);
  }

  AiClassificationResult _mockClassify(String transcript,
      {List<String>? inventoryItems}) {
    final t = transcript.toLowerCase();

    if (_contains(t, ['vibra', 'avería', 'averia', 'fallo', 'roto', 'rota',
        'problema', 'no funciona', 'fuga', 'gotea', 'ruido', 'humo'])) {
      return AiClassificationResult(
        categoria: 'INCIDENCIA',
        prioridad: 'alta',
        datosExtraidos: {
          'descripcion': transcript,
          'ubicacion': 'a determinar',
          'urgencia': 'alta',
        },
        respuestaUsuario: 'Incidencia registrada con prioridad ALTA. Se notificará al capitán.',
      );
    }

    // Semantic inventory matching against actual inventory items
    String? matchedInventoryItem;
    if (inventoryItems != null && inventoryItems.isNotEmpty) {
      for (final item in inventoryItems) {
        final itemWords = item.toLowerCase().split(RegExp(r'[\s_]+'));
        if (itemWords.any((word) => word.length > 2 && t.contains(word))) {
          matchedInventoryItem = item;
          break;
        }
      }
    }

    if (matchedInventoryItem != null ||
        _contains(t, ['queda poco', 'sin stock', 'acabó', 'acabando',
            'reponer', 'poca', 'poco', 'no queda', 'se acabó', 'se acabo',
            'lejía', 'aceite', 'combustible', 'inventario'])) {
      return AiClassificationResult(
        categoria: 'INVENTARIO',
        prioridad: 'media',
        datosExtraidos: {
          'producto': matchedInventoryItem ?? transcript,
          'nivel': 'bajo',
          'cantidad_aproximada': 'baja',
        },
        respuestaUsuario: 'Alerta de inventario registrada. Se actualizará el stock.',
      );
    }

    if (_contains(t, ['cenar', 'comer', 'mañana', 'esta noche', 'evento',
        'visita', 'reunión', 'fiesta', 'cumpleaños', 'llegará'])) {
      return AiClassificationResult(
        categoria: 'EVENTO',
        prioridad: 'media',
        datosExtraidos: {
          'tipo_evento': 'evento',
          'detalle': transcript,
          'cuando': 'pendiente de confirmar',
        },
        respuestaUsuario: 'Evento registrado en el calendario del yate.',
      );
    }

    if (_contains(t, ['qué', 'que ', 'cuál', 'cuándo', 'cómo', 'dónde',
        'cuánto', 'tiene', 'hay ', 'existe', 'lista'])) {
      return AiClassificationResult(
        categoria: 'CONSULTA',
        prioridad: 'baja',
        datosExtraidos: {
          'sobre': 'sistema',
          'pregunta_resumida': transcript,
        },
        respuestaUsuario: 'Consulta registrada. Revisa la sección correspondiente.',
      );
    }

    return AiClassificationResult(
      categoria: 'TAREA',
      prioridad: 'media',
      datosExtraidos: {'descripcion': transcript, 'urgencia': 'media'},
      respuestaUsuario: 'Tarea registrada y pendiente de asignación.',
    );
  }

  bool _contains(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));
}
