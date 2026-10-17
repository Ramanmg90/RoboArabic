import 'package:flutter_test/flutter_test.dart';
import 'package:roboarabic/services/gamification/achievements.dart';
import 'package:roboarabic/services/gamification/gamification_service.dart';

void main() {
  group('levels', () {
    test('thresholds are deterministic', () {
      expect(GamificationService.levelForXp(0), 1);
      expect(GamificationService.levelForXp(99), 1);
      expect(GamificationService.levelForXp(100), 2);
      expect(GamificationService.levelForXp(299), 2);
      expect(GamificationService.levelForXp(300), 3);
    });

    test('progress fraction toward next level', () {
      expect(GamificationService.levelProgress(0), 0);
      expect(GamificationService.levelProgress(50), 0.5);
    });
  });

  group('rewards', () {
    const service = GamificationService();

    test('XP accumulates across distinct keys', () {
      var s = GamificationState.empty;
      s = service.award(s, 'answer:q1', 10).state;
      s = service.award(s, 'answer:q2', 20).state;
      expect(s.xp, 30);
    });

    test('duplicate reward key is not granted twice', () {
      final first = service.award(GamificationState.empty, 'answer:q1', 10);
      final second = service.award(first.state, 'answer:q1', 10);
      expect(second.granted, isFalse);
      expect(second.state.xp, 10);
    });

    test('non-positive amounts are ignored', () {
      final r = service.award(GamificationState.empty, 'x', 0);
      expect(r.granted, isFalse);
      expect(r.state.xp, 0);
    });

    test('config values are adjustable', () {
      const c = RewardConfig(correctAnswer: 5);
      expect(c.correctAnswer, 5);
      expect(c.lessonComplete, 30);
    });
  });

  group('achievements', () {
    const none = UserStats(
        xp: 0, correctAnswers: 0, lessonsCompleted: 0, knownWords: 0);

    test('nothing earned for a new user', () {
      expect(newlyEarned(none, {}), isEmpty);
    });

    test('first correct answer unlocks once', () {
      const s = UserStats(
          xp: 10, correctAnswers: 1, lessonsCompleted: 0, knownWords: 0);
      expect(newlyEarned(s, {}).map((a) => a.id), ['first_correct']);
      expect(newlyEarned(s, {'first_correct'}), isEmpty);
    });
  });
}
