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
  int totalTimeSpent = 0;
  Timer? timer;
  Timer? globalTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
      _startGlobalTimer();
    });
  }

  void _startGlobalTimer() {
    globalTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      totalTimeSpent++;
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

    // Check if answer is provided (for non-timer mode validation if needed)
    if (answers[quiz.questions[currentIndex].id] == null && ref.read(appStateProvider).settings.perQuestionTimer == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer before proceeding')),
      );
      return;
    }

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
    globalTimer?.cancel();
    final quiz = ref.read(quizGenerationProvider).value;
    if (quiz == null) return;

    final result = ScoringService.scoreQuiz(quiz, answers);
    // Add custom time spent info to extra if needed, or rely on internal logic
    ref.read(quizResultsProvider.notifier).addResult(result);

    // Store time spent in a temp state or pass through extra
    context.pushReplacement('/results', extra: totalTimeSpent);
  }

  @override
  void dispose() {
    timer?.cancel();
    globalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizGenerationProvider).value;
    if (quiz == null) return const Scaffold(body: Center(child: Text('No quiz loaded')));

    final q = quiz.questions[currentIndex];
    final settings = ref.watch(appStateProvider).settings;

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: SafeArea(
        child: Column(
          children: [
            // Header Progress
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => context.go('/home'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentIndex + 1} / ${quiz.questions.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFA78BFA)),
                        ),
                      ),
                      if (settings.perQuestionTimer > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: timeLeft <= 5 ? Colors.redAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: timeLeft <= 5 ? Colors.redAccent.withOpacity(0.5) : Colors.greenAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.timer, size: 16, color: timeLeft <= 5 ? Colors.redAccent : Colors.greenAccent),
                              const SizedBox(width: 6),
                              Text(
                                '${timeLeft}s',
                                style: TextStyle(
                                  color: timeLeft <= 5 ? Colors.redAccent : Colors.greenAccent,
                                  fontWeight: FontWeight.w900,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (currentIndex + 1) / quiz.questions.length,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFA78BFA)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeInUp(
                  key: ValueKey(currentIndex),
                  beginOffset: 0.05,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlowCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA78BFA).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    q.type.name.toUpperCase().replaceAll('_', ' '),
                                    style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              q.prompt,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
                            ),
                            const SizedBox(height: 32),
                            _renderQuestionInput(q),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF121C44),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  if (settings.allowBack && currentIndex > 0)
                    Expanded(
                      flex: 1,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() => currentIndex--);
                          _startTimer();
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white54),
                        label: const Text('Back', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA78BFA),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _nextQuestion,
                      child: Text(
                        currentIndex == quiz.questions.length - 1 ? 'SUBMIT QUIZ' : 'CONTINUE →',
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ),
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
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => answers[q.id] = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFA78BFA).withOpacity(0.15) : Colors.white.withOpacity(0.03),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFA78BFA) : Colors.white.withOpacity(0.08),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? const Color(0xFFA78BFA) : Colors.white24, width: 2),
                          color: isSelected ? const Color(0xFFA78BFA) : Colors.transparent,
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : Center(child: Text(String.fromCharCode(65 + index), style: const TextStyle(fontSize: 12, color: Colors.white24, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Text(choice, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.white70))),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFA78BFA), width: 2)),
          ),
          onChanged: (v) => answers[q.id] = v,
        );
      case QuestionType.matching:
        return Column(
          children: List.generate(q.pairs?.length ?? 0, (index) {
            final pair = q.pairs![index];
            final rights = q.pairs!.map((p) => p.right).toList();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(child: Text(pair.left, style: const TextStyle(fontWeight: FontWeight.w500))),
                    const Icon(Icons.link, color: Colors.white24, size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButton<String>(
                          value: answers[q.id]?[index],
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text('Match', style: TextStyle(fontSize: 12, color: Colors.white24)),
                          items: rights.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (v) {
                            setState(() {
                              final current = Map<int, String>.from(answers[q.id] ?? {});
                              current[index] = v!;
                              answers[q.id] = current;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
    }
  }
}
