import 'package:flutter/material.dart';

import '../../data/repositories/app_state.dart';
import '../../shared/widgets/app_background.dart';
import '../exams/exams_page.dart';
import '../games/games_page.dart';
import '../lessons/lessons_page.dart';
import '../profile/profile_page.dart';
import 'dashboard_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.state});
  final AppState state;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  void _go(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final pages = [
      DashboardTab(state: s, onNavigate: _go),
      LessonsPage(state: s),
      GamesPage(state: s),
      ExamsPage(state: s),
      ProfilePage(state: s),
    ];
    return Scaffold(
      body: AppBackground(child: SafeArea(child: pages[_tab])),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'خانه'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'درس‌ها'),
          NavigationDestination(
              icon: Icon(Icons.sports_esports_outlined), label: 'بازی'),
          NavigationDestination(icon: Icon(Icons.quiz_outlined), label: 'آزمون'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'پروفایل'),
        ],
      ),
    );
  }
}
