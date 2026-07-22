import 'package:flutter/material.dart';

import '../../database/material_repository.dart';
import '../../models/material_item.dart';
import '../../localization/app_language.dart';
import 'new_material_page.dart';

class SelectMaterialPage extends StatefulWidget {
  const SelectMaterialPage({super.key});

  @override
  State<SelectMaterialPage> createState() => _SelectMaterialPageState();
}

class _SelectMaterialPageState extends State<SelectMaterialPage> {
  final MaterialRepository _repository = MaterialRepository();

  final TextEditingController _searchController = TextEditingController();

  List<MaterialItem> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    final list = await _repository.getAll();

    if (!mounted) return;

    setState(() {
      _materials = list;
    });
  }

  Future<void> _search(String value) async {
    if (value.trim().isEmpty) {
      _loadMaterials();
      return;
    }

    final list = await _repository.search(value);

    if (!mounted) return;

    setState(() {
      _materials = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLanguage.instance.strings.material)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Material suchen",
                border: OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: Text(AppLanguage.instance.strings.newMaterial),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewMaterialPage()),
                  );

                  await _loadMaterials();
                },
              ),
            ),
          ),

          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _materials.length,
              itemBuilder: (context, index) {
                final material = _materials[index];

                return ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(material.name),
                  subtitle: Text(
                    "${material.articleNumber} • ${material.unit}",
                  ),
                  onTap: () {
                    Navigator.pop(context, material);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
