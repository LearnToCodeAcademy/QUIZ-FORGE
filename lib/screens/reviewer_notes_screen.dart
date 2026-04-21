import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class ReviewerNotesScreen extends ConsumerStatefulWidget {
  final String content;
  const ReviewerNotesScreen({super.key, required this.content});

  @override
  ConsumerState<ReviewerNotesScreen> createState() => _ReviewerNotesScreenState();
}

class _ReviewerNotesScreenState extends ConsumerState<ReviewerNotesScreen> {
  late String formattedContent;

  @override
  void initState() {
    super.initState();
    formattedContent = _formatContent(widget.content);
  }

  String _formatContent(String raw) {
    // Advanced cleaning of markdown symbols
    return raw
        .replaceAll(RegExp(r'#+\s*'), '')      // Remove headers
        .replaceAll(RegExp(r'\*\*'), '')       // Remove bold
        .replaceAll(RegExp(r'__'), '')         // Remove underline
        .replaceAll(RegExp(r'`'), '')          // Remove code ticks
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Normalize newlines
        .replaceAll(RegExp(r'^\s*[\*•-]\s*', multiLine: true), '• ') // Standardize bullets
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Study Guide',
      subtitle: 'AI-Structured Reviewer',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat', extra: widget.content),
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.psychology_rounded),
        label: const Text('Ask QuizForge AI', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: FadeInUp(
          child: GlowCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 10),
                      const Text('Reviewer Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      _ExportButton(label: 'PDF', icon: Icons.picture_as_pdf, color: Colors.redAccent.withOpacity(0.2), onColor: Colors.redAccent),
                      const SizedBox(width: 8),
                      _ExportButton(label: 'DOC', icon: Icons.description, color: Colors.blueAccent.withOpacity(0.2), onColor: Colors.blueAccent),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: SelectableText(
                      formattedContent,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 15,
                        height: 1.8,
                        letterSpacing: 0.3,
                        fontFamily: 'Roboto', // Cleaner reading font
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color onColor;

  const _ExportButton({required this.label, required this.icon, required this.color, required this.onColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exporting to $label...'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: onColor.withOpacity(0.8),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 14, color: onColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: onColor)),
          ],
        ),
      ),
    );
  }
}
