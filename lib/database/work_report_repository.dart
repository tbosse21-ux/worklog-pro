import '../models/work_report.dart';
import 'database_service.dart';

class WorkReportRepository {
  Future<int> insert(WorkReport workReport) async {
    final db = await DatabaseService.database;

    return await db.insert(
      'work_reports',
      workReport.toMap(),
    );
  }

  Future<void> update(WorkReport workReport) async {
    final db = await DatabaseService.database;

    await db.update(
      'work_reports',
      workReport.toMap(),
      where: 'id = ?',
      whereArgs: [workReport.id],
    );
  }

  Future<WorkReport?> getById(int id) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'work_reports',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return WorkReport.fromMap(maps.first);
  }

  Future<List<WorkReport>> getAll() async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'work_reports',
      orderBy: 'date DESC',
    );

    return maps
        .map((e) => WorkReport.fromMap(e))
        .toList();
  }

  Future<List<WorkReport>> getByCustomer(int customerId) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'work_reports',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );

    return maps
        .map((e) => WorkReport.fromMap(e))
        .toList();
  }

  Future<List<String>> getConstructionSites(int customerId) async {
    final db = await DatabaseService.database;

    final maps = await db.rawQuery(
      '''
      SELECT DISTINCT constructionSite
      FROM work_reports
      WHERE customerId = ?
      ORDER BY constructionSite ASC
      ''',
      [customerId],
    );

    return maps
        .map((e) => e['constructionSite'] as String)
        .toList();
  }

  Future<void> delete(int id) async {
    final db = await DatabaseService.database;

    await db.delete(
      'work_reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}