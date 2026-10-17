import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/fa.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../services/progress/review_queue.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/glass_card.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key, required this.state});
  final AppState state;

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  bool _reviewOnly = false;
  bool _flipped = false;
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final all = widget.state.content.vocabulary;
        final items =
            _reviewOnly ? reviewQueue(all, widget.state.vocab) : all;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('همه واژه‌ها')),
                  ButtonSegment(value: true, label: Text('صف مرور')),
                ],
                selected: {_reviewOnly},
                onSelectionChanged: (s) => setState(() {
                  _reviewOnly = s.first;
                  _i = 0;
                  _flipped = false;
                }),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: items.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.check_circle_outline,
                        message: 'همه واژه‌ها را بلدی. آفرین!')
                    : _card(items[_i % items.length], items.length),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _card(VocabularyItem w, int total) {
    final status = widget.state.vocab[w.id] ?? VocabStatus.unknown;
    Future<void> mark(VocabStatus s) async {
      await widget.state.setVocabStatus(w.id, s);
      if (!mounted) return;
      setState(() {
        _i++;
        _flipped = false;
      });
    }

    return Column(
      children: [
        Text('${toFa((_i % total) + 1)} از ${toFa(total)}'),
        const SizedBox(height: 8),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: () => setState(() => _flipped = !_flipped),
            child: SizedBox(
              width: double.infinity,
              child: GlassCard(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(w.arabic,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (_flipped) ...[
                        Text(w.persian, style: const TextStyle(fontSize: 26)),
                        if (w.example.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(w.example,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ] else
                        const Text('برای دیدن معنی بزن',
                            style: TextStyle(color: AppColors.muted)),
                      if (status == VocabStatus.difficult) ...[
                        const SizedBox(height: 12),
                        const Chip(
                            avatar: Icon(Icons.flag, size: 18),
                            label: Text('سخت')),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                  onPressed: () => mark(VocabStatus.unknown),
                  child: const Text('نمی‌دانم')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                  onPressed: () => mark(VocabStatus.difficult),
                  child: const Text('سخته')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                  onPressed: () => mark(VocabStatus.known),
                  child: const Text('بلدم')),
            ),
          ],
        ),
      ],
    );
  }
}
