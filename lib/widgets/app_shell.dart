import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showNav = true,
    this.floatingActionButton,
    this.overlay,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showNav;
  final Widget? floatingActionButton;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF03071E), Color(0xFF131B36), Color(0xFF090D28)],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  if (showNav)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _TopNav(),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            foreground: Paint()..shader = const LinearGradient(
                              colors: [Colors.white, Color(0xFFA78BFA)],
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                          )),
                          const SizedBox(height: 6),
                          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          )),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF121C44).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFFA78BFA), size: 20),
                const SizedBox(width: 4),
                const Text('QuizForge', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFA78BFA), fontSize: 16, letterSpacing: -0.5)),
              ],
            ),
          ),
          const Spacer(),
          _NavIcon(
            icon: Icons.person_rounded,
            isActive: location == '/profile',
            onTap: () => context.go('/profile')
          ),
          const SizedBox(width: 8),
          _NavIcon(
            icon: Icons.settings_rounded,
            isActive: location == '/settings',
            onTap: () => context.go('/settings')
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA78BFA).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? const Color(0xFFA78BFA) : Colors.white60,
        ),
      ),
    );
  }
}
