import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prime_web/offline/download_manager.dart';
import 'package:prime_web/utils/constants.dart';

class DebugInfoScreen extends StatefulWidget {
  const DebugInfoScreen({super.key});

  @override
  State<DebugInfoScreen> createState() => _DebugInfoScreenState();
}

class _DebugInfoScreenState extends State<DebugInfoScreen> {
  final List<String> _debugLogs = [];
  final DownloadManager _dm = DownloadManager();

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    try {
      // Add basic info
      _addLog('=== DEBUG INFO ===');
      _addLog('Base URL: $baseurl');
      _addLog('Database URL: $databaseUrl');

      // Load downloads
      final downloads = await _dm.getAllDownloads();
      _addLog('Total downloads in DB: ${downloads.length}');

      for (final download in downloads) {
        _addLog('Download: ${download.assetId} - ${download.title}');
        _addLog('  Status: ${download.status}');
        _addLog('  Local Path: ${download.localPath}');

        if (download.localPath != null) {
          final file = File(download.localPath!);
          final exists = await file.exists();
          _addLog('  File exists: $exists');
          if (exists) {
            final size = await file.length();
            _addLog('  File size: $size bytes');
          }
        }
        _addLog('');
      }

      // Check download directory
      final dir = await _getDownloadDirectory();
      _addLog('Download directory: ${dir.path}');
      final exists = await dir.exists();
      _addLog('Directory exists: $exists');

      if (exists) {
        final files = await dir.list().toList();
        _addLog('Files in directory: ${files.length}');
        for (final file in files) {
          if (file is File) {
            final size = await file.length();
            _addLog('  ${file.path.split('/').last} - $size bytes');
          }
        }
      }

    } catch (e) {
      _addLog('Error loading debug info: $e');
    }

    setState(() {});
  }

  void _addLog(String message) {
    _debugLogs.add('${DateTime.now().toIso8601String()}: $message');
  }

  Future<Directory> _getDownloadDirectory() async {
    final base = await getExternalStorageDirectory();
    final dir = Directory('${base!.path}/videos');
    return dir;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _debugLogs.clear();
              });
            },
          ),
        ],
      ),
      body: _debugLogs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _debugLogs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    _debugLogs[index],
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                );
              },
            ),
    );
  }
}