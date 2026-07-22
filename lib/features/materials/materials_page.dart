import 'package:flutter/material.dart';

import '../../database/material_repository.dart';
import '../../localization/app_language.dart';
import '../../models/material_item.dart';
import 'new_material_page.dart';

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({super.key});

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  final MaterialRepository _repository = MaterialRepository();

  final TextEditingController _searchController = TextEditingController();

  List<MaterialItem> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    final materials = await _repository.getAll();

    if (!mounted) return;

    setState(() {
      _materials = materials;
    });
  }

  Future<void> _search(String text) async {
    if (text.trim().isEmpty) {
      await _loadMaterials();
      return;
    }

    final materials = await _repository.search(text);

    if (!mounted) return;

    setState(() {
      _materials = materials;
    });
  }

  Future<void> _newMaterial() async {
    final saved = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewMaterialPage()),
    );

    if (saved == true) {
      _loadMaterials();
    }
  }

  Future<void> _editMaterial(MaterialItem material) async {
    final saved = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewMaterialPage(material: material)),
    );

    if (saved == true) {
      _loadMaterials();
    }
  }

  Future<void> _deleteMaterial(MaterialItem material) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Material löschen"),
        content: Text("Soll '${material.name}' wirklich gelöscht werden?"),
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

    if (delete != true) return;

    await _repository.delete(material.id!);

    _loadMaterials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLanguage.instance.strings.material),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: AppLanguage.instance.strings.importMaterial,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "CSV-/Sonepar-Import folgt in einer späteren Version.",
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "import",
            icon: const Icon(Icons.upload_file),
            label: const Text("Importieren"),
            onPressed: () {
              // kommt gleich
            },
          ),

          const SizedBox(height: 12),

          FloatingActionButton.extended(
            heroTag: "new",
            icon: const Icon(Icons.add),
            label: const Text("Material"),
            onPressed: _newMaterial,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Material suchen",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadMaterials();
                          setState(() {});
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (value) {
                _search(value);
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: _materials.isEmpty
                ? const Center(child: Text("Noch kein Material vorhanden."))
                : RefreshIndicator(
                    onRefresh: _loadMaterials,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: _materials.length,
                      itemBuilder: (context, index) {
                        final material = _materials[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.inventory_2),
                            ),
                            title: Text(
                              material.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${material.articleNumber} • ${material.unit}"
                              "\n${material.category}",
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == "edit") {
                                  _editMaterial(material);
                                }

                                if (value == "delete") {
                                  _deleteMaterial(material);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: "edit",
                                  child: Text("Bearbeiten"),
                                ),
                                PopupMenuItem(
                                  value: "delete",
                                  child: Text("Löschen"),
                                ),
                              ],
                            ),
                            onTap: () => _editMaterial(material),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
