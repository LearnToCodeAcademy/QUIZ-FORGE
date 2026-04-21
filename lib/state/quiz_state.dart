import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/models.dart';
import '../models/quiz_models.dart';
import '../services/gemini_service.dart';
import '../services/grok_service.dart';
import '../services/file_parsing_service.dart';
import '../state/app_state.dart';
import '../api_config.dart';

// Gemini service provider
final geminiServiceProvider = Provider<GeminiService>((ref) {
  final appState = ref.watch(appStateProvider);
  String key = appState.settings.geminiKey;

  if (key.isEmpty) {
    try {
      key = dotenv.get('GEMINI_API_KEY', fallback: '');
    } catch (_) {}
  }

  if (key.isEmpty) {
    key = ApiConfig.geminiKey;
  }

  return GeminiService(apiKey: key);
});

// Grok service provider
final grokServiceProvider = Provider<GrokService>((ref) {
  final appState = ref.watch(appStateProvider);
  final apiKey = appState.settings.grokKey.isNotEmpty
      ? appState.settings.grokKey
      : dotenv.get('GROK_API_KEY', fallback: '');
  return GrokService(apiKey: apiKey);
});

// Generation progress state
final generationProgressProvider = StateProvider<double>((ref) => 0.0);

// Helper to simulate progress
void _startProgressSimulation(Ref ref) {
  ref.read(generationProgressProvider.notifier).state = 0.05;

  Timer.periodic(const Duration(milliseconds: 150), (timer) {
    final current = ref.read(generationProgressProvider);
    if (current >= 0.92 || !timer.isActive) {
      timer.cancel();
    } else {
      // Slow down as it gets closer to 95
      final step = (0.95 - current) / 15;
      ref.read(generationProgressProvider.notifier).state += step;
    }
  });
}

void _completeProgress(Ref ref) {
  ref.read(generationProgressProvider.notifier).state = 1.0;
  Future.delayed(const Duration(milliseconds: 500), () {
     ref.read(generationProgressProvider.notifier).state = 0.0;
  });
}

// Quiz generation state
class QuizGenerationNotifier extends AsyncNotifier<Quiz?> {
  @override
  Future<Quiz?> build() async => null;

  Future<void> generateQuizFromFile({
    required UploadedFileMeta file,
    required QuizConfig config,
  }) async {
    state = const AsyncValue.loading();
    _startProgressSimulation(ref);

    state = await AsyncValue.guard(() async {
      final appState = ref.read(appStateProvider);
      final modelType = appState.settings.aiModel;

      final content = await FileParsingService.extractTextFromFile(file);
      if (content == null || content.isEmpty) throw Exception('Could not extract text from file');

      Quiz? quiz;
      if (modelType == 'Grok') {
        quiz = await ref.read(grokServiceProvider).generateQuizFromText(content: content, config: config, source: file.name);
      } else {
        quiz = await ref.read(geminiServiceProvider).generateQuizFromText(content: content, config: config, source: file.name);
      }

      if (quiz == null) throw Exception('Failed to generate quiz from $modelType');
      _completeProgress(ref);
      return quiz;
    });
  }

  Future<void> generateQuizFromText({
    required String content,
    required QuizConfig config,
  }) async {
    state = const AsyncValue.loading();
    _startProgressSimulation(ref);

    state = await AsyncValue.guard(() async {
      final appState = ref.read(appStateProvider);
      final modelType = appState.settings.aiModel;

      Quiz? quiz;
      if (modelType == 'Grok') {
        quiz = await ref.read(grokServiceProvider).generateQuizFromText(content: content, config: config, source: 'Direct Text Input');
      } else {
        quiz = await ref.read(geminiServiceProvider).generateQuizFromText(content: content, config: config, source: 'Direct Text Input');
      }

      if (quiz == null) throw Exception('Failed to generate quiz from $modelType');
      _completeProgress(ref);
      return quiz;
    });
  }
}

final quizGenerationProvider = AsyncNotifierProvider<QuizGenerationNotifier, Quiz?>(QuizGenerationNotifier.new);

