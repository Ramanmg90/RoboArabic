import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class XPProgressBar extends StatelessWidget {
  const XPProgressBar({super.key, required this.progress, required this.label});

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration:
                  reduce ? Duration.zero : const Duration(milliseconds: 500),
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 12,
                backgroundColor: AppColors.softGray,
                valueColor: const AlwaysStoppedAnimation(AppColors.yellow),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
