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
          GlowCard(
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
          const SizedBox(height: 16),

          // File Upload Section
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('📚 Source Materials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFFA78BFA)),
                      onPressed: _pickFile,
                    ),
                  ],
                ),
                if (appState.files.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No files uploaded. Using demo content.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  )
                else
                  ...appState.files.map((f) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.insert_drive_file, size: 20),
                    title: Text(f.name, style: const TextStyle(fontSize: 14)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      onPressed: () => appNotifier.deleteFile(f),
                    ),
                  )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
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
        ],
      ),
    );
  }

  Widget _buildToolCard(String emoji, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: GlowCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
