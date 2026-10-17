import 'package:flutter/material.dart';

import '../../core/utils/nav.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/lesson_progress_card.dart';
import '../grammar/grammar_page.dart';
import '../vocabulary/vocabulary_page.dart';
import 'lesson_page.dart';

/// Lesson map. All lessons stay open: essential material is never locked.
class LessonsPage extends StatelessWidget {
  const LessonsPage({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'نقشهٔ درس‌ها',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      openPage(context, 'واژگان', VocabularyPage(state: state)),
                  icon: const Icon(Icons.style),
                  label: const Text('واژگان'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openPage(
                      context, 'آکادمی گرامر', GrammarPage(state: state)),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('گرامر'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final l in state.content.lessons)
            LessonProgressCard(
              number: l.order,
              title: l.title,
              subtitle: l.subtitle,
              progress: state.lessonProgress(l),
              completed: state.lessonDone(l.id),
              isSample: !l.isVerified,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LessonPage(state: state, lesson: l),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
