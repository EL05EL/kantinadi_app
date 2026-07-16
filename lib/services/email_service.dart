import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EmailService {
  static String get _apiKey => dotenv.env['BREVO_API_KEY'] ?? '';

  static Future<bool> sendReceiptWithAttachment({
    required String toEmail,
    required String subject,
    required String htmlContent,
    required String textContent,
    required String? attachmentBase64,
    required String? attachmentFilename,
  }) async {
    if (_apiKey.isEmpty) {
      return false;
    }

    final url = Uri.parse('https://api.brevo.com/v3/smtp/email');
    try {
      final body = <String, dynamic>{
        'sender': {
          'name': 'Kantin ADI',
          'email': '2400016002@webmail.uad.ac.id'
        },
        'to': [
          {'email': toEmail}
        ],
        'subject': subject,
        'htmlContent': htmlContent,
        'textContent': textContent,
      };

      if (attachmentBase64 != null && attachmentFilename != null) {
        body['attachment'] = [
          {
            'content': attachmentBase64,
            'name': attachmentFilename,
          }
        ];
      }

      final response = await http.post(
        url,
        headers: {
          'api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
