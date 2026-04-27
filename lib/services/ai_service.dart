import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';

class AiService {
  static const String _baseSystemPrompt = '''Eres el asistente inteligente del yate Smart Yat OS. Tu tarea es clasificar mensajes de voz de la tripulación y extraer información relevante.

Clasifica SIEMPRE el mensaje en UNA de estas categorías:
- INCIDENCIA: Problema técnico, avería, fallo en equipamiento del barco
- INVENTARIO: Consumo, gasto o reposición de productos o materiales. Detecta cantidades y unidades.
- CONSULTA_INVENTARIO: El usuario pide la lista de la compra, qué falta, qué hay que comprar, o qué está bajo de stock. Frases como "hazme la lista de la compra", "qué hay que comprar", "qué nos falta", "lista de compras".
- EVENTO: Actividad planificada, comida especial, reunión, visita o celebración
- CONSULTA: Pregunta sobre información existente en el sistema (que NO sea de inventario)
- TAREA: Trabajo a realizar que no encaja en las categorías anteriores

Responde ÚNICAMENTE con un objeto JSON válido (sin texto adicional antes ni después):
{
  "categoria": "INCIDENCIA|INVENTARIO|CONSULTA_INVENTARIO|EVENTO|CONSULTA|TAREA",
  "prioridad": "alta|media|baja",
  "datos_extraidos": {},
  "respuesta_usuario": "Mensaje corto de confirmación en español"
}

Campos por categoría:
- INCIDENCIA: datos_extraidos = {"descripcion": "...", "ubicacion": "...", "urgencia": "alta|media|baja"}
- INVENTARIO: datos_extraidos = {"item_name": "...", "quantity": <número o null>, "unit": "L|kg|uds|botellas|cajas|...", "action": "restar|sumar|alerta", "matched_inventory_id": null}
  - "gasté", "he gastado", "usé", "se acabó", "consumí" → action = "restar"
  - "compré", "llegaron", "repusimos", "añadir" → action = "sumar"
  - "queda poco", "hay poco", "está bajo" → action = "alerta"
  - Convierte texto a número: "dos" → 2, "cinco" → 5, "medio" → 0.5
  - Convierte unidades: "litros" → "L", "kilos" → "kg", "unidades"/"unos" → "uds"
- CONSULTA_INVENTARIO: datos_extraidos = {"consulta": "lista_compra"}
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
    return '$_baseSystemPrompt\n\nITEMS ACTUALES EN EL INVENTARIO DEL YATE:\n$itemsList\n\nSi el usuario menciona cualquiera de estos items o algo semánticamente relacionado, clasifica como INVENTARIO y usa el nombre exacto del item en datos_extraidos.item_name. Ejemplos: "he gastado 2 litros de aceite para el motor" → INVENTARIO (item_name: "Aceite de Motor", quantity: 2, unit: "L", action: "restar").';
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
          final parsed =
              jsonDecode(match.group(0)!) as Map<String, dynamic>;
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

    // BUG-007: Shopping list queries
    if (_contains(t, [
      'lista de la compra',
      'lista compra',
      'qué hay que comprar',
      'que hay que comprar',
      'qué falta',
      'que falta',
      'qué nos falta',
      'que nos falta',
      'necesitamos comprar',
    ])) {
      return AiClassificationResult(
        categoria: 'CONSULTA_INVENTARIO',
        prioridad: 'media',
        datosExtraidos: {'consulta': 'lista_compra'},
        respuestaUsuario: 'Consultando inventario...',
      );
    }

    if (_contains(t, [
      'vibra',
      'avería',
      'averia',
      'fallo',
      'roto',
      'rota',
      'problema',
      'no funciona',
      'fuga',
      'gotea',
      'ruido',
      'humo',
    ])) {
      return AiClassificationResult(
        categoria: 'INCIDENCIA',
        prioridad: 'alta',
        datosExtraidos: {
          'descripcion': transcript,
          'ubicacion': 'a determinar',
          'urgencia': 'alta',
        },
        respuestaUsuario:
            'Incidencia registrada con prioridad ALTA. Se notificará al capitán.',
      );
    }

    // BUG-006: Semantic inventory matching with action and quantity
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
        _contains(t, [
          'queda poco',
          'sin stock',
          'acabó',
          'acabando',
          'reponer',
          'poca',
          'poco',
          'no queda',
          'se acabó',
          'se acabo',
          'gasté',
          'gaste',
          'he gastado',
          'usé',
          'use ',
          'consumí',
          'consumi',
          'compré',
          'compre',
          'llegaron',
          'lejía',
          'aceite',
          'combustible',
          'inventario',
          'bengalas',
          'filtros',
        ])) {
      // Detect action
      String action = 'alerta';
      if (_contains(t, ['gasté', 'gaste', 'gastado', 'usé', 'use ', 'consumí', 'consumi', 'se acabó', 'se acabo', 'acabó'])) {
        action = 'restar';
      } else if (_contains(t, ['compré', 'compre', 'llegaron', 'repusimos', 'añadí', 'anadí'])) {
        action = 'sumar';
      }

      // Extract quantity from text
      double? qty;
      final numMatch = RegExp(r'\b(\d+(?:[.,]\d+)?)\b').firstMatch(t);
      if (numMatch != null) {
        qty = double.tryParse(numMatch.group(1)!.replaceAll(',', '.'));
      } else {
        const wordNums = {
          'uno': 1.0, 'una': 1.0,
          'dos': 2.0,
          'tres': 3.0,
          'cuatro': 4.0,
          'cinco': 5.0,
          'seis': 6.0,
          'siete': 7.0,
          'ocho': 8.0,
          'nueve': 9.0,
          'diez': 10.0,
          'medio': 0.5,
        };
        for (final e in wordNums.entries) {
          if (t.contains(e.key)) {
            qty = e.value;
            break;
          }
        }
      }

      // Extract unit
      String unit = 'uds';
      if (_contains(t, ['litro', 'litros', ' l '])) unit = 'L';
      if (_contains(t, ['kilo', 'kilos', 'kg'])) unit = 'kg';
      if (_contains(t, ['botella', 'botellas'])) unit = 'botellas';
      if (_contains(t, ['caja', 'cajas'])) unit = 'cajas';

      return AiClassificationResult(
        categoria: 'INVENTARIO',
        prioridad: action == 'alerta' ? 'media' : 'alta',
        datosExtraidos: {
          'item_name': matchedInventoryItem ?? transcript,
          'quantity': qty,
          'unit': unit,
          'action': action,
          'matched_inventory_id': null,
        },
        respuestaUsuario: action == 'restar'
            ? 'Stock actualizado. Se han restado ${qty ?? ''} $unit de ${matchedInventoryItem ?? "inventario"}.'
            : action == 'sumar'
                ? 'Stock actualizado. Se han añadido ${qty ?? ''} $unit de ${matchedInventoryItem ?? "inventario"}.'
                : 'Alerta de inventario registrada.',
      );
    }

    if (_contains(t, [
      'cenar',
      'comer',
      'mañana',
      'esta noche',
      'evento',
      'visita',
      'reunión',
      'fiesta',
      'cumpleaños',
      'llegará',
    ])) {
      return AiClassificationResult(
        categoria: 'EVENTO',
        prioridad: 'media',
        datosExtraidos: {
          'tipo_evento': 'evento',
          'detalle': transcript,
          'cuando': 'pendiente de confirmar',
        },
        respuestaUsuario:
            'Evento registrado en el calendario del yate.',
      );
    }

    if (_contains(t, [
      'qué',
      'que ',
      'cuál',
      'cuándo',
      'cómo',
      'dónde',
      'cuánto',
      'tiene',
      'hay ',
      'existe',
      'lista',
    ])) {
      return AiClassificationResult(
        categoria: 'CONSULTA',
        prioridad: 'baja',
        datosExtraidos: {
          'sobre': 'sistema',
          'pregunta_resumida': transcript,
        },
        respuestaUsuario:
            'Consulta registrada. Revisa la sección correspondiente.',
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
