import 'package:flutter/material.dart';

import 'app.dart';
import 'data/models/content_bundle.dart';
import 'data/repositories/app_state.dart';
import 'data/repositories/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = await ProgressRepository.open();
  final content = await ContentBundle.loadAsset();
  final state = AppState(repo, content);
  await state.load();
  runApp(RoboArabicApp(state: state));
}
