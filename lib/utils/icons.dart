import 'package:flutter/material.dart';

abstract class CustomIcons {
  static const _iconPath = 'assets/icons';

  static String homeIcon(Brightness brightness) => brightness == Brightness.dark
      ? '$_iconPath/home_dark.json'
      : '$_iconPath/home_light.json';

  static String demoIcon(Brightness brightness) => brightness == Brightness.dark
      ? '$_iconPath/second_light.json'
      : '$_iconPath/second_dark.json';

  static String settingsIcon(Brightness brightness) =>
      brightness == Brightness.dark
          ? '$_iconPath/settings_dark.json'
          : '$_iconPath/settings_light.json';

  static const splashLogo = '$_iconPath/splash_logo.svg';

  static const darkModeIcon = '$_iconPath/darkmode.svg';

  static const aboutUsIcon = '$_iconPath/aboutus.svg';

  static const privacyIcon = '$_iconPath/privacy.svg';

  static const termsIcon = '$_iconPath/terms.svg';

  static const contactIcon = '$_iconPath/contact_us.svg';

  static const shareIcon = '$_iconPath/share.svg';

  static const rateUsIcon = '$_iconPath/rateus.svg';

  static const webIcon = '$_iconPath/website.svg';

  static const noInternetIcon = '$_iconPath/no_internet.svg';

  static const onboardingImage1 = '$_iconPath/onboarding_a.svg';

  static const onboardingImage2 = '$_iconPath/onboarding_b.svg';

  static const onboardingImage3 = '$_iconPath/onboarding_c.svg';
}
