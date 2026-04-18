import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class QuizConfigScreen extends StatefulWidget {
  const QuizConfigScreen({super.key});

  @override
  State<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends State<QuizConfigScreen> {
  String type = 'Mixed';
  int count = 10;
  String diff = 'Medium';

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Configure Your Quiz',
      subtitle: 'Customize the quiz type, number of questions, and difficulty level',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlowCard(
          child: ListView(
            children: [
              const Text('Quiz Type'),
              Wrap(spacing: 8, children: ['True / False', 'Fill in the Blank', 'Mixed', 'Identification', 'Matching'].map((e) => ChoiceChip(label: Text(e), selected: type == e, onSelected: (_) => setState(() => type = e))).toList()),
              const SizedBox(height: 16),
              const Text('Number of Questions (max 30)'),
              Wrap(spacing: 8, children: [5, 10, 20, 30].map((e) => ChoiceChip(label: Text('$e'), selected: count == e, onSelected: (_) => setState(() => count = e))).toList()),
              const SizedBox(height: 16),
              const Text('Difficulty'),
              Wrap(spacing: 8, children: ['Easy', 'Medium', 'Hard'].map((e) => ChoiceChip(label: Text(e), selected: diff == e, onSelected: (_) => setState(() => diff = e))).toList()),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () {}, child: const Text('Generate Quiz')),
            ],
          ),
        ),
      ),
    );
  }
}
