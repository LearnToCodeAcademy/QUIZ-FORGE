import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ui_parts.dart';
import '../../models/quiz_models.dart';
import '../../state/quiz_state.dart';

class ShellGameScreen extends ConsumerStatefulWidget {
  const ShellGameScreen({super.key});

  @override
  ConsumerState<ShellGameScreen> createState() => _ShellGameScreenState();
}

enum ShellPhase { intro, reveal, lower, shuffle, pick, result, done }

class _ShellGameScreenState extends ConsumerState<ShellGameScreen> {
  late List<QuizQuestion> questions;
  int qIndex = 0;
  ShellPhase phase = ShellPhase.intro;
  int score = 0;
  int attempts = 0;
  int totalTime = 0;
  Timer? timer;

  List<int> positions = [0, 1, 2];
  int winnerCup = 0;
  List<int> liftedCups = [];
  int? pickedSlot;
  bool resultCorrect = false;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    final quiz = ref.read(quizGenerationProvider).value;
    questions = quiz?.questions ?? [];
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => totalTime++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startRound() async {
    final random = Random();
    setState(() {
      winnerCup = random.nextInt(3);
      positions = [0, 1, 2];
      liftedCups = [];
      pickedSlot = null;
      isAnimating = true;
      phase = ShellPhase.reveal;
      liftedCups = [winnerCup];
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      phase = ShellPhase.lower;
      liftedCups = [];
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() => phase = ShellPhase.shuffle);

    int shuffleCount = 5 + qIndex * 2;
    if (shuffleCount > 12) shuffleCount = 12;

    for (int i = 0; i < shuffleCount; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      final pairs = [[0, 1], [1, 2], [0, 2]];
      final pair = pairs[random.nextInt(pairs.length)];

      setState(() {
        int cupA = positions.indexOf(pair[0]);
        int cupB = positions.indexOf(pair[1]);
        int temp = positions[cupA];
        positions[cupA] = positions[cupB];
        positions[cupB] = temp;
      });
    }

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      phase = ShellPhase.pick;
      isAnimating = false;
    });
  }

  void handleCupClick(int slot) {
    if (phase != ShellPhase.pick || isAnimating) return;

    setState(() {
      attempts++;
      pickedSlot = slot;
      isAnimating = true;

      int clickedCup = positions.indexOf(slot);
      resultCorrect = (clickedCup == winnerCup);
      if (resultCorrect) score++;

      liftedCups = [winnerCup];
      phase = ShellPhase.result;
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      setState(() => liftedCups = []);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        if (qIndex + 1 >= questions.length) {
          setState(() {
            phase = ShellPhase.done;
            timer?.cancel();
          });
        } else {
          setState(() {
            qIndex++;
            phase = ShellPhase.intro;
            isAnimating = false;
          });
        }
      });
    });
  }

  String formatTime(int s) {
    return '${(s ~/ 60)}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return AppShell(
        title: 'Shell Game',
        subtitle: 'No questions available',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No questions available', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    if (phase == ShellPhase.done) {
      final pct = (score / questions.length * 100).round();
      return AppShell(
        title: 'Shell Game',
        subtitle: 'No questions available',
        child: Center(
          child: GlowCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 64)),
                const Text('Game Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('$score / ${questions.length}', style: const TextStyle(fontSize: 32)),
                Text('$pct%', style: TextStyle(fontSize: 24, color: pct >= 70 ? Colors.green : Colors.orange)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      qIndex = 0;
                      score = 0;
                      attempts = 0;
                      totalTime = 0;
                      phase = ShellPhase.intro;
                      startTimer();
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

    final q = questions[qIndex];
    String answer = '';
    if (q.type == QuestionType.mcq || q.type == QuestionType.true_false) {
      answer = q.choices?[q.answerIndex ?? 0] ?? '';
    } else if (q.answers != null && q.answers!.isNotEmpty) {
      answer = q.answers![0];
    }

    return AppShell(
      title: 'Shell Game',
      subtitle: '${qIndex + 1} / ${questions.length} | Score: $score | Time: ${formatTime(totalTime)}',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlowCard(
              child: Column(
                children: [
                  const Text('Which cup hides the answer?', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(q.prompt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          _buildPhaseBanner(),
          Expanded(
            child: Stack(
              children: [
                // Table surface
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ...List.generate(3, (cupIdx) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    left: MediaQuery.of(context).size.width * (0.1 + positions[cupIdx] * 0.3),
                    bottom: 110,
                    child: _CupWidget(
                      cupIdx: cupIdx,
                      isLifted: liftedCups.contains(cupIdx),
                      isWinner: cupIdx == winnerCup,
                      answer: answer,
                      onTap: () => handleCupClick(positions[cupIdx]),
                      canPick: phase == ShellPhase.pick && !isAnimating,
                      isCorrectReveal: phase == ShellPhase.result && cupIdx == winnerCup,
                      isWrongReveal: phase == ShellPhase.result && pickedSlot == positions[cupIdx] && cupIdx != winnerCup,
                    ),
                  );
                }),
              ],
            ),
          ),
          if (phase == ShellPhase.intro)
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton(
                onPressed: startRound,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                child: Text('Start Round ${qIndex + 1}'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhaseBanner() {
    String text = '';
    Color color = Colors.white;
    switch (phase) {
      case ShellPhase.intro: text = 'Watch carefully!'; break;
      case ShellPhase.reveal: text = 'Remember the cup!'; color = Colors.blue; break;
      case ShellPhase.lower: text = 'Ready...'; break;
      case ShellPhase.shuffle: text = 'SHUFFLING!'; color = Colors.orange; break;
      case ShellPhase.pick: text = 'Tap the cup!'; color = Colors.green; break;
      case ShellPhase.result: text = resultCorrect ? 'CORRECT!' : 'MISSED IT!'; color = resultCorrect ? Colors.green : Colors.red; break;
      default: break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _CupWidget extends StatelessWidget {
  final int cupIdx;
  final bool isLifted;
  final bool isWinner;
  final String answer;
  final VoidCallback onTap;
  final bool canPick;
  final bool isCorrectReveal;
  final bool isWrongReveal;

  const _CupWidget({
    required this.cupIdx,
    required this.isLifted,
    required this.isWinner,
    required this.answer,
    required this.onTap,
    required this.canPick,
    required this.isCorrectReveal,
    required this.isWrongReveal,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.red, Colors.yellow, Colors.green];
    final color = colors[cupIdx % 3];

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        height: 200,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Shadow
            Container(
              width: 60,
              height: 10,
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isLifted ? 0.1 : 0.3), blurRadius: 5, spreadRadius: 2)],
              ),
            ),
            // Ball/Answer
            if (isWinner && (isLifted || isCorrectReveal))
              Positioned(
                bottom: 5,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    answer,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            // Cup
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(bottom: isLifted ? 80 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        if (isCorrectReveal) BoxShadow(color: Colors.green.withValues(alpha: 0.8), blurRadius: 20, spreadRadius: 5),
                        if (isWrongReveal) BoxShadow(color: Colors.red.withValues(alpha: 0.8), blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (canPick)
              Positioned(
                bottom: -10,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
