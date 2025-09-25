import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'downloads.db');

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Verify schema after DB open
    final cols = await db.rawQuery("PRAGMA table_info(downloads)");
    debugPrint('downloads schema: $cols');

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filename TEXT,
        path TEXT,
        url TEXT,
        status TEXT,
        downloaded_at TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Check if columns exist before adding them
      final columns = await db.rawQuery("PRAGMA table_info(downloads)");
      final columnNames = columns.map((col) => col['name'] as String).toSet();

      if (!columnNames.contains('filename')) {
        await db.execute('ALTER TABLE downloads ADD COLUMN filename TEXT');
      }
      if (!columnNames.contains('downloaded_at')) {
        await db.execute('ALTER TABLE downloads ADD COLUMN downloaded_at TEXT');
      }
    }
  }

  Future<int> insertDownloadRecord(Map<String, dynamic> row) async {
    debugPrint('insertDownloadRecord called: ${row.keys}');
    debugPrint(StackTrace.current.toString());
    final db = await database;
    return await db.insert('downloads', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateDownload(String filename, Map<String, dynamic> download) async {
    final db = await database;
    return await db.update('downloads', download, where: 'filename = ?', whereArgs: [filename]);
  }

  Future<List<Map<String, dynamic>>> getAllDownloads() async {
    final db = await database;
    return await db.query('downloads');
  }

  Future<Map<String, dynamic>?> getDownload(String filename) async {
    final db = await database;
    final results = await db.query('downloads', where: 'filename = ?', whereArgs: [filename]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> deleteDownload(String filename) async {
    final db = await database;
    return await db.delete('downloads', where: 'filename = ?', whereArgs: [filename]);
  }

  Future<int> getCompletedDownloadsCount() async {
    final db = await database;
    final result = await db.rawQuery("SELECT COUNT(*) as count FROM downloads WHERE status = 'completed'");
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}