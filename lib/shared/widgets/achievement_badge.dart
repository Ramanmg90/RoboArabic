import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Unlocked state is shown with icon + label, not color alone.
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({super.key, required this.title, required this.unlocked});
  final String title;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title، ${unlocked ? 'باز شده' : 'قفل'}',
      child: Container(
        width: 96,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: unlocked ? AppColors.yellow : AppColors.softGray,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              unlocked ? Icons.emoji_events : Icons.lock_outline,
              size: 32,
              color: unlocked ? AppColors.yellow : AppColors.muted,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
