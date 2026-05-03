import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';

class AiService {
  static const String _baseSystemPrompt = '''You are the intelligent assistant for Smart Yat OS yacht management. Your task is to classify crew voice messages and extract relevant information. The message may be in ANY language (Spanish, English, French, Russian, Chinese, etc.).

ALWAYS classify the message into ONE of these categories:
- INCIDENCIA: Technical problem, breakdown, failure in boat equipment
- INVENTARIO: Consumption, expense or restocking of products or materials. Detect quantities and units.
- CONSULTA_INVENTARIO: User asks for the shopping list, what is missing, what needs to be bought, or what is low in stock.
- EVENTO: Planned activity, special meal, meeting, visit or celebration
- CONSULTA: Question about existing information in the system (NOT inventory)
- TAREA: Work to be done that does not fit the other categories

Respond ONLY with a valid JSON object (no additional text before or after):
{
  "categoria": "INCIDENCIA|INVENTARIO|CONSULTA_INVENTARIO|EVENTO|CONSULTA|TAREA",
  "prioridad": "alta|media|baja",
  "datos_extraidos": {},
  "respuesta_usuario": "Short confirmation message in the SAME language as the user's message",
  "canonical_english": "Short neutral English description of what was reported (e.g. 'Used 2L of engine oil')",
  "original_language": "ISO 639-1 code of the message language (en, es, fr, ru, zh, etc.)"
}

Fields by category:
- INCIDENCIA: datos_extraidos = {"descripcion": "...", "ubicacion": "...", "urgencia": "alta|media|baja"}
- INVENTARIO: datos_extraidos = {"item_name": "...", "quantity": <number or null>, "unit": "L|kg|uds|botellas|cajas|...", "action": "restar|sumar|alerta", "matched_inventory_id": null}
  - "gasté/used/j'ai utilisé/использовал/用了" → action = "restar"
  - "compré/bought/acheté/купил/买了" → action = "sumar"
  - "queda poco/low stock/peu de stock" → action = "alerta"
  - Convert text to number: "dos/two/deux/два/两" → 2, "medio/half/demi" → 0.5
  - Convert units: "litros/liters/litres" → "L", "kilos/kg" → "kg", "units/unidades" → "uds"
- CONSULTA_INVENTARIO: datos_extraidos = {"consulta": "lista_compra"}
- EVENTO: datos_extraidos = {"tipo_evento": "...", "detalle": "...", "cuando": "..."}
- CONSULTA: datos_extraidos = {"sobre": "...", "pregunta_resumida": "..."}
- TAREA: datos_extraidos = {"descripcion": "...", "urgencia": "alta|media|baja"}

Priority alta: urgent incidents, critical stock, immediate events.
Priority media: most cases.
Priority baja: general information, queries.''';

  String _buildSystemPrompt(List<String>? inventoryItems) {
    if (inventoryItems == null || inventoryItems.isEmpty) {
      return _baseSystemPrompt;
    }
    final itemsList = inventoryItems.map((i) => '  - $i').join('\n');
    return '$_baseSystemPrompt\n\nCURRENT YACHT INVENTORY ITEMS:\n$itemsList\n\nIf the user mentions any of these items or something semantically related, classify as INVENTARIO and use the exact item name in datos_extraidos.item_name.';
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
