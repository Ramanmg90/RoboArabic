import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roboarabic/data/models/content_bundle.dart';
import 'package:roboarabic/data/models/content_validator.dart';

Map<String, dynamic> _read(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

ContentBundle _load() {
  final index = _read('assets/content/index.json');
  final lessons = [
    for (final f in (index['lessons'] as List).cast<String>())
      _read('assets/content/lessons/$f'),
  ];
  return ContentBundle.fromParts(index, lessons);
}

void main() {
  test('bundled content pack is valid', () {
    final b = _load();
    expect(b.lessons, isNotEmpty);
    expect(validateContent(b), isEmpty);
  });

  test('sample pack is labeled as sample, not verified', () {
    final b = _load();
    expect(b.isSample, isTrue);
    expect(b.lessons.every((l) => !l.isVerified), isTrue);
  });

  test('validator catches a broken pack', () {
    final index = _read('assets/content/index.json');
    final l = _read('assets/content/lessons/s1.json');
    (l['questions'] as List).first['acceptedAnswers'] = ['not-an-option'];
    final b = ContentBundle.fromParts(index, [l]);
    expect(validateContent(b), isNotEmpty);
  });
}
