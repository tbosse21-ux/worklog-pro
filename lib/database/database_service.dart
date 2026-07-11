import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(
      await getDatabasesPath(),
      'worklog_pro.db',
    );

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE customers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        """);

        await db.execute("""
          CREATE TABLE work_reports(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            customerId INTEGER NOT NULL,
            constructionSite TEXT NOT NULL,
            startTime TEXT NOT NULL,
            endTime TEXT NOT NULL,
            breakMinutes INTEGER NOT NULL,
            activity TEXT NOT NULL,
            FOREIGN KEY(customerId) REFERENCES customers(id)
          )
        """);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("""
            CREATE TABLE work_reports(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              customerId INTEGER NOT NULL,
              constructionSite TEXT NOT NULL,
              startTime TEXT NOT NULL,
              endTime TEXT NOT NULL,
              breakMinutes INTEGER NOT NULL,
              activity TEXT NOT NULL,
              FOREIGN KEY(customerId) REFERENCES customers(id)
            )
          """);
        }
      },
    );
  }
}
