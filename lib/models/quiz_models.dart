enum QuestionType {
  mcq,
  true_false,
  fill_blank,
  identification,
  matching,
}

class Quiz {
  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.createdAt,
    required this.source,
    this.sourceSummary = '',
  });

  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final String source;
  final String sourceSummary;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'questions': questions.map((q) => q.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'source': source,
        'sourceSummary': sourceSummary,
      };

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List).map((q) => QuizQuestion.fromJson(q)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      source: json['source'],
      sourceSummary: json['sourceSummary'] ?? '',
    );
  }
}

class MatchingPair {
  final String left;
  final String right;

  MatchingPair({required this.left, required this.right});

  Map<String, dynamic> toJson() => {'left': left, 'right': right};
  factory MatchingPair.fromJson(Map<String, dynamic> json) => MatchingPair(left: json['left'], right: json['right']);
}

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    this.choices,
    this.answerIndex,
    this.answers,
    this.pairs,
    required this.explanation,
  });

  final String id;
  final QuestionType type;
  final String prompt;
  final List<String>? choices;
  final int? answerIndex;
  final List<String>? answers;
  final List<MatchingPair>? pairs;
  final String explanation;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'prompt': prompt,
        'choices': choices,
        'answerIndex': answerIndex,
        'answers': answers,
        'pairs': pairs?.map((p) => p.toJson()).toList(),
        'explanation': explanation,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      type: QuestionType.values.byName(json['type']),
      prompt: json['prompt'],
      choices: json['choices'] != null ? List<String>.from(json['choices']) : null,
      answerIndex: json['answerIndex'],
      answers: json['answers'] != null ? List<String>.from(json['answers']) : null,
      pairs: json['pairs'] != null ? (json['pairs'] as List).map((p) => MatchingPair.fromJson(p)).toList() : null,
      explanation: json['explanation'],
    );
  }
}

class QuizConfig {
  QuizConfig({
    this.numQuestions = 10,
    this.difficulty = 'Medium',
    this.quizType = 'mixed',
  });

  final int numQuestions;
  final String difficulty; // Easy, Medium, Hard
  final String quizType; // mcq, true_false, fill_blank, identification, matching, mixed
}

class QuizResult {
  QuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
    this.perQuestionResults = const [],
  });

  final String quizId;
  final double score;
  final int totalQuestions;
  final DateTime completedAt;
  final List<QuestionResult> perQuestionResults;

  double get percentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;
}

class QuestionResult {
  final String id;
  final bool isCorrect;
  final double score;

  QuestionResult({required this.id, required this.isCorrect, required this.score});
}
