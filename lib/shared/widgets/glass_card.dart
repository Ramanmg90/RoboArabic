import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Translucent card. Blur is opt-in (default off) because it is expensive on
/// low-end devices; without blur it falls back to a plain translucent surface.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.blur = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppRadius.card);
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassDark : AppColors.glassLight,
        borderRadius: radius,
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );
    if (!blur) return box;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: box,
      ),
    );
  }
}
