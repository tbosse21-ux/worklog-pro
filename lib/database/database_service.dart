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
      version: 4,
      onCreate: (db, version) async {
        // Kunden
        await db.execute("""
          CREATE TABLE customers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        """);

        // Firma
        await db.execute("""
          CREATE TABLE company(
            id INTEGER PRIMARY KEY,
            companyName TEXT,
            contactPerson TEXT,
            street TEXT,
            zipCode TEXT,
            city TEXT,
            phone TEXT,
            mobile TEXT,
            email TEXT,
            website TEXT,
            logoPath TEXT
          )
        """);

        // Wochenbericht (Kopf)
        await db.execute("""
          CREATE TABLE work_reports(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerId INTEGER NOT NULL,
            constructionSite TEXT NOT NULL,
            calendarWeek INTEGER NOT NULL,
            year INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            FOREIGN KEY(customerId) REFERENCES customers(id)
          )
        """);

        // Tage eines Berichtes
        await db.execute("""
          CREATE TABLE work_report_days(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reportId INTEGER NOT NULL,
            weekday INTEGER NOT NULL,
            startTime TEXT,
            endTime TEXT,
            breakMinutes INTEGER,
            activity TEXT,
            FOREIGN KEY(reportId) REFERENCES work_reports(id)
          )
        """);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute("DROP TABLE IF EXISTS work_reports;");
          await db.execute("DROP TABLE IF EXISTS work_report_days;");

          await db.execute("""
            CREATE TABLE work_reports(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customerId INTEGER NOT NULL,
              constructionSite TEXT NOT NULL,
              calendarWeek INTEGER NOT NULL,
              year INTEGER NOT NULL,
              createdAt TEXT NOT NULL,
              FOREIGN KEY(customerId) REFERENCES customers(id)
            )
          """);

          await db.execute("""
            CREATE TABLE work_report_days(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              reportId INTEGER NOT NULL,
              weekday INTEGER NOT NULL,
              startTime TEXT,
              endTime TEXT,
              breakMinutes INTEGER,
              activity TEXT,
              FOREIGN KEY(reportId) REFERENCES work_reports(id)
            )
          """);
        }
      },
    );
  }
}