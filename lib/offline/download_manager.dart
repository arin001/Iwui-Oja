import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DownloadItem {
  final String assetId;
  final String title;
  final String filePath; // local .mp4 path
  final int? fileSize;

  DownloadItem({
    required this.assetId,
    required this.title,
    required this.filePath,
    this.fileSize,
  });

  Map<String, dynamic> toJson() => {
    'assetId': assetId,
    'title': title,
    'filePath': filePath,
    'fileSize': fileSize,
  };

  static DownloadItem fromJson(Map<String, dynamic> j) => DownloadItem(
    assetId: j['assetId'],
    title: j['title'],
    filePath: j['filePath'],
    fileSize: j['fileSize'],
  );
}

class DownloadManager with ChangeNotifier {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final List<DownloadItem> _items = [];
  bool _initialized = false;

  List<DownloadItem> get items => List.unmodifiable(_items);

  Future<Directory> _downloadsDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'downloads'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _indexFile() async {
    final dir = await _downloadsDir();
    return File(p.join(dir.path, 'index.json'));
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final idx = await _indexFile();
      if (await idx.exists()) {
        final data = jsonDecode(await idx.readAsString()) as List;
        _items.clear();
        _items.addAll(data.map((e) => DownloadItem.fromJson(e)));
      }
    } catch (_) {
      // start clean
    }
  }

  Future<void> _saveIndex() async {
    final idx = await _indexFile();
    await idx.writeAsString(jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  Stream<double> download({
    required String assetId,
    required String title,
    required Uri url,
  }) async* {
    await init();
    final dir = await _downloadsDir();
    final tmpPath = p.join(dir.path, '$assetId.tmp');
    final finalPath = p.join(dir.path, '$assetId.mp4');

    // If already downloaded, emit 100% and stop
    if (await File(finalPath).exists()) {
      yield 1.0;
      return;
    }

    final req = http.Request('GET', url);
    final resp = await req.send();
    if (resp.statusCode != 200) {
      throw Exception('Download failed: ${resp.statusCode}');
    }

    final contentLen = resp.contentLength ?? 0;
    int received = 0;
    final sink = File(tmpPath).openWrite();

    await for (final chunk in resp.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (contentLen > 0) {
        yield received / contentLen;
      }
    }
    await sink.close();

    // Move to final .mp4
    final tmpFile = File(tmpPath);
    await tmpFile.rename(finalPath);

    // Save entry
    final file = File(finalPath);
    final size = await file.length();
    final item = DownloadItem(
      assetId: assetId,
      title: title,
      filePath: finalPath,
      fileSize: size,
    );
    _items.removeWhere((e) => e.assetId == assetId);
    _items.add(item);
    await _saveIndex();
    notifyListeners();

    yield 1.0;
  }

  Future<void> remove(String assetId) async {
    await init();
    final dir = await _downloadsDir();
    try {
      final f1 = File(p.join(dir.path, '$assetId.mp4'));
      if (await f1.exists()) await f1.delete();
      final ftmp = File(p.join(dir.path, '$assetId.tmp'));
      if (await ftmp.exists()) await ftmp.delete();
    } catch (_) {}
    _items.removeWhere((e) => e.assetId == assetId);
    await _saveIndex();
    notifyListeners();
  }

  DownloadItem? getById(String assetId) {
    return _items.firstWhere((e) => e.assetId == assetId, orElse: () => null as DownloadItem);
  }
}
