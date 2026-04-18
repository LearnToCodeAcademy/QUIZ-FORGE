import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      title: 'My Bookmarks',
      subtitle: 'Saved quizzes you can review, remix, or download.',
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GlowCard(
          child: EmptyState(message: 'No bookmarks yet. Save quizzes after completing them!'),
        ),
      ),
    );
  }
}
