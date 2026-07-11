import 'package:flutter/material.dart';
import '../../database/customer_repository.dart';
import '../../models/customer.dart';

class NewWorkReportPage extends StatefulWidget {
  const NewWorkReportPage({super.key});

  @override
  State<NewWorkReportPage> createState() => _NewWorkReportPageState();
}

class _NewWorkReportPageState extends State<NewWorkReportPage> {
  final CustomerRepository _customerRepository = CustomerRepository();

  Customer? _selectedCustomer;
  List<Customer> _customerSuggestions = [];
  
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _constructionSiteController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 15, minute: 30);

  int _breakMinutes = 30;

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
    if (text.trim().isEmpty) {
      setState(() {
        _customerSuggestions = [];
      });
      return;
    }

    final customers =
        await _customerRepository.searchCustomers(text);

    setState(() {
      _customerSuggestions = customers;
    });
  }
  @override
  Widget build(BuildContext context) {
    final h = _workingDuration.inHours;
    final m = _workingDuration.inMinutes.remainder(60);

    return Scaffold(
      appBar: AppBar(title: const Text("Neuer Arbeitsbericht")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text("Datum"),
            subtitle: Text(_formatDate(_selectedDate)),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customerController,

            onChanged: _searchCustomers,

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
             });

             FocusScope.of(context).nextFocus();
           },
            decoration: const InputDecoration(
              labelText: "Kunde / Firma",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _constructionSiteController,
            decoration: const InputDecoration(
              labelText: "Baustelle",
              border: OutlineInputBorder(),
            ),
          ),
          if (_customerSuggestions.isNotEmpty)
             Card(
               margin: const EdgeInsets.only(top: 8),
               child: ListView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: _customerSuggestions.length,
                 itemBuilder: (context, index) {
                   final customer = _customerSuggestions[index];

                   return ListTile(
                     leading: const Icon(Icons.business),
                     title: Text(customer.name),
                     onTap: () {
                       setState(() {
                         _selectedCustomer = customer;
                         _customerController.text = customer.name;
                         _customerSuggestions.clear();
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
                    title: const Text("Beginn"),
                    subtitle: Text(_formatTime(_startTime)),
                    onTap: _pickStartTime,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: ListTile(
                    title: const Text("Ende"),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Text("Pause", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: _decreaseBreak,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text("$_breakMinutes Min"),
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
              title: const Text("Arbeitszeit"),
              trailing: Text(
                "$h Std. ${m.toString().padLeft(2, '0')} Min.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _activityController,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: "Tätigkeit",
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Speichern"),
            ),
          ),
        ],
      ),
    );
  }
}
