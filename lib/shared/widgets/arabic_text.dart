import 'package:flutter/material.dart';

/// Arabic text with RTL direction and generous line height so diacritics
/// are never clipped.
class ArabicText extends StatelessWidget {
  const ArabicText(
    this.text, {
    super.key,
    this.size = 24,
    this.bold = false,
    this.align = TextAlign.start,
  });

  final String text;
  final double size;
  final bool bold;
  final TextAlign align;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textDirection: TextDirection.rtl,
        textAlign: align,
        style: TextStyle(
          fontSize: size,
          height: 1.9,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      );
}
