import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/fa.dart';
import '../../core/utils/nav.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../services/gamification/achievements.dart';
import '../../services/gamification/gamification_service.dart';
import '../../shared/widgets/achievement_badge.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_action_button.dart';
import '../../shared/widgets/streak_indicator.dart';
import '../../shared/widgets/xp_progress_bar.dart';
import '../exams/exams_page.dart';
import '../grammar/grammar_page.dart';
import '../lessons/lesson_page.dart';
import '../progress/progress_page.dart';
import '../vocabulary/vocabulary_page.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab(
      {super.key, required this.state, required this.onNavigate});
  final AppState state;
  final ValueChanged<int> onNavigate;

  Lesson? _continueLesson() {
    final lessons = state.content.lessons;
    if (lessons.isEmpty) return null;
    for (final l in lessons) {
      if (!state.lessonDone(l.id)) return l;
    }
    return lessons.first;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final xp = state.xp;
        final level = state.level;
        final next = GamificationService.xpForLevel(level + 1);
        final target = state.mission.target;
        final done = state.missionProgress.clamp(0, target);
        final cont = _continueLesson();
        final name = state.nickname.isEmpty ? '' : ' ${state.nickname}';

        Widget quick(IconData icon, String label, VoidCallback onTap) =>
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      Icon(icon, color: AppColors.orange),
                      const SizedBox(height: 4),
                      Text(label, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('سلام$name! 👋',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('سطح ${toFa(level)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      StreakIndicator(days: state.streak),
                    ],
                  ),
                  const SizedBox(height: 8),
                  XPProgressBar(
                    progress: GamificationService.levelProgress(xp),
                    label: '${toFa(xp)} از ${toFa(next)} امتیاز',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        done >= target ? Icons.check_circle : Icons.flag,
                        color:
                            done >= target ? AppColors.mint : AppColors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          done >= target
                              ? 'مأموریت امروز انجام شد!'
                              : 'مأموریت امروز: ${toFa(target)} سؤال پاسخ بده',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: done / target, minHeight: 8),
                  const SizedBox(height: 4),
                  Text(
                      '${toFa(done)} از ${toFa(target)}  •  جایزه: ${toFa(state.gamification.config.dailyMission)} XP'),
                ],
              ),
            ),
            if (cont != null) ...[
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ادامهٔ یادگیری'),
                    Text(cont.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GradientActionButton(
                      label: 'برو به درس',
                      icon: Icons.play_arrow,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              LessonPage(state: state, lesson: cont),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (state.content.isSample) ...[
              const SizedBox(height: 12),
              GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.coral),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.content.sourceNote)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                quick(Icons.map, 'درس‌ها', () => onNavigate(1)),
                const SizedBox(width: 8),
                quick(
                    Icons.style,
                    'واژگان',
                    () => openPage(
                        context, 'واژگان', VocabularyPage(state: state))),
                const SizedBox(width: 8),
                quick(
                    Icons.menu_book,
                    'گرامر',
                    () => openPage(
                        context, 'آکادمی گرامر', GrammarPage(state: state))),
                const SizedBox(width: 8),
                quick(Icons.quiz, 'آزمون', () => onNavigate(3)),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  openPage(context, 'پیشرفت', ProgressPage(state: state)),
              icon: const Icon(Icons.insights),
              label: const Text('داشبورد پیشرفت'),
            ),
            const SizedBox(height: 20),
            const Text('آخرین نتایج',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (state.attempts.isEmpty)
              const SizedBox(
                height: 140,
                child: EmptyStateView(
                  icon: Icons.emoji_events_outlined,
                  message: 'هنوز آزمونی نداده‌ای. اولین آزمونت را شروع کن!',
                ),
              )
            else
              for (final a in state.attempts.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                        '${attemptTitle(state.content, a.lessonId)}: ${toFa(a.correct)} از ${toFa(a.total)} پاسخ درست'),
                  ),
                ),
            const SizedBox(height: 20),
            const Text('دستاوردها',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
