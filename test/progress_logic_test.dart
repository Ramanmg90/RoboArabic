import 'package:flutter_test/flutter_test.dart';
import 'package:roboarabic/data/models/models.dart';
import 'package:roboarabic/services/progress/analytics.dart';
import 'package:roboarabic/services/progress/daily_mission.dart';
import 'package:roboarabic/services/progress/streak.dart';

AnswerLogEntry _e(String q, String topic, bool ok, DateTime at) =>
    AnswerLogEntry(
      questionId: q,
      lessonId: 'l',
      topicId: topic,
      correct: ok,
      at: at,
    );

void main() {
  final today = DateTime(2026, 10, 16, 12);

  group('streak', () {
    test('counts consecutive days', () {
      final days = {'2026-10-16', '2026-10-15', '2026-10-14'};
      expect(currentStreak(days, today), 3);
    });

    test('stays alive if only yesterday is active', () {
      expect(currentStreak({'2026-10-15'}, today), 1);
    });

    test('breaks after a gap', () {
      expect(currentStreak({'2026-10-13'}, today), 0);
    });
  });

  group('analytics', () {
    test('topic accuracy and weak topics', () {
      final log = [
        _e('a', 'g-x', false, today),
        _e('b', 'g-x', false, today),
        _e('c', 'vocab', true, today),
        _e('d', 'vocab', true, today),
      ];
      final stats = topicAccuracy(log);
      expect(stats['g-x']!.accuracy, 0);
      expect(weakTopics(stats), ['g-x']);
    });

    test('wrong question ids use the latest attempt', () {
      final log = [
        _e('a', 't', false, today.subtract(const Duration(hours: 2))),
        _e('a', 't', true, today),
        _e('b', 't', false, today),
      ];
      expect(wrongQuestionIds(log), ['b']);
    });

    test('last 7 days counts', () {
      final log = [_e('a', 't', true, today), _e('b', 't', true, today)];
      final c = last7DaysCounts(log, today);
      expect(c.length, 7);
      expect(c.last, 2);
      expect(c.first, 0);
    });
  });

  group('daily mission', () {
    test('completes at the target', () {
      const m = DailyMission(target: 2);
      final log = [_e('a', 't', true, today)];
      expect(m.isComplete(log, today), isFalse);
      expect(m.isComplete([...log, _e('b', 't', false, today)], today), isTrue);
    });

    test('reward key is unique per day', () {
      const m = DailyMission();
      expect(m.rewardKey(today), 'mission:2026-10-16');
    });
  });
}
