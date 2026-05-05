import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

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

  // v2: adds an `isLocal` flag to each cache table so server sync
  // (insertAll) can leave admin-created/edited rows untouched.
  static const int _schemaVersion = 2;

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return openDatabase(
        'smart_campus.db',
        version: _schemaVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
    final dbPath = join(await getDatabasesPath(), 'smart_campus.db');
    return openDatabase(
      dbPath,
      version: _schemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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
        isBookmarked INTEGER,
        isLocal INTEGER NOT NULL DEFAULT 0
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
        isReminded INTEGER,
        isLocal INTEGER NOT NULL DEFAULT 0
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
        status TEXT,
        isLocal INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Existing rows are server-origin by definition — default 0.
      await db.execute(
        'ALTER TABLE announcements '
        'ADD COLUMN isLocal INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE events '
        'ADD COLUMN isLocal INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE timetable_items '
        'ADD COLUMN isLocal INTEGER NOT NULL DEFAULT 0',
      );
    }
  }
}
