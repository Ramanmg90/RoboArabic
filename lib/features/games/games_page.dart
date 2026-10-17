import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/nav.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../services/quiz/exercise_generator.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/glass_card.dart';
import '../exams/quiz_runner.dart';
import 'word_match_page.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final vocab = state.content.vocabulary;
    final all = state.content.questions;

    void run(String title, List<Question> qs) => openPage(
          context,
          title,
          qs.isEmpty
              ? const EmptyStateView(
                  icon: Icons.inbox_outlined,
                  message: 'برای این بازی هنوز سؤالی وجود ندارد.',
                )
              : QuizRunner(state: state, questions: qs),
        );

    final games = <(IconData, String, String, VoidCallback)>[
      (
        Icons.compare_arrows,
        'تطبیق واژه',
        'کلمهٔ عربی را به معنی فارسی وصل کن',
        () => openPage(context, 'تطبیق واژه', WordMatchPage(state: state)),
      ),
      (
        Icons.flash_on,
        'چالش واژگان',
        'سؤال‌های چندگزینه‌ای از واژه‌های درس‌ها',
        () => run('چالش واژگان',
            ExerciseGenerator(vocab).vocabChoices(count: 8)),
      ),
      (
        Icons.translate,
        'ترجمهٔ جمله',
        'جمله‌ها را ترجمه کن و با نمونه مقایسه کن',
        () => run('ترجمهٔ جمله',
            all.where((q) => q.type == QuestionType.translationSelf).toList()),
      ),
      (
        Icons.menu_book,
        'چالش گرامر',
        'سؤال‌های گرامری درس‌ها',
        () => run('چالش گرامر',
            all.where((q) => q.topicId.startsWith('g-')).toList()),
      ),
      (
        Icons.today,
        'آزمون روزانه',
        'پنج سؤال تازه برای امروز',
        () {
          final day = state.now;
          final gen =
              ExerciseGenerator(vocab, seed: ExerciseGenerator.daySeed(day));
          final pool = [...all, ...gen.vocabChoices(count: 6)];
          run('آزمون روزانه', ExerciseGenerator.dailySet(pool, day));
        },
      ),
      (
        Icons.replay,
        'مرور اشتباهات',
        'سؤال‌هایی که آخرین بار غلط جواب دادی',
        () => run('مرور اشتباهات', state.mistakeQuestions()),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'مرکز بازی',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final g in games)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: g.$4,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: GlassCard(
                child: Row(
                  children: [
                    Icon(g.$1, size: 32, color: AppColors.orange),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.$2,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Text(g.$3,
                              style: const TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
