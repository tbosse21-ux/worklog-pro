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

    final t = AppLanguage.instance.strings;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(t.languageChangedTitle),
        content: Text(t.languageChangedContent),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(t.ok),
          ),
        ],
      ),
    );

    if (!mounted) return;
    RestartWidget.restartApp(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLanguage.instance.strings;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              t.language,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
            title: Text(t.companyData),
            subtitle: Text(t.editCompanyData),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompanyPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(t.pdfExportTitle),
            subtitle: Text(t.pdfExportSubtitle),
          ),

          ListTile(
            leading: const Icon(Icons.save),
            title: Text(t.backupTitle),
            subtitle: Text(t.backupSubtitle),
          ),
        ],
      ),
    );
  }
}
