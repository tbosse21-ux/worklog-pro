import 'package:flutter/material.dart';

import '../../database/customer_repository.dart';
import '../../models/customer.dart';

class NewCustomerPage extends StatefulWidget {
  final Customer? customer;

  const NewCustomerPage({
    super.key,
    this.customer,
  });

  @override
  State<NewCustomerPage> createState() => _NewCustomerPageState();
}

class _NewCustomerPageState extends State<NewCustomerPage> {
  final CustomerRepository _repository = CustomerRepository();
  final TextEditingController _nameController = TextEditingController();

  bool get _isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();

    if (_isEdit) {
      _nameController.text = widget.customer!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte Kunde / Firma eingeben."),
        ),
      );
      return;
    }

    if (_isEdit) {
      await _repository.update(
        widget.customer!.copyWith(
          name: name,
        ),
      );
    } else {
      await _repository.insert(
        Customer(name: name),
      );
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? "Kunde bearbeiten" : "Neuer Kunde",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Kunde / Firma *",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveCustomer,
                child: Text(
                  _isEdit ? "Änderungen speichern" : "Speichern",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}