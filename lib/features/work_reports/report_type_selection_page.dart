import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import 'new_work_report_page.dart';
import 'new_week_report_page.dart';

class ReportTypeSelectionPage extends StatelessWidget {
  const ReportTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLanguage.instance.strings;

    return Scaffold(
      appBar: AppBar(title: Text(t.newWorkReport)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              t.chooseReportType,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            _typeCard(
              context,
              icon: Icons.today,
              title: t.dayReport,
              subtitle: t.dayReportSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NewWorkReportPage(),
                  ),
                );
              },
            ),

            _typeCard(
              context,
              icon: Icons.view_week,
              title: t.weekReport,
              subtitle: t.weekReportSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NewWeekReportPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 36),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
