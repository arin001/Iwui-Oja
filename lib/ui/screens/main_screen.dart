import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prime_web/cubit/get_setting_cubit.dart';
import 'package:prime_web/provider/navigation_bar_provider.dart';
import 'package:prime_web/ui/screens/home_screen.dart';
import 'package:prime_web/ui/screens/setting_screens/settings_screen.dart';
import 'package:prime_web/ui/widgets/widgets.dart';
import 'package:prime_web/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.webUrl, super.key});

  final String webUrl;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Create a global instance of FirebaseMessaging
final _firebaseMessaging = FirebaseMessaging.instance;

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _selectedIndex = showBottomNavigationBar ? 0 : -1;
  int _previousIndex = showBottomNavigationBar ? 0 : -1;

  late AnimationController idleAnimation;
  late AnimationController onSelectedAnimation;
  late AnimationController onChangedAnimation;
  Duration animationDuration = const Duration(milliseconds: 700);
  late AppLifecycleReactor? _appLifecycleReactor;
  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [];

  late final List<Widget> _tabs = [];
  var _navigationTabs = <Map<String, String>>[];
  double appVersion = 0.0;

  @override
  void initState() {
    super.initState();

    _maybeShowUpdateDialog();

    demoInitializeTabs();

    idleAnimation = AnimationController(vsync: this);
    onSelectedAnimation =
        AnimationController(vsync: this, duration: animationDuration);
    onChangedAnimation =
        AnimationController(vsync: this, duration: animationDuration);
    Future.delayed(Duration.zero, () {
      context
          .read<NavigationBarProvider>()
          .setAnimationController(navigationContainerAnimationController);
    });
    FirebaseInitialize().initFirebaseState(context);

    if (context.read<GetSettingCubit>().showOpenAds() == true) {
      final appOpenAdManager = AdMobService()..loadOpenAd();
      _appLifecycleReactor =
          AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
      _appLifecycleReactor!.listenToAppStateChanges();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestNotificationPermissions();
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      /* start--uncommnet  below 2 lines to enable landscape mode */
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      /*end */
    ]);
  }

  Future<void> _maybeShowUpdateDialog() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version + packageInfo.buildNumber;
    if (forceUpdatee == '1') {
      int getExtendedVersionNumber(String version) {
        List versionCells = version.split('.');
        log('$versionCells - $version');
        versionCells = versionCells.map((i) => int.parse(i)).toList();
        return versionCells[0] * 100000 +
            versionCells[1] * 1000 +
            versionCells[2];
      }

      // remove plus sign
      String removePlusSign({required String input}) {
        if (!input.contains('+')) {
          return input;
        }
        List<String> parts = input.split('+');
        if (parts.length != 2) return input;
        String mainVersion = parts[0];
        String buildNumber = parts[1];
        return '$mainVersion$buildNumber';
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        int currentExtendedVersion = getExtendedVersionNumber(currentVersion);
        String? androidAppVersionRemovePlus = removePlusSign(
            input: context.read<GetSettingCubit>().androidAppVertion());
        String? iosVersionRemovePlus =
            removePlusSign(input: context.read<GetSettingCubit>().iosVertion());
        int androidAppVersionRequired =
            getExtendedVersionNumber(androidAppVersionRemovePlus);
        int iosVersionRequired = getExtendedVersionNumber(iosVersionRemovePlus);

        if (Platform.isAndroid) {
          if (currentExtendedVersion < androidAppVersionRequired) {
            _showUpdateVersionDialog(context, false);
          }
        } else {
          if (currentExtendedVersion < iosVersionRequired) {
            _showUpdateVersionDialog(context, false);
          }
        }
      });
    }
  }

  Future<void> requestNotificationPermissions() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission();

    // Request permission for Android
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void demoInitializeTabs() {
    if (showBottomNavigationBar) {
      // Demo User
      Future.delayed(Duration.zero, () {
        for (int i = 0; i < _navigationTabs.length; i++) {
          _navigatorKeys.add(GlobalKey<NavigatorState>());

          _tabs.add(
            Navigator(
              key: _navigatorKeys[i],
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (_) => HomeScreen(
                    _navigationTabs[i]['url']!,
                  ),
                );
              },
            ),
          );
        }

        _navigatorKeys.add(GlobalKey<NavigatorState>());
        _tabs.add(
          Navigator(
            key: _navigatorKeys[_navigationTabs.length],
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(builder: (_) => const SettingsScreen());
            },
          ),
        );

        setState(() {});
      });
    } else {
      _navigatorKeys.add(GlobalKey<NavigatorState>());
      setState(() {});
    }
  }

  void initializeTabs() {
    if (showBottomNavigationBar) {
      Future.delayed(Duration.zero, () {
        for (var i = 0; i < _navigationTabs.length; i++) {
          _navigatorKeys.add(GlobalKey<NavigatorState>());
          _tabs.add(
            Navigator(
              key: _navigatorKeys[i],
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => HomeScreen(_navigationTabs[i]['url']!),
              ),
            ),
          );
        }

        ///
        _navigatorKeys.add(GlobalKey<NavigatorState>());
        _tabs.add(
          Navigator(
            key: _navigatorKeys[2],
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            ),
          ),
        );

        setState(() {});
      });
    } else {
      _navigatorKeys.add(GlobalKey<NavigatorState>());
      setState(() {});
    }
  }

  @override
  void dispose() {
    idleAnimation.dispose();
    onSelectedAnimation.dispose();
    onChangedAnimation.dispose();
    navigationContainerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _navigationTabs = navigationTabs(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Theme.of(context).cardColor,
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    return PopScope(
      canPop: !context.read<GetSettingCubit>().showExitPopupScreen(),
      onPopInvokedWithResult: (_, __) => _navigateBack(context),
      child: GestureDetector(
        onTap: () =>
            context.read<NavigationBarProvider>().animationController.reverse(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          bottomNavigationBar: showBottomNavigationBar
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
                    child: _bottomNavigationBar,
                  ),
                )
              : null,
          body: showBottomNavigationBar
              ? IndexedStack(
                  index: _selectedIndex,
                  children: _tabs,
                )
              : Navigator(
                  key: _navigatorKeys[0],
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute(
                      builder: (_) => HomeScreen(
                        widget.webUrl,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget get _bottomNavigationBar {
    return Container(
      height: 75,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: GlassBoxCurve(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width / 10,
        child: Padding(
          padding: const EdgeInsets.only(left: 2, right: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_navigationTabs.length + 1, (i) {
              if (i == _navigationTabs.length) {
                return _buildNavItem(
                  _navigationTabs.length,
                  CustomStrings.settings,
                  CustomIcons.settingsIcon(Theme.of(context).brightness),
                );
              }
              return _buildNavItem(
                i,
                _navigationTabs[i]['label']!,
                _navigationTabs[i]['icon']!,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, String icon) {
    return InkWell(
      onTap: () => onButtonPressed(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          Lottie.asset(
            icon,
            height: 30,
            repeat: true,
            controller: _selectedIndex == index
                ? onSelectedAnimation
                : _previousIndex == index
                    ? onChangedAnimation
                    : idleAnimation,
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Text(
              _truncateText(title),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: _selectedIndex == index
                  ? Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.normal,
                      )
                  : Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 35,
              height: 3,
              decoration: BoxDecoration(
                color: _selectedIndex == index
                    ? Theme.of(context).indicatorColor
                    : Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                boxShadow: _selectedIndex == index
                    ? [
                        BoxShadow(
                          color: Theme.of(context)
                              .indicatorColor
                              .withValues(alpha: .5),
                          blurRadius: 50, // soften the shadow
                          spreadRadius: 20,
                          //extend the shadow
                        ),
                      ]
                    : [],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _truncateText(String text, {int maxLength = 15}) {
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  void onButtonPressed(int index) {
    if (!context
        .read<NavigationBarProvider>()
        .animationController
        .isAnimating) {
      context.read<NavigationBarProvider>().animationController.reverse();
    }
    // pageController.jumpToPage(index);
    onSelectedAnimation
      ..reset()
      ..forward();

    onChangedAnimation
      ..value = 1
      ..reverse();

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  Future<bool> _navigateBack(BuildContext context) async {
    if (Platform.isIOS && Navigator.of(context).userGestureInProgress) {
      return Future.value(true);
    }

    final isFirstRouteInCurrentTab =
        !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
    if (!context
        .read<NavigationBarProvider>()
        .animationController
        .isAnimating) {
      await context.read<NavigationBarProvider>().animationController.reverse();
    }
    if (!isFirstRouteInCurrentTab) {
      return Future.value(false);
    } else {
      context.read<GetSettingCubit>().showExitPopupScreen()
          ? showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Do you want to exit app?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // SystemNavigator.pop;
                      // Navigator.of(context).pop();
                      SystemNavigator.pop();
                      exit(0);
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            )
          : SystemNavigator.pop();
      return Future.value(true);
    }
  }

  Future<void> _updateApp(BuildContext context) async {
    if (await canLaunchUrl(Uri.parse(storeUrl))) {
      await launchUrl(Uri.parse(storeUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again'),
        ),
      );
    }
  }

  Future<void> _showUpdateVersionDialog(
      BuildContext context, bool isSkippable) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: isSkippable,
          child: AlertDialog(
            title: const Text("New version available"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("Please update to the latest version of the app."),
                ],
              ),
            ),
            actions: <Widget>[
              // A "skip" button is only shown if it's a recommended upgrade
              isSkippable
                  ? TextButton(
                      child: const Text('Skip'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  : Container(),
              TextButton(
                child: const Text('Update'),
                onPressed: () {
                  _updateApp(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
