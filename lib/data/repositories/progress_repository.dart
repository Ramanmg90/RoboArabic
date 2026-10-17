import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// Isolates SQLite from the UI. Schema changes go through [migrate]:
/// never drop tables, only add, so student progress survives upgrades.
class ProgressRepository {
  ProgressRepository(this._db);
  final Database _db;

  static const dbVersion = 2;

  static Future<ProgressRepository> open() async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dir, 'roboarabic.db'),
      version: dbVersion,
      onCreate: (db, v) => migrate(db, 0, v),
      onUpgrade: migrate,
    );
    return ProgressRepository(db);
  }

  static Future<void> migrate(Database db, int from, int to) async {
    if (from < 1) {
      await db.execute(
          'CREATE TABLE reward_claims(claim_key TEXT PRIMARY KEY, xp INTEGER NOT NULL, at INTEGER NOT NULL)');
      await db.execute(
          'CREATE TABLE vocab_state(id TEXT PRIMARY KEY, status TEXT NOT NULL)');
      await db.execute(
          'CREATE TABLE settings(k TEXT PRIMARY KEY, v TEXT NOT NULL)');
      await db.execute(
          'CREATE TABLE achievements(id TEXT PRIMARY KEY, at INTEGER NOT NULL)');
      await db.execute(
          'CREATE TABLE quiz_attempts(id INTEGER PRIMARY KEY AUTOINCREMENT, lesson_id TEXT NOT NULL, correct INTEGER NOT NULL, total INTEGER NOT NULL, at INTEGER NOT NULL)');
    }
    if (from < 2) {
      await db.execute(
          'CREATE TABLE answer_log(id INTEGER PRIMARY KEY AUTOINCREMENT, question_id TEXT NOT NULL, lesson_id TEXT NOT NULL, topic_id TEXT NOT NULL, correct INTEGER NOT NULL, at INTEGER NOT NULL)');
      await db.execute('CREATE TABLE activity_days(day TEXT PRIMARY KEY)');
    }
    // if (from < 3) { add new tables/columns here, never drop existing data }
  }

  Future<void> close() => _db.close();

  Future<Map<String, int>> loadClaims() async {
    final rows = await _db.query('reward_claims');
    return {
      for (final r in rows) r['claim_key'] as String: r['xp'] as int,
    };
  }

  Future<void> saveClaim(String key, int xp) => _db.insert(
        'reward_claims',
        {
          'claim_key': key,
          'xp': xp,
          'at': DateTime.now().millisecondsSinceEpoch
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

  Future<Map<String, VocabStatus>> loadVocab() async {
    final rows = await _db.query('vocab_state');
    return {
      for (final r in rows)
        r['id'] as String: VocabStatus.values.firstWhere(
          (s) => s.name == r['status'],
          orElse: () => VocabStatus.unknown,
        ),
    };
  }

  Future<void> setVocab(String id, VocabStatus s) => _db.insert(
        'vocab_state',
        {'id': id, 'status': s.name},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<String?> getSetting(String k) async {
    final rows = await _db.query('settings', where: 'k = ?', whereArgs: [k]);
    return rows.isEmpty ? null : rows.first['v'] as String;
  }

  Future<void> setSetting(String k, String v) => _db.insert(
        'settings',
        {'k': k, 'v': v},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<Set<String>> loadAchievements() async {
    final rows = await _db.query('achievements');
    return {for (final r in rows) r['id'] as String};
  }

  Future<void> saveAchievement(String id) => _db.insert(
        'achievements',
        {'id': id, 'at': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

  Future<void> saveAttempt(String lessonId, int correct, int total) =>
      _db.insert('quiz_attempts', {
        'lesson_id': lessonId,
        'correct': correct,
        'total': total,
        'at': DateTime.now().millisecondsSinceEpoch,
      });

  Future<List<QuizAttempt>> recentAttempts({int limit = 20}) async {
    final rows =
        await _db.query('quiz_attempts', orderBy: 'id DESC', limit: limit);
    return rows
        .map((r) => QuizAttempt(
              lessonId: r['lesson_id'] as String,
              correct: r['correct'] as int,
              total: r['total'] as int,
              at: DateTime.fromMillisecondsSinceEpoch(r['at'] as int),
            ))
        .toList();
  }

  Future<void> logAnswer(
    String questionId,
    String lessonId,
    String topicId,
    bool correct,
    DateTime at,
  ) async {
    await _db.insert('answer_log', {
      'question_id': questionId,
      'lesson_id': lessonId,
      'topic_id': topicId,
      'correct': correct ? 1 : 0,
      'at': at.millisecondsSinceEpoch,
    });
  }

  Future<List<AnswerLogEntry>> loadAnswerLog() async {
    final rows = await _db.query('answer_log', orderBy: 'id ASC');
    return rows
        .map((r) => AnswerLogEntry(
              questionId: r['question_id'] as String,
              lessonId: r['lesson_id'] as String,
              topicId: r['topic_id'] as String,
              correct: (r['correct'] as int) == 1,
              at: DateTime.fromMillisecondsSinceEpoch(r['at'] as int),
            ))
        .toList();
  }

  Future<void> markActivityDay(String day) => _db.insert(
        'activity_days',
        {'day': day},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

  Future<Set<String>> loadActivityDays() async {
    final rows = await _db.query('activity_days');
    return {for (final r in rows) r['day'] as String};
  }

  /// Explicit, confirmed reset from Settings.
  Future<void> resetAll() async {
    for (final t in [
      'reward_claims',
      'vocab_state',
      'achievements',
      'quiz_attempts',
      'answer_log',
      'activity_days',
    ]) {
      await _db.delete(t);
    }
  }
}
