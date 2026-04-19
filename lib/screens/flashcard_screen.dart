import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  const FlashcardScreen({super.key, required this.flashcards});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;

  void _next() {
    if (_currentIndex < widget.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.flashcards[_currentIndex];

    return AppShell(
      title: 'Flashcards',
      subtitle: '${_currentIndex + 1} / ${widget.flashcards.length}',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isFlipped = !_isFlipped),
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: _isFlipped ? 180 : 0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, double val, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(val * 0.0174533),
                      child: val < 90
                          ? _buildCardSide(card.front, 'Front')
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(180 * 0.0174533),
                              child: _buildCardSide(card.back, 'Back', isBack: true),
                            ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(
                  onPressed: _currentIndex > 0 ? _prev : null,
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 32,
                ),
                Text(
                  'Tap to flip',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                IconButton.filledTonal(
                  onPressed: _currentIndex < widget.flashcards.length - 1 ? _next : null,
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide(String text, String label, {bool isBack = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBack
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF3B0764), const Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isBack ? Colors.blueAccent : const Color(0xFFA78BFA)).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(
          color: (isBack ? Colors.blueAccent : const Color(0xFFA78BFA)).withOpacity(0.5),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isBack ? 20 : 26,
                    fontWeight: isBack ? FontWeight.w400 : FontWeight.bold,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
