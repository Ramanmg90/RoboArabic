import 'package:flutter/material.dart';

import '../../shared/widgets/app_background.dart';

/// Pushes [child] inside a titled scaffold with the shared background.
Future<void> openPage(BuildContext context, String title, Widget child) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: AppBackground(child: SafeArea(child: child)),
      ),
    ),
  );
}
