import 'package:flutter/material.dart';
import '../../localization/app_language.dart';
import '../customers/customers_page.dart';
import '../reports/reports_page.dart';
import '../settings/settings_page.dart';
import '../work_reports/new_work_report_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WorkLog Pro"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          Text(
            AppLanguage.instance.strings.welcome,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          _menuCard(
            context,
            icon: Icons.description,
            title: AppLanguage.instance.strings.newWorkReport,
            subtitle: AppLanguage.instance.strings.newReportSubtitle,
            page: const NewWorkReportPage(),
          ),

          _menuCard(
            context,
            icon: Icons.folder,
            title: AppLanguage.instance.strings.reports,
            subtitle: AppLanguage.instance.strings.reportsSubtitle,
            page: const ReportsPage(),
          ),

          _menuCard(
            context,
            icon: Icons.people,
            title: AppLanguage.instance.strings.customers,
            subtitle: AppLanguage.instance.strings.customersSubtitle,
            page: const CustomersPage(),
          ),

          _menuCard(
            context,
            icon: Icons.settings,
            title: AppLanguage.instance.strings.settings,
            subtitle: AppLanguage.instance.strings.settingsSubtitle,
            page: const SettingsPage(),
          ),

          const SizedBox(height: 25),

          const Center(
            child: Text(
              "Version 0.1.0",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          icon,
          size: 34,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
      ),
    );
  }
}