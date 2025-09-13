import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:prime_web/cubit/get_setting_cubit.dart';
import 'package:prime_web/main.dart';
import 'package:prime_web/provider/navigation_bar_provider.dart';
import 'package:prime_web/ui/widgets/admob_service.dart';
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
  }

  @override
  void dispose() {
    navigationContainerAnimationController.dispose();
    super.dispose();
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
              : null,
    );
  }

  Widget displayAd() {
    return context.read<GetSettingCubit>().showBannerAds()
        ? SizedBox(
            height: 50,
            width: double.maxFinite,
            child: AdWidget(
              key: UniqueKey(),
              ad: AdMobService.createBannerAd()..load(),
            ),
          )
        : const SizedBox.shrink();
  }
}
