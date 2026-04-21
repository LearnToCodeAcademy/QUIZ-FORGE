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
            content: Text('Uploaded ${file.name}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      title: 'Hi, ${appState.userName.split(' ')[0]}',
      subtitle: 'Ready to study today?',
      overlay: (flashcardState.isLoading || reviewerState.isLoading)
          ? LoadingOverlay(
              message: flashcardState.isLoading ? 'Generating Flashcards...' : 'Forging Reviewer Notes...',
              progress: progress,
            )
          : null,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // AI Model Quick Switch
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: GlowCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: Color(0xFFA78BFA)),
                  const SizedBox(width: 12),
                  const Text('AI Engine', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  DropdownButton<String>(
                    value: appState.settings.aiModel,
                    underline: const SizedBox(),
                    dropdownColor: const Color(0xFF1A1F3D),
                    items: ['Grok', 'Google Gemini'].map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m, style: const TextStyle(color: Colors.white, fontSize: 13)),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.folder_copy_rounded, color: Color(0xFFA78BFA), size: 18),
                          SizedBox(width: 8),
                          Text('Study Materials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFA78BFA).withOpacity(0.1),
                          foregroundColor: const Color(0xFFA78BFA),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: _pickFile,
                      ),
                    ],
                  ),
                  if (appState.files.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.cloud_upload_outlined, color: Colors.white24, size: 32),
                          SizedBox(height: 8),
                          Text('No files yet', style: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('Using default demo content', style: TextStyle(color: Colors.white24, fontSize: 11)),
                        ],
                      ),
                    )
                  else
                    ...appState.files.map((f) => Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.description_rounded, size: 18, color: Color(0xFFA78BFA)),
                        title: Text(f.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.white38),
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
            child: Text("Study Tools", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5))
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.95,
              children: [
                _buildToolCard(
                  '🎯', 'Generate Quiz', 'Test your knowledge with AI',
                  () => context.go('/quiz-config'),
                ),
                _buildToolCard(
                  '📝', 'Reviewer', 'AI-structured notes & summaries',
                  () async {
                    if (reviewerState.isLoading) return;
                    await ref.read(reviewerNotesGenerationProvider.notifier).generateReviewerNotes(content: contentToUse);
                    final result = ref.read(reviewerNotesGenerationProvider).value;
                    if (result != null && context.mounted) {
                      context.push('/reviewer-notes', extra: result);
                    }
                  }
                ),
                _buildToolCard(
                  '🗂️', 'Flashcards', 'Flip cards for quick memorization',
                  () async {
                    if (flashcardState.isLoading) return;
                    await ref.read(flashcardGenerationProvider.notifier).generateFlashcards(content: contentToUse);
                    final result = ref.read(flashcardGenerationProvider).value;
                    if (result != null && context.mounted) {
                      context.push('/flashcards', extra: result);
                    }
                  }
                ),
                _buildToolCard(
                  '💬', 'AI Chat', 'Ask specific questions on content',
                  () => context.go('/chat'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildToolCard(String emoji, String title, String subtitle, VoidCallback onTap) {
    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFA78BFA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.2)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 10, height: 1.3)),
        ],
      ),
    );
  }
}
