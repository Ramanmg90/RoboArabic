import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/fa.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_action_button.dart';
import '../../shared/widgets/question_option_tile.dart';

/// Arabic-to-Persian matching. XP is granted once per word via real
/// reward keys; wrong taps cost nothing.
class WordMatchPage extends StatefulWidget {
  const WordMatchPage({super.key, required this.state});
  final AppState state;

  @override
  State<WordMatchPage> createState() => _WordMatchPageState();
}

class _WordMatchPageState extends State<WordMatchPage> {
  late List<VocabularyItem> _left;
  late List<VocabularyItem> _right;
  final _matched = <String>{};
  String? _selected;
  String? _wrongRight;
  int _mistakes = 0;
  int _xp = 0;
  Timer? _flash;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    final pool = [...widget.state.content.vocabulary]..shuffle();
    _left = pool.take(5).toList();
    _right = [..._left]..shuffle();
    _matched.clear();
    _selected = null;
    _wrongRight = null;
    _mistakes = 0;
    _xp = 0;
  }

  @override
  void dispose() {
    _flash?.cancel();
    super.dispose();
  }

  Future<void> _tapRight(VocabularyItem r) async {
    final s = _selected;
    if (s == null || _matched.contains(r.id)) return;
    final leftItem = _left.firstWhere((e) => e.id == s);
    if (s == r.id) {
      final gained = await widget.state.award(
        'match:${r.id}',
        widget.state.gamification.config.correctAnswer,
      );
      await widget.state.logAnswer('match-${r.id}', r.lessonId, 'vocab', true);
      if (widget.state.haptics) HapticFeedback.lightImpact();
      if (!mounted) return;
      setState(() {
        _xp += gained;
        _matched.add(r.id);
        _selected = null;
      });
    } else {
      await widget.state
          .logAnswer('match-${leftItem.id}', leftItem.lessonId, 'vocab', false);
      if (!mounted) return;
      setState(() {
        _mistakes++;
        _wrongRight = r.id;
      });
      _flash?.cancel();
      _flash = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _wrongRight = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.content.vocabulary.length < 2) {
      return const EmptyStateView(
        icon: Icons.style_outlined,
        message: 'برای این بازی واژهٔ کافی وجود ندارد.',
      );
    }
    if (_matched.length == _left.length) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 64),
                const SizedBox(height: 8),
                Text(
                  'همه را درست وصل کردی! ${toFa(_xp)} XP',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('اشتباه‌ها: ${toFa(_mistakes)}'),
                const SizedBox(height: 12),
                GradientActionButton(
                  label: 'دوباره',
                  onPressed: () => setState(_deal),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('اول کلمهٔ عربی، بعد معنی فارسی آن را انتخاب کن.'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  for (final w in _left)
                    QuestionOptionTile(
                      text: w.arabic,
                      state: _matched.contains(w.id)
                          ? OptionState.correct
                          : _selected == w.id
                              ? OptionState.selected
                              : OptionState.idle,
                      onTap: _matched.contains(w.id)
                          ? null
                          : () => setState(() => _selected = w.id),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  for (final w in _right)
                    QuestionOptionTile(
                      text: w.persian,
                      state: _matched.contains(w.id)
                          ? OptionState.correct
                          : _wrongRight == w.id
                              ? OptionState.wrong
                              : OptionState.idle,
                      onTap: _matched.contains(w.id) ? null : () => _tapRight(w),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
