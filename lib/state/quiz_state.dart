import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_models.dart';
import '../services/gemini_service.dart';
import '../services/file_parsing_service.dart';
import '../state/app_state.dart';

// Gemini service provider
final geminiServiceProvider = Provider<GeminiService>((ref) {
  final settings = ref.watch(appStateProvider);
  return GeminiService(apiKey: settings.settings.geminiKey);
});

// Quiz generation state
class QuizGenerationNotifier extends AsyncNotifier<Quiz?> {
  @override
  Future<Quiz?> build() async => null;

  Future<void> generateQuizFromFile({
    required String filePath,
    required QuizConfig config,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Extract text from file
      final content = await FileParsingService.extractTextFromFile(filePath);
      if (content == null || content.isEmpty) {
        throw Exception('Could not extract text from file');
      }

      // Generate quiz using Gemini
      final gemini = ref.read(geminiServiceProvider);
      final fileName = filePath.split('/').last;
      
      final quiz = await gemini.generateQuizFromText(
        content: content,
        config: config,
        source: fileName,
      );

      if (quiz == null) {
        throw Exception('Failed to generate quiz from Gemini');
      }

      return quiz;
    });
  }

  Future<void> generateQuizFromText({
    required String content,
    required QuizConfig config,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final gemini = ref.read(geminiServiceProvider);
      
      final quiz = await gemini.generateQuizFromText(
        content: content,
        config: config,
        source: 'Direct Text Input',
      );

      if (quiz == null) {
        throw Exception('Failed to generate quiz from Gemini');
      }

      return quiz;
    });
  }
}

final quizGenerationProvider = AsyncNotifierProvider<QuizGenerationNotifier, Quiz?>(
  QuizGenerationNotifier.new,
);

// Quiz history provider
class QuizHistoryNotifier extends Notifier<List<Quiz>> {
  @override
  List<Quiz> build() => [];

  void addQuiz(Quiz quiz) {
    state = [...state, quiz];
  }

  void removeQuiz(String quizId) {
    state = state.where((q) => q.id != quizId).toList();
  }
}

final quizHistoryProvider = NotifierProvider<QuizHistoryNotifier, List<Quiz>>(
  QuizHistoryNotifier.new,
);

// Quiz results provider
class QuizResultsNotifier extends Notifier<List<QuizResult>> {
  @override
  List<QuizResult> build() => [];

  void addResult(QuizResult result) {
    state = [...state, result];
  }

  double getAverageScore() {
    if (state.isEmpty) return 0;
    final total = state.fold<double>(0, (sum, r) => sum + r.percentage);
    return total / state.length;
  }
}

final quizResultsProvider = NotifierProvider<QuizResultsNotifier, List<QuizResult>>(
  QuizResultsNotifier.new,
);
