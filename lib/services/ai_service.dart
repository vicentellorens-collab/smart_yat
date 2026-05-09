import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';

class AiService {
  static const String _baseSystemPrompt =
      'You are the voice assistant for SmartCrew, an intelligent yacht management system. '
      'Your task is to classify crew voice messages and extract structured data from them. '
      'The message may be in ANY language: Spanish, English, French, Russian, Chinese, or others.\n\n'
      'ALWAYS classify into ONE of these categories:\n'
      '- INCIDENCIA: Something on the boat is broken, making unusual noise, leaking, smoking, or not working correctly.\n'
      '  Examples: "el winch vibra", "the generator is leaking", "le moteur fait un bruit", "генератор шумит"\n\n'
      '- INVENTARIO: A supply has been consumed, is running low, has run out, or has been restocked.\n'
      '  Examples: "gasté 2 litros de aceite", "we are low on bleach", "il n\'y a plus de papier", "масло закончилось"\n\n'
      '- CONSULTA_INVENTARIO: The user is asking what needs to be bought or what is running low.\n'
      '  Examples: "hazme la lista de la compra", "what do we need to buy", "qu\'est-ce qu\'il faut acheter", "что нужно купить"\n\n'
      '- EVENTO: The owner or guests want to organize an activity, meal, appointment, or celebration.\n'
      '  Examples: "mañana el owner quiere cenar para 8", "dinner party Saturday night", "le propriétaire veut un dîner"\n\n'
      '- TAREA: Something needs to be done (maintenance, cleaning, preparation) that is not an incident.\n'
      '  Examples: "hay que lijar la barandilla", "clean the deck before arrival", "il faut nettoyer le pont"\n\n'
      '- CONSULTA: A question about information already in the system (not inventory).\n'
      '  Examples: "qué le gusta al owner", "what does the owner like to eat"\n\n'
      'Respond ONLY with a valid JSON object — no text before or after, no markdown, no code blocks:\n'
      '{\n'
      '  "categoria": "INCIDENCIA|INVENTARIO|CONSULTA_INVENTARIO|EVENTO|TAREA|CONSULTA",\n'
      '  "prioridad": "alta|media|baja",\n'
      '  "datos_extraidos": {},\n'
      '  "respuesta_usuario": "Confirmation in the EXACT same language as the user message. Be specific: mention what was registered.",\n'
      '  "canonical_english": "Short neutral English summary (max 80 chars). E.g. \'Low stock alert: bleach\', \'Used 2L engine oil\', \'Incident: bow winch noise\'",\n'
      '  "original_language": "ISO 639-1 code: es, en, fr, ru, zh, it, de, pt, etc."\n'
      '}\n\n'
      'datos_extraidos fields by category:\n'
      '- INCIDENCIA: {"descripcion": "...", "ubicacion": "location on boat or null", "urgencia": "alta|media|baja"}\n'
      '- INVENTARIO: {"item_name": "exact name from inventory list if matched, else best guess", "quantity": <number or null>, "unit": "L|kg|g|uds|botellas|cajas|packs|m", "action": "restar|sumar|alerta", "matched_inventory_id": null}\n'
      '  - action "restar": gasté/used/consumed/se acabó/ran out/j\'ai utilisé/использовал/用了/gasté\n'
      '  - action "sumar": compré/bought/restocked/llegaron/acheté/купил/买了\n'
      '  - action "alerta": queda poco/low/running low/peu de stock/мало/快没了\n'
      '  - Quantity words: uno/one/un=1, dos/two/deux/два/两=2, tres/three/trois/три=3, medio/half/demi=0.5\n'
      '  - Units: litro/liter/litre→L, kilo→kg, gramo→g, botella→botellas, caja→cajas\n'
      '- CONSULTA_INVENTARIO: {"consulta": "lista_compra"}\n'
      '- EVENTO: {"tipo_evento": "dinner|party|visit|meeting|appointment|other", "detalle": "...", "cuando": "date/time or null"}\n'
      '- TAREA: {"descripcion": "...", "urgencia": "alta|media|baja"}\n'
      '- CONSULTA: {"sobre": "topic", "pregunta_resumida": "..."}';


  String _buildSystemPrompt(List<String>? inventoryItems) {
    if (inventoryItems == null || inventoryItems.isEmpty) {
      return _baseSystemPrompt;
    }
    final itemsList = inventoryItems.map((i) => '  - $i').join('\n');
    return '$_baseSystemPrompt\n\n'
        'CURRENT YACHT INVENTORY ITEMS (for semantic matching):\n$itemsList\n\n'
        'If the user mentions any of these items or something semantically related '
        '(synonyms, plurals, indirect descriptions), classify as INVENTARIO and use '
        'the exact item name from this list in datos_extraidos.item_name.';
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
              'max_tokens': 600,
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
    return _mockClassify(transcript, inventoryItems: inventoryItems);
  }


