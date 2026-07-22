import 'package:flutter/material.dart';

import '../../database/customer_repository.dart';
import '../../database/work_report_repository.dart';
import '../../database/work_report_day_repository.dart';
import '../../localization/app_language.dart';
import '../../localization/language_strings.dart';
import '../../models/customer.dart';
import '../../models/work_report.dart';
import '../../models/work_report_day.dart';

class NewWeekReportPage extends StatefulWidget {
  final WorkReport? report;

  const NewWeekReportPage({
    super.key,
    this.report,
  });

  @override
  State<NewWeekReportPage> createState() => _NewWeekReportPageState();
}

class _WeekDayInput {
  final int weekday; // 1 = Montag ... 7 = Sonntag
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int breakMinutes;
  final TextEditingController activityController;

  _WeekDayInput({required this.weekday})
      : breakMinutes = 30,
        activityController = TextEditingController();

  bool get isFilled =>
      startTime != null ||
      endTime != null ||
      activityController.text.trim().isNotEmpty;

  Duration get duration {
    if (startTime == null || endTime == null) return Duration.zero;

    final start = startTime!.hour * 60 + startTime!.minute;
    final end = endTime!.hour * 60 + endTime!.minute;
    final minutes = (end - start - breakMinutes).clamp(0, 24 * 60);

    return Duration(minutes: minutes);
  }

  void dispose() {
    activityController.dispose();
  }
}

