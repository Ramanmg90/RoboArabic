import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/fa.dart';
import '../../core/utils/nav.dart';
import '../../data/models/content_bundle.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../services/quiz/exercise_generator.dart';
import '../../shared/widgets/glass_card.dart';
import 'quiz_runner.dart';

String attemptTitle(ContentBundle c, String id) {
  if (id == 'mixed') return 'آزمون ترکیبی';
  if (id == 'timed') return 'تمرین زمان‌دار';
  return c.lessonById(id)?.title ?? id;
}

class ExamsPage extends StatelessWidget {
  const ExamsPage({super.key, required this.state});
  final AppState state;

  List<Question> _mixedPool() {
    final gen = ExerciseGenerator(state.content.vocabulary);
    return [...state.content.questions, ...gen.vocabChoices(count: 6)]
      ..shuffle();
  }

  void _start(BuildContext context, String title, List<Question> qs,
      String label, {Duration? limit}) {
    openPage(
      context,
      title,
      QuizRunner(
        state: state,
        questions: qs,
        immediateFeedback: false,
        timeLimit: limit,
        saveAttemptAs: label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = state.content;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'مرکز آزمون',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const GlassCard(
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'سؤال‌های چندگزینه‌ای و جای‌خالی خودکار تصحیح می‌شوند. '
                    'ترجمهٔ آزاد خودارزیابی است و در نمره نمی‌آید.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.shuffle),
            title: const Text('آزمون ترکیبی'),
            subtitle: const Text('۱۰ سؤال از همهٔ درس‌ها'),
            onTap: () => _start(context, 'آزمون ترکیبی',
                _mixedPool().take(10).toList(), 'mixed'),
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('تمرین زمان‌دار'),
            subtitle: const Text('۱۰ سؤال در ۳ دقیقه'),
            onTap: () => _start(context, 'تمرین زمان‌دار',
                _mixedPool().take(10).toList(), 'timed',
                limit: const Duration(minutes: 3)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('آزمون هر درس',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          for (final l in c.lessons)
            ListTile(
              leading: CircleAvatar(child: Text(toFa(l.order))),
              title: Text(l.title),
              onTap: () {
                final gen = ExerciseGenerator(c.vocabulary);
                final qs = [
                  ...l.questions,
                  ...gen.vocabChoices(count: 4, lessonId: l.id),
                ];
                _start(context, 'آزمون: ${l.title}', qs, l.id);
              },
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
            for (final a in state.attempts.take(5))
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(attemptTitle(c, a.lessonId)),
                subtitle: Text(
                    '${toFa(a.correct)} از ${toFa(a.total)} پاسخ درست'),
              ),
        ],
      ),
    );
  }
}
