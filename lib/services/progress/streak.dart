String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Consecutive active days ending today. If today has no activity yet the
/// streak is still alive when yesterday was active.
int currentStreak(Set<String> activeDays, DateTime today) {
  var day = DateTime(today.year, today.month, today.day);
  if (!activeDays.contains(dayKey(day))) {
    day = day.subtract(const Duration(days: 1));
  }
  var n = 0;
  while (activeDays.contains(dayKey(day))) {
    n++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return n;
}
