import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/fa.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../services/quiz/quiz_evaluator.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_action_button.dart';
import '../../shared/widgets/question_option_tile.dart';

class QuizEntry {
  const QuizEntry(this.question, this.answer, this.verdict);
  final Question question;
  final String answer;
  final Verdict verdict;
}

class QuizOutcome {
  const QuizOutcome(this.entries, this.xpGained);
  final List<QuizEntry> entries;
  final int xpGained;

  int get graded =>
      entries.where((e) => e.verdict != Verdict.selfAssess).length;
  int get correct => entries.where((e) => e.verdict == Verdict.correct).length;
}

/// One engine for lesson exercises, games and exams.
/// - [immediateFeedback]=false behaves like an exam: results appear at the end.
/// - [timeLimit] ends the run automatically when time is up.
/// - [saveAttemptAs] stores the result in exam history.
class QuizRunner extends StatefulWidget {
  const QuizRunner({
    super.key,
    required this.state,
    required this.questions,
    this.immediateFeedback = true,
    this.timeLimit,
    this.saveAttemptAs,
    this.onFinished,
  });

  final AppState state;
  final List<Question> questions;
  final bool immediateFeedback;
  final Duration? timeLimit;
  final String? saveAttemptAs;
  final ValueChanged<QuizOutcome>? onFinished;

  @override
  State<QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends State<QuizRunner> {
  final _text = TextEditingController();
  final _entries = <QuizEntry>[];
  Timer? _timer;
  int _i = 0;
  int _xp = 0;
  int _levelBefore = 1;
  int _remaining = 0;
  String? _selected;
  Verdict? _verdict;
  bool _done = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _entries.clear();
    _i = 0;
    _xp = 0;
    _selected = null;
    _verdict = null;
    _done = false;
    _busy = false;
    _text.clear();
    _levelBefore = widget.state.level;
    _timer?.cancel();
    final limit = widget.timeLimit;
    if (limit != null) {
      _remaining = limit.inSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted || _done) return;
        setState(() => _remaining--);
        if (_remaining <= 0) _finish();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    super.dispose();
  }

  Question get _q => widget.questions[_i];

