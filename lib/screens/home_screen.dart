import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('🎯', 'Generate Quiz', 'MCQ, fill-in-blank, matching & true/false', '/quiz-config'),
      ('📝', 'Reviewer Notes', 'AI-structured study notes with key concepts', '/history'),
      ('🗂️', 'Flashcards', 'Flip cards to test memory', '/history'),
      ('💬', 'Chat with AI', 'Ask questions about your materials', '/session'),
    ];

    return AppShell(
      title: 'What would you like to do?',
      subtitle: 'Study Tools',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlowCard(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: items
                .map(
                  (e) => InkWell(
                    onTap: () => context.go(e.$4),
                    child: GlowCard(
                      padding: const EdgeInsets.all(10),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(e.$1, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text(e.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(e.$3, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ]),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
