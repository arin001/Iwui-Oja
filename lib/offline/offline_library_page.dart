import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'database_helper.dart';

class OfflineLibraryPage extends StatefulWidget {
  const OfflineLibraryPage({super.key});

  @override
  State<OfflineLibraryPage> createState() => _OfflineLibraryPageState();
}

class _OfflineLibraryPageState extends State<OfflineLibraryPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _downloads = [];

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    final downloads = await dbHelper.getAllDownloads();
    if (mounted) {
      setState(() => _downloads = downloads);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline downloads')),
      body: _downloads.isEmpty
          ? const Center(child: Text('No downloads yet'))
          : ListView.separated(
        itemCount: _downloads.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final download = _downloads[i];
          final status = download['status'] as String;
          final progress = download['progress'] as int? ?? 0;
          final filename = download['filename'] as String;
          final path = download['path'] as String?;

          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.video_file, color: Colors.grey),
            ),
            title: Text(filename),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${DateTime.parse(download['downloaded_at']).toLocal().toString().substring(0, 16)}'),
                if (status == 'downloading' || status == 'paused')
                  Column(
                    children: [
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress / 100.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          status == 'downloading' ? Colors.blue : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$progress% • $status',
                        style: TextStyle(
                          fontSize: 12,
                          color: status == 'downloading' ? Colors.blue : Colors.orange,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: status == 'completed' ? Colors.green : Colors.red,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Action buttons based on status
                if (status == 'downloading')
                  IconButton(
                    icon: const Icon(Icons.pause, color: Colors.orange),
                    onPressed: () async {
                      // TODO: Implement pause functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pause not implemented yet')),
                      );
                    },
                    tooltip: 'Pause',
                  )
                else if (status == 'paused')
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.blue),
                    onPressed: () async {
                      // TODO: Implement resume functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Resume not implemented yet')),
                      );
                    },
                    tooltip: 'Resume',
                  ),

                // Open button for completed downloads
                if (status == 'completed' && path != null)
                  IconButton(
                    icon: const Icon(Icons.play_circle, color: Colors.green),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OfflinePlayerPage(path: path, title: filename),
                      ),
                    ),
                    tooltip: 'Play',
                  ),

                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await dbHelper.deleteDownload(filename);
                    _loadDownloads(); // Refresh the list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted: $filename')),
                    );
                  },
                  tooltip: 'Delete',
                ),
              ],
            ),
            onTap: (status == 'completed' && path != null)
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OfflinePlayerPage(path: path, title: filename),
                      ),
                    )
                : null,
          );
        },
      ),
    );
  }
}

class OfflinePlayerPage extends StatefulWidget {
  final String path;
  final String title;
  const OfflinePlayerPage({super.key, required this.path, required this.title});

  @override
  State<OfflinePlayerPage> createState() => _OfflinePlayerPageState();
}

class _OfflinePlayerPageState extends State<OfflinePlayerPage> {
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() => _ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: _ready
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(_controller),
              // Simple watermark for PoC (optional)
              Positioned(
                right: 12,
                bottom: 12,
                child: Opacity(
                  opacity: 0.25,
                  child: Text(
                    'Offline • ${DateTime.now().toIso8601String().substring(11, 19)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: _ready
          ? FloatingActionButton(
        onPressed: () => setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        }),
        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      )
          : null,
    );
  }
}
