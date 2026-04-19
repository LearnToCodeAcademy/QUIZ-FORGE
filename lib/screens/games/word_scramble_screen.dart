import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ui_parts.dart';
import '../../models/quiz_models.dart';
import '../../state/quiz_state.dart';

class WordScrambleScreen extends ConsumerStatefulWidget {
  const WordScrambleScreen({super.key});

  @override
  ConsumerState<WordScrambleScreen> createState() => _WordScrambleScreenState();
}

class _WordScrambleScreenState extends ConsumerState<WordScrambleScreen> {
  late List<Map<String, dynamic>> questions;
  int index = 0;
  List<int> selected = [];
  List<int> used = [];
  int score = 0;
  bool done = false;
  String status = 'idle'; // idle, correct, wrong
  int timeElapsed = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    final quiz = ref.read(quizGenerationProvider).value;
    questions = _buildScrambleQuestions(quiz);
    timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => timeElapsed++));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildScrambleQuestions(Quiz? quiz) {
    if (quiz == null) return [];
    List<Map<String, dynamic>> qs = [];
    for (var q in quiz.questions) {
      String answer = "";
      if (q.type == QuestionType.mcq && q.choices != null && q.answerIndex != null) {
        answer = q.choices![q.answerIndex!];
      } else if (q.type == QuestionType.true_false && q.choices != null && q.answerIndex != null) {
        answer = q.choices![q.answerIndex!];
      } else if (q.answers != null && q.answers!.isNotEmpty) {
        answer = q.answers![0];
      }

      if (answer.isEmpty || answer.length < 3) continue;

      List<String> letters = answer.replaceAll(' ', '_').split('');
      // Secure shuffle
      letters.shuffle();
      qs.add({
        'prompt': q.prompt,
        'answer': answer,
        'letters': letters,
      });
    }
    return qs;
  }

  void handleLetterClick(int li) {
    if (status != 'idle') return;
    if (used.contains(li)) return;

    setState(() {
      selected.add(li);
      used.add(li);

      final q = questions[index];
      String assembled = selected.map((si) => q['letters'][si].replaceAll('_', ' ')).join('');

      if (assembled.length == q['answer'].length) {
        if (assembled.toLowerCase() == q['answer'].toString().toLowerCase()) {
          status = 'correct';
          score++;
          Future.delayed(const Duration(milliseconds: 900), advance);
        } else {
          status = 'wrong';
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!mounted) return;
            setState(() {
              selected = [];
              used = [];
              status = 'idle';
            });
          });
        }
      }
    });
  }

  void advance() {
    if (!mounted) return;
    setState(() {
      status = 'idle';
      selected = [];
      used = [];
      if (index + 1 >= questions.length) {
        done = true;
        timer?.cancel();
      } else {
        index++;
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
        title: 'Word Scramble',
        subtitle: 'No words found',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No scrambleable answers found'),
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
        title: 'Word Scramble',
        subtitle: 'No words found',
        child: Center(
          child: GlowCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🧩', style: TextStyle(fontSize: 64)),
                const Text('Word Scramble Done!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('$score / ${questions.length}', style: const TextStyle(fontSize: 32)),
                Text('$pct%', style: TextStyle(fontSize: 24, color: pct >= 70 ? Colors.green : Colors.orange)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      index = 0;
                      score = 0;
                      done = false;
                      timeElapsed = 0;
                      selected = [];
                      used = [];
                      status = 'idle';
                      timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => timeElapsed++));
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
    final assembled = selected.map((si) => q['letters'][si].replaceAll('_', ' ')).join('');

    return AppShell(
      title: 'Word Scramble',
      subtitle: '${index + 1} / ${questions.length} | Score: $score | Time: ${formatTime(timeElapsed)}',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlowCard(
              child: Column(
                children: [
                  Text('QUESTION ${index + 1}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(q['prompt'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: status == 'correct' ? Colors.green.withValues(alpha: 0.2) : status == 'wrong' ? Colors.red.withValues(alpha: 0.2) : Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: status == 'correct' ? Colors.green : status == 'wrong' ? Colors.red : Colors.white10,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                assembled.isEmpty ? 'Tap letters below...' : assembled,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: assembled.isEmpty ? Colors.white30 : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(q['letters'].length, (li) {
                final isUsed = used.contains(li);
                return GestureDetector(
                  onTap: () => handleLetterClick(li),
                  child: Opacity(
                    opacity: isUsed ? 0.3 : 1.0,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [if (!isUsed) const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        q['letters'][li] == '_' ? '⎵' : q['letters'][li],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: selected.isEmpty || status != 'idle' ? null : () {
                      setState(() {
                        int last = selected.removeLast();
                        used.remove(last);
                      });
                    },
                    child: const Text('Remove'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: selected.isEmpty || status != 'idle' ? null : () {
                      setState(() {
                        selected = [];
                        used = [];
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: status != 'idle' ? null : advance,
                    child: const Text('Skip'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
