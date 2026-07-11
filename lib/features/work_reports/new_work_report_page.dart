import 'package:flutter/material.dart';

class NewWorkReportPage extends StatelessWidget {
  const NewWorkReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Neuer Arbeitsbericht"),
      ),
      body: const Center(
        child: Text(
          "Hier entsteht später der Arbeitsbericht.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}