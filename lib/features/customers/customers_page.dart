import 'package:flutter/material.dart';
import 'new_customer_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final List<String> _customers = [];
 
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
              decoration: InputDecoration(
                hintText: "Kunde suchen...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

             Expanded(
               child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text("Neuer Kunde"),
                      onTap: () async {
                        final result = await Navigator.push<String>(
                         context,
                         MaterialPageRoute(
                           builder: (_) => const NewCustomerPage(),
                         ),
                       );

                       if (result != null && result.isNotEmpty) {
                         setState(() {
                           _customers.add(result);
                           _customers.sort();
                         });
                       }
                     },
                   ),

                  const Divider(),

                   ..._customers.map(
                     (customer) => ListTile(
                      title: Text(customer),
                     ),
                   ),
                 ],
               ),
              )
                        ],
        ),
      ),
    );
  }
}