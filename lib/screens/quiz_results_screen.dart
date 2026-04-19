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
              const Text('Quiz Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 32),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: lastResult.percentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(Color(settings.accent)),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${lastResult.percentage.round()}%',
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '${lastResult.score.round()} / ${lastResult.totalQuestions}',
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              GlowCard(
                child: Column(
                  children: [
                    _ResultStatRow(label: 'Correct', value: lastResult.score.round().toString(), color: Colors.greenAccent),
                    const Divider(color: Colors.white10),
                    _ResultStatRow(label: 'Incorrect', value: (lastResult.totalQuestions - lastResult.score).round().toString(), color: Colors.redAccent),
                    const Divider(color: Colors.white10),
                    _ResultStatRow(label: 'Time Spent', value: '2:30', color: Colors.blueAccent),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Question Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              ..._buildQuestionReview(ref),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Back to Home'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go('/quiz-config'),
                      child: const Text('New Quiz'),
                    ),
                  ),
                ],
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

    return quiz.questions.map((q) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q.prompt, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Explanation: ${q.explanation}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showExplanationDialog(ref, q),
                  icon: const Icon(Icons.psychology, size: 18),
                  label: const Text('Ask AI to Explain'),
                ),
              ),
            ],
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

  const _ResultStatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
