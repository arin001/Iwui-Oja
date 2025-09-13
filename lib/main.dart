import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prime_web/cubit/fcm_cubit.dart';
import 'package:prime_web/cubit/get_onboarding_cubit.dart';
import 'package:prime_web/cubit/get_setting_cubit.dart';
import 'package:prime_web/provider/navigation_bar_provider.dart';
import 'package:prime_web/provider/theme_provider.dart';
import 'package:prime_web/ui/screens/setting_screens/settings_screen.dart';
import 'package:prime_web/ui/screens/splash_screen.dart';
import 'package:prime_web/ui/widgets/admob_service.dart';
import 'package:prime_web/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();
late SharedPreferences pref;

Future<bool> enableStoragePermission() async {
  if (Platform.isIOS) {
    if (await Permission.storage.isGranted) {
      return true;
    } else {
      return (await Permission.storage.request()).isGranted;
    }
  } else {
    final androidDeviceInfo = await DeviceInfoPlugin().androidInfo;

    if (androidDeviceInfo.version.sdkInt < 33) {
      if (await Permission.storage.isGranted) {
        return true;
      } else {
        return (await Permission.storage.request()).isGranted;
      }
    } else {
      if (await Permission.photos.isGranted) {
        return true;
      } else {
        return (await Permission.photos.request()).isGranted;
      }
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pref = await SharedPreferences.getInstance();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,

    /// NOTE: Uncomment below 2 lines to enable landscape mode
    // DeviceOrientation.landscapeLeft,
    // DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  await Firebase.initializeApp();
  AdMobService.initialize();

  const counter = 0;

  if (isStoragePermissionEnabled) {
    await enableStoragePermission();
  }

  await SharedPreferences.getInstance().then((prefs) {
    prefs.setInt('counter', counter);
    final bool isDarkTheme;
    if (prefs.getBool('isDarkTheme') ?? ThemeMode.system == ThemeMode.dark) {
      isDarkTheme = true;
    } else {
      isDarkTheme = false;
    }

    return runApp(
      ChangeNotifierProvider<ThemeProvider>(
        child: const MyApp(),
        create: (BuildContext context) {
          return ThemeProvider(isDarkTheme: isDarkTheme);
        },
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationBarProvider>(
          create: (_) => NavigationBarProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, value, child) {
          return MultiProvider(
            providers: [
              BlocProvider(
                create: (context) => GetSettingCubit(),
              ),
              BlocProvider(
                create: (context) => GetOnboardingCubit(),
              ),
              BlocProvider(
                create: (context) => SetFcmCubit(),
              ),
            ],
            child: MaterialApp(
              title: appName,
              debugShowCheckedModeBanner: false,
              themeMode: value.getTheme(),
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              navigatorKey: navigatorKey,
              onGenerateRoute: (RouteSettings settings) {
                return switch (settings.name) {
                  'settings' => CupertinoPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  _ => null,
                };
              },
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
