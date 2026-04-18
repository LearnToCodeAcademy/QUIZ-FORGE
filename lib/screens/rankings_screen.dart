import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class RankingsScreen extends StatelessWidget {
  const RankingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const top3 = [
      ('RYAN CHESTER MEDALLO', 1, 'R'),
      ('PRINCE MARL LIZANDRELLE MIRASOL', 3, 'P'),
      ('John', 0, 'J'),
    ];
    return AppShell(
      title: 'Leaderboard',
      subtitle: 'Top users ranked by file uploads',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlowCard(
          child: Column(children: [
            Row(
              children: top3
                  .map((u) => Expanded(
                        child: Column(children: [
                          CircleAvatar(radius: 24, child: Text(u.$3)),
                          const SizedBox(height: 8),
                          Text(u.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('${u.$2} files', style: const TextStyle(color: Colors.white60)),
                        ]),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const ListTile(title: Text('#4 mr cooking beginners'), trailing: Text('0 files')),
          ]),
        ),
      ),
    );
  }
}
