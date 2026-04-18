import 'package:flutter/material.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ui_parts.dart';

class ShellGameScreen extends StatelessWidget {
  const ShellGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Shell Game',
      subtitle: 'Watch carefully — remember which cup holds the answer!',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlowCard(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Which cup hides the answer?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Text('🔴', style: TextStyle(fontSize: 64)), Text('🟡', style: TextStyle(fontSize: 64)), Text('🟢', style: TextStyle(fontSize: 64))]),
            const SizedBox(height: 22),
            ElevatedButton(onPressed: () {}, child: const Text('Start Round 1')),
          ]),
        ),
      ),
    );
  }
}
