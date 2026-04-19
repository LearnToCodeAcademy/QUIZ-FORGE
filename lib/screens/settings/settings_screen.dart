import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_state.dart';
import '../../state/auth_state.dart';
import '../../models/models.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ui_parts.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final grokCtrl = TextEditingController();
  final geminiCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final settings = state.settings;
    grokCtrl.text = settings.grokKey;
    geminiCtrl.text = settings.geminiKey;
    final colors = [0xFF8B5CF6, 0xFF60A5FA, 0xFF4ADE80, 0xFFF97316, 0xFFEC4899, 0xFF6366F1, 0xFF94A3B8];
    final fonts = ['Inter', 'Roboto', 'Open Sans', 'Lato', 'Montserrat', 'Nunito', 'Playfair Display', 'Source Code Pro', 'Poppins', 'Merriweather'];

    return AppShell(
      title: 'Settings',
      subtitle: 'Customize your QuizForge experience',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlowCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🎨 Theme Color', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: colors.map((c) => GestureDetector(onTap: () => notifier.setSettings(settings.copyWith(accent: c)), child: CircleAvatar(backgroundColor: Color(c), child: settings.accent == c ? const Icon(Icons.check, color: Colors.white) : null))).toList()),
            ]),
          ),
          const SizedBox(height: 12),
          GlowCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🔠 Font Style', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fonts
                    .map((f) => ChoiceChip(
                          label: Text(f),
                          selected: settings.fontFamily == f,
                          onSelected: (_) => notifier.setSettings(settings.copyWith(fontFamily: f)),
                        ))
                    .toList(),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          GlowCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📝 Quiz Settings', style: TextStyle(fontWeight: FontWeight.w700)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Allow Going Back to Previous Questions'),
                subtitle: const Text('When off, you can only move forward during quizzes.'),
                value: settings.allowBack,
                onChanged: (v) => notifier.setSettings(settings.copyWith(allowBack: v)),
              ),
              Row(children: [
                const Text('Per-Question Timer'),
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    initialValue: '${settings.perQuestionTimer}',
                    decoration: const InputDecoration(suffixText: 'sec'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => notifier.setSettings(settings.copyWith(perQuestionTimer: int.tryParse(v) ?? 0)),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          GlowCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🤖 Choose AI Model', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: ChoiceChip(label: const Text('Grok'), selected: settings.aiModel == 'Grok', onSelected: (_) => notifier.setSettings(settings.copyWith(aiModel: 'Grok')))),
                const SizedBox(width: 8),
                Expanded(child: ChoiceChip(label: const Text('Google Gemini'), selected: settings.aiModel == 'Google Gemini', onSelected: (_) => notifier.setSettings(settings.copyWith(aiModel: 'Google Gemini')))),
              ]),
              const SizedBox(height: 10),
              TextField(controller: grokCtrl, decoration: const InputDecoration(labelText: 'Grok (xAI) API Key')),
              const SizedBox(height: 8),
              TextField(controller: geminiCtrl, decoration: const InputDecoration(labelText: 'Google Gemini API Key')),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => notifier.setSettings(
                  settings.copyWith(grokKey: grokCtrl.text.trim(), geminiKey: geminiCtrl.text.trim()),
                ),
                child: const Text('Save API Keys'),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          GlowCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('⚠️ Danger Zone', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.redAccent)),
              const Text('Clear all saved data including settings, API keys, and preferences.'),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () {
                      notifier.setSettings(const AppSettings());
                    },
                    child: const Text('Reset Settings'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).signOut();
                    },
                    child: const Text('Sign Out'),
                  ),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
