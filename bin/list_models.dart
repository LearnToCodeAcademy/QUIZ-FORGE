import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('📋 Listing available Gemini models...\n');
  
  const apiKey = 'AIzaSyCTBlCBXH3uCtmo1K9juaZe1kxvv6avtec';
  
  try {
    // Try v1 API
    print('Trying v1 API...');
    var response = await http.get(
      Uri.parse('https://generativelanguage.googleapis.com/v1/models?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response: $data');
      
      if (data['models'] != null) {
        print('\n✅ Available Models:');
        for (final model in data['models']) {
          print('  • ${model['name']}');
        }
      }
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
