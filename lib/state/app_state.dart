import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

class AppState {
  AppState({
    this.userName = 'mr cooking beginners',
    this.userEmail = 'hanmajohn3@gmail.com',
    this.files = const [],
    this.bookmarks = const [],
    this.activities = const [],
    this.sessions = const [],
    this.settings = const AppSettings(),
  });

  final String userName;
  final String userEmail;
  final List<UploadedFileMeta> files;
  final List<BookmarkItem> bookmarks;
  final List<ActivityItem> activities;
  final List<SessionItem> sessions;
  final AppSettings settings;

  AppState copyWith({
    String? userName,
    String? userEmail,
    List<UploadedFileMeta>? files,
    List<BookmarkItem>? bookmarks,
    List<ActivityItem>? activities,
    List<SessionItem>? sessions,
    AppSettings? settings,
  }) {
    return AppState(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      files: files ?? this.files,
      bookmarks: bookmarks ?? this.bookmarks,
      activities: activities ?? this.activities,
      sessions: sessions ?? this.sessions,
      settings: settings ?? this.settings,
    );
  }
}

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() => AppState(
        sessions: [
          SessionItem(
            title: 'Speed Blitz',
            subtitle: 'Cyber Law Quiz',
            time: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      );

  void addFile(UploadedFileMeta file) {
    state = state.copyWith(files: [...state.files, file]);
  }

  void deleteFile(UploadedFileMeta file) {
    state = state.copyWith(files: state.files.where((f) => f != file).toList());
  }

  void addBookmark(String title) {
    state = state.copyWith(bookmarks: [...state.bookmarks, BookmarkItem(title: title, createdAt: DateTime.now())]);
  }

  void setSettings(AppSettings settings) {
    state = state.copyWith(settings: settings);
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);
