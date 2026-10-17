import '../../data/models/models.dart';
import 'streak.dart';

class TopicStat {
  const TopicStat(this.correct, this.total);
  final int correct;
  final int total;
  double get accuracy => total == 0 ? 0 : correct / total;
}

Map<String, TopicStat> topicAccuracy(List<AnswerLogEntry> log) {
  final c = <String, int>{};
  final t = <String, int>{};
  for (final e in log) {
    t[e.topicId] = (t[e.topicId] ?? 0) + 1;
    if (e.correct) c[e.topicId] = (c[e.topicId] ?? 0) + 1;
  }
  return {for (final k in t.keys) k: TopicStat(c[k] ?? 0, t[k]!)};
}

/// Topics with enough answers and low accuracy, weakest first.
List<String> weakTopics(
  Map<String, TopicStat> stats, {
  int minAnswers = 2,
  double threshold = 0.7,
}) {
  final list = stats.entries
      .where((e) => e.value.total >= minAnswers && e.value.accuracy < threshold)
      .toList()
    ..sort((a, b) => a.value.accuracy.compareTo(b.value.accuracy));
  return list.map((e) => e.key).toList();
}

/// Answers per day for the last 7 days, oldest first.
List<int> last7DaysCounts(List<AnswerLogEntry> log, DateTime today) {
  final base = DateTime(today.year, today.month, today.day);
  final counts = <String, int>{};
  for (final e in log) {
    final k = dayKey(e.at);
    counts[k] = (counts[k] ?? 0) + 1;
  }
  return [
    for (var i = 6; i >= 0; i--)
      counts[dayKey(DateTime(base.year, base.month, base.day - i))] ?? 0,
  ];
}

/// Questions whose most recent attempt was wrong (for "review mistakes").
List<String> wrongQuestionIds(List<AnswerLogEntry> log) {
  final latest = <String, AnswerLogEntry>{};
  for (final e in log) {
    final prev = latest[e.questionId];
    if (prev == null || !e.at.isBefore(prev.at)) latest[e.questionId] = e;
  }
  return latest.values.where((e) => !e.correct).map((e) => e.questionId).toList();
}
