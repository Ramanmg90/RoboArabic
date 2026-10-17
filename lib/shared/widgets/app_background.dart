import 'package:flutter/material.dart';

/// Cheap decorative background: two soft radial glows (no blur filter).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: -120,
          right: -100,
          child: _Glow(size: 320, color: Color(0x55FF7A24)),
        ),
        const Positioned(
          bottom: -140,
          left: -120,
          child: _Glow(size: 340, color: Color(0x4442D6A4)),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withAlpha(0)],
          ),
        ),
      ),
    );
  }
}
