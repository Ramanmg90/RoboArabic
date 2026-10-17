import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../../services/gamification/achievements.dart';
import '../../services/gamification/gamification_service.dart';
import '../../services/progress/analytics.dart';
import '../../services/progress/daily_mission.dart';
import '../../services/progress/streak.dart';
import '../../services/quiz/exercise_generator.dart';
import '../models/content_bundle.dart';
import '../models/models.dart';
import 'progress_repository.dart';

class AppState extends ChangeNotifier {
  AppState(
    this.repo,
    this.content, {
    this.gamification = const GamificationService(),
    this.mission = const DailyMission(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ProgressRepository repo;
  final ContentBundle content;
  final GamificationService gamification;
  final DailyMission mission;
  final DateTime Function() _clock;

  GamificationState _g = GamificationState.empty;
  Map<String, VocabStatus> vocab = {};
  Set<String> unlocked = {};
  List<QuizAttempt> attempts = [];
  List<AnswerLogEntry> log = [];
  Set<String> activityDays = {};
  bool onboardingDone = false;
  String nickname = '';
  ThemeMode themeMode = ThemeMode.system;
  bool haptics = true;
  bool sound = true;

  DateTime get now => _clock();
  int get xp => _g.xp;
  int get level => GamificationService.levelForXp(xp);
  int get streak => currentStreak(activityDays, now);
  int get missionProgress => mission.progress(log, now);
  bool isClaimed(String key) => _g.claimed.containsKey(key);
  bool lessonDone(String lessonId) => isClaimed('lesson:$lessonId');
  bool grammarDone(String topicId) => isClaimed('grammar:$topicId');

  /// Fraction of a lesson's exercises answered correctly at least once.
  double lessonProgress(Lesson l) {
    if (l.questions.isEmpty) return lessonDone(l.id) ? 1 : 0;
    final done = l.questions.where((q) => isClaimed('answer:${q.id}')).length;
    return done / l.questions.length;
  }

  Future<void> load() async {
    try {
      _g = GamificationState(await repo.loadClaims());
      vocab = await repo.loadVocab();
      unlocked = await repo.loadAchievements();
      attempts = await repo.recentAttempts();
      log = await repo.loadAnswerLog();
      activityDays = await repo.loadActivityDays();
      onboardingDone = (await repo.getSetting('onboarding_done')) == '1';
      nickname = ((await repo.getSetting('nickname')) ?? '').trim();
      haptics = (await repo.getSetting('haptics')) != '0';
      sound = (await repo.getSetting('sound')) != '0';
      themeMode = switch (await repo.getSetting('theme')) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (e) {
      // Corrupted/missing data must not crash the app: start clean in memory.
      debugPrint('RoboArabic: failed to load progress: $e');
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboardingDone = true;
    await repo.setSetting('onboarding_done', '1');
    notifyListeners();
  }

  // ---- settings ----
  Future<void> setNickname(String v) async {
    nickname = v.trim();
    await repo.setSetting('nickname', nickname.isEmpty ? ' ' : nickname);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    themeMode = m;
    await repo.setSetting('theme', m.name);
    notifyListeners();
  }

  Future<void> setHaptics(bool v) async {
    haptics = v;
    await repo.setSetting('haptics', v ? '1' : '0');
    notifyListeners();
  }

  Future<void> setSound(bool v) async {
    sound = v;
    await repo.setSetting('sound', v ? '1' : '0');
    notifyListeners();
  }

  // ---- rewards ----
  /// Grants XP once per [key]; replays and repeated taps give nothing.
  Future<int> award(String key, int amount) async {
    final r = gamification.award(_g, key, amount);
    if (!r.granted) return 0;
    _g = r.state;
    await repo.saveClaim(key, r.amount);
    await _checkAchievements();
    notifyListeners();
    return r.amount;
  }

  Future<int> rewardAnswer(Question q) => award(
        'answer:${q.id}',
        q.difficulty >= 3
            ? gamification.config.difficultChallenge
            : gamification.config.correctAnswer,
      );

  /// Logs an answer for analytics/streak and completes the daily mission.
  Future<void> logAnswer(
    String questionId,
    String lessonId,
    String topicId,
    bool correct,
  ) async {
    final t = now;
    await repo.logAnswer(questionId, lessonId, topicId, correct, t);
    log = [
      ...log,
      AnswerLogEntry(
        questionId: questionId,
        lessonId: lessonId,
        topicId: topicId,
        correct: correct,
        at: t,
      ),
    ];
    await _markToday();
    if (mission.isComplete(log, t)) {
      await award(mission.rewardKey(t), gamification.config.dailyMission);
    }
    notifyListeners();
  }

  Future<void> recordAnswer(Question q, bool correct) =>
      logAnswer(q.id, q.lessonId, q.topicId, correct);

  Future<void> _markToday() async {
    final k = dayKey(now);
    if (activityDays.contains(k)) return;
    activityDays = {...activityDays, k};
    await repo.markActivityDay(k);
  }

  Future<void> setVocabStatus(String id, VocabStatus s) async {
    vocab = {...vocab, id: s};
    await repo.setVocab(id, s);
    await _markToday();
    await _checkAchievements();
    notifyListeners();
  }

  Future<int> completeLesson(String lessonId) async {
    await _markToday();
    return award('lesson:$lessonId', gamification.config.lessonComplete);
  }

  Future<int> completeGrammar(String topicId) async {
    await _markToday();
    return award('grammar:$topicId', gamification.config.grammarTopic);
  }

  Future<void> finishQuiz(String label, int correct, int total) async {
    await repo.saveAttempt(label, correct, total);
    attempts = await repo.recentAttempts();
    notifyListeners();
  }

  /// Finds a question by id, including auto-generated vocabulary questions.
  Question? questionById(String id) {
    for (final q in content.questions) {
      if (q.id == id) return q;
    }
    if (id.startsWith(ExerciseGenerator.idPrefix)) {
      final vid = id.substring(ExerciseGenerator.idPrefix.length);
      for (final v in content.vocabulary) {
        if (v.id == vid) {
          return ExerciseGenerator(content.vocabulary).vocabChoice(v);
        }
      }
    }
    return null;
  }

  List<Question> mistakeQuestions() => [
        for (final id in wrongQuestionIds(log))
          if (questionById(id) != null) questionById(id)!,
      ];

  UserStats get stats => UserStats(
        xp: xp,
        correctAnswers:
            _g.claimed.keys.where((k) => k.startsWith('answer:')).length,
        lessonsCompleted:
            _g.claimed.keys.where((k) => k.startsWith('lesson:')).length,
        knownWords: vocab.values.where((s) => s == VocabStatus.known).length,
      );

  Future<void> _checkAchievements() async {
    for (final a in newlyEarned(stats, unlocked)) {
      unlocked = {...unlocked, a.id};
      await repo.saveAchievement(a.id);
    }
  }

  Future<void> resetProgress() async {
    await repo.resetAll();
    _g = GamificationState.empty;
    vocab = {};
    unlocked = {};
    attempts = [];
    log = [];
    activityDays = {};
    notifyListeners();
  }
}
