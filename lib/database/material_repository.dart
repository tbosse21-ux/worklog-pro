import '../models/material_item.dart';
import 'database_service.dart';

class MaterialRepository {
  Future<int> insert(MaterialItem material) async {
    final db = await DatabaseService.database;

    return db.insert('materials', material.toMap());
  }

  Future<void> update(MaterialItem material) async {
    final db = await DatabaseService.database;

    await db.update(
      'materials',
      material.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await DatabaseService.database;

    await db.delete('materials', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MaterialItem>> getAll() async {
    final db = await DatabaseService.database;

    final maps = await db.query('materials', orderBy: 'name ASC');

    return maps.map(MaterialItem.fromMap).toList();
  }

  Future<List<MaterialItem>> search(String text) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'materials',
      where: 'name LIKE ? OR articleNumber LIKE ?',
      whereArgs: ['%$text%', '%$text%'],
      orderBy: 'name ASC',
    );

    return maps.map(MaterialItem.fromMap).toList();
  }

  Future<MaterialItem?> getById(int id) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return MaterialItem.fromMap(maps.first);
  }
}
