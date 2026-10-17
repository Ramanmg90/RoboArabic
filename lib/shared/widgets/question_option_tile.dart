import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum OptionState { idle, selected, correct, wrong }

/// Correct/wrong are shown with an icon AND color (never color alone).
class QuestionOptionTile extends StatelessWidget {
  const QuestionOptionTile({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (state) {
      OptionState.correct => (AppColors.mint, Icons.check_circle),
      OptionState.wrong => (AppColors.coral, Icons.cancel),
      OptionState.selected => (AppColors.orange, Icons.radio_button_checked),
      OptionState.idle => (AppColors.muted, Icons.radio_button_unchecked),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 17))),
            ],
          ),
        ),
      ),
    );
  }
}
