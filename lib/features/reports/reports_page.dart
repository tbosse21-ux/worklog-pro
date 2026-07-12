import 'package:flutter/material.dart';

import '../../database/customer_repository.dart';
import '../../database/work_report_repository.dart';
import '../../models/customer.dart';
import '../../models/work_report.dart';
import '../work_reports/new_work_report_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final WorkReportRepository _workReportRepository = WorkReportRepository();

  final CustomerRepository _customerRepository = CustomerRepository();

  List<WorkReport> _reports = [];
  final Map<int, Customer> _customers = {};

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports = await _workReportRepository.getAll();

    for (final report in reports) {
      if (!_customers.containsKey(report.customerId)) {
        final customer = await _customerRepository.getCustomerById(
          report.customerId,
        );

        if (customer != null) {
          _customers[report.customerId] = customer;
        }
      }
    }

    setState(() {
      _reports = reports;
    });
  }

  String _formatDate(String date) {
    final d = DateTime.parse(date);

    return "${d.day.toString().padLeft(2, "0")}."
        "${d.month.toString().padLeft(2, "0")}."
        "${d.year}";
  }

  String _workingTime(WorkReport report) {
    final start = report.startTime.split(":");
    final end = report.endTime.split(":");

    final startMinutes = int.parse(start[0]) * 60 + int.parse(start[1]);

    final endMinutes = int.parse(end[0]) * 60 + int.parse(end[1]);

    final minutes = endMinutes - startMinutes - report.breakMinutes;

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    return "$hours Std. ${mins.toString().padLeft(2, '0')} Min.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Berichte")),
      body: _reports.isEmpty
          ? const Center(child: Text("Noch keine Arbeitsberichte vorhanden."))
          : ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];

                final customer = _customers[report.customerId];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(customer?.name ?? "Unbekannter Kunde"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatDate(report.date)),
                        Text(report.constructionSite),
                        Text(_workingTime(report)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NewWorkReportPage(report: report),
                        ),
                      );

                      _loadReports();
                    },
                  ),
                );
              },
            ),
    );
  }
}
