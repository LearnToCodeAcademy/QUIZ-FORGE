import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/models.dart';
import '../models/quiz_models.dart';
import '../services/gemini_service.dart';
import '../services/grok_service.dart';
import '../services/file_parsing_service.dart';
import '../state/app_state.dart';

// Gemini service provider
final geminiServiceProvider = Provider<GeminiService>((ref) {
  final appState = ref.watch(appStateProvider);
  final apiKey = appState.settings.geminiKey.isNotEmpty
      ? appState.settings.geminiKey
      : dotenv.get('GEMINI_API_KEY', fallback: '');
  return GeminiService(apiKey: apiKey);
});

// Grok service provider
final grokServiceProvider = Provider<GrokService>((ref) {
  final appState = ref.watch(appStateProvider);
  final apiKey = appState.settings.grokKey.isNotEmpty
      ? appState.settings.grokKey
      : dotenv.get('GROK_API_KEY', fallback: '');
  return GrokService(apiKey: apiKey);
});

// Quiz generation state
class QuizGenerationNotifier extends AsyncNotifier<Quiz?> {
  @override
  Future<Quiz?> build() async => null;

  Future<void> generateQuizFromFile({
    required UploadedFileMeta file,
    required QuizConfig config,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final appState = ref.read(appStateProvider);
      final modelType = appState.settings.aiModel;

      // Extract text from file
      final content = await FileParsingService.extractTextFromFile(file);
      if (content == null || content.isEmpty) {
        throw Exception('Could not extract text from file');
      }

      final fileName = file.name;
      
      Quiz? quiz;
      if (modelType == 'Grok') {
        final grok = ref.read(grokServiceProvider);
        quiz = await grok.generateQuizFromText(
          content: content,
          config: config,
          source: fileName,
        );
      } else {
        final gemini = ref.read(geminiServiceProvider);
        quiz = await gemini.generateQuizFromText(
          content: content,
          config: config,
          source: fileName,
        );
      }

      if (quiz == null) {
        throw Exception('Failed to generate quiz from $modelType');
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
      final appState = ref.read(appStateProvider);
      final modelType = appState.settings.aiModel;

      Quiz? quiz;
      if (modelType == 'Grok') {
        final grok = ref.read(grokServiceProvider);
        quiz = await grok.generateQuizFromText(
          content: content,
          config: config,
          source: 'Direct Text Input',
        );
      } else {
        final gemini = ref.read(geminiServiceProvider);
        quiz = await gemini.generateQuizFromText(
          content: content,
          config: config,
          source: 'Direct Text Input',
        );
      }

      if (quiz == null) {
        throw Exception('Failed to generate quiz from $modelType');
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

// Flashcard generation state
class FlashcardGenerationNotifier extends AsyncNotifier<List<Flashcard>?> {
  @override
  Future<List<Flashcard>?> build() async => null;

  Future<void> generateFlashcards({required String content}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final appState = ref.read(appStateProvider);
      final modelType = appState.settings.aiModel;

      if (modelType == 'Grok') {
        return await ref.read(grokServiceProvider).generateFlashcards(content: content);
      } else {
        return await ref.read(geminiServiceProvider).generateFlashcards(content: content);
      }
    });
  }
}

final flashcardGenerationProvider = AsyncNotifierProvider<FlashcardGenerationNotifier, List<Flashcard>?>(
  FlashcardGenerationNotifier.new,
);

// Reviewer notes generation state
class ReviewerNotesGenerationNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> generateReviewerNotes({required String content}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final appState = ref.read(appStateProvider);
      final modelType = appState.settings.aiModel;

      if (modelType == 'Grok') {
        return await ref.read(grokServiceProvider).generateReviewerNotes(content: content);
      } else {
        return await ref.read(geminiServiceProvider).generateReviewerNotes(content: content);
      }
    });
  }
}

final reviewerNotesGenerationProvider = AsyncNotifierProvider<ReviewerNotesGenerationNotifier, String?>(
  ReviewerNotesGenerationNotifier.new,
);

// Chat state
class ChatNotifier extends AutoDisposeAsyncNotifier<List<ChatMessage>> {
  @override
  Future<List<ChatMessage>> build() async => [];

  Future<void> sendMessage(String text) async {
    final currentMessages = state.value ?? [];
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    state = AsyncValue.data([...currentMessages, userMessage]);

    final appState = ref.read(appStateProvider);
    final modelType = appState.settings.aiModel;

    String? response;
    if (modelType == 'Grok') {
      response = await ref.read(grokServiceProvider).chat(message: text, history: currentMessages);
    } else {
      response = await ref.read(geminiServiceProvider).chat(message: text, history: currentMessages);
    }

    if (response != null) {
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: response,
        isUser: false,
        createdAt: DateTime.now(),
      );
      state = AsyncValue.data([...state.value!, aiMessage]);
    }
  }
}

final chatProvider = AutoDisposeAsyncNotifierProvider<ChatNotifier, List<ChatMessage>>(
  ChatNotifier.new,
);

// Explanation state
class ExplanationNotifier extends AutoDisposeAsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> explain({
    required String question,
    required String userAnswer,
    required String correctAnswer,
    required String context,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final appState = ref.read(appStateProvider);
      final modelType = appState.settings.aiModel;

      if (modelType == 'Grok') {
        return await ref.read(grokServiceProvider).explainAnswer(
              question: question,
              userAnswer: userAnswer,
              correctAnswer: correctAnswer,
              context: context,
            );
      } else {
        return await ref.read(geminiServiceProvider).explainAnswer(
              question: question,
              userAnswer: userAnswer,
              correctAnswer: correctAnswer,
              context: context,
            );
      }
    });
  }
}

final explanationProvider = AutoDisposeAsyncNotifierProvider<ExplanationNotifier, String?>(
  ExplanationNotifier.new,
);
