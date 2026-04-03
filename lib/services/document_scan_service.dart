import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class DocumentScanResult {
  final String type;
  final String description;
  final String? holderName;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final String status;

  DocumentScanResult({
    required this.type,
    required this.description,
    this.holderName,
    this.issuedAt,
    this.expiresAt,
    required this.status,
  });
}

class DocumentScanService {
  Future<DocumentScanResult> scanDocument(List<File> images) async {
    try {
      if (images.isEmpty) throw Exception('No images provided');

      final imageContents = <Map<String, dynamic>>[];
      for (final image in images.take(4)) {
        final bytes = await image.readAsBytes();
        final base64Image = base64.encode(bytes);
        imageContents.add({
          'type': 'image',
          'source': {
            'type': 'base64',
            'media_type': 'image/jpeg',
            'data': base64Image,
          }
        });
      }

      imageContents.add({
        'type': 'text',
        'text': '''Analiza este documento y extrae la siguiente información en formato JSON exacto:
{
  "type": "tipo de documento (certificado, pasaporte, titulación, etc.)",
  "description": "descripción breve del documento",
  "holderName": "nombre del titular o null",
  "issuedAt": "fecha de emisión en formato ISO 8601 o null",
  "expiresAt": "fecha de caducidad en formato ISO 8601 o null",
  "status": "Válido, Caducado, o Pendiente"
}
Responde SOLO con el JSON, sin texto adicional.'''
      });

      final response = await http.post(
        Uri.parse(ApiConfig.anthropicBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': ApiConfig.anthropicApiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': ApiConfig.claudeModel,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': imageContents}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['content'][0]['text'] as String;
        final jsonStr = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final result = jsonDecode(jsonStr) as Map<String, dynamic>;
        return DocumentScanResult(
          type: result['type'] ?? 'Documento',
          description: result['description'] ?? '',
          holderName: result['holderName'],
          issuedAt: result['issuedAt'] != null ? DateTime.tryParse(result['issuedAt']) : null,
          expiresAt: result['expiresAt'] != null ? DateTime.tryParse(result['expiresAt']) : null,
          status: result['status'] ?? 'Pendiente',
        );
      }
    } catch (e) {
      // Fall through to mock
    }

    return DocumentScanResult(
      type: 'Documento',
      description: 'Documento escaneado - editar manualmente',
      status: 'Pendiente',
    );
  }
}
