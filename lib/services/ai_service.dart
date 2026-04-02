import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';

class AiService {
  static const String _systemPrompt = '''Eres el asistente inteligente del yate Smart Yat OS. Tu tarea es clasificar mensajes de voz de la tripulación y extraer información relevante.

Clasifica SIEMPRE el mensaje en UNA de estas categorías:
- INCIDENCIA: Problema técnico, avería, fallo en equipamiento del barco
- INVENTARIO: Nivel de stock bajo, necesidad de reposición de productos o materiales
- PREFERENCIA_OWNER: Gustos, preferencias o aversiones personales del propietario del yate
- EVENTO: Actividad planificada, comida especial, reunión, visita o celebración
- CONSULTA: Pregunta sobre información existente en el sistema
- TAREA: Trabajo a realizar que no encaja en las categorías anteriores

Responde ÚNICAMENTE con un objeto JSON válido (sin texto adicional antes ni después):
{
  "categoria": "INCIDENCIA|INVENTARIO|PREFERENCIA_OWNER|EVENTO|CONSULTA|TAREA",
  "prioridad": "alta|media|baja",
  "datos_extraidos": {},
  "respuesta_usuario": "Mensaje corto de confirmación en español"
}

Campos por categoría:
- INCIDENCIA: datos_extraidos = {"descripcion": "...", "ubicacion": "...", "urgencia": "alta|media|baja"}
- INVENTARIO: datos_extraidos = {"producto": "...", "nivel": "bajo|sin_stock|ok", "cantidad_aproximada": "..."}
- PREFERENCIA_OWNER: datos_extraidos = {"tipo": "comida|bebida|temperatura|musica|eventos|otro", "detalle": "...", "positivo": true|false}
- EVENTO: datos_extraidos = {"tipo_evento": "...", "detalle": "...", "cuando": "..."}
- CONSULTA: datos_extraidos = {"sobre": "...", "pregunta_resumida": "..."}
- TAREA: datos_extraidos = {"descripcion": "...", "urgencia": "alta|media|baja"}

Prioridad alta: incidencias urgentes, stock crítico, eventos inmediatos.
Prioridad media: mayoría de casos.
Prioridad baja: información general, consultas.''';

  Future<AiClassificationResult> classify(String transcript) async {
    if (ApiConfig.anthropicApiKey == 'YOUR_API_KEY_HERE') {
      return _mockClassify(transcript);
    }
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
              'system': _systemPrompt,
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

  AiClassificationResult _mockClassify(String transcript) {
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

    if (_contains(t, ['queda poco', 'sin stock', 'acabó', 'acabando',
        'reponer', 'poca', 'poco', 'lejía', 'aceite', 'combustible', 'agua',
        'inventario'])) {
      return AiClassificationResult(
        categoria: 'INVENTARIO',
        prioridad: 'media',
        datosExtraidos: {
          'producto': transcript,
          'nivel': 'bajo',
          'cantidad_aproximada': 'baja',
        },
        respuestaUsuario: 'Alerta de inventario registrada. Se actualizará el stock.',
      );
    }

    if (_contains(t, ['owner', 'propietario', 'le gusta', 'no le gusta',
        'prefiere', 'le encanta', 'no quiere', 'odia', 'adora'])) {
      final isPositive = !_contains(t, ['no le gusta', 'no quiere', 'odia', 'no le']);
      return AiClassificationResult(
        categoria: 'PREFERENCIA_OWNER',
        prioridad: 'media',
        datosExtraidos: {
          'tipo': _inferPreferenceType(t),
          'detalle': transcript,
          'positivo': isPositive,
        },
        respuestaUsuario:
            'Preferencia del owner registrada${isPositive ? " ✓" : " (negativa)"}.',
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

  String _inferPreferenceType(String t) {
    if (_contains(t, ['comer', 'comida', 'carne', 'pescado', 'sushi', 'fruta',
        'verdura', 'almuerzo', 'cena', 'desayuno'])) return 'comida';
    if (_contains(t, ['beber', 'bebida', 'vino', 'champagne', 'cerveza',
        'agua', 'zumo', 'café', 'té'])) return 'bebida';
    if (_contains(t, ['temperatura', 'frío', 'frio', 'calor', 'grados',
        'aire', 'clima'])) return 'temperatura';
    if (_contains(t, ['música', 'musica', 'canción', 'jazz', 'rock',
        'silencio', 'sonido'])) return 'musica';
    if (_contains(t, ['evento', 'fiesta', 'visita', 'reunión'])) return 'eventos';
    return 'otro';
  }
}
