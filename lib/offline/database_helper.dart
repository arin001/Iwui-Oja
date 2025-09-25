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
    final db = await openDatabase(
      join(await getDatabasesPath(), 'app.db'),
      version: 3,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE downloads(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            assetId TEXT,
            title TEXT,
            localPath TEXT,
            progress INTEGER DEFAULT 0,
            status TEXT DEFAULT 'queued',
            sizeBytes INTEGER,
            downloadedAt TEXT,
            filename TEXT,
            downloaded_at TEXT,
            path TEXT,
            url TEXT
          )
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        final cols = (await db.rawQuery("PRAGMA table_info(downloads)"))
            .map((r) => r['name'].toString()).toList();
        if (!cols.contains('path')) await db.execute("ALTER TABLE downloads ADD COLUMN path TEXT");
        if (!cols.contains('url')) await db.execute("ALTER TABLE downloads ADD COLUMN url TEXT");
        // copy localPath -> path if present
        if (cols.contains('localPath')) {
          await db.execute("UPDATE downloads SET path = localPath WHERE path IS NULL OR path = ''");
        }
      },
    );

    // Verify schema after DB open
    final cols = await db.rawQuery("PRAGMA table_info(downloads)");
    debugPrint('downloads schema: $cols');

    return db;
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