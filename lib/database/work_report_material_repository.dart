import '../models/work_report_material.dart';
import 'database_service.dart';

class WorkReportMaterialRepository {
  Future<int> insert(WorkReportMaterial material) async {
    final db = await DatabaseService.database;

    return db.insert('work_report_materials', material.toMap());
  }

  Future<void> deleteByReport(int reportId) async {
    final db = await DatabaseService.database;

    await db.delete(
      'work_report_materials',
      where: 'reportId = ?',
      whereArgs: [reportId],
    );
  }

  Future<List<WorkReportMaterial>> getByReport(int reportId) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'work_report_materials',
      where: 'reportId = ?',
      whereArgs: [reportId],
      orderBy: 'id ASC',
    );

    return maps.map(WorkReportMaterial.fromMap).toList();
  }
}
