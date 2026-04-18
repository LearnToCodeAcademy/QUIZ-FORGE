import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/games/game_hub_screen.dart';
import 'screens/games/shell_game_screen.dart';
import 'screens/games/speed_blitz_screen.dart';
import 'screens/games/word_scramble_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/quiz_config_screen.dart';
import 'screens/rankings_screen.dart';
import 'screens/session_screen.dart';
import 'screens/settings/settings_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LandingScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/bookmarks', builder: (_, __) => const BookmarksScreen()),
      GoRoute(path: '/session', builder: (_, __) => const SessionScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/rankings', builder: (_, __) => const RankingsScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/quiz-config', builder: (_, __) => const QuizConfigScreen()),
      GoRoute(path: '/games', builder: (_, __) => const GameHubScreen()),
      GoRoute(path: '/games/shell', builder: (_, __) => const ShellGameScreen()),
      GoRoute(path: '/games/word-scramble', builder: (_, __) => const WordScrambleScreen()),
      GoRoute(path: '/games/speed-blitz', builder: (_, __) => const SpeedBlitzScreen()),
    ],
    errorBuilder: (_, __) => const Scaffold(body: Center(child: Text('Route not found'))),
  );
}
