import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prime_web/cubit/fcm_cubit.dart';
import 'package:prime_web/cubit/get_onboarding_cubit.dart';
import 'package:prime_web/cubit/get_setting_cubit.dart';
import 'package:prime_web/ui/screens/main_screen.dart';
import 'package:prime_web/ui/screens/maintenance_screen/maintenance_mode_screen.dart';
import 'package:prime_web/ui/screens/onboarding_screen/onboarding_screen.dart';
import 'package:prime_web/ui/widgets/no_internet.dart';
import 'package:prime_web/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late GetSettingCubit _getSettingCubit;
  late GetOnboardingCubit _getOnbordingCubit;
  bool isSettingLoaded = false;
  bool isOnboardingLoaded = false;
  bool isConnected = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getSettingCubit = context.read<GetSettingCubit>();
    _getOnbordingCubit = context.read<GetOnboardingCubit>();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    setState(() {
      isLoading = true;
    });
    if (await NoInternet.isUserOffline()) {
      setState(() {
        isConnected = false;
        isLoading = false;
      });
    } else {
      setState(() {
        isConnected = true;
        isLoading = false;
      });
      _initializeSettingsAndOnboarding();
    }
  }

  Future<void> _initializeSettingsAndOnboarding() async {
    await Future.wait([
      _getSettingCubit.getSetting(),
      _getOnbordingCubit.getOnboardingScreens(),
      context.read<SetFcmCubit>().setFcm(),
    ]);
  }

  void _checkBothLoaded() {
    if (isSettingLoaded && isOnboardingLoaded) {
      startTimer();
    }
  }

  Future<void> startTimer() async {
    final pref = await SharedPreferences.getInstance();
    final state = _getSettingCubit.state;
    if (state is GetSettingStateInSussess) {
      final maintenanceMode = state.settingdata.appMaintenanceMode;
      if (maintenanceMode == "1") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MaintenanceModeScreen(),
          ),
        );
      } else {
        if (_getSettingCubit.onboardingStatus() &&
            (pref.getBool('isFirstTimeUser') ?? true) &&
            _getOnbordingCubit.onBoardingListIsNotEmpty()) {
          final onboardingStyle = _getSettingCubit.onbordingStyle();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => OnboardingScreen(style: onboardingStyle)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                webUrl: webInitialUrl,
              ),
            ),
          );
        }
      }
    } else if (state is GetSettingInError) {
      print('Error fetching settings: ${state.error}');
    }
  }

  Future<void> _retryConnection() async {
    setState(() {
      isLoading = true;
    });
    await _checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark));

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return isConnected
        ? MultiBlocListener(
            listeners: [
              BlocListener<GetSettingCubit, GetSettingState>(
                  listener: (context, state) {
                if (state is GetSettingStateInSussess) {
                  isSettingLoaded = true;
                  _checkBothLoaded();
                }
                if (state is GetSettingInError) {
                  print('Error fetching settings: ${state.error}');
                }
              }),
              BlocListener<GetOnboardingCubit, GetOnboardingState>(
                  listener: (context, state) {
                if (state is GetOnboardingStateSuccess) {
                  isOnboardingLoaded = true;
                  _checkBothLoaded();
                }
                if (state is GetOnboardingError) {
                  print('Error fetching onboarding: ${state.error}');
                }
              }),
            ],
            child: Scaffold(
              body: SizedBox.expand(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [splashBackColor1, splashBackColor2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      CustomIcons.splashLogo,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            body: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              alignment: Alignment.center,
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    CustomIcons.noInternetIcon,
                    height: 100,
                    width: 100,
                  ),
                  Text(
                    CustomStrings.noInternet1,
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                  Text(
                    CustomStrings.noInternet2,
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).cardColor,
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: _retryConnection,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
  }
}
