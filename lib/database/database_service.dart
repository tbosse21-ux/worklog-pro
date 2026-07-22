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
      version: 6,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Frühe Entwicklungsphase: bei jedem Schemawechsel sauber neu aufbauen.
        // Kunden- und Firmendaten bleiben erhalten, nur die Berichte werden
        // neu angelegt (Testberichte gehen dabei verloren).
        await db.execute("DROP TABLE IF EXISTS work_report_days;");
        await db.execute("DROP TABLE IF EXISTS work_reports;");

        await _createSchema(db, skipCustomersAndCompany: true);
      },
    );
  }

  static Future<void> _createSchema(
    Database db, {
    bool skipCustomersAndCompany = false,
  }) async {
    if (!skipCustomersAndCompany) {
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
    }

    // Arbeitsberichte (Kopf) – für Tages- UND Wochenberichte.
    // reportType unterscheidet 'day' (Zeiten direkt hier) von 'week'
    // (Zeiten stecken dann in work_report_days).
    await db.execute("""
      CREATE TABLE work_reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reportType TEXT NOT NULL DEFAULT 'day',
        date TEXT NOT NULL,
        customerId INTEGER NOT NULL,
        constructionSite TEXT NOT NULL,
        startTime TEXT NOT NULL DEFAULT '',
        endTime TEXT NOT NULL DEFAULT '',
        breakMinutes INTEGER NOT NULL DEFAULT 0,
        activity TEXT,
        FOREIGN KEY(customerId) REFERENCES customers(id)
      )
    """);

    // Einzelne Tage eines Wochenberichts.
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
}