  void _haptic(bool good) {
    if (!widget.state.haptics) return;
    if (good) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _submit() async {
    if (_busy || _verdict != null || _done) return;
    final q = _q;
    final isChoice = q.type == QuestionType.multipleChoice;
    final answer = isChoice ? (_selected ?? '') : _text.text;
    final isSelf = q.type == QuestionType.translationSelf;
    if (!isSelf && answer.trim().isEmpty) return;
    _busy = true;
    final r = const QuizEvaluator().evaluate(q, answer);
    if (r.verdict != Verdict.selfAssess) {
      final ok = r.verdict == Verdict.correct;
      await widget.state.recordAnswer(q, ok);
      if (ok) _xp += await widget.state.rewardAnswer(q);
      _haptic(ok);
    }
    _entries.add(QuizEntry(q, answer, r.verdict));
    _busy = false;
    if (!mounted) return;
    if (widget.immediateFeedback) {
      setState(() => _verdict = r.verdict);
    } else {
      await _next();
    }
  }

  Future<void> _next() async {
    if (_i + 1 < widget.questions.length) {
      setState(() {
        _i++;
        _selected = null;
        _verdict = null;
        _text.clear();
      });
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    if (_done) return;
    _timer?.cancel();
    final outcome = QuizOutcome(List.of(_entries), _xp);
    final label = widget.saveAttemptAs;
    if (label != null) {
      await widget.state.finishQuiz(label, outcome.correct, outcome.graded);
    }
    if (!mounted) return;
    setState(() => _done = true);
    widget.onFinished?.call(outcome);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const EmptyStateView(
        icon: Icons.inbox_outlined,
        message: 'هنوز سؤالی برای این بخش وجود ندارد.',
      );
    }
    return _done ? _summary() : _question();
  }

  Widget _question() {
    final q = _q;
    final total = widget.questions.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text('سؤال ${toFa(_i + 1)} از ${toFa(total)}'),
            const Spacer(),
            if (widget.timeLimit != null)
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18),
                  const SizedBox(width: 4),
                  Text('${toFa(_remaining ~/ 60)}:${toFa(_remaining % 60).padLeft(2, '۰')}'),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _i / total, minHeight: 6),
        const SizedBox(height: 12),
        GlassCard(
          child: Text(
            q.prompt,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.7),
          ),
        ),
        const SizedBox(height: 12),
        if (q.type == QuestionType.multipleChoice)
          for (final o in q.options)
            QuestionOptionTile(
              text: o,
              state: _optionState(q, o),
              onTap: _verdict == null ? () => setState(() => _selected = o) : null,
            )
        else if (q.type == QuestionType.fillBlank)
          TextField(
            controller: _text,
            enabled: _verdict == null,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'پاسخ عربی',
            ),
          )
        else ...[
          const Text('این سؤال خودارزیابی است و در نمره حساب نمی‌شود.'),
          const SizedBox(height: 8),
          TextField(
            controller: _text,
            enabled: _verdict == null,
            maxLines: 2,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ترجمهٔ شما',
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (_verdict == null)
          GradientActionButton(
            label: widget.immediateFeedback
                ? (q.type == QuestionType.translationSelf
                    ? 'نمایش پاسخ نمونه'
                    : 'بررسی پاسخ')
                : (_i + 1 < total ? 'ثبت و بعدی' : 'ثبت و پایان'),
            onPressed: _submit,
          )
        else ...[
          _feedback(q, _verdict!),
          const SizedBox(height: 12),
          GradientActionButton(
            label: _i + 1 < total ? 'سؤال بعدی' : 'پایان',
            onPressed: _next,
          ),
        ],
      ],
    );
  }

  OptionState _optionState(Question q, String o) {
    if (_verdict == null) {
      return _selected == o ? OptionState.selected : OptionState.idle;
    }
    if (q.acceptedAnswers.contains(o)) return OptionState.correct;
    if (_selected == o) return OptionState.wrong;
    return OptionState.idle;
  }

  Widget _feedback(Question q, Verdict v) {
    final (IconData icon, Color color, String title) = switch (v) {
      Verdict.correct => (Icons.check_circle, AppColors.mint, 'درست! ✔'),
      Verdict.incorrect => (Icons.cancel, AppColors.coral, 'نادرست ✘'),
      Verdict.selfAssess => (Icons.rate_review, AppColors.orange, 'خودارزیابی'),
    };
    final reward = widget.state.gamification.config.correctAnswer;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (v == Verdict.correct) _XpPop(label: '+${toFa(reward)} XP'),
            ],
          ),
          const SizedBox(height: 8),
          if (v == Verdict.selfAssess) Text('پاسخ نمونه: ${q.acceptedAnswers.first}'),
          Text(q.explanation),
        ],
      ),
    );
  }

  Widget _summary() {
    final graded = _entries.where((e) => e.verdict != Verdict.selfAssess).toList();
    final correct = graded.where((e) => e.verdict == Verdict.correct).length;
    final wrong = graded.where((e) => e.verdict == Verdict.incorrect).toList();
    final selfs = _entries.where((e) => e.verdict == Verdict.selfAssess).toList();
    final leveledUp = widget.state.level > _levelBefore;

    final byTopic = <String, List<bool>>{};
    for (final e in graded) {
      byTopic.putIfAbsent(e.question.topicId, () => []).add(e.verdict == Verdict.correct);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            children: [
              const Icon(Icons.emoji_events, size: 64, color: AppColors.yellow),
              const SizedBox(height: 8),
              Text(
                '${toFa(correct)} از ${toFa(graded.length)} پاسخ درست',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('امتیاز این دور: ${toFa(_xp)} XP'),
              if (leveledUp) ...[
                const SizedBox(height: 8),
                _XpPop(label: 'سطح جدید! سطح ${toFa(widget.state.level)} 🎉'),
              ],
              if (widget.timeLimit != null && _remaining <= 0)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('زمان تمام شد.'),
                ),
            ],
          ),
        ),
        if (byTopic.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('عملکرد بر اساس مبحث', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          for (final e in byTopic.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${widget.state.content.topicName(e.key)}: '
                '${toFa(e.value.where((x) => x).length)} از ${toFa(e.value.length)}',
              ),
            ),
        ],
        if (wrong.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('مرور پاسخ‌های نادرست', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final e in wrong)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.question.prompt),
                    const SizedBox(height: 4),
                    Text('پاسخ شما: ${e.answer}'),
                    ArabicText('پاسخ درست: ${e.question.acceptedAnswers.first}', size: 18),
                    Text(e.question.explanation),
                  ],
                ),
              ),
            ),
        ],
        if (selfs.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('خودارزیابی (بدون نمره)', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final e in selfs)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.question.prompt),
                    Text('ترجمهٔ شما: ${e.answer.isEmpty ? '—' : e.answer}'),
                    Text('پاسخ نمونه: ${e.question.acceptedAnswers.first}'),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: 16),
        GradientActionButton(
          label: 'تلاش دوباره',
          onPressed: () => setState(_start),
        ),
      ],
    );
  }
}

class _XpPop extends StatelessWidget {
  const _XpPop({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? 1 : 0.6, end: 1),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 350),
      curve: Curves.elasticOut,
      builder: (_, s, child) => Transform.scale(scale: s, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.yellow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
