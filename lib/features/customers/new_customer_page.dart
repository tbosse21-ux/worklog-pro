import 'package:flutter/material.dart';
import '../../database/customer_repository.dart';
import '../../models/customer.dart';

class NewCustomerPage extends StatefulWidget {
  const NewCustomerPage({super.key});

  @override
  State<NewCustomerPage> createState() => _NewCustomerPageState();
}

class _NewCustomerPageState extends State<NewCustomerPage> {
  final TextEditingController _nameController = TextEditingController();
  final CustomerRepository _repository = CustomerRepository();
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte Kunde / Firma eingeben."),
        ),
      );
      return;
    }

    // Später speichern wir hier in der Datenbank
    Navigator.pop(
      context,
      _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Neuer Kunde"),
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
                child: const Text(
                  "Speichern",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}