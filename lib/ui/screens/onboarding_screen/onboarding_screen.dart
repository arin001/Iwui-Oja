import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prime_web/cubit/get_onboarding_cubit.dart';
import 'package:prime_web/main.dart' show navigatorKey;
import 'package:prime_web/ui/screens/main_screen.dart';
import 'package:prime_web/ui/screens/onboarding_screen/widgets/style_one.dart';
import 'package:prime_web/ui/screens/onboarding_screen/widgets/style_three.dart';
import 'package:prime_web/ui/screens/onboarding_screen/widgets/style_two.dart';
import 'package:prime_web/ui/widgets/glassmorphism_container.dart';
import 'package:prime_web/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.style, super.key});
  final String style;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(keepPage: false);
  int totalPages = 0;
  final ValueNotifier<int> _currentIndex = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  void _jumpToHomePage() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('isFirstTimeUser', false);
    await navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute<MyHomePage>(
        builder: (_) => MyHomePage(webUrl: webInitialUrl),
      ),
    );
  }

  void _onPageChanged() {
    log('changing page');
    if (_pageController.page!.toInt() < totalPages - 1) {
      log('controller changing ${_pageController.page}');
      _pageController.animateToPage(_pageController.page!.toInt() + 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad);
      log('${_pageController.page}');
    } else {
      _jumpToHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
              onPressed: _jumpToHomePage,
              child: Text(
                'Skip',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ))
        ],
      ),
      body: BlocConsumer<GetOnboardingCubit, GetOnboardingState>(
          listener: (context, state) {
        if (state is GetOnboardingError) {
          _jumpToHomePage();
        }
      }, builder: (context, state) {
        if (state is GetOnboardingStateSuccess) {
          totalPages = state.onBoardingData.length;
          return PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (index) {
              _currentIndex.value = index;
            },
            itemBuilder: (context, index) {
              return switch (widget.style) {
                'style1' => StyleOne(
                    pageController: _pageController,
                    data: state.onBoardingData[index],
                    currentIndex: _currentIndex,
                    totalIndex: totalPages,
                    onChanged: _onPageChanged),
                'style2' => StyleTwo(
                    data: state.onBoardingData[index],
                    currentIndex: _currentIndex,
                    totalIndex: totalPages,
                    onChanged: _onPageChanged,
                  ),
                'style3' => StyleThree(
                    data: state.onBoardingData[index],
                    currentIndex: _currentIndex,
                    totalIndex: totalPages,
                    onChanged: _onPageChanged,
                  ),
                String() => throw UnimplementedError(),
              };
            },
          );
        }
        return const SizedBox.shrink();
      }),
    ));
  }
}
