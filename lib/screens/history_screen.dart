import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      title: 'Activity History',
      subtitle: 'Your recent actions and events',
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GlowCard(
          child: EmptyState(message: 'No activity yet. Start using QuizForge to build your history!', icon: Icons.history),
        ),
      ),
    );
  }
}
