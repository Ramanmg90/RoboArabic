import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/fa.dart';
import '../../data/repositories/app_state.dart';
import '../../services/gamification/achievements.dart';
import '../../services/progress/analytics.dart';
import '../../shared/widgets/achievement_badge.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/streak_indicator.dart';
import '../exams/exams_page.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final c = state.content;
        final stats = topicAccuracy(state.log);
        final weak = weakTopics(stats);
        final days = last7DaysCounts(state.log, state.now);
        final maxDay = days.fold(1, (a, b) => b > a ? b : a);
        final reviewed =
            state.vocab.values.where((s) => s.name != 'unknown').length;
        final lessonsDone = c.lessons.where((l) => state.lessonDone(l.id)).length;

        Widget tile(String label, String value) => Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                tile('امتیاز', toFa(state.xp)),
                const SizedBox(width: 8),
                tile('سطح', toFa(state.level)),
                const SizedBox(width: 8),
                tile('درس تکمیل‌شده',
                    '${toFa(lessonsDone)}/${toFa(c.lessons.length)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                tile('واژهٔ مرورشده',
                    '${toFa(reviewed)}/${toFa(c.vocabulary.length)}'),
                const SizedBox(width: 8),
                GlassCard(child: StreakIndicator(days: state.streak)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('فعالیت ۷ روز اخیر',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GlassCard(
              child: SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < days.length; i++)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(toFa(days[i]),
                              style: const TextStyle(fontSize: 11)),
                          Container(
                            width: 20,
                            height: 6 + 60.0 * days[i] / maxDay,
                            decoration: BoxDecoration(
                              color: days[i] == 0
                                  ? AppColors.softGray
                                  : AppColors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Text(i == 6 ? 'امروز' : toFa(6 - i),
                              style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('دقت بر اساس مبحث',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (stats.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('هنوز پاسخی ثبت نشده است.'),
              )
            else
              for (final e in stats.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${c.topicName(e.key)}: ${toFa((e.value.accuracy * 100).round())}٪ (${toFa(e.value.correct)} از ${toFa(e.value.total)})'),
                      LinearProgressIndicator(
                        value: e.value.accuracy,
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 16),
            const Text('نقاط ضعف',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (weak.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('فعلاً نقطهٔ ضعف مشخصی نداری. ادامه بده!'),
              )
            else
              for (final t in weak)
                ListTile(
                  leading: const Icon(Icons.warning_amber_rounded,
                      color: AppColors.coral),
                  title: Text(c.topicName(t)),
                  subtitle: const Text('این مبحث را بیشتر تمرین کن'),
                ),
            const SizedBox(height: 16),
            const Text('تاریخچهٔ آزمون‌ها',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (state.attempts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('هنوز آزمونی نداده‌ای.'),
              )
            else
              for (final a in state.attempts.take(10))
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(attemptTitle(c, a.lessonId)),
                  subtitle: Text(
                      '${toFa(a.correct)} از ${toFa(a.total)} پاسخ درست'),
                ),
            const SizedBox(height: 16),
            const Text('دستاوردها',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final Achievement a in defaultAchievements)
                  AchievementBadge(
                    title: a.title,
                    unlocked: state.unlocked.contains(a.id),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