class _NewWeekReportPageState extends State<NewWeekReportPage> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final WorkReportRepository _workReportRepository = WorkReportRepository();
  final WorkReportDayRepository _dayRepository = WorkReportDayRepository();

  List<String> _weekdayLabels(LanguageStrings t) => [
        t.weekdayMonday,
        t.weekdayTuesday,
        t.weekdayWednesday,
        t.weekdayThursday,
        t.weekdayFriday,
        t.weekdaySaturday,
        t.weekdaySunday,
      ];

  Customer? _selectedCustomer;
  List<Customer> _customerSuggestions = [];
  List<String> _constructionSuggestions = [];

  bool _showCustomerSuggestions = false;
  bool _showConstructionSuggestions = false;

  bool get _isEditing => widget.report != null;

  bool get _customerExists {
    return _customerSuggestions.any(
      (customer) =>
          customer.name.toLowerCase() ==
          _customerController.text.trim().toLowerCase(),
    );
  }

  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _constructionSiteController =
      TextEditingController();

  DateTime _weekStart = _mondayOf(DateTime.now());

  late final List<_WeekDayInput> _days = List.generate(
    7,
    (index) => _WeekDayInput(weekday: index + 1),
  );

  static DateTime _mondayOf(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  @override
  void initState() {
    super.initState();

    if (widget.report != null) {
      _loadReport();
    }
  }

  Future<void> _loadReport() async {
    final report = widget.report!;

    final customer = await _customerRepository.getCustomerById(
      report.customerId,
    );

    final days = await _dayRepository.getByReportId(report.id!);

    setState(() {
      _selectedCustomer = customer;
      _customerController.text = customer?.name ?? "";
      _constructionSiteController.text = report.constructionSite;
      _weekStart = _mondayOf(DateTime.parse(report.date));

      for (final day in days) {
        final target = _days[day.weekday - 1];

        if (day.startTime.isNotEmpty) {
          final parts = day.startTime.split(":");
          target.startTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }

        if (day.endTime.isNotEmpty) {
          final parts = day.endTime.split(":");
          target.endTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }

        target.breakMinutes = day.breakMinutes;
        target.activityController.text = day.activity;
      }
    });
  }

  @override
  void dispose() {
    _customerController.dispose();
    _constructionSiteController.dispose();

    for (final day in _days) {
      day.dispose();
    }

    super.dispose();
  }

  Future<void> _pickWeekStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _weekStart = _mondayOf(picked));
    }
  }

  Future<void> _searchCustomers(String text) async {
    setState(() => _showCustomerSuggestions = text.trim().isNotEmpty);

    if (text.trim().isEmpty) {
      setState(() => _customerSuggestions = []);
      return;
    }

    final customers = await _customerRepository.searchCustomers(text);

    setState(() => _customerSuggestions = customers);
  }

  Future<void> _searchConstructionSites(String text) async {
    setState(() => _showConstructionSuggestions = text.trim().isNotEmpty);

    if (_selectedCustomer == null) return;

    final sites = await _workReportRepository.getConstructionSites(
      _selectedCustomer!.id!,
    );

    setState(() {
      _constructionSuggestions = sites
          .where((site) => site.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _pickTime(_WeekDayInput day, {required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? day.startTime : day.endTime) ??
          const TimeOfDay(hour: 7, minute: 0),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          day.startTime = picked;
        } else {
          day.endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return "--:--";
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

  Duration get _weekTotal {
    return _days.fold(
      Duration.zero,
      (total, day) => total + day.duration,
    );
  }

  Future<void> _saveWeekReport() async {
    final t = AppLanguage.instance.strings;

    // Falls der Nutzer einen Namen getippt, aber keinen Vorschlag
    // angetippt hat: Kunden trotzdem automatisch anlegen/finden.
    if (_selectedCustomer == null &&
        _customerController.text.trim().isNotEmpty) {
      _selectedCustomer =
          await _customerRepository.getOrCreate(_customerController.text);
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.pleaseSelectCustomer)),
      );
      return;
    }

    if (_constructionSiteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.pleaseEnterSite)),
      );
      return;
    }

    final hasAnyDay = _days.any((day) => day.isFilled);

    if (!hasAnyDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.pleaseSelectAtLeastOneDay)),
      );
      return;
    }

    final header = WorkReport(
      reportType: 'week',
      date: _weekStart.toIso8601String(),
      customerId: _selectedCustomer!.id!,
      constructionSite: _constructionSiteController.text.trim(),
      startTime: '',
      endTime: '',
      breakMinutes: 0,
      activity: '',
    );

    int reportId;

    if (_isEditing) {
      reportId = widget.report!.id!;

      await _workReportRepository.update(
        header.copyWith(id: reportId),
      );

      await _dayRepository.deleteByReportId(reportId);
    } else {
      reportId = await _workReportRepository.insert(header);
    }

    for (final day in _days) {
      if (!day.isFilled) continue;

      await _dayRepository.insert(
        WorkReportDay(
          reportId: reportId,
          weekday: day.weekday,
          startTime: day.startTime != null ? _formatTime(day.startTime) : "",
          endTime: day.endTime != null ? _formatTime(day.endTime) : "",
          breakMinutes: day.breakMinutes,
          activity: day.activityController.text.trim(),
        ),
      );
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _deleteWeekReport() async {
    final t = AppLanguage.instance.strings;

    final delete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.deleteWeekReportTitle),
          content: Text(t.deleteWeekReportConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.delete),
            ),
          ],
        );
      },
    );

    if (delete != true) return;

    await _dayRepository.deleteByReportId(widget.report!.id!);
    await _workReportRepository.delete(widget.report!.id!);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLanguage.instance.strings;
    final labels = _weekdayLabels(t);
    final total = _weekTotal;
    final totalHours = total.inHours;
    final totalMinutes = total.inMinutes.remainder(60);

    return Scaffold(
      appBar: AppBar(title: Text(t.newWeekReportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _customerController,
            onChanged: _searchCustomers,
            onTapOutside: (_) {
              setState(() {
                _customerSuggestions.clear();
                _showCustomerSuggestions = false;
              });
              FocusScope.of(context).unfocus();
            },
            onEditingComplete: () async {
              if (_customerController.text.trim().isEmpty) return;

              final customer = await _customerRepository.getOrCreate(
                _customerController.text,
              );

              setState(() {
                _selectedCustomer = customer;
                _customerController.text = customer.name;
                _customerSuggestions.clear();
                _showCustomerSuggestions = false;
              });

              FocusScope.of(context).nextFocus();
            },
            decoration: InputDecoration(
              labelText: t.customer,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_showCustomerSuggestions &&
              _customerController.text.trim().isNotEmpty)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    _customerSuggestions.length + (_customerExists ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index == _customerSuggestions.length) {
                    return ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(
                        t.createNewCustomer.replaceAll(
                          '{name}',
                          _customerController.text,
                        ),
                      ),
                      onTap: () async {
                        final customer =
                            await _customerRepository.getOrCreate(
                          _customerController.text,
                        );

                        setState(() {
                          _selectedCustomer = customer;
                          _customerController.text = customer.name;
                          _customerSuggestions.clear();
                          _showCustomerSuggestions = false;
                        });
                      },
                    );
                  }

                  final customer = _customerSuggestions[index];

                  return ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(customer.name),
                    onTap: () {
                      setState(() {
                        _selectedCustomer = customer;
                        _customerController.text = customer.name;
                        _customerSuggestions.clear();
                        _showCustomerSuggestions = false;
                      });
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          TextField(
            controller: _constructionSiteController,
            onChanged: _searchConstructionSites,
            onTapOutside: (_) {
              setState(() {
                _constructionSuggestions.clear();
                _showConstructionSuggestions = false;
              });
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              labelText: t.constructionSite,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_showConstructionSuggestions &&
              _constructionSiteController.text.trim().isNotEmpty)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _constructionSuggestions.length + 1,
                itemBuilder: (context, index) {
                  if (index == _constructionSuggestions.length) {
                    return ListTile(
                      leading: const Icon(Icons.add_location_alt),
                      title: Text(
                        t.createNewSite.replaceAll(
                          '{name}',
                          _constructionSiteController.text,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _constructionSuggestions.clear();
                          _showConstructionSuggestions = false;
                        });
                      },
                    );
                  }

                  final site = _constructionSuggestions[index];

                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(site),
                    onTap: () {
                      setState(() {
                        _constructionSiteController.text = site;
                        _constructionSuggestions.clear();
                        _showConstructionSuggestions = false;
                      });
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(t.weekStartLabel),
              subtitle: Text(_formatDate(_weekStart)),
              onTap: _pickWeekStart,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            t.daysLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 8),

          ..._days.map((day) {
            final date = _weekStart.add(Duration(days: day.weekday - 1));

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${labels[day.weekday - 1]}, ${_formatDate(date)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickTime(day, isStart: true),
                            child: Text(
                              "${t.start} ${_formatTime(day.startTime)}",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickTime(day, isStart: false),
                            child: Text(
                              "${t.end} ${_formatTime(day.endTime)}",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(t.pause),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            if (day.breakMinutes == 0) return;
                            setState(() => day.breakMinutes -= 15);
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text("${day.breakMinutes} ${t.minutesShort}"),
                        IconButton(
                          onPressed: () {
                            setState(() => day.breakMinutes += 15);
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: day.activityController,
                      decoration: InputDecoration(
                        labelText: t.activity,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      maxLines: 2,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(t.weeklyWorkingTime),
              trailing: Text(
                "$totalHours ${t.hoursShort} ${totalMinutes.toString().padLeft(2, '0')} ${t.minutesShort}.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _saveWeekReport,
              child: Text(
                _isEditing ? t.saveChanges : t.save,
              ),
            ),
          ),

          if (_isEditing) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete),
                label: Text(t.deleteReport),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: _deleteWeekReport,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
