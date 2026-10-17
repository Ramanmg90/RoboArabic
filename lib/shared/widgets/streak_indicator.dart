import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/fa.dart';

class StreakIndicator extends StatelessWidget {
  const StreakIndicator({super.key, required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final active = days > 0;
    return Semantics(
      label: 'استریک ${toFa(days)} روز',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: active ? AppColors.orange : AppColors.muted,
          ),
          const SizedBox(width: 4),
          Text(
            '${toFa(days)} روز',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
