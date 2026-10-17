class UserStats {
  const UserStats({
    required this.xp,
    required this.correctAnswers,
    required this.lessonsCompleted,
    required this.knownWords,
  });
  final int xp;
  final int correctAnswers;
  final int lessonsCompleted;
  final int knownWords;
}

class Achievement {
  const Achievement(this.id, this.title, this.isEarned);
  final String id;
  final String title;
  final bool Function(UserStats) isEarned;
}

final List<Achievement> defaultAchievements = [
  Achievement('first_correct', 'اولین پاسخ درست', (s) => s.correctAnswers >= 1),
  Achievement('xp_100', '۱۰۰ امتیاز', (s) => s.xp >= 100),
  Achievement('first_lesson', 'اولین درس', (s) => s.lessonsCompleted >= 1),
  Achievement('words_5', '۵ کلمه یاد گرفتی', (s) => s.knownWords >= 5),
];

/// Returns achievements newly earned (not already in [unlocked]).
List<Achievement> newlyEarned(
  UserStats stats,
  Set<String> unlocked, {
  List<Achievement>? rules,
}) =>
    (rules ?? defaultAchievements)
        .where((a) => !unlocked.contains(a.id) && a.isEarned(stats))
        .toList();
