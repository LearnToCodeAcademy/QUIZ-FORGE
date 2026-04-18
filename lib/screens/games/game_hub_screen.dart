import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ui_parts.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Shell Game', 'Watch the cups shuffle — tap the one hiding the correct answer!', '/games/shell'),
      ('Matching Pairs', 'Flip cards and match every term with its definition.', '/games'),
      ('Word Scramble', 'Unscramble key terms letter-by-letter.', '/games/word-scramble'),
      ('Speed Blitz', 'Race the clock — answer MCQ questions fast.', '/games/speed-blitz'),
    ];
    return AppShell(
      title: 'Games',
      subtitle: 'Playful but polished study-game modes',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlowCard(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: items
                .map((e) => InkWell(
                      onTap: () => context.go(e.$3),
                      child: GlowCard(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(e.$1, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(e.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.white60))]),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
