import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roboarabic/data/models/models.dart';
import 'package:roboarabic/data/repositories/progress_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<ProgressRepository> _open(String path) async {
  final db = await databaseFactoryFfi.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: ProgressRepository.dbVersion,
      onCreate: (db, v) => ProgressRepository.migrate(db, 0, v),
    ),
  );
  return ProgressRepository(db);
}

void main() {
  sqfliteFfiInit();

  test('progress survives closing and reopening the database', () async {
    final dir = Directory.systemTemp.createTempSync('roboarabic_test');
    final path = '${dir.path}/t.db';

    var repo = await _open(path);
    await repo.saveClaim('answer:q1', 10);
    await repo.saveClaim('answer:q1', 10); // duplicate ignored
    await repo.setVocab('v1', VocabStatus.known);
    await repo.setSetting('onboarding_done', '1');
    await repo.logAnswer('q1', 'l1', 't1', false, DateTime(2026, 10, 16));
    await repo.markActivityDay('2026-10-16');
    await repo.close();

    repo = await _open(path);
    expect(await repo.loadClaims(), {'answer:q1': 10});
    expect((await repo.loadVocab())['v1'], VocabStatus.known);
    expect(await repo.getSetting('onboarding_done'), '1');
    final log = await repo.loadAnswerLog();
    expect(log.single.questionId, 'q1');
    expect(log.single.correct, isFalse);
    expect(await repo.loadActivityDays(), {'2026-10-16'});

    await repo.resetAll();
    expect(await repo.loadClaims(), isEmpty);
    await repo.close();
    dir.deleteSync(recursive: true);
  });
}
