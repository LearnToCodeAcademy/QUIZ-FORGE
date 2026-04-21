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

    final colors = [
      {'val': 0xFFA78BFA, 'name': 'Violet'},
      {'val': 0xFF38BDF8, 'name': 'Azure'},
      {'val': 0xFF34D399, 'name': 'Emerald'},
      {'val': 0xFFF472B6, 'name': 'Pink'},
      {'val': 0xFFFBBF24, 'name': 'Amber'},
    ];

    final fonts = ['Inter', 'Poppins', 'Roboto', 'Montserrat', 'Merriweather'];

    return AppShell(
      title: 'Settings',
      subtitle: 'Personalize your forge',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        children: [
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(icon: Icons.palette_outlined, title: 'Appearance'),
                  const SizedBox(height: 20),
                  const Text('Theme Accent', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: colors.map((c) => GestureDetector(
                      onTap: () => notifier.setSettings(settings.copyWith(accent: c['val'] as int)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: settings.accent == c['val'] ? Color(c['val'] as int) : Colors.transparent,
                            width: 2
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(c['val'] as int),
                          child: settings.accent == c['val'] ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Typography', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: fonts.map((f) => ChoiceChip(
                      label: Text(f, style: const TextStyle(fontSize: 11)),
                      selected: settings.fontFamily == f,
                      onSelected: (_) => notifier.setSettings(settings.copyWith(fontFamily: f)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(icon: Icons.quiz_outlined, title: 'Quiz Logic'),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Allow Back Navigation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Review previous questions during exam', style: TextStyle(fontSize: 11)),
                    value: settings.allowBack,
                    activeColor: Color(settings.accent),
                    onChanged: (v) => notifier.setSettings(settings.copyWith(allowBack: v)),
                  ),
                  const Divider(color: Colors.white10),
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Question Timer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text('Seconds per question (0 to disable)', style: TextStyle(fontSize: 11, color: Colors.white38)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: '${settings.perQuestionTimer}',
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            suffixText: 's',
                            suffixStyle: const TextStyle(fontSize: 10, color: Colors.white24)
                          ),
                          onChanged: (v) => notifier.setSettings(settings.copyWith(perQuestionTimer: int.tryParse(v) ?? 0)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(icon: Icons.key_outlined, title: 'AI Configuration'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: geminiCtrl,
                    obscureText: true,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Google Gemini API Key',
                      labelStyle: TextStyle(fontSize: 12),
                      hintText: 'AIzaSy...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        notifier.setSettings(settings.copyWith(geminiKey: geminiCtrl.text.trim()));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API Keys Updated')));
                      },
                      child: const Text('SAVE CREDENTIALS'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(icon: Icons.warning_amber_rounded, title: 'Account', color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent, width: 1)),
                          onPressed: () => notifier.setSettings(const AppSettings()),
                          child: const Text('RESET APP', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () async => await ref.read(authNotifierProvider.notifier).signOut(),
                          child: const Text('SIGN OUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends ConsumerWidget {
  final IconData icon;
  final String title;
  final Color? color;

  const _SectionHeader({required this.icon, required this.title, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = color ?? Color(ref.watch(appStateProvider).settings.accent);
    return Row(
      children: [
        Icon(icon, size: 18, color: themeColor),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: themeColor, letterSpacing: 0.5)),
      ],
    );
  }
}
