import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roboarabic/shared/widgets/question_option_tile.dart';
import 'package:roboarabic/shared/widgets/xp_progress_bar.dart';

Widget _rtl(Widget child) => MaterialApp(
      locale: const Locale('fa'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('XPProgressBar shows its label in RTL', (tester) async {
    await tester.pumpWidget(
        _rtl(const XPProgressBar(progress: 0.5, label: '۵۰ از ۱۰۰ امتیاز')));
    expect(find.text('۵۰ از ۱۰۰ امتیاز'), findsOneWidget);
  });

  testWidgets('correct option shows an icon, not color alone', (tester) async {
    await tester.pumpWidget(_rtl(const QuestionOptionTile(
        text: 'قلم', state: OptionState.correct, onTap: null)));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
