import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_models.dart';
import '../state/quiz_state.dart';
import '../state/app_state.dart';
import '../services/scoring_service.dart';
import '../widgets/ui_parts.dart';

class QuizPlayerScreen extends ConsumerStatefulWidget {
  const QuizPlayerScreen({super.key});

  @override
  ConsumerState<QuizPlayerScreen> createState() => _QuizPlayerScreenState();
}

class _QuizPlayerScreenState extends ConsumerState<QuizPlayerScreen> {
  int currentIndex = 0;
  Map<String, dynamic> answers = {};
  int timeLeft = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  void _startTimer() {
    final settings = ref.read(appStateProvider).settings;
    if (settings.perQuestionTimer > 0) {
      setState(() {
        timeLeft = settings.perQuestionTimer;
      });
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (timeLeft <= 1) {
          _nextQuestion();
        } else {
          setState(() {
            timeLeft--;
          });
        }
      });
    }
  }

  void _nextQuestion() {
    final quiz = ref.read(quizGenerationProvider).value;
    if (quiz == null) return;

    if (currentIndex < quiz.questions.length - 1) {
      setState(() {
        currentIndex++;
      });
      _startTimer();
    } else {
      _submitQuiz();
    }
  }

  void _submitQuiz() {
    timer?.cancel();
    final quiz = ref.read(quizGenerationProvider).value;
    if (quiz == null) return;

    final result = ScoringService.scoreQuiz(quiz, answers);
    ref.read(quizResultsProvider.notifier).addResult(result);
    context.pushReplacement('/results');
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizGenerationProvider).value;
    if (quiz == null) return const Scaffold(body: Center(child: Text('No quiz loaded')));

    final q = quiz.questions[currentIndex];
    final settings = ref.watch(appStateProvider).settings;

    return Scaffold(
      backgroundColor: const Color(0xFF050924),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (currentIndex + 1) / quiz.questions.length,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(Color(settings.accent)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentIndex + 1} of ${quiz.questions.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (settings.perQuestionTimer > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: timeLeft <= 5 ? Colors.red.withOpacity(0.2) : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⏱ ${timeLeft}s',
                        style: TextStyle(
                          color: timeLeft <= 5 ? Colors.redAccent : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlowCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(settings.accent).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              q.type.name.toUpperCase().replaceAll('_', ' '),
                              style: TextStyle(
                                color: Color(settings.accent),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            q.prompt,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 24),
                          _renderQuestionInput(q),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (settings.allowBack)
                    TextButton.icon(
                      onPressed: currentIndex > 0
                          ? () {
                              setState(() => currentIndex--);
                              _startTimer();
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    )
                  else
                    const SizedBox(),
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(currentIndex == quiz.questions.length - 1 ? 'Finish ✓' : 'Next →'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderQuestionInput(QuizQuestion q) {
    switch (q.type) {
      case QuestionType.mcq:
      case QuestionType.true_false:
        return Column(
          children: List.generate(q.choices?.length ?? 0, (index) {
            final choice = q.choices![index];
            final isSelected = answers[q.id] == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => answers[q.id] = index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(ref.read(appStateProvider).settings.accent).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: isSelected ? Color(ref.read(appStateProvider).settings.accent) : Colors.white10,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? Color(ref.read(appStateProvider).settings.accent) : Colors.white30),
                          color: isSelected ? Color(ref.read(appStateProvider).settings.accent) : Colors.transparent,
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(choice)),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      case QuestionType.fill_blank:
      case QuestionType.identification:
        return TextField(
          decoration: const InputDecoration(
            hintText: 'Type your answer here...',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => answers[q.id] = v,
        );
      case QuestionType.matching:
        // Simplified matching for now: list of dropdowns
        return Column(
          children: List.generate(q.pairs?.length ?? 0, (index) {
            final pair = q.pairs![index];
            final rights = q.pairs!.map((p) => p.right).toList();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(child: Text(pair.left)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: answers[q.id]?[index],
                      hint: const Text('Match'),
                      items: rights.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) {
                        setState(() {
                          final current = Map<int, String>.from(answers[q.id] ?? {});
                          current[index] = v!;
                          answers[q.id] = current;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        );
    }
  }
}
