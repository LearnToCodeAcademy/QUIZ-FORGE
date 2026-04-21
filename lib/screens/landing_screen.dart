import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_state.dart';
import '../state/app_state.dart';
import '../widgets/ui_parts.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA78BFA).withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFA78BFA).withOpacity(0.05), blurRadius: 40, spreadRadius: 10)
                    ]
                  ),
                  child: const Icon(Icons.bolt_rounded, size: 80, color: Color(0xFFA78BFA)),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    const Text(
                      'QuizForge AI',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Forging documents into knowledge.',
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GlowCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Elevate your study routine',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to access your personal study vault and AI tutor.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () async {
                              try {
                                final authService = ref.read(authServiceProvider);
                                final result = await authService.signInWithGoogle();

                                if (result != null && context.mounted) {
                                  ref.read(appStateProvider.notifier).setUser(
                                    userName: authService.displayName,
                                    userEmail: authService.userEmail,
                                    isAuthenticated: true,
                                  );
                                  context.go('/home');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Sign-in error: $e')),
                                  );
                                }
                              }
                            },
                            icon: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1200px-Google_\"G\"_logo.svg.png',
                              height: 20,
                            ),
                            label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Protected by Firebase Auth',
                          style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
