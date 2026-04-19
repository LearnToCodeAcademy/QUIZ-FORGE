import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_models.dart';
import '../state/quiz_state.dart';
import '../state/app_state.dart';
import '../widgets/ui_parts.dart';

class QuizResultsScreen extends ConsumerWidget {
  const QuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(quizResultsProvider);
    if (results.isEmpty) return const Scaffold(body: Center(child: Text('No results found')));

    final lastResult = results.last;
    final settings = ref.watch(appStateProvider).settings;

    return Scaffold(
      backgroundColor: const Color(0xFF050924),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              FadeInUp(
                child: const Text('Quiz Complete!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: lastResult.percentage / 100),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 16,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            valueColor: AlwaysStoppedAnimation(
                              value >= 0.8 ? Colors.greenAccent : (value >= 0.5 ? Colors.orangeAccent : Colors.redAccent),
                            ),
                          );
                        },
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: lastResult.percentage),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Column(
                          children: [
                            Text(
                              '${value.round()}%',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: value >= 80 ? Colors.greenAccent : (value >= 50 ? Colors.orangeAccent : Colors.redAccent),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${lastResult.score.round()} / ${lastResult.totalQuestions}',
                              style: const TextStyle(fontSize: 16, color: Colors.white54, fontWeight: FontWeight.w600, letterSpacing: 1),
                            ),
                          ],
                        );
                      }
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: GlowCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _ResultStatRow(label: 'Correct Answers', value: lastResult.score.round().toString(), color: Colors.greenAccent, icon: Icons.check_circle),
                      Divider(color: Colors.white.withOpacity(0.1), height: 24),
                      _ResultStatRow(label: 'Incorrect Answers', value: (lastResult.totalQuestions - lastResult.score).round().toString(), color: Colors.redAccent, icon: Icons.cancel),
                      Divider(color: Colors.white.withOpacity(0.1), height: 24),
                      const _ResultStatRow(label: 'Completion Time', value: '2:30', color: Colors.blueAccent, icon: Icons.timer),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Question Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 16),
              ..._buildQuestionReview(ref),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => context.go('/home'),
                        child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFA78BFA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => context.go('/quiz-config'),
                        child: const Text('New Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  List<Widget> _buildQuestionReview(WidgetRef ref) {
    final quiz = ref.watch(quizGenerationProvider).value;
    if (quiz == null) return [];

    int index = 0;
    return quiz.questions.map((q) {
      index++;
      return FadeInUp(
        delay: Duration(milliseconds: 300 + (index * 50)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlowCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFA78BFA).withOpacity(0.1), shape: BoxShape.circle),
                      child: Text('$index', style: const TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(q.prompt, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, height: 1.4)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.05),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.greenAccent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(q.explanation, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFA78BFA),
                      backgroundColor: const Color(0xFFA78BFA).withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () => _showExplanationDialog(ref, q),
                    icon: const Icon(Icons.psychology, size: 18),
                    label: const Text('Ask AI to Explain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showExplanationDialog(WidgetRef ref, QuizQuestion q) {
    showDialog(
      context: ref.context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final explanation = ref.watch(explanationProvider);

          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F3D),
            title: const Text('AI Explanation', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: explanation.when(
                data: (text) => Text(text ?? 'No explanation available.', style: const TextStyle(color: Colors.white70)),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          );
        },
      ),
    );

    // Trigger explanation
    ref.read(explanationProvider.notifier).explain(
          question: q.prompt,
          userAnswer: "User selected index/value", // In a real app, pass the actual user answer
          correctAnswer: q.explanation,
          context: "Quiz on AI-generated content",
        );
  }
}

class _ResultStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ResultStatRow({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
