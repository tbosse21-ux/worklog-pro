import 'package:flutter/material.dart';

import 'app.dart';
import 'localization/app_language.dart';
import 'restart_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLanguage.instance.init();

  runApp(
    RestartWidget(
      child: const WorkLogProApp(),
    ),
  );
}