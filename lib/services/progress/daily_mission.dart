import '../../data/models/models.dart';
import 'streak.dart';

/// Daily mission: answer [target] questions today.
class DailyMission {
  const DailyMission({this.target = 5});
  final int target;

  int progress(List<AnswerLogEntry> log, DateTime today) {
    final k = dayKey(today);
    return log.where((e) => dayKey(e.at) == k).length;
  }

  bool isComplete(List<AnswerLogEntry> log, DateTime today) =>
      progress(log, today) >= target;

  String rewardKey(DateTime today) => 'mission:${dayKey(today)}';
}
