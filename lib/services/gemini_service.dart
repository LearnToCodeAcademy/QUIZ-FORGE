import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_models.dart';

class GeminiService {
  final String apiKey;
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-pro:generateContent';

  GeminiService({required this.apiKey});

  // Generate quiz from text content
  Future<Quiz?> generateQuizFromText({
    required String content,
    required QuizConfig config,
    required String source,
  }) async {
    try {
      final prompt = _buildQuizPrompt(content, config);
      
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 4096,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        return _parseQuizFromResponse(text, source);
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Quiz Generation Error: $e');
      return null;
    }
  }

  // Generate reviewer notes
  Future<String?> generateReviewerNotes(String content) async {
    try {
      final prompt = '''
Please provide comprehensive reviewer notes for the following content. 
Focus on:
1. Key concepts and definitions
2. Important points to remember
3. Common misconceptions
4. Real-world applications

Content:
$content

Provide the notes in a structured, organized manner.
''';

      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      }
      return null;
    } catch (e) {
      print('Reviewer Notes Error: $e');
      return null;
    }
  }

  // Generate flashcards
  Future<List<Map<String, String>>?> generateFlashcards(String content) async {
    try {
      final prompt = '''
Create flashcards from the following content. Each flashcard should have:
- Front (question/concept)
- Back (answer/explanation)

Format your response as a JSON array like this:
[
  {"front": "Question 1", "back": "Answer 1"},
  {"front": "Question 2", "back": "Answer 2"}
]

Content:
$content

Generate 10-15 flashcards.
''';

      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.5,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        // Extract JSON from response
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final cards = List<Map<String, String>>.from(
            (jsonDecode(jsonStr) as List).map((item) => Map<String, String>.from(item as Map))
          );
          return cards;
        }
      }
      return null;
    } catch (e) {
      print('Flashcards Generation Error: $e');
      return null;
    }
  }

  // Chat with AI about content
  Future<String?> chatWithContext(String content, String userMessage) async {
    try {
      final prompt = '''
You are an educational AI assistant. Help the user with their question about the following content.

Content:
$content

User Question: $userMessage

Provide a clear, educational, and helpful response.
''';

      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      }
      return null;
    } catch (e) {
      print('Chat Error: $e');
      return null;
    }
  }

  String _buildQuizPrompt(String content, QuizConfig config) {
    return '''
Generate a ${config.quizType} quiz based on the following content.

Requirements:
- Number of questions: ${config.numQuestions}
- Difficulty level: ${config.difficulty}
- Question type: ${config.quizType}
- Each question should have 4 multiple choice options (A, B, C, D)
- Include explanations for correct answers

Content:
$content

Format your response EXACTLY as a JSON array like this:
[
  {
    "question": "What is...",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswer": 0,
    "explanation": "The correct answer is Option A because..."
  }
]

Generate only the JSON array, no other text.
''';
  }

  Quiz? _parseQuizFromResponse(String text, String source) {
    try {
      // Extract JSON from response
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text);
      if (jsonMatch == null) return null;

      final jsonStr = jsonMatch.group(0)!;
      final parsed = jsonDecode(jsonStr) as List;

      final questions = <QuizQuestion>[];
      for (int i = 0; i < parsed.length; i++) {
        final q = parsed[i] as Map<String, dynamic>;
        questions.add(QuizQuestion(
          id: 'q_$i',
          question: q['question'] as String,
          options: List<String>.from(q['options'] as List),
          correctAnswer: q['correctAnswer'] as int,
          explanation: q['explanation'] as String? ?? 'No explanation provided.',
        ));
      }

      return Quiz(
        id: 'quiz_${DateTime.now().millisecondsSinceEpoch}',
        title: 'AI-Generated Quiz from $source',
        description: 'Generated by Gemini AI',
        questions: questions,
        createdAt: DateTime.now(),
        source: source,
      );
    } catch (e) {
      print('Parse Quiz Error: $e');
      return null;
    }
  }
}
