import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'database_helper.dart';

Future<bool> deleteDownloadedFile(String? filePath) async {
  debugPrint('deleteDownloadedFile called with path: $filePath');
  if (filePath == null || filePath.isEmpty) {
    debugPrint('deleteDownloadedFile: null or empty path');
    return false;
  }
  try {
    final f = File(filePath);
    final exists = await f.exists();
    debugPrint('File exists check: $filePath -> $exists');

    // also try alternative column names e.g. localPath
    if (exists) {
      await f.delete();
      final stillExists = await f.exists();
      debugPrint('Deleted file: $filePath, still exists after delete: $stillExists');
      return !stillExists;
    }
    // try removing temp/partial variants
    final part = '$filePath.part';
    final tmp = '${p.withoutExtension(filePath)}.tmp';
    final partExists = await File(part).exists();
    final tmpExists = await File(tmp).exists();
    debugPrint('Checking variants: part=$partExists, tmp=$tmpExists');

    if (partExists) {
      await File(part).delete();
      debugPrint('Deleted part file: $part');
    }
    if (tmpExists) {
      await File(tmp).delete();
      debugPrint('Deleted tmp file: $tmp');
    }
    return false;
  } catch (e, st) {
    debugPrint('deleteDownloadedFile error: $e\n$st');
    return false;
  }
}

enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
}

class DownloadItem {
  final String assetId;
  final String title;
  final String? localPath;
  final int progress; // 0-100
  final DownloadStatus status;
  final int? sizeBytes;
  final DateTime? downloadedAt;

  DownloadItem({
    required this.assetId,
    required this.title,
    this.localPath,
    this.progress = 0,
    this.status = DownloadStatus.queued,
    this.sizeBytes,
    this.downloadedAt,
  });

  Map<String, dynamic> toJson() => {
    'assetId': assetId,
    'title': title,
    'localPath': localPath,
    'progress': progress,
    'status': status.name,
    'sizeBytes': sizeBytes,
    'downloadedAt': downloadedAt?.toIso8601String(),
  };

  static DownloadItem fromJson(Map<String, dynamic> j) => DownloadItem(
    assetId: j['assetId'],
    title: j['title'],
    localPath: j['localPath'],
    progress: j['progress'] ?? 0,
    status: DownloadStatus.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => DownloadStatus.queued,
    ),
    sizeBytes: j['sizeBytes'],
    downloadedAt: j['downloadedAt'] != null ? DateTime.parse(j['downloadedAt']) : null,
  );

  DownloadItem copyWith({
    String? assetId,
    String? title,
    String? localPath,
    int? progress,
    DownloadStatus? status,
    int? sizeBytes,
    DateTime? downloadedAt,
  }) {
    return DownloadItem(
      assetId: assetId ?? this.assetId,
      title: title ?? this.title,
      localPath: localPath ?? this.localPath,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }
}

class DownloadManager with ChangeNotifier {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final DatabaseHelper _db = DatabaseHelper();
  final Map<String, StreamSubscription?> _activeDownloads = {};
  final Map<String, CancelToken> _cancelTokens = {};

  Future<void> init() async {
    // Database is initialized lazily
  }

  Future<List<DownloadItem>> getAllDownloads() async {
    final downloads = await _db.getAllDownloads();
    return downloads.map((d) => DownloadItem.fromJson(d)).toList();
  }

  Future<int> getCompletedDownloadsCount() async {
    return await _db.getCompletedDownloadsCount();
  }

  Future<void> startDownload({
    required String assetId,
    required String title,
    required Uri url,
  }) async {
    debugPrint('DownloadManager.startDownload called: $assetId, $title, $url');

    // Check if already exists in database
    debugPrint('=== DOWNLOAD MANAGER CHECK ===');
    debugPrint('startDownload: checking existing record for assetId=$assetId');
    final existing = await _db.getDownload(assetId);
    debugPrint('Database query result: found=${existing != null}');

    if (existing != null) {
      debugPrint('Existing record details: $existing');
      final item = DownloadItem.fromJson(existing);
      debugPrint('Parsed item: status=${item.status}, localPath=${item.localPath}');

      if (item.status == DownloadStatus.completed) {
        debugPrint('Status is completed, checking file existence...');
        // Check if file actually exists on disk
        if (item.localPath != null) {
          final file = File(item.localPath!);
          final fileExists = await file.exists();
          debugPrint('File existence check: ${item.localPath} -> exists: $fileExists');
          if (fileExists) {
            final fileSize = await file.length();
            debugPrint('File exists with size: $fileSize bytes');
            debugPrint('Download already exists and file is present: $assetId');
            debugPrint('=== DOWNLOAD SKIPPED - FILE EXISTS ===');
            return;
          } else {
            debugPrint('Download record exists but file missing, restarting: $assetId');
            // File is missing, restart download
          }
        } else {
          debugPrint('Download completed but no file path, restarting: $assetId');
          // No file path, restart download
        }
      } else {
        debugPrint('Status is not completed (${item.status}), proceeding with download');
      }
    } else {
      debugPrint('No existing record found for assetId=$assetId, proceeding with download');
    }
    debugPrint('=== PROCEEDING WITH DOWNLOAD ===');

    // Create initial entry
    final downloadData = {
      'assetId': assetId,
      'title': title,
      'localPath': null,
      'progress': 0,
      'status': DownloadStatus.queued.name,
      'sizeBytes': null,
      'downloadedAt': null,
    };

    await _db.insertDownloadRecord(downloadData);
    notifyListeners();

    // Start the actual download
    _downloadFile(assetId, title, url);
  }

