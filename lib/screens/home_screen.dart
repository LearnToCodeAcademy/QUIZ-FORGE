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
          SnackBar(content: Text('Uploaded ${file.name}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flashcardState = ref.watch(flashcardGenerationProvider);
    final reviewerState = ref.watch(reviewerNotesGenerationProvider);
    final appState = ref.watch(appStateProvider);
    final appNotifier = ref.read(appStateProvider.notifier);

    final String contentToUse = appState.files.isNotEmpty ? "Content from ${appState.files.last.name}" : demoContent;

    return AppShell(
      title: 'What would you like to do?',
      subtitle: 'Study Tools',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // AI Model Quick Switch
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: GlowCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.white70),
                  const SizedBox(width: 12),
                  const Text('AI Model:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: appState.settings.aiModel,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: const Color(0xFF1A1F3D),
                      items: ['Grok', 'Google Gemini'].map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m, style: const TextStyle(color: Colors.white)),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          appNotifier.setSettings(appState.settings.copyWith(aiModel: val));
                        }
                      },
                    ),
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
                          Icon(Icons.folder_open, color: Color(0xFFA78BFA)),
                          SizedBox(width: 8),
                          Text('Source Materials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFFA78BFA), size: 28),
                        onPressed: _pickFile,
                      ),
                    ],
                  ),
                  if (appState.files.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.white54),
                          SizedBox(width: 8),
                          Expanded(child: Text('No files uploaded. Using default demo text to demonstrate AI generation.', style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4))),
                        ],
                      ),
                    )
                  else
                    ...appState.files.map((f) => Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file, size: 20, color: Colors.blueAccent),
                        title: Text(f.name, style: const TextStyle(fontSize: 14)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                          onPressed: () => appNotifier.deleteFile(f),
                        ),
                      ),
                    )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(delay: const Duration(milliseconds: 300), child: const Text("Study Tools", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildToolCard(
                  '🎯', 'Generate Quiz', 'MCQ, fill-in-blank, matching & T/F',
                  () => context.go('/quiz-config'),
                ),
                _buildToolCard(
                  '📝', 'Reviewer Notes',
                  reviewerState.isLoading ? 'Generating...' : 'AI-structured study notes',
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
                  '🗂️', 'Flashcards',
                  flashcardState.isLoading ? 'Generating...' : 'Flip cards to test memory',
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
                  '💬', 'Chat with AI', 'Ask questions about materials',
                  () => context.go('/chat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(String emoji, String title, String subtitle, VoidCallback onTap) {
    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFA78BFA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Expanded(child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.3))),
        ],
      ),
    );
  }
}
