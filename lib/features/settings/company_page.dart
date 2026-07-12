import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import '../../models/company.dart';
import '../../repositories/company_repository.dart';
import '../../localization/app_language.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final _repository = CompanyRepository();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _logoPath;
  final _companyName = TextEditingController();
  final _contactPerson = TextEditingController();
  final _street = TextEditingController();
  final _zipCode = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    final company = await _repository.load();

    if (company == null) return;

    _companyName.text = company.companyName;
    _contactPerson.text = company.contactPerson;
    _street.text = company.street;
    _zipCode.text = company.zipCode;
    _city.text = company.city;
    _phone.text = company.phone;
    _mobile.text = company.mobile;
    _email.text = company.email;
    _website.text = company.website;
    _logoPath = company.logoPath;
  }

  Future<void> _save() async {
    final t = AppLanguage.instance.strings;
    final company = Company(
      id: 1,
      companyName: _companyName.text,
      contactPerson: _contactPerson.text,
      street: _street.text,
      zipCode: _zipCode.text,
      city: _city.text,
      phone: _phone.text,
      mobile: _mobile.text,
      email: _email.text,
      website: _website.text,
      logoPath: _logoPath ?? "",
    );

    await _repository.save(company);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.companySaved)));
  }

  Future<void> _pickLogo() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;

    setState(() {
      _logoPath = image.path;
    });
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _companyName.dispose();
    _contactPerson.dispose();
    _street.dispose();
    _zipCode.dispose();
    _city.dispose();
    _phone.dispose();
    _mobile.dispose();
    _email.dispose();
    _website.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLanguage.instance.strings;

    return Scaffold(
      appBar: AppBar(title: Text(t.companyData)),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        t.companyLogo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _logoPath == null || _logoPath!.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text(t.selectLogo),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_logoPath!),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      FilledButton.icon(
                        onPressed: _pickLogo,
                        icon: const Icon(Icons.photo),
                        label: Text(t.selectLogo),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _field(t.companyName, _companyName),
              _field(t.contactPerson, _contactPerson),
              _field(t.street, _street),

              Row(
                children: [
                  Expanded(flex: 2, child: _field(t.zipCode, _zipCode)),

                  const SizedBox(width: 12),

                  Expanded(flex: 5, child: _field(t.city, _city)),
                ],
              ),

              _field(t.phone, _phone),
              _field(t.mobile, _mobile),
              _field(t.email, _email),
              _field(t.website, _website),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(t.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
