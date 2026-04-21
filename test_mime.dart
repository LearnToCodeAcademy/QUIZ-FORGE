import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyDlNZD34adO9iT2QzhCnY6YmbV0b2MwqOU';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro-preview:generateContent?key=$apiKey';
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'contents': [{'parts': [{'text': 'Generate JSON { "status": "ok" }'}]}],
      'generationConfig': {'temperature': 0.1, 'responseMimeType': 'application/json'}
    }),
  );
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
