import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';
import '../models/quiz_models.dart';
import '../models/models.dart';
import '../state/quiz_state.dart';
import '../state/app_state.dart';

class QuizConfigScreen extends ConsumerStatefulWidget {
  const QuizConfigScreen({super.key});

  @override
  ConsumerState<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends ConsumerState<QuizConfigScreen> {
  String type = 'Mixed';
  int count = 10;
  String diff = 'Medium';

  @override
  Widget build(BuildContext context) {
    final quizGen = ref.watch(quizGenerationProvider);
    final appState = ref.watch(appStateProvider);
    final appNotifier = ref.read(appStateProvider.notifier);
    final settings = appState.settings;

    return AppShell(
      title: 'Configure Your Quiz',
      subtitle: 'Customize the quiz type, number of questions, and difficulty level',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlowCard(
          child: ListView(
            children: [
              // AI Selection at the Top
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI Model', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        DropdownButton<String>(
                          value: settings.aiModel,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: const Color(0xFF1A1F3D),
                          items: ['Grok', 'Google Gemini'].map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              appNotifier.setSettings(settings.copyWith(aiModel: val));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),

              if (appState.files.isNotEmpty) ...[
                const Text('Active Source:', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description, color: Color(0xFFA78BFA)),
                  title: Text(appState.files.last.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                    onPressed: () => appNotifier.deleteFile(appState.files.last),
                  ),
                ),
                const Divider(color: Colors.white10, height: 24),
              ],

              const Text('Quiz Type'),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['True / False', 'Fill in the Blank', 'Mixed', 'Identification', 'Matching']
                      .map((e) => ChoiceChip(label: Text(e), selected: type == e, onSelected: (_) => setState(() => type = e)))
                      .toList()),
              const SizedBox(height: 16),
              const Text('Number of Questions'),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 8,
                  children: [5, 10, 20, 30]
                      .map((e) => ChoiceChip(label: Text('$e'), selected: count == e, onSelected: (_) => setState(() => count = e)))
                      .toList()),
              const SizedBox(height: 16),
              const Text('Difficulty'),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 8,
                  children: ['Easy', 'Medium', 'Hard']
                      .map((e) => ChoiceChip(label: Text(e), selected: diff == e, onSelected: (_) => setState(() => diff = e)))
                      .toList()),
              const SizedBox(height: 32),
              if (quizGen.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Color(settings.accent),
                    ),
                    onPressed: () async {
                      final config = QuizConfig(
                        quizType: type,
                        numQuestions: count,
                        difficulty: diff,
                      );

                      if (appState.files.isNotEmpty) {
                        await ref.read(quizGenerationProvider.notifier).generateQuizFromFile(
                              file: appState.files.last,
                              config: config,
                            );
                      } else {
                        await ref.read(quizGenerationProvider.notifier).generateQuizFromText(
                              content: "Flutter is an open-source UI software development kit created by Google. It is used to develop cross platform applications from a single codebase for any web browser, Fuchsia, Android, iOS, Linux, macOS, and Windows. First described in 2015, Flutter was released in May 2017.",
                              config: config,
                            );
                      }

                      if (ref.read(quizGenerationProvider).hasValue && context.mounted) {
                        context.push('/quiz-player');
                      }
                    },
                    child: const Text('GENERATE QUIZ', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
