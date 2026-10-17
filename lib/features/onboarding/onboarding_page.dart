import 'package:flutter/material.dart';

import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_action_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      Icons.smart_toy,
      'به روبو عربی خوش آمدی',
      'عربی پایه نهم را قدم‌به‌قدم و بدون نیاز به اینترنت یاد بگیر.'
    ),
    (
      Icons.bolt,
      'امتیاز بگیر، سطح بالا برو',
      'با هر پاسخ درست امتیاز (XP) می‌گیری. برای پاسخ نادرست هیچ جریمه‌ای نداری.'
    ),
    (
      Icons.rocket_launch,
      'بدون ثبت‌نام شروع کن',
      'همه‌چیز روی گوشی خودت ذخیره می‌شود.'
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    for (final p in _pages)
                      Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(p.$1, size: 72),
                              const SizedBox(height: 16),
                              Text(p.$2,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text(p.$3,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              GradientActionButton(
                label: last ? 'شروع کنیم' : 'بعدی',
                onPressed: last
                    ? widget.onStart
                    : () => _controller.nextPage(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
