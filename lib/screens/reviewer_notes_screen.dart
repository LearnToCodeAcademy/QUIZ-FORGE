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
    // Basic cleaning of markdown symbols if not using a renderer
    return raw
        .replaceAll(RegExp(r'#+\s*'), '') // Remove headers
        .replaceAll(RegExp(r'\*\*'), '') // Remove bold
        .replaceAll(RegExp(r'\*'), '•') // Replace bullet points
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Reviewer Notes',
      subtitle: 'AI-Generated Study Guide',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           context.push('/chat', extra: widget.content);
        },
        backgroundColor: const Color(0xFFA78BFA),
        icon: const Icon(Icons.psychology),
        label: const Text('Ask QuizForge AI'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FadeInUp(
          child: GlowCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_stories, color: Color(0xFFA78BFA), size: 20),
                    const SizedBox(width: 8),
                    const Text('Study Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, color: Colors.white70),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading PDF...')),
                        );
                      },
                      tooltip: 'Download PDF',
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        formattedContent,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
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
