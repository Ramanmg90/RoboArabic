import 'content_bundle.dart';
import 'models.dart';

/// Integrity checks for a content pack. Run in CI (see test/content_test.dart)
/// so a bad book import fails the build instead of reaching students.
List<String> validateContent(ContentBundle b) {
  final errors = <String>[];
  final lessonIds = <String>{};
  final vocabIds = <String>{};
  final questionIds = <String>{};
  final grammarIds = {for (final g in b.grammarTopics) g.id};

  for (final l in b.lessons) {
    if (!lessonIds.add(l.id)) errors.add('duplicate lesson id ${l.id}');
    for (final v in l.vocabulary) {
      if (!vocabIds.add(v.id)) errors.add('duplicate vocab id ${v.id}');
    }
    for (final q in l.questions) {
      if (!questionIds.add(q.id)) errors.add('duplicate question id ${q.id}');
      if (q.difficulty < 1 || q.difficulty > 3) {
        errors.add('${q.id}: difficulty must be 1..3');
      }
      if (q.acceptedAnswers.isEmpty) errors.add('${q.id}: no accepted answers');
      if (q.type == QuestionType.multipleChoice) {
        if (q.options.length < 2) errors.add('${q.id}: needs 2+ options');
        if (!q.acceptedAnswers.every(q.options.contains)) {
          errors.add('${q.id}: accepted answer is not among options');
        }
      }
      final t = q.topicId;
      if (t != 'vocab' && t != 'translation' && !grammarIds.contains(t)) {
        errors.add('${q.id}: unknown topic $t');
      }
    }
  }
  return errors;
}
