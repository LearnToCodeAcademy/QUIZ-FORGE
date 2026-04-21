import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../state/quiz_state.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final String demoContent =
      "Flutter is an open-source UI software development kit created by Google. It is used to develop cross platform applications from a single codebase for any web browser, Fuchsia, Android, iOS, Linux, macOS, and Windows. First described in 2015, Flutter was released in May 2017.";

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt', 'json', 'csv', 'md'],
    );

    if (result != null) {
      final file = result.files.single;
      ref.read(appStateProvider.notifier).addFile(UploadedFileMeta(
            name: file.name,
            path: kIsWeb ? null : file.path,
            bytes: file.bytes,
            createdAt: DateTime.now(),
          ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ ${file.name} uploaded successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flashcardState = ref.watch(flashcardGenerationProvider);
    final reviewerState = ref.watch(reviewerNotesGenerationProvider);
    final progress = ref.watch(generationProgressProvider);
    final appState = ref.watch(appStateProvider);
    final appNotifier = ref.read(appStateProvider.notifier);

    final String contentToUse = appState.files.isNotEmpty ? "Content from ${appState.files.last.name}" : demoContent;

    return AppShell(
      title: '${_getGreeting()},',
      subtitle: '${appState.userName.split(' ')[0]}',
      overlay: (flashcardState.isLoading || reviewerState.isLoading)
          ? LoadingOverlay(
              message: flashcardState.isLoading ? 'Forging Flashcards...' : 'Generating Study Guide...',
              progress: progress,
            )
          : null,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        children: [
          // AI Model Quick Switch
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: GlowCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.psychology_rounded, color: Colors.amberAccent, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Engine', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      Text('Powered by Gemini 3.1 Pro', style: TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: appState.settings.aiModel,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    items: ['Grok', 'Google Gemini'].map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        appNotifier.setSettings(appState.settings.copyWith(aiModel: val));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // File Upload Section
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: GlowCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.folder_copy_rounded, color: Color(0xFF38BDF8), size: 18),
                          SizedBox(width: 10),
                          Text('Study Materials', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF38BDF8),
                          backgroundColor: const Color(0xFF38BDF8).withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (appState.files.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.auto_stories_rounded, color: Colors.white.withOpacity(0.1), size: 40),
                          const SizedBox(height: 12),
                          const Text('Drop your lecture notes here', style: TextStyle(color: Colors.white38, fontSize: 13)),
                        ],
                      ),
                    )
                  else
                    ...appState.files.map((f) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.description_rounded, size: 20, color: Color(0xFF38BDF8)),
                        title: Text(f.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text('${(DateTime.now().difference(f.createdAt).inMinutes)}m ago', style: const TextStyle(fontSize: 10, color: Colors.white24)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          onPressed: () => appNotifier.deleteFile(f),
                        ),
                      ),
                    )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const FadeInUp(
            delay: Duration(milliseconds: 300),
            child: Text("Study Dashboard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5))
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildActionCard(
                  '🎯', 'Smart Quiz', 'AI-generated exam', const Color(0xFFF472B6),
                  () => context.go('/quiz-config'),
                ),
                _buildActionCard(
                  '📝', 'Reviewer', 'Guided summaries', const Color(0xFF38BDF8),
                  () async {
                    if (reviewerState.isLoading) return;
                    await ref.read(reviewerNotesGenerationProvider.notifier).generateReviewerNotes(content: contentToUse);
                    final result = ref.read(reviewerNotesGenerationProvider).value;
                    if (result != null && context.mounted) {
                      context.push('/reviewer-notes', extra: result);
                    }
                  }
                ),
                _buildActionCard(
                  '🗂️', 'Flashcards', 'Active recall deck', const Color(0xFFA78BFA),
                  () async {
                    if (flashcardState.isLoading) return;
                    await ref.read(flashcardGenerationProvider.notifier).generateFlashcards(content: contentToUse);
                    final result = ref.read(flashcardGenerationProvider).value;
                    if (result != null && context.mounted) {
                      context.push('/flashcards', extra: result);
                    }
                  }
                ),
                _buildActionCard(
                  '💬', 'AI Tutor', 'Contextual chat', const Color(0xFF34D399),
                  () => context.go('/chat'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionCard(String emoji, String title, String subtitle, Color color, VoidCallback onTap) {
    return GlowCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            right: -10, top: -10,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: color.withOpacity(0.05), shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
