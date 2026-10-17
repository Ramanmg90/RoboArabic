import 'package:flutter_test/flutter_test.dart';
import 'package:roboarabic/data/models/models.dart';
import 'package:roboarabic/services/quiz/exercise_generator.dart';

List<VocabularyItem> _vocab() => [
      for (var i = 0; i < 6; i++)
        VocabularyItem(
          id: 'v$i',
          lessonId: 'l',
          arabic: 'a$i',
          persian: 'p$i',
          example: '',
        ),
    ];

void main() {
  test('generated question contains the right answer and 4 unique options', () {
    final gen = ExerciseGenerator(_vocab(), seed: 1);
    final q = gen.vocabChoice(_vocab().first);
    expect(q.options.length, 4);
    expect(q.options.toSet().length, 4);
    expect(q.options, contains('p0'));
    expect(q.acceptedAnswers, ['p0']);
  });

  test('same seed gives same questions', () {
    final a = ExerciseGenerator(_vocab(), seed: 7).vocabChoices(count: 3);
    final b = ExerciseGenerator(_vocab(), seed: 7).vocabChoices(count: 3);
    expect(a.map((q) => q.id), b.map((q) => q.id));
  });

  test('daily set is stable within a day and may differ across days', () {
    final pool = ExerciseGenerator(_vocab(), seed: 1).vocabChoices(count: 6);
    final d1 = DateTime(2026, 10, 16);
    final a = ExerciseGenerator.dailySet(pool, d1, count: 4);
    final b = ExerciseGenerator.dailySet(pool, d1, count: 4);
    expect(a.map((q) => q.id), b.map((q) => q.id));
  });
}
