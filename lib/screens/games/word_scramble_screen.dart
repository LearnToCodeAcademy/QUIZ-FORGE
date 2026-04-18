import 'package:flutter/material.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ui_parts.dart';

class WordScrambleScreen extends StatelessWidget {
  const WordScrambleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const letters = ['c', 'y', 't', 'r', 'o', 'i', 'g', 'h', 'p'];
    return AppShell(
      title: 'Word Scramble',
      subtitle: 'Tap the letters in the correct order to form the answer',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlowCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('QUESTION 1', textAlign: TextAlign.center),
            const SizedBox(height: 10),
            const Text('Which type of intellectual property protection exists from the moment of creation?', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(height: 48, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: const Text('Tap letters below...')),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: letters.map((e) => Chip(label: Text(e))).toList()),
            const Spacer(),
            const Row(children: [OutlinedButton(onPressed: null, child: Text('Remove')), SizedBox(width: 8), OutlinedButton(onPressed: null, child: Text('Clear')), Spacer(), OutlinedButton(onPressed: null, child: Text('Skip'))]),
          ]),
        ),
      ),
    );
  }
}
