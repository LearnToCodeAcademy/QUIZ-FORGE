import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'routing.dart';

class QuizForgeApp extends ConsumerWidget {
  const QuizForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appStateProvider.select((s) => s.settings));
    return MaterialApp.router(
      title: 'QuizForge',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(settings),
      routerConfig: buildRouter(),
    );
  }
}
