import 'package:flutter/material.dart';

import '../../database/material_repository.dart';
import '../../models/material_item.dart';

class NewMaterialPage extends StatefulWidget {
  final MaterialItem? material;

  const NewMaterialPage({super.key, this.material});

  @override
  State<NewMaterialPage> createState() => _NewMaterialPageState();
}

class _NewMaterialPageState extends State<NewMaterialPage> {
  final MaterialRepository _repository = MaterialRepository();

  final _nameController = TextEditingController();
  final _articleController = TextEditingController();
  final _unitController = TextEditingController();
  final _categoryController = TextEditingController();

  bool get _editing => widget.material != null;

  @override
  void initState() {
    super.initState();

    if (widget.material != null) {
      _nameController.text = widget.material!.name;
      _articleController.text = widget.material!.articleNumber;
      _unitController.text = widget.material!.unit;
      _categoryController.text = widget.material!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _articleController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    final material = MaterialItem(
      id: widget.material?.id,
      name: _nameController.text.trim(),
      articleNumber: _articleController.text.trim(),
      unit: _unitController.text.trim(),
      category: _categoryController.text.trim(),
    );

    if (_editing) {
      await _repository.update(material);
    } else {
      await _repository.insert(material);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? "Material bearbeiten" : "Neues Material"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Material"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _articleController,
            decoration: const InputDecoration(labelText: "Artikelnummer"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _unitController,
            decoration: const InputDecoration(labelText: "Einheit"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: "Kategorie"),
          ),
          const SizedBox(height: 30),
          FilledButton(
            onPressed: _save,
            child: Text(_editing ? "Speichern" : "Material anlegen"),
          ),
        ],
      ),
    );
  }
}
