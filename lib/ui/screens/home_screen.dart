import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:prime_web/cubit/get_setting_cubit.dart';
import 'package:prime_web/main.dart';
import 'package:prime_web/provider/navigation_bar_provider.dart';
import 'package:prime_web/offline/database_helper.dart';
import 'package:prime_web/offline/offline_library_page.dart';
import 'package:prime_web/ui/widgets/load_web_view.dart';
import 'package:prime_web/utils/constants.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(this.url, {super.key, this.mainPage = true});

  final String url;
  final bool mainPage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen>, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _completedDownloadsCount = 0;

  @override
  void initState() {
    super.initState();
    if (!showBottomNavigationBar) {
      Future.delayed(Duration.zero, () {
        context
            .read<NavigationBarProvider>()
            .setAnimationController(navigationContainerAnimationController);
      });
    }
    _loadCompletedDownloadsCount();
  }

  @override
  void dispose() {
    navigationContainerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletedDownloadsCount() async {
    final downloads = await _dbHelper.getAllDownloads();
    final count = downloads.where((d) => d['status'] == 'completed').length;
    if (mounted) {
      setState(() => _completedDownloadsCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      bottomNavigationBar: displayAd(),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: LoadWebView(url: widget.url),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: !showBottomNavigationBar
          ? FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0).animate(
                CurvedAnimation(
                  parent: navigationContainerAnimationController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0, 1),
                ).animate(
                  CurvedAnimation(
                    parent: navigationContainerAnimationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: FloatingActionButton(
                    child: Lottie.asset(
                      CustomIcons.settingsIcon(Theme.of(context).brightness),
                      height: 30,
                      repeat: true,
                    ),
                    onPressed: () =>
                        navigatorKey.currentState!.pushNamed('settings'),
                  ),
                ),
              ),
            )
          : !widget.mainPage
              ? Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 30),
                  child: FloatingActionButton(
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 30,
                    ),
                    onPressed: () {
                      if (mounted) {
                        context
                            .read<NavigationBarProvider>()
                            .animationController
                            .reverse();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                )
              : // My Downloads button for main page
                Container(
                  margin: const EdgeInsets.only(bottom: 130), // Position above navigation bar
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () {
                          debugPrint('FAB pressed - navigating to OfflineLibraryPage');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OfflineLibraryPage(),
                            ),
                          );
                        },
                        backgroundColor: context.read<GetSettingCubit>().loadercolor(),
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.download_done, size: 28),
                        label: const Text(
                          'My Downloads',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        elevation: 10,
                        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      if (_completedDownloadsCount > 0)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              _completedDownloadsCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget displayAd() {
    return const SizedBox.shrink();
  }
}
