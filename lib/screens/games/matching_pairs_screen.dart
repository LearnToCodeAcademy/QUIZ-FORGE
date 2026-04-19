import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ui_parts.dart';
import '../../models/quiz_models.dart';
import '../../state/quiz_state.dart';

class MatchingPairsScreen extends ConsumerStatefulWidget {
  const MatchingPairsScreen({super.key});

  @override
  ConsumerState<MatchingPairsScreen> createState() => _MatchingPairsScreenState();
}

class CardModel {
  final String id;
  final int pairId;
  final String text;
  final String side; // 'term' or 'def'
  String status; // 'hidden', 'flipped', 'matched'

  CardModel({
    required this.id,
    required this.pairId,
    required this.text,
    required this.side,
    this.status = 'hidden',
  });
}

class _MatchingPairsScreenState extends ConsumerState<MatchingPairsScreen> {
  List<CardModel> cards = [];
  List<String> flippedIds = [];
  int matches = 0;
  int attempts = 0;
  bool done = false;
  int timeElapsed = 0;
  bool locked = false;
  Timer? timer;
  int totalPairs = 0;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    final quiz = ref.read(quizGenerationProvider).value;
    if (quiz == null) return;

    List<Map<String, String>> pairs = [];
    for (var q in quiz.questions) {
      if (pairs.length >= 8) break;
      if (q.type == QuestionType.matching && q.pairs != null) {
        for (var p in q.pairs!) {
          if (pairs.length >= 8) break;
          pairs.add({'term': p.left, 'def': p.right});
        }
      } else if ((q.type == QuestionType.mcq || q.type == QuestionType.true_false) && q.choices != null && q.answerIndex != null) {
        String term = q.prompt.replaceAll(RegExp(r'^(what is |define |which )', caseSensitive: false), '').replaceAll('?', '').trim();
        if (term.length > 60) continue;
        pairs.add({'term': term, 'def': q.choices![q.answerIndex!]});
      } else if (q.answers != null && q.answers!.isNotEmpty && q.prompt.length <= 80) {
        pairs.add({'term': q.prompt.replaceAll('?', '').trim(), 'def': q.answers![0]});
      }
    }

    if (pairs.length < 2) return;

    totalPairs = pairs.length;
    List<CardModel> newCards = [];
    for (int i = 0; i < pairs.length; i++) {
      newCards.add(CardModel(id: 't$i', pairId: i, text: pairs[i]['term']!, side: 'term'));
      newCards.add(CardModel(id: 'd$i', pairId: i, text: pairs[i]['def']!, side: 'def'));
    }
    newCards.shuffle();

    setState(() {
      cards = newCards;
      matches = 0;
      attempts = 0;
      done = false;
      timeElapsed = 0;
      flippedIds = [];
      locked = false;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => timeElapsed++));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void handleCardClick(String id) {
    if (locked) return;
    final cardIdx = cards.indexWhere((c) => c.id == id);
    if (cardIdx == -1 || cards[cardIdx].status != 'hidden' || flippedIds.contains(id)) return;

    setState(() {
      cards[cardIdx].status = 'flipped';
      flippedIds.add(id);
    });

    if (flippedIds.length == 2) {
      setState(() {
        attempts++;
        locked = true;
      });

      final cardA = cards.firstWhere((c) => c.id == flippedIds[0]);
      final cardB = cards.firstWhere((c) => c.id == flippedIds[1]);

      if (cardA.pairId == cardB.pairId && cardA.side != cardB.side) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            cardA.status = 'matched';
            cardB.status = 'matched';
            matches++;
            flippedIds = [];
            locked = false;
            if (matches == totalPairs) {
              done = true;
              timer?.cancel();
            }
          });
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            cardA.status = 'hidden';
            cardB.status = 'hidden';
            flippedIds = [];
            locked = false;
          });
        });
      }
    }
  }

  String formatTime(int s) {
    return '${(s ~/ 60)}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return AppShell(
        title: 'Matching Pairs',
        subtitle: 'Select two cards to find a match',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Not enough pairs to play'),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    if (done) {
      final accuracy = (totalPairs / max(attempts, totalPairs) * 100).round();
      return AppShell(
        title: 'Matching Pairs',
        subtitle: 'Select two cards to find a match',
        child: Center(
          child: GlowCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🧩', style: TextStyle(fontSize: 64)),
                const Text('All Pairs Matched!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('$matches Pairs', style: const TextStyle(fontSize: 32)),
                Text('$accuracy% Accuracy', style: TextStyle(fontSize: 24, color: accuracy >= 70 ? Colors.green : Colors.orange)),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _setupGame, child: const Text('Play Again')),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
              ],
            ),
          ),
        ),
      );
    }

    return AppShell(
      title: 'Matching Pairs',
      subtitle: '$matches / $totalPairs Matched | Attempts: $attempts | Time: ${formatTime(timeElapsed)}',
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return GestureDetector(
              onTap: () => handleCardClick(card.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: card.status == 'matched'
                      ? Colors.green.withOpacity(0.5)
                      : card.status == 'flipped'
                          ? Colors.deepPurple
                          : Colors.deepPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: card.status == 'flipped' ? Colors.white : Colors.white10,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: card.status == 'hidden'
                    ? const Text('?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white24))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            card.side.toUpperCase(),
                            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Center(
                              child: Text(
                                card.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
