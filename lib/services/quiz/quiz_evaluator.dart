import '../../data/models/models.dart';

enum Verdict { correct, incorrect, selfAssess }

class AnswerResult {
  const AnswerResult(this.verdict);
  final Verdict verdict;
}

/// Grades only questions that can be graded reliably (choice / short exact
/// answers). Free translation is never auto-graded: it is self-assessed.
class QuizEvaluator {
  const QuizEvaluator();

  static final _diacritics = RegExp('[\u064B-\u065F\u0670\u0640]');

  static String normalize(String s) => s
      .replaceAll(_diacritics, '')
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ی', 'ي')
      .replaceAll('ک', 'ك')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  AnswerResult evaluate(Question q, String answer) {
    if (q.type == QuestionType.translationSelf) {
      return const AnswerResult(Verdict.selfAssess);
    }
    final a = normalize(answer);
    final ok = q.acceptedAnswers.any((x) => normalize(x) == a);
    return AnswerResult(ok ? Verdict.correct : Verdict.incorrect);
  }
}
