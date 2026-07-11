import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Einstellungen"),
      ),
      body: const Center(
        child: Text(
          "Einstellungen folgen später.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}