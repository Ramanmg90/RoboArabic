import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/fa.dart';
import 'glass_card.dart';

class LessonProgressCard extends StatelessWidget {
  const LessonProgressCard({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.completed,
    required this.isSample,
    required this.onTap,
  });

  final int number;
  final String title;
  final String subtitle;
  final double progress;
  final bool completed;
  final bool isSample;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = completed
        ? 'تکمیل‌شده'
        : progress > 0
            ? 'در حال یادگیری'
            : 'شروع نشده';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: GlassCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: completed ? AppColors.mint : AppColors.orange,
                child: completed
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text(
                        toFa(number),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: completed ? 1 : progress,
                        minHeight: 8,
                        backgroundColor: AppColors.softGray,
                        valueColor: AlwaysStoppedAnimation(
                          completed ? AppColors.mint : AppColors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        Text(status, style: const TextStyle(fontSize: 12)),
                        if (isSample)
                          const Text(
                            'نمونه',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.coral,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left),
            ],
          ),
        ),
      ),
    );
  }
}
