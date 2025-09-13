import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'download_manager.dart';

class OfflineLibraryPage extends StatefulWidget {
  const OfflineLibraryPage({super.key});

  @override
  State<OfflineLibraryPage> createState() => _OfflineLibraryPageState();
}

class _OfflineLibraryPageState extends State<OfflineLibraryPage> {
  final dm = DownloadManager();

  @override
  void initState() {
    super.initState();
    dm.addListener(_onChange);
    dm.init();
  }

  @override
  void dispose() {
    dm.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = dm.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Offline downloads')),
      body: items.isEmpty
          ? const Center(child: Text('No downloads yet'))
          : ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final it = items[i];
          return ListTile(
            title: Text(it.title),
            subtitle: Text('${(it.fileSize ?? 0) ~/ (1024 * 1024)} MB'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => dm.remove(it.assetId),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OfflinePlayerPage(path: it.filePath, title: it.title),
              ),
            ),
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
