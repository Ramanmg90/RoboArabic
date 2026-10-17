import 'package:flutter_test/flutter_test.dart';
import 'package:roboarabic/data/models/models.dart';
import 'package:roboarabic/services/progress/review_queue.dart';

VocabularyItem _w(String id) =>
    VocabularyItem(id: id, lessonId: 'l', arabic: id, persian: id, example: '');

void main() {
  test('known words leave the queue; difficult words come first', () {
    final items = [_w('a'), _w('b'), _w('c')];
    final q = reviewQueue(items, {
      'a': VocabStatus.known,
      'c': VocabStatus.difficult,
    });
    expect(q.map((e) => e.id), ['c', 'b']);
  });
}