  void _downloadFile(String assetId, String title, Uri url) async {
    // Get download directory and compute file path
    final dir = await _getDownloadDirectory();
    final sanitizedTitle = _sanitizeFileName(title);
    final fileName = '${assetId}__$sanitizedTitle.mp4';
    final filePath = p.join(dir.path, fileName);
    debugPrint('_downloadFile: computed filePath=$filePath for assetId=$assetId, title=$title');

    try {

      // Check if file already exists before starting download
      final targetFile = File(filePath);
      if (await targetFile.exists()) {
        // File exists, update DB status to completed and return
        await _db.updateDownload(assetId, {
          'status': DownloadStatus.completed.name,
          'localPath': filePath,
          'progress': 100,
          'downloadedAt': DateTime.now().toIso8601String(),
        });
        debugPrint('File already exists. Skipping download: $filePath');
        notifyListeners();
        return;
      }

      // Update status to downloading
      await _db.updateDownload(assetId, {'status': DownloadStatus.downloading.name});
      notifyListeners();

      // Create cancel token for this download
      final cancelToken = CancelToken();
      _cancelTokens[assetId] = cancelToken;

      // Start download with Dio
      final dio = Dio();
      await dio.downloadUri(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) async {
          if (total > 0) {
            final progress = ((received / total) * 100).round();
            await _db.updateDownload(assetId, {
              'progress': progress,
              'sizeBytes': total,
            });
            notifyListeners();
          }
        },
      );

      // Download completed successfully
      await _db.updateDownload(assetId, {
        'status': DownloadStatus.completed.name,
        'localPath': filePath,
        'progress': 100,
        'downloadedAt': DateTime.now().toIso8601String(),
      });

      // Clean up
      _cancelTokens.remove(assetId);
      notifyListeners();

      // TODO: Send completion message to JavaScript
      // This would need access to the WebViewController

    } catch (e) {
      // Clean up partial file on failure
      try {
        if (await File(filePath).exists()) {
          await File(filePath).delete();
          debugPrint('Cleaned up partial file on failure: $filePath');
        }
      } catch (cleanupError) {
        debugPrint('Failed to cleanup partial file: $cleanupError');
      }

      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Download was cancelled
        await _db.updateDownload(assetId, {'status': DownloadStatus.paused.name});
      } else {
        // Download failed
        await _db.updateDownload(assetId, {'status': DownloadStatus.failed.name});
      }
      _cancelTokens.remove(assetId);
      notifyListeners();
    }
  }

  Future<void> pauseDownload(String assetId) async {
    final cancelToken = _cancelTokens[assetId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();
      await _db.updateDownload(assetId, {'status': DownloadStatus.paused.name});
      notifyListeners();
    }
  }

  Future<void> resumeDownload(String assetId) async {
    final download = await _db.getDownload(assetId);
    if (download != null) {
      final item = DownloadItem.fromJson(download);
      if (item.status == DownloadStatus.paused || item.status == DownloadStatus.failed) {
        // For simplicity, restart the download
        // In a real implementation, you'd resume from where it left off
        final url = Uri.parse(''); // You'd need to store the original URL
        _downloadFile(assetId, item.title, url);
      }
    }
  }

  Future<void> cancelDownload(String assetId) async {
    // Cancel active download
    final cancelToken = _cancelTokens[assetId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();
    }

    // Delete partial file
    final download = await _db.getDownload(assetId);
    if (download != null && download['localPath'] != null) {
      final file = File(download['localPath']);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // Remove from database
    await _db.deleteDownload(assetId);
    _cancelTokens.remove(assetId);
    notifyListeners();
  }

  Future<void> deleteDownload(String assetId) async {
    // Cancel if active
    await cancelDownload(assetId);

    // Delete completed file using the safe delete function
    final download = await _db.getDownload(assetId);
    if (download != null) {
      // Try both path and localPath columns
      final filePath = download['path'] ?? download['localPath'];
      await deleteDownloadedFile(filePath);
    }

    // Remove from database
    await _db.deleteDownload(assetId);
    notifyListeners();
  }

  Future<Directory> _getDownloadDirectory() async {
    final base = await getExternalStorageDirectory();
    final dir = Directory(p.join(base!.path, 'videos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  Future<DownloadItem?> getDownloadById(String assetId) async {
    final download = await _db.getDownload(assetId);
    return download != null ? DownloadItem.fromJson(download) : null;
  }

  // For backward compatibility with existing UI
  Future<List<DownloadItem>> get items async => await getAllDownloads();

  Future<void> remove(String assetId) async => await deleteDownload(assetId);

  Future<void> removeDownloadRecordAndFile(String assetId, String? filePath) async {
    debugPrint('removeDownloadRecordAndFile called: assetId=$assetId, filePath=$filePath');

    final removedFile = await deleteDownloadedFile(filePath);
    debugPrint('File deletion result: $removedFile for path: $filePath');

    final db = await _db.database;
    try {
      // prefer deleting the DB row. If you want keep history, update status instead.
      final deletedRows = await db.delete('downloads', where: 'assetId = ?', whereArgs: [assetId]);
      debugPrint('Removed DB record assetId:$assetId, deletedRows:$deletedRows, fileDeleted:$removedFile');
    } catch (e) {
      debugPrint('DB delete failed: $e');
    }
    // notify UI
    notifyListeners();
  }
}