// Quiz history provider
class QuizHistoryNotifier extends Notifier<List<Quiz>> {
  @override
  List<Quiz> build() => [];
  void addQuiz(Quiz quiz) => state = [...state, quiz];
  void removeQuiz(String quizId) => state = state.where((q) => q.id != quizId).toList();
}
final quizHistoryProvider = NotifierProvider<QuizHistoryNotifier, List<Quiz>>(QuizHistoryNotifier.new);

// Quiz results provider
class QuizResultsNotifier extends Notifier<List<QuizResult>> {
  @override
  List<QuizResult> build() => [];
  void addResult(QuizResult result) => state = [...state, result];
}
final quizResultsProvider = NotifierProvider<QuizResultsNotifier, List<QuizResult>>(QuizResultsNotifier.new);

// Flashcard generation state
class FlashcardGenerationNotifier extends AsyncNotifier<List<Flashcard>?> {
  @override
  Future<List<Flashcard>?> build() async => null;

  Future<void> generateFlashcards({required String content}) async {
    state = const AsyncValue.loading();
    _startProgressSimulation(ref);
    state = await AsyncValue.guard(() async {
      final modelType = ref.read(appStateProvider).settings.aiModel;
      final result = modelType == 'Grok'
          ? await ref.read(grokServiceProvider).generateFlashcards(content: content)
          : await ref.read(geminiServiceProvider).generateFlashcards(content: content);
      _completeProgress(ref);
      return result;
    });
  }
}
final flashcardGenerationProvider = AsyncNotifierProvider<FlashcardGenerationNotifier, List<Flashcard>?>(FlashcardGenerationNotifier.new);

// Reviewer notes generation state
class ReviewerNotesGenerationNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> generateReviewerNotes({required String content}) async {
    state = const AsyncValue.loading();
    _startProgressSimulation(ref);
    state = await AsyncValue.guard(() async {
      final modelType = ref.read(appStateProvider).settings.aiModel;
      final result = modelType == 'Grok'
          ? await ref.read(grokServiceProvider).generateReviewerNotes(content: content)
          : await ref.read(geminiServiceProvider).generateReviewerNotes(content: content);
      _completeProgress(ref);
      return result;
    });
  }
}
final reviewerNotesGenerationProvider = AsyncNotifierProvider<ReviewerNotesGenerationNotifier, String?>(ReviewerNotesGenerationNotifier.new);

// Chat state
class ChatNotifier extends AutoDisposeAsyncNotifier<List<ChatMessage>> {
  @override
  Future<List<ChatMessage>> build() async => [];

  Future<void> sendMessage(String text) async {
    final currentMessages = state.value ?? [];
    final userMessage = ChatMessage(id: DateTime.now().millisecondsSinceEpoch.toString(), text: text, isUser: true, createdAt: DateTime.now());
    state = AsyncValue.data([...currentMessages, userMessage]);

    final modelType = ref.read(appStateProvider).settings.aiModel;
    String? response = modelType == 'Grok'
        ? await ref.read(grokServiceProvider).chat(message: text, history: currentMessages)
        : await ref.read(geminiServiceProvider).chat(message: text, history: currentMessages);

    if (response != null) {
      final aiMessage = ChatMessage(id: (DateTime.now().millisecondsSinceEpoch + 1).toString(), text: response, isUser: false, createdAt: DateTime.now());
      state = AsyncValue.data([...state.value!, aiMessage]);
    }
  }
}
final chatProvider = AutoDisposeAsyncNotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

// Explanation state
class ExplanationNotifier extends AutoDisposeAsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> explain({required String question, required String userAnswer, required String correctAnswer, required String context}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final modelType = ref.read(appStateProvider).settings.aiModel;
      return modelType == 'Grok'
          ? await ref.read(grokServiceProvider).explainAnswer(question: question, userAnswer: userAnswer, correctAnswer: correctAnswer, context: context)
          : await ref.read(geminiServiceProvider).explainAnswer(question: question, userAnswer: userAnswer, correctAnswer: correctAnswer, context: context);
    });
  }
}
final explanationProvider = AutoDisposeAsyncNotifierProvider<ExplanationNotifier, String?>(ExplanationNotifier.new);
