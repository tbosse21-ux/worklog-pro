import 'package:flutter/material.dart';

import '../../database/customer_repository.dart';
import '../../models/customer.dart';
import 'new_customer_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final CustomerRepository _repository = CustomerRepository();

  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await _repository.getAll();

    setState(() {
      _customers = customers;
      _filteredCustomers = customers;
    });
  }

  Future<void> _openNewCustomer() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const NewCustomerPage(),
      ),
    );

    if (saved == true) {
      await _loadCustomers();
    }
  }

  Future<void> _editCustomer(Customer customer) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NewCustomerPage(customer: customer),
      ),
    );

    if (saved == true) {
      await _loadCustomers();
    }
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kunde löschen"),
        content: Text(
          'Soll "${customer.name}" wirklich gelöscht werden?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Abbrechen"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Löschen"),
          ),
        ],
      ),
    );

    if (delete == true) {
      await _repository.delete(customer.id!);
      await _loadCustomers();
    }
  }

  void _search(String value) {
    final search = value.toLowerCase();

    setState(() {
      _filteredCustomers = _customers.where((customer) {
        return customer.name.toLowerCase().contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kunden"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: _search,
              decoration: InputDecoration(
                hintText: "Kunde suchen...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Neuer Kunde"),
              onTap: _openNewCustomer,
            ),

            const Divider(),

            Expanded(
              child: _filteredCustomers.isEmpty
                  ? const Center(
                      child: Text(
                        "Noch keine Kunden vorhanden.",
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];

                        return ListTile(
                          leading: const Icon(Icons.business),
                          title: Text(customer.name),
                          subtitle: const Text(
                            "Tippen = Bearbeiten | Lange drücken = Löschen",
                          ),
                          onTap: () => _editCustomer(customer),
                          onLongPress: () => _deleteCustomer(customer),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}