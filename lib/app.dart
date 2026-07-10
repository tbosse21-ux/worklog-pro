import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_page.dart';

class WorkLogProApp extends StatelessWidget {
  const WorkLogProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkLog Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0D47A1),
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: const DashboardPage(),
    );
  }
}