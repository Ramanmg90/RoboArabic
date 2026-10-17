/// Converts an int to Persian digits for consistent numeral display.
String toFa(int n) {
  const digits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  return n.toString().split('').map((c) {
    final d = int.tryParse(c);
    return d == null ? c : digits[d];
  }).join();
}
