import 'package:flutter/material.dart';

import '../../core/utils/fa.dart';
import '../../core/utils/nav.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_action_button.dart';
import '../../shared/widgets/grammar_topic_card.dart';
import '../exams/quiz_runner.dart';

class GrammarPage extends StatelessWidget {
  const GrammarPage({super.key, required this.state});
  final AppState state;

  static const _levels = {1: 'آسان', 2: 'متوسط', 3: 'دشوار'};

  @override
  Widget build(BuildContext context) {
    final topics = state.content.grammarTopics;
    if (topics.isEmpty) {
      return const EmptyStateView(
        icon: Icons.menu_book_outlined,
        message: 'هنوز مبحث گرامری اضافه نشده است.',
      );
    }
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final done = topics.where((t) => state.grammarDone(t.id)).length;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('${toFa(done)} از ${toFa(topics.length)} مبحث مطالعه شده'),
            const SizedBox(height: 8),
            for (final entry in _levels.entries) ...[
              if (topics.any((t) => t.difficulty == entry.key)) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                for (final t in topics.where((t) => t.difficulty == entry.key))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => openPage(
                        context,
                        t.title,
                        GrammarDetail(state: state, topic: t),
                      ),
                      child: GlassCard(
                        child: Row(
                          children: [
                            Icon(
                              state.grammarDone(t.id)
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(t.title)),
                            const Icon(Icons.chevron_left),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ],
        );
      },
    );
  }
}

class GrammarDetail extends StatelessWidget {
  const GrammarDetail({super.key, required this.state, required this.topic});
  final AppState state;
  final GrammarTopic topic;

  @override
  Widget build(BuildContext context) {
    final qs =
        state.content.questions.where((q) => q.topicId == topic.id).toList();
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final done = state.grammarDone(topic.id);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GrammarTopicCard(topic: topic),
            if (qs.isNotEmpty)
              GradientActionButton(
                label: 'تمرین کوتاه (${toFa(qs.length)} سؤال)',
                icon: Icons.edit,
                onPressed: () => openPage(
                  context,
                  'تمرین: ${topic.title}',
                  QuizRunner(state: state, questions: qs),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: done ? null : () => state.completeGrammar(topic.id),
              icon: Icon(done ? Icons.check_circle : Icons.done),
              label: Text(done ? 'مطالعه شد' : 'مطالعه کردم'),
            ),
          ],
        );
      },
    );
  }
}
