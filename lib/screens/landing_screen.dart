import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [Color(0xFF1A1048), Color(0xFF050924)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚡ QuizForge', style: TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Text(
                    'Study Smarter with AI-Powered Learning Tools',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Transform any document into interactive quizzes, smart study reviewers, and AI chat sessions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121C44),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('🔒 Secure sign-in with Google'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => context.go('/home'),
                          icon: const Icon(Icons.g_mobiledata, size: 30),
                          label: const Text('Continue as mr cooking beginners'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
