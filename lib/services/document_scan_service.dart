import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class DocumentScanResult {
  final String type;
  final String description;
  final String? holderName;
  final String? documentNumber;
  final String? issuingAuthority;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final String status;
  final String confidence;

  DocumentScanResult({
    required this.type,
    required this.description,
    this.holderName,
    this.documentNumber,
    this.issuingAuthority,
    this.issuedAt,
    this.expiresAt,
    required this.status,
    this.confidence = 'medium',
  });
}

class DocumentScanService {
  static const String _systemPrompt =
      'You are a document analysis expert specializing in maritime certificates, '
      'official identification documents, and vessel paperwork. '
      'Your task is to extract structured data from document photos with maximum accuracy. '
      'Return ONLY valid JSON. Never add text before or after the JSON object.';

  static const String _userInstructions = '''Analyze this document image carefully and extract the following information.
Return ONLY a valid JSON object — no markdown, no code blocks, no explanations.

CRITICAL — expiry date extraction:
Look for ANY of these labels to find the expiry date:
"Expiry Date", "Expiry", "Valid Until", "Valid To", "Date of Expiry", "Expires",
"Revalidation Date", "Fecha de caducidad", "Fecha de vencimiento", "Valido hasta",
"Caducidad", "Vence", "Date d expiration", "Действителен до", "到期日",
"Ablaufdatum", "Scadenza", "Geldig tot".
This field is critical — examine every date on the document.

Date format rules:
- Always return dates as YYYY-MM-DD
- If only month and year visible (e.g. "04/2027" or "April 2027") return YYYY-MM-01
- If only year visible return YYYY-01-01
- Never guess a date — return null if genuinely not found

Return this exact JSON structure:
{
  "type": "Document type in English (e.g. STCW Basic Safety Training, ENG1 Medical Certificate, Passport, Insurance Certificate, Navigation Certificate)",
  "description": "Brief description of the document in its original language",
  "holderName": "Full name of the person or vessel this document belongs to, or null",
  "documentNumber": "Certificate or document reference number if visible, or null",
  "issuingAuthority": "Issuing organization, institution or country if visible, or null",
  "issuedAt": "YYYY-MM-DD or null",
  "expiresAt": "YYYY-MM-DD or null",
  "status": "Valid if expiry date is in the future or no expiry, Expired if expiry date is in the past, Pending if cannot determine",
  "confidence": "high if all main fields found clearly, medium if some fields uncertain, low if image is unclear or partially visible"
}''';

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
        'text': _userInstructions,
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
          'system': _systemPrompt,
          'messages': [
            {'role': 'user', 'content': imageContents}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['content'][0]['text'] as String;
        final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (match != null) {
          final result = jsonDecode(match.group(0)!) as Map<String, dynamic>;
          return DocumentScanResult(
            type: result['type'] ?? 'Document',
            description: result['description'] ?? '',
            holderName: result['holderName'],
            documentNumber: result['documentNumber'],
            issuingAuthority: result['issuingAuthority'],
            issuedAt: result['issuedAt'] != null
                ? DateTime.tryParse(result['issuedAt'])
                : null,
            expiresAt: result['expiresAt'] != null
                ? DateTime.tryParse(result['expiresAt'])
                : null,
            status: result['status'] ?? 'Pending',
            confidence: result['confidence'] ?? 'medium',
          );
        }
      }
    } catch (e) {
      // Fall through to fallback
    }

    return DocumentScanResult(
      type: 'Document',
      description: 'Scanned document — please fill in manually',
      status: 'Pending',
      confidence: 'low',
    );
  }
}
