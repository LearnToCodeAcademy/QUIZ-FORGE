class UploadedFileMeta {
  UploadedFileMeta({required this.name, required this.path, required this.createdAt});
  final String name;
  final String path;
  final DateTime createdAt;
}

class BookmarkItem {
  BookmarkItem({required this.title, required this.createdAt});
  final String title;
  final DateTime createdAt;
}

class ActivityItem {
  ActivityItem({required this.title, required this.description, required this.time});
  final String title;
  final String description;
  final DateTime time;
}

class SessionItem {
  SessionItem({required this.title, required this.subtitle, required this.time});
  final String title;
  final String subtitle;
  final DateTime time;
}

class RankingUser {
  RankingUser({required this.name, required this.files, required this.initials});
  final String name;
  final int files;
  final String initials;
}

class AppSettings {
  const AppSettings({
    this.accent = 0xFF8B5CF6,
    this.fontFamily = 'Inter',
    this.allowBack = true,
    this.perQuestionTimer = 0,
    this.aiModel = 'Grok',
    this.grokKey = '',
    this.geminiKey = '',
  });

  final int accent;
  final String fontFamily;
  final bool allowBack;
  final int perQuestionTimer;
  final String aiModel;
  final String grokKey;
  final String geminiKey;

  AppSettings copyWith({
    int? accent,
    String? fontFamily,
    bool? allowBack,
    int? perQuestionTimer,
    String? aiModel,
    String? grokKey,
    String? geminiKey,
  }) {
    return AppSettings(
      accent: accent ?? this.accent,
      fontFamily: fontFamily ?? this.fontFamily,
      allowBack: allowBack ?? this.allowBack,
      perQuestionTimer: perQuestionTimer ?? this.perQuestionTimer,
      aiModel: aiModel ?? this.aiModel,
      grokKey: grokKey ?? this.grokKey,
      geminiKey: geminiKey ?? this.geminiKey,
    );
  }
}
