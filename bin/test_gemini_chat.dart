import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = 'AIzaSyAH2bUX7bjGZYdWJkDY6IWG0RGLoMXteBk';
  const model = 'gemini-3.1-pro-preview';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

  print('Testing Gemini API (Model: $model) with Chat...');

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': 'Hello, are you gemini-3.1-pro-preview? Can you confirm your model version?'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      print('\n✅ Success! AI Response:');
      print(text);
    } else {
      print('\n❌ Failed! Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('\n❌ Error: $e');
  }
}
