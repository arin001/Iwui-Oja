import 'package:flutter/material.dart';

const primaryColors = MaterialColor(
  0xFF30475E, // primaryColor
  <int, Color>{
    50: primaryColor,
    100: primaryColor,
    200: primaryColor,
    300: primaryColor,
    400: primaryColor,
    500: primaryColor,
    600: primaryColor,
    700: primaryColor,
    800: primaryColor,
    900: primaryColor,
  },
);

const primaryColor = Color(0xFF30475E);
const backgroundColorLightTheme = Color(0xFFF5F5F5);
const backgroundColorDarkTheme = Color(0xFF041C32);
const accentColor = Color(0xFFC92BCE);
const splashBackColor1 = Color(0xFF13123F);
const splashBackColor2 = Color(0xFFD932C7);
const whiteColor = Color(0xFFFFFFFF);
const blackColor = Color(0xFF000000);

const onboardingButtonColor1 = Color(0xFF21005D);
const onboardingButtonColor2 = Color(0xFFD932C7);
const onboardingBGColor = Color(0xFFFFFFFF);

const indicatorColor1 = Color(0xFF6A05FE);
const indicatorColor2 = Color(0xFFFD41B4);
const indicatorColor3 = Color(0xFFF37B46);

const indicatorColor = LinearGradient(
  colors: [
    onboardingButtonColor1,
    onboardingButtonColor2,
  ],
);
