import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/app_state.dart';
import 'features/home/home_page.dart';
import 'features/onboarding/onboarding_page.dart';

class RoboArabicApp extends StatelessWidget {
  const RoboArabicApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'روبو عربی',
        debugShowCheckedModeBanner: false,
        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: state.themeMode,
        home: state.onboardingDone
            ? HomePage(state: state)
            : OnboardingPage(onStart: state.completeOnboarding),
      ),
    );
  }
}
