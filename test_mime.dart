import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyAH2bUX7bjGZYdWJkDY6IWG0RGLoMXteBk';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro-preview:generateContent?key=$apiKey';
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'contents': [{'parts': [{'text': 'Generate JSON { "hello": "world" }'}]}],
      'generationConfig': {'temperature': 0.1, 'responseMimeType': 'application/json'}
    }),
  );
  print(response.statusCode);
  print(response.body);
}