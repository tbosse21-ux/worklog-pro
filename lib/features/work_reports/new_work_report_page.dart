import 'package:flutter/material.dart';
import '../../database/customer_repository.dart';
import '../../localization/app_language.dart';
import '../../models/customer.dart';
import '../../database/work_report_repository.dart';
import '../../models/work_report.dart';

class NewWorkReportPage extends StatefulWidget {
  final WorkReport? report;

  const NewWorkReportPage({
    super.key,
    this.report,
  });

  @override
  State<NewWorkReportPage> createState() => _NewWorkReportPageState();
}

class _NewWorkReportPageState extends State<NewWorkReportPage> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final WorkReportRepository _workReportRepository = WorkReportRepository();

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
  final TextEditingController _activityController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 15, minute: 30);

  int _breakMinutes = 30;

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

    setState(() {
      _selectedCustomer = customer;

      _customerController.text = customer?.name ?? "";

      _constructionSiteController.text = report.constructionSite;

      _activityController.text = report.activity;

      _selectedDate = DateTime.parse(report.date);

      final start = report.startTime.split(":");
      _startTime = TimeOfDay(
        hour: int.parse(start[0]),
        minute: int.parse(start[1]),
      );

      final end = report.endTime.split(":");
      _endTime = TimeOfDay(
        hour: int.parse(end[0]),
        minute: int.parse(end[1]),
      );

      _breakMinutes = report.breakMinutes;
    });
  }

  @override
  void dispose() {
    _customerController.dispose();
    _constructionSiteController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _increaseBreak() {
    setState(() => _breakMinutes += 15);
  }

  void _decreaseBreak() {
    if (_breakMinutes == 0) return;
    setState(() => _breakMinutes -= 15);
  }

  Duration get _workingDuration {
    final start = _startTime.hour * 60 + _startTime.minute;
    final end = _endTime.hour * 60 + _endTime.minute;
    final minutes = (end - start - _breakMinutes).clamp(0, 24 * 60);
    return Duration(minutes: minutes);
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

  String _formatTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

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

    if (_selectedCustomer == null) {
      return;
    }

    final sites = await _workReportRepository.getConstructionSites(
      _selectedCustomer!.id!,
    );

    setState(() {
      _constructionSuggestions = sites
          .where(
            (site) => site.toLowerCase().contains(text.toLowerCase()),
          )
          .toList();
    });
  }

  Future<void> _saveWorkReport() async {
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

    final report = WorkReport(
      reportType: 'day',
      date: _selectedDate.toIso8601String(),
      customerId: _selectedCustomer!.id!,
      constructionSite: _constructionSiteController.text.trim(),
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      breakMinutes: _breakMinutes,
      activity: _activityController.text.trim(),
    );

    if (_isEditing) {
      await _workReportRepository.update(
        report.copyWith(
          id: widget.report!.id,
        ),
      );
    } else {
      await _workReportRepository.insert(report);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLanguage.instance.strings;
    final h = _workingDuration.inHours;
    final m = _workingDuration.inMinutes.remainder(60);

    return Scaffold(
      appBar: AppBar(title: Text(t.newWorkReport)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(t.date),
            subtitle: Text(_formatDate(_selectedDate)),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
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
              if (_customerController.text.trim().isEmpty) {
                return;
              }

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
                itemCount: _customerSuggestions.length +
                    (_customerExists ? 0 : 1),
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

                        FocusScope.of(context).nextFocus();
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

                      FocusScope.of(context).nextFocus();
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

                        FocusScope.of(context).nextFocus();
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

                      FocusScope.of(context).nextFocus();
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Card(
                  child: ListTile(
                    title: Text(t.start),
                    subtitle: Text(_formatTime(_startTime)),
                    onTap: _pickStartTime,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: ListTile(
                    title: Text(t.end),
                    subtitle: Text(_formatTime(_endTime)),
                    onTap: _pickEndTime,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(t.pause, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: _decreaseBreak,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text("$_breakMinutes ${t.minutesShort}"),
                  IconButton(
                    onPressed: _increaseBreak,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(t.workingTime),
              trailing: Text(
                "$h ${t.hoursShort} ${m.toString().padLeft(2, '0')} ${t.minutesShort}.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _activityController,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: t.activity,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveWorkReport,
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final delete = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(t.deleteReportConfirmTitle),
                            content: Text(t.deleteReportConfirmContent),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text(t.cancel),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text(t.delete),
                              ),
                            ],
                          );
                        },
                      );

                      if (delete != true) return;
                      await _workReportRepository.delete(
                        widget.report!.id!,
                      );

                      if (!mounted) return;

                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
