// Quiz Models
class Quiz {
  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.createdAt,
    required this.source,
  });

  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final String source; // file name or source

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'questions': questions.map((q) => q.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'source': source,
      };
}

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer; // index
  final String explanation;

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
      };
}

class QuizConfig {
  QuizConfig({
    this.numQuestions = 10,
    this.difficulty = 'Medium',
    this.quizType = 'Multiple Choice',
  });

  final int numQuestions;
  final String difficulty; // Easy, Medium, Hard
  final String quizType; // Multiple Choice, True/False, Short Answer
}

class QuizResult {
  QuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  final String quizId;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  double get percentage => (score / totalQuestions) * 100;
}
