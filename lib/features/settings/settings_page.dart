import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../localization/app_strings.dart';
import '../../localization/de.dart';
import '../../localization/en.dart';
import '../../localization/language_service.dart';
import '../../localization/pl.dart';
import '../../restart_widget.dart';
import 'company_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _language = "Deutsch";

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    await LanguageService.loadLanguage();

    if (!mounted) return;

    setState(() {
      if (AppStrings.current is GermanStrings) {
        _language = "Deutsch";
      } else if (AppStrings.current is EnglishStrings) {
        _language = "English";
      } else {
        _language = "Polski";
      }
    });
  }

  Future<void> _changeLanguage(String language) async {
    await AppLanguage.instance.changeLanguage(language);

    if (!mounted) return;

    setState(() {
      _language = language;
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Sprache geändert"),
        content: const Text(
          "Die App wird jetzt neu geladen, damit alle Änderungen übernommen werden.",
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    RestartWidget.restartApp(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Einstellungen")),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          const ListTile(
            leading: Icon(Icons.language),
            title: Text(
              "Sprache",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          RadioListTile<String>(
            value: "Deutsch",
            groupValue: _language,
            title: const Text("Deutsch"),
            onChanged: (value) {
              if (value != null) {
                _changeLanguage(value);
              }
            },
          ),

          RadioListTile<String>(
            value: "English",
            groupValue: _language,
            title: const Text("English"),
            onChanged: (value) {
              if (value != null) {
                _changeLanguage(value);
              }
            },
          ),

          RadioListTile<String>(
            value: "Polski",
            groupValue: _language,
            title: const Text("Polski"),
            onChanged: (value) {
              if (value != null) {
                _changeLanguage(value);
              }
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.business),
            title: Text(AppLanguage.instance.strings.companyData),
            subtitle: Text(AppLanguage.instance.strings.editCompanyData),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompanyPage()),
              );
            },
          ),

          const ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text("PDF"),
            subtitle: Text("kommt später"),
          ),

          const ListTile(
            leading: Icon(Icons.save),
            title: Text("Backup"),
            subtitle: Text("kommt später"),
          ),
        ],
      ),
    );
  }
}
