import 'package:flutter/material.dart';
import '../customers/customers_page.dart';

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

          const Text(
            "Willkommen",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          _menuCard(
            Icons.description,
            "Arbeitsbericht erstellen",
            "Neuen Bericht beginnen",
          ),

          _menuCard(
            Icons.folder,
            "Berichte",
            "Vorhandene Berichte ansehen",
          ),

          _menuCard(
             Icons.people,
             "Kunden",
             "Kunden verwalten",
             onTap: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (_) => const CustomersPage(),
                 ),
               );
             },
           ),

          _menuCard(
            Icons.settings,
            "Einstellungen",
            "Sprache und Optionen",
          ),

          const SizedBox(height: 25),

          const Center(
            child: Text(
              "Version 0.1.0",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
      IconData icon,
      String title,
      String subtitle, {
        VoidCallback? onTap,
        }) 
        {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 34),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}