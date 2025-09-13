import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prime_web/cubit/get_setting_cubit.dart';
import 'package:prime_web/provider/navigation_bar_provider.dart';
import 'package:prime_web/provider/theme_provider.dart';
import 'package:prime_web/ui/widgets/widgets.dart';
import 'package:prime_web/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoadWebView extends StatefulWidget {
  const LoadWebView({this.url = '', super.key});

  final String url;

  @override
  State<LoadWebView> createState() => _LoadWebViewState();
}

class _LoadWebViewState extends State<LoadWebView>
    with SingleTickerProviderStateMixin {
  final webViewKey = GlobalKey();

  late PullToRefreshController _pullToRefreshController;
  CookieManager cookieManager = CookieManager.instance();
  InAppWebViewController? webViewController;
  double progress = 0;
  String url = '';
  int _previousScrollY = 0;
  bool isLoading = false;
  bool showErrorPage = false;
  bool slowInternetPage = false;
  bool noInternet = false;
  late Animation<double> animation;
  final expiresDate =
      DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _validURL = false;
  bool canGoBack = false;

  // Download state variables
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadingFileName = '';

  @override
  void initState() {
    super.initState();
    NoInternet.initConnectivity().then(
          (value) => setState(() {
        _connectionStatus = value;
      }),
    );
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      NoInternet.updateConnectionStatus(result).then((value) {
        _connectionStatus = value;
        if (_connectionStatus != [ConnectivityResult.none]) {
          setState(() {
            noInternet = false;
            webViewController?.reload();
          });
        }
      });
    });

    try {
      _pullToRefreshController = PullToRefreshController(
        settings: PullToRefreshSettings(
          color: context.read<GetSettingCubit>().loadercolor(),
        ),
        onRefresh: () async {
          await webViewController!.loadUrl(
            urlRequest: URLRequest(url: await webViewController!.getUrl()),
          );
        },
      );
    } catch (e, stackTrace) {
      log('Error initializing PullToRefreshController: $e');
      log('StackTrace: $stackTrace');
    }

    context.read<ThemeProvider>().addListener(() {
      webViewController!.reload();
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    webViewController = null;
    super.dispose();
  }

  final _inAppWebViewSettings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    useOnDownloadStart: true,
    javaScriptCanOpenWindowsAutomatically: true,
    userAgent:
    'Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36',
    verticalScrollBarEnabled: false,
    horizontalScrollBarEnabled: false,
    transparentBackground: true,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    allowsInlineMediaPlayback: true,
  );

  // Download handler method
  Future<void> _handleCustomDownload(String downloadUrl, String title, String? assetId) async {
    // Check permissions first with user guidance
    bool hasPermission = await _requestStoragePermission();

    if (!hasPermission) {
      // Show dialog and try once more
      await _showPermissionDialog();
      hasPermission = await _requestStoragePermission();

      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download videos'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    // Rest of your download logic remains the same...
    try {
      final dio = Dio();

      // Generate filename
      String fileName = _generateFileName(downloadUrl, title);

      // Get save path
      String savePath = await _getDownloadPath(fileName);

      print('Attempting to download to: $savePath'); // Debug log

      // Check if file already exists
      final file = File(savePath);
      if (await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File already exists: $fileName')),
        );
        return;
      }

      // Update UI state
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
        _downloadingFileName = fileName;
      });

      // Show download started message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starting download: $fileName')),
      );

      // Start download
      await dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            setState(() {
              _downloadProgress = progress;
            });

            // Send progress update to JavaScript
            _sendProgressToWeb(progress, assetId);
          }
        },
      );

      // Download completed
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
        _downloadingFileName = '';
      });

      // Send completion message to JavaScript
      _sendCompletionToWeb(assetId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download completed: $fileName\nSaved to: $savePath')),
      );

    } catch (e) {
      print('Download error: $e'); // Debug log

      // Handle download error
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
        _downloadingFileName = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );

      // Send error to JavaScript
      _sendErrorToWeb(assetId);
    }
  }


