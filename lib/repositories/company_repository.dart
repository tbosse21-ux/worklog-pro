import 'package:sqflite/sqflite.dart';

import '../database/database_service.dart';
import '../models/company.dart';

class CompanyRepository {
  Future<void> save(Company company) async {
    final db = await DatabaseService.database;

    await db.insert(
      'company',
      company.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Company?> load() async {
    final db = await DatabaseService.database;

    final result = await db.query(
      'company',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Company.fromMap(result.first);
  }

  Future<void> delete() async {
    final db = await DatabaseService.database;

    await db.delete('company');
  }
}