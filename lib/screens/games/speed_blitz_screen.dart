import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ui_parts.dart';
import '../../models/quiz_models.dart';
import '../../state/quiz_state.dart';

class SpeedBlitzScreen extends ConsumerStatefulWidget {
  const SpeedBlitzScreen({super.key});

  @override
  ConsumerState<SpeedBlitzScreen> createState() => _SpeedBlitzScreenState();
}

class _SpeedBlitzScreenState extends ConsumerState<SpeedBlitzScreen> {
  static const int timePerQ = 12;
  late List<QuizQuestion> questions;
  int index = 0;
  int score = 0;
  int streak = 0;
  int bestStreak = 0;
  int timeLeft = timePerQ;
  bool done = false;
  String? feedback; // 'correct', 'wrong', 'timeout'
  int? selectedIdx;
  int totalTime = 0;
  Timer? timer;
  Timer? totalTimer;

  @override
  void initState() {
    super.initState();
    final quiz = ref.read(quizGenerationProvider).value;
    questions = (quiz?.questions ?? [])
        .where((q) => (q.type == QuestionType.mcq || q.type == QuestionType.true_false) && q.choices != null && q.answerIndex != null)
        .toList();
    questions.shuffle();

    if (questions.isNotEmpty) {
      startRoundTimer();
      totalTimer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => totalTime++));
    }
  }

  void startRoundTimer() {
    timer?.cancel();
    timeLeft = timePerQ;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (timeLeft <= 1) {
          timeLeft = 0;
          timer?.cancel();
          feedback = 'timeout';
          streak = 0;
          Future.delayed(const Duration(seconds: 1), advance);
        } else {
          timeLeft--;
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    totalTimer?.cancel();
    super.dispose();
  }

  void handleAnswer(int choiceIdx) {
    if (feedback != null) return;
    timer?.cancel();

    setState(() {
      selectedIdx = choiceIdx;
      final q = questions[index];
      if (choiceIdx == q.answerIndex) {
        feedback = 'correct';
        score++;
        streak++;
        if (streak > bestStreak) bestStreak = streak;
      } else {
        feedback = 'wrong';
        streak = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 900), advance);
  }

  void advance() {
    if (!mounted) return;
    setState(() {
      feedback = null;
      selectedIdx = null;
      if (index + 1 >= questions.length) {
        done = true;
        totalTimer?.cancel();
      } else {
        index++;
        startRoundTimer();
      }
    });
  }

  String formatTime(int s) {
    return '${(s ~/ 60)}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return AppShell(
        title: 'Speed Blitz',
        subtitle: 'No questions available',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No MCQ questions found'),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    if (done) {
      final pct = (score / questions.length * 100).round();
      return AppShell(
        title: 'Speed Blitz',
        subtitle: 'No questions available',
        child: Center(
          child: GlowCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 64)),
                const Text('Speed Blitz Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('$score / ${questions.length}', style: const TextStyle(fontSize: 32)),
                Text('$pct%', style: TextStyle(fontSize: 24, color: pct >= 70 ? Colors.green : Colors.orange)),
                const SizedBox(height: 16),
                Text('Best Streak: 🔥 $bestStreak', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      index = 0;
                      score = 0;
                      streak = 0;
                      bestStreak = 0;
                      done = false;
                      totalTime = 0;
                      feedback = null;
                      selectedIdx = null;
                      questions.shuffle();
                      startRoundTimer();
                      totalTimer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => totalTime++));
                    });
                  },
                  child: const Text('Play Again'),
                ),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
              ],
            ),
          ),
        ),
      );
    }

    final q = questions[index];
    final timerPct = timeLeft / timePerQ;
    final timerColor = timerPct > 0.6 ? Colors.green : timerPct > 0.3 ? Colors.orange : Colors.red;

    return AppShell(
      title: 'Speed Blitz',
      subtitle: '${index + 1} / ${questions.length} | Score: $score | Time: ${formatTime(totalTime)}',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                ),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  height: 8,
                  width: MediaQuery.of(context).size.width * 0.8 * timerPct,
                  decoration: BoxDecoration(color: timerColor, borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${timeLeft}s ${feedback == 'timeout' ? '— Time\'s up!' : ''}',
              textAlign: TextAlign.center,
              style: TextStyle(color: timerColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GlowCard(
              child: Column(
                children: [
                  if (streak >= 2) Text('🔥 $streak STREAK', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(q.prompt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(q.choices?.length ?? 0, (ci) {
              bool isCorrect = ci == q.answerIndex;
              bool isSelected = ci == selectedIdx;

              Color? bgColor;
              if (feedback != null) {
                if (isCorrect) {
                  bgColor = Colors.green.withOpacity(0.3);
                } else if (isSelected) {
                  bgColor = Colors.red.withOpacity(0.3);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => handleAnswer(ci),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: bgColor ?? Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: feedback != null
                            ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.white10))
                            : Colors.white10,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.deepPurple,
                          child: Text(String.fromCharCode(65 + ci), style: const TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(q.choices![ci])),
                        if (feedback != null && isCorrect) const Icon(Icons.check, color: Colors.green),
                        if (feedback != null && isSelected && !isCorrect) const Icon(Icons.close, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
