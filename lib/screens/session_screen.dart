import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(appStateProvider).sessions;
    return AppShell(
      title: 'Current Session',
      subtitle: 'Your active tasks and recent activity',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const GlowCard(child: ListTile(title: Text('NO ACTIVE TASK'), subtitle: Text('Start a quiz, reviewer, or chat session from home.'))),
            const SizedBox(height: 12),
            Expanded(
              child: GlowCard(
                child: sessions.isEmpty
                    ? const EmptyState(message: 'No sessions yet. Complete a quiz to see it here.', icon: Icons.assignment_outlined)
                    : ListView(
                        children: sessions
                            .map((s) => ListTile(title: Text(s.title), subtitle: Text(s.subtitle), trailing: Text('${s.time.hour}:${s.time.minute.toString().padLeft(2, '0')}')))
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
