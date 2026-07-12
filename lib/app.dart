import 'package:flutter/material.dart';

import 'features/dashboard/dashboard_page.dart';
import 'localization/app_language.dart';

class WorkLogProApp extends StatelessWidget {
  const WorkLogProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppLanguage.instance.strings.appName,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF0D47A1),
            scaffoldBackgroundColor: Colors.grey.shade100,
          ),
          home: const DashboardPage(),
        );
      },
    );
  }
}