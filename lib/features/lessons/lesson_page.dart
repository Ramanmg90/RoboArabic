import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/fa.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_action_button.dart';
import '../../shared/widgets/grammar_topic_card.dart';
import '../exams/quiz_runner.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key, required this.state, required this.lesson});
  final AppState state;
  final Lesson lesson;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int _step = 0;
  bool _showTranslation = false;
  int? _xpGained;

  Lesson get _l => widget.lesson;

  List<(String, Widget)> _steps() => [
        ('مقدمه', _intro()),
        if (_l.vocabulary.isNotEmpty) ('واژگان', _vocab()),
        if (_l.textArabic.isNotEmpty) ('متن و ترجمه', _text()),
        if (_l.grammar.isNotEmpty) ('گرامر', _grammar()),
        if (_l.questions.isNotEmpty)
          (
            'تمرین',
            QuizRunner(
              key: ValueKey('ex-${_l.id}'),
              state: widget.state,
              questions: _l.questions,
            ),
          ),
        if (_l.examTips.isNotEmpty) ('نکات امتحانی', _tips()),
        ('پایان درس', _summary()),
      ];

  @override
  Widget build(BuildContext context) {
    final steps = _steps();
    final last = _step == steps.length - 1;
    return Scaffold(
      appBar: AppBar(title: Text(_l.title)),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحلهٔ ${toFa(_step + 1)} از ${toFa(steps.length)}: ${steps[_step].$1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: (_step + 1) / steps.length,
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              Expanded(child: steps[_step].$2),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_step > 0)
                      OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: const Text('قبلی'),
                      ),
                    const Spacer(),
                    if (!last)
                      SizedBox(
                        width: 160,
                        child: GradientActionButton(
                          label: 'بعدی',
                          onPressed: () => setState(() => _step++),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _intro() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _l.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_l.intro, style: const TextStyle(height: 1.8)),
                if (!_l.isVerified) ...[
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.coral),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            'محتوای نمونه: از کتاب رسمی نیست و تأیید نشده.'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      );

  Widget _vocab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final w in _l.vocabulary)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: Row(
                  children: [
                    Expanded(child: ArabicText(w.arabic, size: 26, bold: true)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w.persian, style: const TextStyle(fontSize: 18)),
                          if (w.example.isNotEmpty)
                            ArabicText(w.example, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );

  Widget _text() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(child: ArabicText(_l.textArabic, size: 26)),
          const SizedBox(height: 12),
          if (_showTranslation)
            GlassCard(
              child: Text(
                _l.textPersian,
                style: const TextStyle(fontSize: 18, height: 1.8),
              ),
            )
          else
            OutlinedButton(
              onPressed: () => setState(() => _showTranslation = true),
              child: const Text('نمایش ترجمه'),
            ),
        ],
      );

  Widget _grammar() => ListView(
        padding: const EdgeInsets.all(16),
        children: [for (final g in _l.grammar) GrammarTopicCard(topic: g)],
      );

  Widget _tips() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final t in _l.examTips)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: AppColors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(t, style: const TextStyle(height: 1.7))),
                  ],
                ),
              ),
            ),
        ],
      );

  Widget _summary() {
    final done = widget.state.lessonDone(_l.id);
    final reward = widget.state.gamification.config.lessonComplete;
    final gained = _xpGained;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.flag,
                size: 64,
                color: done ? AppColors.mint : AppColors.orange,
              ),
              const SizedBox(height: 8),
              Text(
                done ? 'این درس تکمیل شده است' : 'آمادهٔ پایان درس هستی؟',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (gained != null && gained > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('+${toFa(gained)} XP'),
                ),
              const SizedBox(height: 12),
              if (!done)
                GradientActionButton(
                  label: 'تکمیل درس (+${toFa(reward)} XP)',
                  onPressed: () async {
                    final xp = await widget.state.completeLesson(_l.id);
                    if (!mounted) return;
                    setState(() => _xpGained = xp);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
