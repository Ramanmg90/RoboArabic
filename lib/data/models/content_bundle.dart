import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'models.dart';

/// All bundled educational content. Content lives in JSON "content packs"
/// (assets/content/index.json + lessons/*.json); UI never hardcodes lessons.
class ContentBundle {
  ContentBundle({
    required this.version,
    required this.isSample,
    required this.sourceNote,
    required List<Lesson> lessons,
  }) : lessons = ([...lessons]..sort((a, b) => a.order.compareTo(b.order)));

  final String version;
  final bool isSample;
  final String sourceNote;
  final List<Lesson> lessons;

  late final List<VocabularyItem> vocabulary = [
    for (final l in lessons) ...l.vocabulary,
  ];
  late final List<Question> questions = [
    for (final l in lessons) ...l.questions,
  ];
  late final List<GrammarTopic> grammarTopics = [
    for (final l in lessons) ...l.grammar,
  ];

  Lesson? lessonById(String id) {
    for (final l in lessons) {
      if (l.id == id) return l;
    }
    return null;
  }

  String topicName(String id) {
    if (id == 'vocab') return 'واژگان';
    if (id == 'translation') return 'ترجمه';
    for (final g in grammarTopics) {
      if (g.id == id) return g.title;
    }
    return id;
  }

  factory ContentBundle.fromParts(
    Map<String, dynamic> index,
    List<Map<String, dynamic>> lessonJsons,
  ) =>
      ContentBundle(
        version: index['version'] as String,
        isSample: index['isSample'] as bool,
        sourceNote: index['sourceNote'] as String,
        lessons: lessonJsons.map(Lesson.fromJson).toList(),
      );

  static Future<ContentBundle> loadAsset() async {
    final index = jsonDecode(
      await rootBundle.loadString('assets/content/index.json'),
    ) as Map<String, dynamic>;
    final lessons = <Map<String, dynamic>>[];
    for (final f in (index['lessons'] as List).cast<String>()) {
      lessons.add(
        jsonDecode(await rootBundle.loadString('assets/content/lessons/$f'))
            as Map<String, dynamic>,
      );
    }
    return ContentBundle.fromParts(index, lessons);
  }
}
