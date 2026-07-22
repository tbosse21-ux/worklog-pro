import 'package:flutter/material.dart';

import '../../database/customer_repository.dart';
import '../../database/work_report_repository.dart';
import '../../database/work_report_day_repository.dart';
import '../../localization/app_language.dart';
import '../../models/customer.dart';
import '../../models/work_report.dart';
import '../../models/work_report_day.dart';
import '../../services/pdf_service.dart';
import '../work_reports/new_work_report_page.dart';
import '../work_reports/new_week_report_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final WorkReportRepository _workReportRepository = WorkReportRepository();

  final CustomerRepository _customerRepository = CustomerRepository();
  final WorkReportDayRepository _dayRepository = WorkReportDayRepository();

  List<WorkReport> _reports = [];
  final Map<int, Customer> _customers = {};
  final Map<int, List<WorkReportDay>> _weekDays = {};

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

      if (report.isWeekReport && report.id != null) {
        _weekDays[report.id!] =
            await _dayRepository.getByReportId(report.id!);
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
    final t = AppLanguage.instance.strings;

    final start = report.startTime.split(":");
    final end = report.endTime.split(":");

    final startMinutes = int.parse(start[0]) * 60 + int.parse(start[1]);

    final endMinutes = int.parse(end[0]) * 60 + int.parse(end[1]);

    final minutes = endMinutes - startMinutes - report.breakMinutes;

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    return "$hours ${t.hoursShort} ${mins.toString().padLeft(2, '0')} ${t.minutesShort}.";
  }

  String _weekWorkingTime(WorkReport report) {
    final t = AppLanguage.instance.strings;

    final days = _weekDays[report.id] ?? [];

    final total = days.fold<Duration>(
      Duration.zero,
      (sum, day) => sum + Duration(minutes: (day.hours * 60).round()),
    );

    final hours = total.inHours;
    final mins = total.inMinutes.remainder(60);

    return "$hours ${t.hoursShort} ${mins.toString().padLeft(2, '0')} ${t.minutesShort}.";
  }

  Future<void> _handlePdf(
    BuildContext context,
    int reportId,
    Future<void> Function(int) action,
  ) async {
    final t = AppLanguage.instance.strings;

    try {
      await action(reportId);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.pdfError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLanguage.instance.strings;

    return Scaffold(
      appBar: AppBar(title: Text(t.reports)),
      body: _reports.isEmpty
          ? Center(child: Text(t.noReportsYet))
          : ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];

                final customer = _customers[report.customerId];
                final isWeek = report.isWeekReport;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Icon(
                      isWeek ? Icons.view_week : Icons.description,
                    ),
                    title: Text(customer?.name ?? t.unknownCustomer),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWeek
                              ? "${t.weekFromPrefix} ${_formatDate(report.date)}"
                              : _formatDate(report.date),
                        ),
                        Text(report.constructionSite),
                        Text(
                          isWeek
                              ? _weekWorkingTime(report)
                              : _workingTime(report),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: t.printReport,
                          icon: const Icon(Icons.print),
                          onPressed: () => _handlePdf(
                            context,
                            report.id!,
                            PdfService.preview,
                          ),
                        ),
                        IconButton(
                          tooltip: t.shareReport,
                          icon: const Icon(Icons.share),
                          onPressed: () => _handlePdf(
                            context,
                            report.id!,
                            PdfService.share,
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => isWeek
                              ? NewWeekReportPage(report: report)
                              : NewWorkReportPage(report: report),
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
