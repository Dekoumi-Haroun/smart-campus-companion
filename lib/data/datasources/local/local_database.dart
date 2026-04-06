import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton that manages the on-device SQLite database.
///
/// Provides a single [database] getter that lazily initialises the DB
/// and creates the three cache tables on first run.
class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  Database? _database;

  /// Returns the opened database, creating it on first access.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'smart_campus.db');
    return openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE announcements (
        id TEXT PRIMARY KEY,
        title TEXT,
        body TEXT,
        category TEXT,
        summary TEXT,
        source TEXT,
        date TEXT,
        readTime INTEGER,
        isBookmarked INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        location TEXT,
        dateTime TEXT,
        imageUrl TEXT,
        endTime TEXT,
        category TEXT,
        attendeeCount INTEGER,
        isReminded INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE timetable_items (
        id TEXT PRIMARY KEY,
        courseName TEXT,
        instructor TEXT,
        room TEXT,
        dayOfWeek INTEGER,
        startTime TEXT,
        endTime TEXT,
        status TEXT
      )
    ''');
  }
}
