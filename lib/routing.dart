import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'models/models.dart';
import 'state/auth_state.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/flashcard_screen.dart';
import 'screens/reviewer_notes_screen.dart';
import 'screens/games/game_hub_screen.dart';
import 'screens/games/matching_pairs_screen.dart';
import 'screens/games/shell_game_screen.dart';
import 'screens/games/speed_blitz_screen.dart';
import 'screens/games/word_scramble_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/quiz_config_screen.dart';
import 'screens/quiz_player_screen.dart';
import 'screens/quiz_results_screen.dart';
import 'screens/rankings_screen.dart';
import 'screens/session_screen.dart';
import 'screens/settings/settings_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      // If auth is still loading, don't redirect yet
      if (authState.isLoading) return null;

      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LandingScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/bookmarks', builder: (_, __) => const BookmarksScreen()),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final contextData = state.extra as String?;
          return ChatScreen(initialContext: contextData);
        }
      ),
      GoRoute(path: '/session', builder: (_, __) => const SessionScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/rankings', builder: (_, __) => const RankingsScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/quiz-config', builder: (_, __) => const QuizConfigScreen()),
      GoRoute(path: '/quiz-player', builder: (_, __) => const QuizPlayerScreen()),
      GoRoute(
        path: '/flashcards',
        builder: (context, state) {
          final flashcards = state.extra as List<Flashcard>;
          return FlashcardScreen(flashcards: flashcards);
        },
      ),
      GoRoute(
        path: '/reviewer-notes',
        builder: (context, state) {
          final content = state.extra as String;
          return ReviewerNotesScreen(content: content);
        },
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) {
          final time = state.extra as int?;
          return QuizResultsScreen(timeSpent: time);
        }
      ),
      GoRoute(path: '/games', builder: (_, __) => const GameHubScreen()),
      GoRoute(path: '/games/shell', builder: (_, __) => const ShellGameScreen()),
      GoRoute(path: '/games/matching', builder: (_, __) => const MatchingPairsScreen()),
      GoRoute(path: '/games/word-scramble', builder: (_, __) => const WordScrambleScreen()),
      GoRoute(path: '/games/speed-blitz', builder: (_, __) => const SpeedBlitzScreen()),
    ],
    errorBuilder: (_, __) => const Scaffold(body: Center(child: Text('Route not found'))),
  );
});
