import '../models/quiz_models.dart';

class ScoringService {
  static String _normalize(String v) => v.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static QuizResult scoreQuiz(Quiz quiz, Map<String, dynamic> answers) {
    double earned = 0;
    int possible = 0;
    final perQuestionResults = <QuestionResult>[];

    for (final q in quiz.questions) {
      if (q.type == QuestionType.matching) {
        final expected = q.pairs ?? [];
        final given = answers[q.id] as Map<int, String>? ?? {};
        double qEarned = 0;

        for (int i = 0; i < expected.length; i++) {
          final ok = _normalize(given[i] ?? '') == _normalize(expected[i].right);
          if (ok) qEarned += 1;
        }

        earned += qEarned;
        possible += expected.length;
        perQuestionResults.add(QuestionResult(
          id: q.id,
          isCorrect: qEarned == expected.length,
          score: qEarned,
        ));
        continue;
      }

      possible += 1;
      bool correct = false;

      if (q.type == QuestionType.mcq || q.type == QuestionType.true_false) {
        correct = answers[q.id] == q.answerIndex;
      } else if (q.type == QuestionType.fill_blank) {
        final userAnswers = answers[q.id] is List ? List<String>.from(answers[q.id]) : [answers[q.id]?.toString() ?? ''];
        final correctAnswers = q.answers ?? [];

        if (correctAnswers.isEmpty) {
          correct = false;
        } else if (userAnswers.length >= correctAnswers.length) {
          correct = true;
          for (int i = 0; i < correctAnswers.length; i++) {
            if (_normalize(userAnswers[i]) != _normalize(correctAnswers[i])) {
              correct = false;
              break;
            }
          }
        } else {
          final joined = _normalize(userAnswers.join(' '));
          correct = correctAnswers.any((a) => _normalize(a) == joined);
        }
      } else if (q.type == QuestionType.identification) {
        final user = _normalize(answers[q.id]?.toString() ?? '');
        correct = (q.answers ?? []).any((a) => _normalize(a) == user);
      }

      if (correct) earned += 1;
      perQuestionResults.add(QuestionResult(
        id: q.id,
        isCorrect: correct,
        score: correct ? 1.0 : 0.0,
      ));
    }

    return QuizResult(
      quizId: quiz.id,
      score: earned,
      totalQuestions: possible,
      completedAt: DateTime.now(),
      perQuestionResults: perQuestionResults,
    );
  }
}
