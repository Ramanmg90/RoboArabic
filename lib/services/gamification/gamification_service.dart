/// Configurable XP values.
class RewardConfig {
  const RewardConfig({
    this.correctAnswer = 10,
    this.difficultChallenge = 20,
    this.lessonComplete = 30,
    this.dailyMission = 50,
    this.grammarTopic = 15,
  });

  final int correctAnswer;
  final int difficultChallenge;
  final int lessonComplete;
  final int dailyMission;
  final int grammarTopic;
}

/// Immutable XP state. XP is derived from unique reward claims, so a
/// reward key can never be counted twice.
class GamificationState {
  const GamificationState(this.claimed);
  static const empty = GamificationState({});

  final Map<String, int> claimed;
  int get xp => claimed.values.fold(0, (a, b) => a + b);
}

class RewardResult {
  const RewardResult(this.state, this.granted, this.amount);
  final GamificationState state;
  final bool granted;
  final int amount;
}

class GamificationService {
  const GamificationService({this.config = const RewardConfig()});
  final RewardConfig config;

  /// XP needed to reach [level]: 0, 100, 300, 600, ...
  static int xpForLevel(int level) => 50 * level * (level - 1);

  static int levelForXp(int xp) {
    var level = 1;
    while (xp >= xpForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  /// Progress (0..1) toward the next level.
  static double levelProgress(int xp) {
    final l = levelForXp(xp);
    final start = xpForLevel(l);
    final end = xpForLevel(l + 1);
    return (xp - start) / (end - start);
  }

  RewardResult award(GamificationState s, String key, int amount) {
    if (amount <= 0 || s.claimed.containsKey(key)) {
      return RewardResult(s, false, 0);
    }
    return RewardResult(
      GamificationState({...s.claimed, key: amount}),
      true,
      amount,
    );
  }
}
