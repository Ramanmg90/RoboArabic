import '../../data/models/models.dart';

/// Words not yet known; difficult words come first.
List<VocabularyItem> reviewQueue(
  List<VocabularyItem> items,
  Map<String, VocabStatus> states,
) {
  VocabStatus s(VocabularyItem i) => states[i.id] ?? VocabStatus.unknown;
  final queue = items.where((i) => s(i) != VocabStatus.known).toList();
  queue.sort((a, b) {
    final da = s(a) == VocabStatus.difficult ? 0 : 1;
    final db = s(b) == VocabStatus.difficult ? 0 : 1;
    return da.compareTo(db);
  });
  return queue;
}
