import 'package:flutter_test/flutter_test.dart';
import 'package:roboarabic/data/models/models.dart';
import 'package:roboarabic/services/quiz/quiz_evaluator.dart';

Question _q(QuestionType t, List<String> accepted) => Question(
      id: 'q',
      lessonId: 'l',
      topicId: 't',
      type: t,
      prompt: 'p',
      options: const [],
      acceptedAnswers: accepted,
      explanation: 'e',
      difficulty: 1,
    );

void main() {
  const ev = QuizEvaluator();

  test('diacritics are ignored', () {
    final q = _q(QuestionType.fillBlank, ['كتاب']);
    expect(ev.evaluate(q, 'كِتَابٌ').verdict, Verdict.correct);
  });

  test('Persian ye/kaf and whitespace are normalized', () {
    final q = _q(QuestionType.fillBlank, ['كتاب']);
    expect(ev.evaluate(q, '  کتاب ').verdict, Verdict.correct);
  });

  test('wrong answer is incorrect', () {
    final q = _q(QuestionType.fillBlank, ['كتاب']);
    expect(ev.evaluate(q, 'قلم').verdict, Verdict.incorrect);
  });

  test('translation is never auto-graded', () {
    final q = _q(QuestionType.translationSelf, ['این کتاب است.']);
    expect(ev.evaluate(q, 'anything').verdict, Verdict.selfAssess);
  });
}
