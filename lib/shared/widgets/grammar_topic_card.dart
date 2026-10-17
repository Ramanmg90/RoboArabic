import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import 'arabic_text.dart';
import 'glass_card.dart';

class GrammarTopicCard extends StatelessWidget {
  const GrammarTopicCard({super.key, required this.topic});
  final GrammarTopic topic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(topic.explanation, style: const TextStyle(height: 1.7)),
            const SizedBox(height: 8),
            for (final e in topic.examples) ...[
              ArabicText(e.arabic, size: 22),
              Text(e.persian),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}
