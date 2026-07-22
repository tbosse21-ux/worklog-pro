import '../models/work_report_day.dart';
import 'database_service.dart';

class WorkReportDayRepository {
  Future<int> insert(WorkReportDay day) async {
    final db = await DatabaseService.database;

    return await db.insert(
      'work_report_days',
      day.toMap(),
    );
  }

  Future<List<WorkReportDay>> getByReportId(int reportId) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'work_report_days',
      where: 'reportId = ?',
      whereArgs: [reportId],
      orderBy: 'weekday ASC',
    );

    return maps.map((e) => WorkReportDay.fromMap(e)).toList();
  }

  Future<void> deleteByReportId(int reportId) async {
    final db = await DatabaseService.database;

    await db.delete(
      'work_report_days',
      where: 'reportId = ?',
      whereArgs: [reportId],
    );
  }
}