  AiClassificationResult _mockClassify(String transcript,
      {List<String>? inventoryItems}) {
    final t = transcript.toLowerCase();

    // Shopping list queries
    if (_contains(t, [
      'lista de la compra', 'lista compra', 'qué hay que comprar',
      'que hay que comprar', 'qué falta', 'que falta', 'qué nos falta',
      'que nos falta', 'necesitamos comprar', 'what do we need to buy',
      'shopping list', 'what to buy', 'qu\'est-ce qu\'il faut',
    ])) {
      return AiClassificationResult(
        categoria: 'CONSULTA_INVENTARIO',
        prioridad: 'media',
        datosExtraidos: {'consulta': 'lista_compra'},
        respuestaUsuario: 'Consultando lista de compras...',
      );
    }

    // Incidents
    if (_contains(t, [
      'vibra', 'avería', 'averia', 'fallo', 'roto', 'rota', 'problema',
      'no funciona', 'fuga', 'gotea', 'ruido', 'humo', 'broken', 'leak',
      'not working', 'noise', 'smoke', 'cassé', 'fuite', 'bruit',
      'сломан', 'течь', 'шум',
    ])) {
      return AiClassificationResult(
        categoria: 'INCIDENCIA',
        prioridad: 'alta',
        datosExtraidos: {
          'descripcion': transcript,
          'ubicacion': 'a determinar',
          'urgencia': 'alta',
        },
        respuestaUsuario: 'Incidencia registrada. Se notificará al capitán.',
      );
    }

    // Semantic inventory matching
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

    final inventoryKeywords = [
      'queda poco', 'sin stock', 'acabó', 'acabando', 'reponer',
      'no queda', 'se acabó', 'se acabo', 'gasté', 'gaste',
      'he gastado', 'usé', 'consumí', 'consumi', 'compré', 'compre',
      'llegaron', 'lejía', 'aceite', 'combustible', 'bengalas',
      'filtros', 'papel', 'jabón', 'jabon', 'detergente',
      'running low', 'ran out', 'used up', 'restocked', 'bought',
      'peu de', 'plus de', 'j\'ai utilisé', 'acheté',
    ];

    if (matchedInventoryItem != null || _contains(t, inventoryKeywords)) {
      String action = 'alerta';
      if (_contains(t, [
        'gasté', 'gaste', 'gastado', 'usé', 'use ', 'consumí', 'consumi',
        'se acabó', 'se acabo', 'acabó', 'ran out', 'used', 'consumed',
        'j\'ai utilisé', 'использовал',
      ])) {
        action = 'restar';
      } else if (_contains(t, [
        'compré', 'compre', 'llegaron', 'repusimos', 'añadí', 'anadí',
        'bought', 'restocked', 'acheté', 'купил',
      ])) {
        action = 'sumar';
      }

      double? qty;
      final numMatch = RegExp(r'\b(\d+(?:[.,]\d+)?)\b').firstMatch(t);
      if (numMatch != null) {
        qty = double.tryParse(numMatch.group(1)!.replaceAll(',', '.'));
      } else {
        const wordNums = {
          'uno': 1.0, 'una': 1.0, 'one': 1.0, 'un': 1.0,
          'dos': 2.0, 'two': 2.0, 'deux': 2.0,
          'tres': 3.0, 'three': 3.0, 'trois': 3.0,
          'cuatro': 4.0, 'four': 4.0, 'quatre': 4.0,
          'cinco': 5.0, 'five': 5.0, 'cinq': 5.0,
          'medio': 0.5, 'half': 0.5, 'demi': 0.5,
        };
        for (final e in wordNums.entries) {
          if (t.contains(e.key)) { qty = e.value; break; }
        }
      }

      String unit = 'uds';
      if (_contains(t, ['litro', 'litros', 'liter', 'liters', 'litre'])) unit = 'L';
      if (_contains(t, ['kilo', 'kilos', 'kg'])) unit = 'kg';
      if (_contains(t, ['gramo', 'gramos', 'gram', 'grams'])) unit = 'g';
      if (_contains(t, ['botella', 'botellas', 'bottle', 'bottles'])) unit = 'botellas';
      if (_contains(t, ['caja', 'cajas', 'box', 'boxes'])) unit = 'cajas';

      final itemLabel = matchedInventoryItem ?? transcript;
      return AiClassificationResult(
        categoria: 'INVENTARIO',
        prioridad: action == 'alerta' ? 'media' : 'alta',
        datosExtraidos: {
          'item_name': itemLabel,
          'quantity': qty,
          'unit': unit,
          'action': action,
          'matched_inventory_id': null,
        },
        respuestaUsuario: action == 'restar'
            ? 'Stock actualizado: ${qty != null ? "$qty $unit de " : ""}$itemLabel descontado.'
            : action == 'sumar'
                ? 'Stock actualizado: ${qty != null ? "$qty $unit de " : ""}$itemLabel añadido.'
                : 'Alerta de inventario registrada para $itemLabel.',
      );
    }

    // Events
    if (_contains(t, [
      'cenar', 'comer', 'esta noche', 'evento', 'visita', 'reunión',
      'fiesta', 'cumpleaños', 'llegará', 'cena', 'dinner', 'party',
      'tonight', 'tomorrow', 'dîner', 'soirée', 'demain', 'mañana',
    ])) {
      return AiClassificationResult(
        categoria: 'EVENTO',
        prioridad: 'media',
        datosExtraidos: {
          'tipo_evento': 'evento',
          'detalle': transcript,
          'cuando': 'pendiente de confirmar',
        },
        respuestaUsuario: 'Evento registrado en el calendario.',
      );
    }

    // Queries
    if (_contains(t, [
      'qué ', 'que ', 'cuál', 'cuándo', 'cómo', 'dónde', 'cuánto',
      'what ', 'when ', 'how ', 'where ', 'which ',
      'quel', 'quand', 'comment', 'où ',
    ])) {
      return AiClassificationResult(
        categoria: 'CONSULTA',
        prioridad: 'baja',
        datosExtraidos: {
          'sobre': 'sistema',
          'pregunta_resumida': transcript,
        },
        respuestaUsuario: 'Consulta registrada.',
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
