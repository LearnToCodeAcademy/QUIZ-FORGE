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
  String type = 'Multiple Choice';
  int count = 10;
  String diff = 'Medium';

  @override
  Widget build(BuildContext context) {
    final quizGen = ref.watch(quizGenerationProvider);
    final appState = ref.watch(appStateProvider);
    final progress = ref.watch(generationProgressProvider);
    final appNotifier = ref.read(appStateProvider.notifier);
    final settings = appState.settings;

    return AppShell(
      title: 'Configure Quiz',
      subtitle: 'Customize your AI-generated exam',
      overlay: quizGen.isLoading ? LoadingOverlay(message: 'Forging your quiz...', progress: progress) : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FadeInUp(
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
                        const Text('AI Model', style: TextStyle(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.bold)),
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
                const Text('Active Source', style: TextStyle(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: Color(0xFFA78BFA), size: 18),
                      const SizedBox(width: 12),
                      Expanded(child: Text(appState.files.last.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 24),
              ],

              const Text('Quiz Type', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ['Multiple Choice', 'True / False', 'Fill in the Blank', 'Mixed', 'Identification', 'Matching']
                      .map((e) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ChoiceChip(
                          label: Text(e, style: TextStyle(fontSize: 12, fontWeight: type == e ? FontWeight.bold : FontWeight.normal)),
                          selected: type == e,
                          onSelected: (_) => setState(() => type = e),
                          backgroundColor: Colors.transparent,
                          selectedColor: const Color(0xFFA78BFA).withOpacity(0.2),
                          side: BorderSide(color: type == e ? const Color(0xFFA78BFA) : Colors.white10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ))
                      .toList()),
              const SizedBox(height: 24),
              const Text('Number of Questions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                  spacing: 10,
                  children: [5, 10, 20, 30]
                      .map((e) => ChoiceChip(
                          label: Text('$e', style: const TextStyle(fontSize: 12)),
                          selected: count == e,
                          onSelected: (_) => setState(() => count = e),
                          backgroundColor: Colors.transparent,
                          selectedColor: const Color(0xFFA78BFA).withOpacity(0.2),
                          side: BorderSide(color: count == e ? const Color(0xFFA78BFA) : Colors.white10),
                        ))
                      .toList()),
              const SizedBox(height: 24),
              const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                  spacing: 10,
                  children: ['Easy', 'Medium', 'Hard']
                      .map((e) => ChoiceChip(
                          label: Text(e, style: const TextStyle(fontSize: 12)),
                          selected: diff == e,
                          onSelected: (_) => setState(() => diff = e),
                          backgroundColor: Colors.transparent,
                          selectedColor: const Color(0xFFA78BFA).withOpacity(0.2),
                          side: BorderSide(color: diff == e ? const Color(0xFFA78BFA) : Colors.white10),
                        ))
                      .toList()),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('GENERATE QUIZ', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Color(settings.accent),
                    elevation: 12,
                    shadowColor: Color(settings.accent).withOpacity(0.5),
                  ),
                  onPressed: quizGen.isLoading ? null : () async {
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
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
