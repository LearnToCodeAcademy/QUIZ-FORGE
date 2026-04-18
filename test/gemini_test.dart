import 'dart:async';
import 'dart:io';
import 'package:quizforge/services/gemini_service.dart';
import 'package:quizforge/models/quiz_models.dart';

void main() async {
  print('╔════════════════════════════════════════════════════════════════╗');
  print('║          QuizForge - Gemini API Quiz Generation Test           ║');
  print('╚════════════════════════════════════════════════════════════════╝\n');

  const geminiApiKey = 'AIzaSyCTBlCBXH3uCtmo1K9juaZe1kxvv6avtec';
  final geminiService = GeminiService(apiKey: geminiApiKey);

  // Test 1: Generate Quiz from Sample Text
  print('\n📚 TEST 1: Generating Quiz from Sample Text Content');
  print('─' * 65);

  final sampleContent = '''
Flutter is an open-source UI framework by Google for building beautiful, 
natively compiled applications from a single codebase for mobile, web, and desktop.

Key Features of Flutter:
1. Hot Reload - See changes instantly without restarting your app
2. Rich Widgets - Pre-built, customizable UI components
3. Single Codebase - Write once, deploy everywhere
4. Native Performance - Compiled to native code
5. Open Source - Free to use and contribute

Dart Language:
Flutter uses Dart as its programming language. Dart is:
- Object-oriented
- Strongly typed but with type inference
- Supports functional programming
- Garbage collected
- Fast and efficient

The Flutter Architecture consists of:
1. Framework Layer - UI components and state management
2. Engine Layer - Core rendering and animation
3. Embedder Layer - Platform-specific code

Main Concepts:
- Widgets: Everything is a widget in Flutter
- State: Mutable and Immutable widgets
- BuildContext: Reference to widget position in tree
- Provider/Riverpod: State management solutions
- GoRouter: Navigation and routing
''';

  print('📝 Sample Content: Flutter Development Guide');
  print('Content length: ${sampleContent.length} characters\n');

  final config = QuizConfig(
    numQuestions: 5,
    difficulty: 'Medium',
    quizType: 'Multiple Choice',
  );

  print('⚙️ Quiz Configuration:');
  print('   - Number of Questions: ${config.numQuestions}');
  print('   - Difficulty Level: ${config.difficulty}');
  print('   - Quiz Type: ${config.quizType}\n');

  print('⏳ Generating quiz from Gemini API...');
  print('🔗 API Key: ${geminiApiKey.substring(0, 20)}...\n');

  try {
    final startTime = DateTime.now();
    final quiz = await geminiService.generateQuizFromText(
      content: sampleContent,
      config: config,
      source: 'Flutter Development Guide',
    );
    final duration = DateTime.now().difference(startTime);

    if (quiz != null) {
      print('✅ Quiz Generated Successfully!');
      print('⏱️  Generation Time: ${duration.inSeconds}s ${duration.inMilliseconds % 1000}ms\n');

      print('═' * 65);
      print('QUIZ DETAILS');
      print('═' * 65);
      print('📌 Quiz ID: ${quiz.id}');
      print('📄 Title: ${quiz.title}');
      print('📖 Description: ${quiz.description}');
      print('📂 Source: ${quiz.source}');
      print('📅 Created: ${quiz.createdAt}');
      print('❓ Total Questions: ${quiz.questions.length}\n');

      print('═' * 65);
      print('QUIZ QUESTIONS');
      print('═' * 65);

      for (int i = 0; i < quiz.questions.length; i++) {
        final q = quiz.questions[i];
        print('\n📌 Question ${i + 1}:');
        print('   ${q.question}\n');
        print('   Options:');
        for (int j = 0; j < q.options.length; j++) {
          final isCorrect = j == q.correctAnswer;
          final prefix = isCorrect ? '✓' : '•';
          print('   $prefix ${String.fromCharCode(65 + j)}) ${q.options[j]}');
        }
        print('\n   Correct Answer: ${String.fromCharCode(65 + q.correctAnswer)}');
        print('   Explanation: ${q.explanation}');
      }

      print('\n═' * 65);
      print('QUIZ JSON EXPORT');
      print('═' * 65);
      print(jsonEncode(quiz.toJson(), indent: 2));

      // Save to file
      final jsonFile = File('generated_quiz.json');
      await jsonFile.writeAsString(jsonEncode(quiz.toJson()), flush: true);
      print('\n💾 Quiz saved to: generated_quiz.json');
    } else {
      print('❌ Failed to generate quiz');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  // Test 2: Test with Different Difficulty Levels
  print('\n\n📚 TEST 2: Testing Different Difficulty Levels');
  print('─' * 65);

  final difficulties = ['Easy', 'Medium', 'Hard'];

  for (final difficulty in difficulties) {
    print('\n🎯 Generating $difficulty Quiz...');
    final config = QuizConfig(
      numQuestions: 3,
      difficulty: difficulty,
      quizType: 'Multiple Choice',
    );

    try {
      final quiz = await geminiService.generateQuizFromText(
        content: sampleContent,
        config: config,
        source: 'Difficulty Test - $difficulty',
      );

      if (quiz != null) {
        print('✅ $difficulty quiz generated with ${quiz.questions.length} questions');
      } else {
        print('❌ Failed to generate $difficulty quiz');
      }
    } catch (e) {
      print('❌ Error generating $difficulty quiz: $e');
    }
  }

  // Test 3: Test Reviewer Notes
  print('\n\n📚 TEST 3: Generating Reviewer Notes');
  print('─' * 65);
  print('⏳ Generating reviewer notes from Gemini API...\n');

  try {
    final notes = await geminiService.generateReviewerNotes(sampleContent);
    if (notes != null) {
      print('✅ Reviewer Notes Generated:\n');
      print(notes);
    } else {
      print('❌ Failed to generate reviewer notes');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  // Test 4: Test Flashcards
  print('\n\n📚 TEST 4: Generating Flashcards');
  print('─' * 65);
  print('⏳ Generating flashcards from Gemini API...\n');

  try {
    final flashcards = await geminiService.generateFlashcards(sampleContent);
    if (flashcards != null && flashcards.isNotEmpty) {
      print('✅ Flashcards Generated: ${flashcards.length} cards\n');
      for (int i = 0; i < flashcards.length && i < 5; i++) {
        final card = flashcards[i];
        print('Card ${i + 1}:');
        print('  Front: ${card['front']}');
        print('  Back: ${card['back']}\n');
      }
    } else {
      print('❌ Failed to generate flashcards');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  print('\n═' * 65);
  print('✨ All tests completed!');
  print('═' * 65);
}

// Helper function to pretty print JSON
String jsonEncode(dynamic obj, {int indent = 0}) {
  final buffer = StringBuffer();
  final indentStr = ' ' * indent;
  final nextIndentStr = ' ' * (indent + 2);

  if (obj is Map) {
    buffer.write('{\n');
    final entries = obj.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('$nextIndentStr"${entry.key}": ');
      buffer.write(jsonEncode(entry.value, indent: indent + 2));
      if (i < entries.length - 1) {
        buffer.write(',');
      }
      buffer.write('\n');
    }
    buffer.write('$indentStr}');
  } else if (obj is List) {
    buffer.write('[\n');
    for (int i = 0; i < obj.length; i++) {
      buffer.write('$nextIndentStr');
      buffer.write(jsonEncode(obj[i], indent: indent + 2));
      if (i < obj.length - 1) {
        buffer.write(',');
      }
      buffer.write('\n');
    }
    buffer.write('$indentStr]');
  } else if (obj is String) {
    buffer.write('"$obj"');
  } else {
    buffer.write(obj.toString());
  }

  return buffer.toString();
}
