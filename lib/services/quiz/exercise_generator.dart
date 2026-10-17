import 'dart:math';

import '../../data/models/models.dart';

/// Builds practice questions automatically from lesson vocabulary, so every
/// new lesson immediately gets exercises without hand-written questions.
class ExerciseGenerator {
  ExerciseGenerator(this.vocab, {int? seed}) : _rng = Random(seed);

  final List<VocabularyItem> vocab;
  final Random _rng;

  static const idPrefix = 'gen-vocab-';

  static int daySeed(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  Question vocabChoice(VocabularyItem w) {
    final others = vocab
        .where((v) => v.persian != w.persian)
        .map((v) => v.persian)
        .toSet()
        .toList()
      ..shuffle(_rng);
    final options = [w.persian, ...others.take(3)]..shuffle(_rng);
    return Question(
      id: '$idPrefix${w.id}',
      lessonId: w.lessonId,
      topicId: 'vocab',
      type: QuestionType.multipleChoice,
      prompt: 'معنی «${w.arabic}» چیست؟',
      options: options,
      acceptedAnswers: [w.persian],
      explanation: '«${w.arabic}» یعنی «${w.persian}».',
      difficulty: 1,
    );
  }

  List<Question> vocabChoices({int count = 5, String? lessonId}) {
    final pool = vocab
        .where((v) => lessonId == null || v.lessonId == lessonId)
        .toList()
      ..shuffle(_rng);
    return pool.take(count).map(vocabChoice).toList();
  }

  /// Same questions for everyone on the same calendar day.
  static List<Question> dailySet(
    List<Question> pool,
    DateTime day, {
    int count = 5,
  }) {
    final list = [...pool]..shuffle(Random(daySeed(day)));
    return list.take(count).toList();
  }
}
