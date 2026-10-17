enum QuestionType { multipleChoice, fillBlank, translationSelf }

enum VocabStatus { unknown, known, difficult }

enum ContentStatus { sample, verified }

class Question {
  const Question({
    required this.id,
    required this.lessonId,
    required this.topicId,
    required this.type,
    required this.prompt,
    required this.options,
    required this.acceptedAnswers,
    required this.explanation,
    required this.difficulty,
  });

  final String id;
  final String lessonId;
  final String topicId;
  final QuestionType type;
  final String prompt;
  final List<String> options;
  final List<String> acceptedAnswers;
  final String explanation;
  final int difficulty;

  factory Question.fromJson(Map<String, dynamic> j, {String? lessonId}) =>
      Question(
        id: j['id'] as String,
        lessonId: (j['lessonId'] as String?) ?? lessonId ?? '',
        topicId: j['topicId'] as String,
        type: QuestionType.values.byName(j['type'] as String),
        prompt: j['prompt'] as String,
        options: List<String>.from(j['options'] as List),
        acceptedAnswers: List<String>.from(j['acceptedAnswers'] as List),
        explanation: j['explanation'] as String,
        difficulty: j['difficulty'] as int,
      );
}

class VocabularyItem {
  const VocabularyItem({
    required this.id,
    required this.lessonId,
    required this.arabic,
    required this.persian,
    required this.example,
  });

  final String id;
  final String lessonId;
  final String arabic;
  final String persian;
  final String example;

  factory VocabularyItem.fromJson(Map<String, dynamic> j, {String? lessonId}) =>
      VocabularyItem(
        id: j['id'] as String,
        lessonId: (j['lessonId'] as String?) ?? lessonId ?? '',
        arabic: j['arabic'] as String,
        persian: j['persian'] as String,
        example: (j['example'] as String?) ?? '',
      );
}

class GrammarExample {
  const GrammarExample(this.arabic, this.persian);
  final String arabic;
  final String persian;

  factory GrammarExample.fromJson(Map<String, dynamic> j) =>
      GrammarExample(j['arabic'] as String, j['persian'] as String);
}

class GrammarTopic {
  const GrammarTopic({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.difficulty,
    required this.explanation,
    required this.examples,
  });

  final String id;
  final String lessonId;
  final String title;
  final int difficulty;
  final String explanation;
  final List<GrammarExample> examples;

  factory GrammarTopic.fromJson(Map<String, dynamic> j, {String? lessonId}) =>
      GrammarTopic(
        id: j['id'] as String,
        lessonId: lessonId ?? '',
        title: j['title'] as String,
        difficulty: j['difficulty'] as int,
        explanation: j['explanation'] as String,
        examples: ((j['examples'] as List?) ?? const [])
            .map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Lesson {
  const Lesson({
    required this.id,
    required this.order,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.intro,
    required this.textArabic,
    required this.textPersian,
    required this.vocabulary,
    required this.grammar,
    required this.examTips,
    required this.questions,
  });

  final String id;
  final int order;
  final String title;
  final String subtitle;
  final ContentStatus status;
  final String intro;
  final String textArabic;
  final String textPersian;
  final List<VocabularyItem> vocabulary;
  final List<GrammarTopic> grammar;
  final List<String> examTips;
  final List<Question> questions;

  bool get isVerified => status == ContentStatus.verified;

  static List<Map<String, dynamic>> _list(Object? o) =>
      ((o as List?) ?? const []).cast<Map<String, dynamic>>();

  factory Lesson.fromJson(Map<String, dynamic> j) {
    final id = j['id'] as String;
    final text = j['text'] as Map<String, dynamic>?;
    return Lesson(
      id: id,
      order: j['order'] as int,
      title: j['title'] as String,
      subtitle: (j['subtitle'] as String?) ?? '',
      status: ContentStatus.values.byName((j['status'] as String?) ?? 'sample'),
      intro: (j['intro'] as String?) ?? '',
      textArabic: (text?['arabic'] as String?) ?? '',
      textPersian: (text?['persian'] as String?) ?? '',
      vocabulary: _list(j['vocabulary'])
          .map((e) => VocabularyItem.fromJson(e, lessonId: id))
          .toList(),
      grammar: _list(j['grammar'])
          .map((e) => GrammarTopic.fromJson(e, lessonId: id))
          .toList(),
      examTips: List<String>.from((j['examTips'] as List?) ?? const []),
      questions: _list(j['questions'])
          .map((e) => Question.fromJson(e, lessonId: id))
          .toList(),
    );
  }
}

class QuizAttempt {
  const QuizAttempt({
    required this.lessonId,
    required this.correct,
    required this.total,
    required this.at,
  });

  final String lessonId;
  final int correct;
  final int total;
  final DateTime at;
}

class AnswerLogEntry {
  const AnswerLogEntry({
    required this.questionId,
    required this.lessonId,
    required this.topicId,
    required this.correct,
    required this.at,
  });

  final String questionId;
  final String lessonId;
  final String topicId;
  final bool correct;
  final DateTime at;
}