//Enhanced Permission Request with User Guidance

  Future<void> _showPermissionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
            'This app needs storage permission to download videos. '
                'Please grant the permission in the next dialog, or go to '
                'Settings > Apps > Prime Web > Permissions to enable it manually.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // This opens the app settings
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }


  // Helper methods
  String _generateFileName(String url, String title) {
    // Try to get filename from URL
    String fileName;
    try {
      final uri = Uri.parse(url);
      fileName = uri.pathSegments.last;

      // If no extension, try to get from URL parameters or add .mp4
      if (!fileName.contains('.')) {
        fileName = '${title.replaceAll(RegExp(r'[^\w\s-]'), '')}.mp4';
      }
    } catch (e) {
      fileName = '${title.replaceAll(RegExp(r'[^\w\s-]'), '')}.mp4';
    }

    // Clean filename
    fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

    return fileName;
  }

  Future<String> _getDownloadPath(String fileName) async {
    String? dirPath;

    if (Platform.isAndroid) {
      try {
        // Check Android version
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 30) {
          // Android 11+ - Use app-specific directory to avoid scoped storage issues
          final directory = await getExternalStorageDirectory();
          dirPath = '${directory?.path}/Downloads';
        } else {
          // Android 10 and below - Use public Downloads folder
          dirPath = '/storage/emulated/0/Download';
        }

        // Test if directory is accessible
        final testDir = Directory(dirPath);
        if (!await testDir.exists()) {
          await testDir.create(recursive: true);
        }

        // Test write permission by creating a temp file
        final testFile = File('$dirPath/.test_write');
        try {
          await testFile.writeAsString('test');
          await testFile.delete();
        } catch (e) {
          // Fallback to app-specific directory
          final directory = await getExternalStorageDirectory();
          dirPath = '${directory?.path}/Downloads';
          final fallbackDir = Directory(dirPath);
          if (!await fallbackDir.exists()) {
            await fallbackDir.create(recursive: true);
          }
        }

      } catch (e) {
        // Final fallback
        final directory = await getExternalStorageDirectory();
        dirPath = '${directory?.path}/Downloads';
      }
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      dirPath = directory.path;
    }

    // Ensure directory exists
    final dir = Directory(dirPath!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return '$dirPath/$fileName';
  }


  Future<bool> _needsStoragePermission() async {
    // Storage permission only needed for Android 10 (SDK 29) and below
    if (Platform.isAndroid) {
      int sdkInt = int.parse((await File('/system/build.prop').readAsString())
          .split('\n')
          .firstWhere((line) => line.startsWith('ro.build.version.sdk'), orElse: () => 'ro.build.version.sdk=30')
          .split('=')[1]);
      return sdkInt <= 29;
    }
    return false;
  }



  Future<bool> _requestStoragePermission() async {
    if (Platform.isIOS) return true; // iOS doesn't need explicit storage permission

    try {
      // Check Android version
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ (API 33+) - Use media permissions
        final videoStatus = await Permission.videos.status;
        if (videoStatus.isGranted) return true;

        final videoResult = await Permission.videos.request();
        return videoResult.isGranted;

      } else if (sdkInt >= 30) {
        // Android 11-12 (API 30-32) - Use manage external storage
        final manageStatus = await Permission.manageExternalStorage.status;
        if (manageStatus.isGranted) return true;

        final manageResult = await Permission.manageExternalStorage.request();
        if (manageResult.isGranted) return true;

        // Fallback to regular storage permission
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted) return true;

        final storageResult = await Permission.storage.request();
        return storageResult.isGranted;

      } else {
        // Android 10 and below (API 29 and below)
        final status = await Permission.storage.status;
        if (status.isGranted) return true;

        final result = await Permission.storage.request();
        return result.isGranted;
      }
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }



  void _sendProgressToWeb(double progress, String? assetId) {
    final progressPercent = (progress * 100).toInt();
    final jsCode = '''
      window.postMessage({
        status: 'downloading',
        progress: $progressPercent,
        assetId: '$assetId'
      }, '*');
    ''';

    webViewController?.evaluateJavascript(source: jsCode);
  }

  void _sendCompletionToWeb(String? assetId) {
    final jsCode = '''
      window.postMessage({
        status: 'done',
        assetId: '$assetId'
      }, '*');
    ''';

    webViewController?.evaluateJavascript(source: jsCode);
  }

  void _sendErrorToWeb(String? assetId) {
    final jsCode = '''
      window.postMessage({
        status: 'error',
        assetId: '$assetId'
      }, '*');
    ''';

    webViewController?.evaluateJavascript(source: jsCode);
  }

  @override
  Widget build(BuildContext context) {
    _validURL = Uri.tryParse(widget.url)?.isAbsolute ?? false;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) async {
        if (didPop) return;
        if (await _exitApp(context)) {
          Navigator.of(context).pop();
        }
      },
      child: Stack(
        children: [
          if (_validURL)
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: _inAppWebViewSettings,
              pullToRefreshController:
              context.read<GetSettingCubit>().pullToRefresh()
                  ? _pullToRefreshController
                  : null,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  EagerGestureRecognizer.new,
                ),
              },
              onWebViewCreated: (controller) async {
                webViewController = controller;

                // Add JavaScript handler for download
                webViewController?.addJavaScriptHandler(
                    handlerName: 'App',
                    callback: (args) async {
                      if (args.isNotEmpty && args[0] is Map) {
                        var data = args[0];
                        String action = data['action'] ?? '';

                        if (action == 'download') {
                          String fileUrl = data['url'] ?? '';
                          String fileName = data['filename'] ?? 'video.mp4';

                          if (fileUrl.isEmpty) {
                            print('Download failed: No URL provided');
                            return;
                          }

                          try {
                            // 1. Request permission (Android 10 and below)
                            if (Platform.isAndroid) {
                              if (await _needsStoragePermission()) {
                                var status = await Permission.storage.request();
                                if (!status.isGranted) {
                                  print('Permission denied');
                                  return;
                                }
                              }
                            }

                            // 2. Get private app folder
                            Directory appDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
                            String savePath = "${appDir.path}/$fileName";

                            // 3. Download file
                            Dio dio = Dio();
                            await dio.download(
                              fileUrl,
                              savePath,
                              onReceiveProgress: (count, total) {
                                if (total != -1) {
                                  print("Download progress: ${(count / total * 100).toStringAsFixed(0)}%");
                                }
                              },
                            );

                            print('Download complete: $savePath');

                          } catch (e) {
                            print('Download error: $e');
                          }
                        }
                      }
                    }
                );


                await cookieManager.setCookie(
                  url: WebUri(widget.url),
                  name: 'myCookie',
                  value: 'myValue',
                  expiresDate: expiresDate,
                  isHttpOnly: false,
                  isSecure: true,
                );
              },
              onScrollChanged: (controller, x, y) async {
                final currentScrollY = y;
                final animationController =
                    context.read<NavigationBarProvider>().animationController;

                if (currentScrollY > _previousScrollY) {
                  _previousScrollY = currentScrollY;
                  if (!animationController.isAnimating) {
                    await animationController.forward();
                  }
                } else {
                  _previousScrollY = currentScrollY;

                  if (!animationController.isAnimating) {
                    await animationController.reverse();
                  }
                }
              },
              onLoadStart: (controller, url) async {
                setState(() {
                  isLoading = true;
                  showErrorPage = false;
                  slowInternetPage = false;
                  this.url = url.toString();
                });
              },
              onLoadStop: (controller, url) async {
                await _pullToRefreshController.endRefreshing();

                setState(() {
                  this.url = url.toString();
                  isLoading = false;
                });
                final mode = context.read<ThemeProvider>().isDarkMode
                    ? "\'dark\'"
                    : "\'light\'";
                final themeChange = """
                  let meta = document.querySelector('meta[name="color-scheme"]');
                  if (meta) {
                  meta.setAttribute('content', $mode); 
                  } else {
                  meta = document.createElement('meta');
                  meta.name = 'color-scheme';
                  meta.content = $mode;
                  document.head.appendChild(meta);
                  }""";
                await webViewController!
                    .evaluateJavascript(source: themeChange);

                // Removes header and footer from page
                if (context.read<GetSettingCubit>().hideHeader()) {
                  await webViewController!
                      .evaluateJavascript(
                    source:
                    "javascript:(function() { var head = document.getElementsByTagName('header')[0];if(head && head.parentNode){head.parentNode.removeChild(head);} })()",
                  )
                      .then(
                        (_) => debugPrint(
                      'Page finished loading Javascript (header)',
                    ),
                  )
                      .catchError((Object e) => debugPrint('$e'));
                }

                if (context.read<GetSettingCubit>().hideFooter()) {
                  await webViewController!
                      .evaluateJavascript(
                    source:
                    "javascript:(function() { var footer = document.getElementsByTagName('footer')[0];if(footer && footer.parentNode){footer.parentNode.removeChild(footer);} })()",
                  )
                      .then(
                        (_) => debugPrint(
                      'Page finished loading Javascript (footer)',
                    ),
                  )
                      .catchError((Object e) => debugPrint('$e'));
                }
              },
              onReceivedError: (controller, request, error) async {
                print("onReceivedError Hear.......$error");
                await _pullToRefreshController.endRefreshing();
                setState(() {
                  isLoading = false;
                  print('${request.url.origin} - ${widget.url}');
                  if (request.url.origin == widget.url &&
                      (error.type == WebResourceErrorType.HOST_LOOKUP ||
                          error.description == 'net::ERR_NAME_NOT_RESOLVED' ||
                          error.description == 'net::ERR_CONNECTION_CLOSED')) {
                    slowInternetPage = true;
                    return;
                  }
                  if (error.type ==
                      WebResourceErrorType.NOT_CONNECTED_TO_INTERNET ||
                      error.description == 'net::ERR_INTERNET_DISCONNECTED') {
                    noInternet = true;
                    return;
                  }
                });
              },
              onReceivedHttpError: (controller, request, response) {
                _pullToRefreshController.endRefreshing();
                if ([100, 299].contains(response.statusCode) ||
                    [400, 599].contains(response.statusCode)) {
                  setState(() {
                    showErrorPage = true;
                    isLoading = false;
                  });
                }
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              },
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                await Permission.location.request();
                return Future.value(
                  GeolocationPermissionShowPromptResponse(
                    origin: origin,
                    allow: true,
                    retain: true,
                  ),
                );
              },
              onPermissionRequest: (controller, request) async {
                for (final element in request.resources) {
                  if (element == PermissionResourceType.MICROPHONE) {
                    await Permission.microphone.request();
                  }
                  if (element == PermissionResourceType.CAMERA) {
                    await Permission.camera.request();
                  }
                }

                return PermissionResponse(
                  action: PermissionResponseAction.GRANT,
                  resources: request.resources,
                );
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  if (progress == 100) {
                    _pullToRefreshController.endRefreshing();
                    isLoading = false;
                  }
                  this.progress = progress / 100;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var url = navigationAction.request.url.toString();
                final uri = Uri.parse(url);

                if (Platform.isIOS && url.contains('geo')) {
                  url = url.replaceFirst(
                    'geo://',
                    'http://maps.apple.com/',
                  );
                } else if (url.contains('tel:') ||
                    url.contains('mailto:') ||
                    url.contains('play.google.com') ||
                    url.contains('maps') ||
                    url.contains('messenger.com')) {
                  url = Uri.encodeFull(url);
                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      await launchUrl(uri);
                    }
                    return NavigationActionPolicy.CANCEL;
                  } catch (e) {
                    await launchUrl(uri);
                    return NavigationActionPolicy.CANCEL;
                  }
                } else if (![
                  'http',
                  'https',
                  'file',
                  'chrome',
                  'data',
                  'javascript',
                ].contains(uri.scheme)) {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                    return NavigationActionPolicy.CANCEL;
                  }
                }

                return NavigationActionPolicy.ALLOW;
              },
              onCloseWindow: (controller) async {},
              onUpdateVisitedHistory: (controller, url, androidIsReload) async {
                print(
                    '************************$url - $androidIsReload****************************');
                setState(() {
                  this.url = url.toString();
                });
              },
            )
          else
            Center(
              child: Text(
                'Url is not valid',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),

          // Page loading indicator
          if (isLoading)
            if (Platform.isIOS)
              Center(
                child: CupertinoActivityIndicator(
                  radius: 18,
                  color: context.read<GetSettingCubit>().loadercolor(),
                ),
              )
            else
              Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: context.read<GetSettingCubit>().loadercolor(),
                ),
              )
          else
            const SizedBox.shrink(),

          // No internet / error overlays
          if (noInternet)
            const Center(
              child: NoInternetWidget(),
            )
          else
            const SizedBox.shrink(),
          if (showErrorPage)
            Center(
              child: NotFound(
                webViewController: webViewController!,
                url: url,
                title1: CustomStrings.pageNotFound1,
                title2: CustomStrings.pageNotFound2,
              ),
            )
          else
            const SizedBox.shrink(),
          if (slowInternetPage)
            Center(
              child: NotFound(
                webViewController: webViewController!,
                url: url,
                title1: CustomStrings.incorrectURL1,
                title2: CustomStrings.incorrectURL2,
              ),
            )
          else
            const SizedBox.shrink(),

          // Download progress overlay
          if (_isDownloading)
            Positioned(
              left: 16,
              right: 16,
              bottom: 80,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.black87,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.download, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Downloading ${_downloadingFileName}',
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(_downloadProgress * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _downloadProgress,
                          minHeight: 6,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.read<GetSettingCubit>().loadercolor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (mounted) {
      await context.read<NavigationBarProvider>().animationController.reverse();
    }
    if (!_validURL) {
      return true;
    }
    final originalUrl = widget.url;
    final currentUrl = url;
    print('$originalUrl - $currentUrl');
    if (await webViewController!.canGoBack() && originalUrl != currentUrl) {
      await webViewController!.goBack();
      return false;
    } else {
      return true;
    }
  }

  Future<bool> requestPermission() async {
    final status = await Permission.storage.status;

    if (status == PermissionStatus.granted) {
      return true;
    } else if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  Future<String> getFilePath(String uniqueFileName) async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = '/storage/emulated/0/Download';
        final testDir = Directory(externalStorageDirPath);
        if (!await testDir.exists()) {
          final directory = await getExternalStorageDirectory();
          externalStorageDirPath = directory?.path ?? '/storage/emulated/0';
        }
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path ?? '/storage/emulated/0';
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }

    final dir = Directory(externalStorageDirPath!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return '$externalStorageDirPath/$uniqueFileName';
  }
}
