import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';
// Note: In a real app, I'd add flutter_markdown to pubspec.yaml
// For now, I'll use a simple Text widget or assume Markdown display is handled via a widget.

class ReviewerNotesScreen extends StatelessWidget {
  final String content;
  const ReviewerNotesScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Reviewer Notes',
      subtitle: 'AI-Generated Study Guide',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlowCard(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
