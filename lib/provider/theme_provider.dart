import 'package:flutter/material.dart';
import 'package:prime_web/main.dart';
import 'package:prime_web/ui/styles/colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required bool isDarkTheme}) {
    themeMode = isDarkTheme ? ThemeMode.dark : ThemeMode.light;
  }
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return themeMode.name == Brightness.dark.name;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  Future<void> toggleTheme({required bool isOn}) async {
    print('toggling UI');
    if (isOn) {
      themeMode = ThemeMode.dark;
      await pref.setBool('isDarkTheme', true);
    } else {
      themeMode = ThemeMode.light;
      await pref.setBool('isDarkTheme', false);
    }

    notifyListeners();
  }

  ThemeMode getTheme() => themeMode;
}

class AppThemes {
  static final darkTheme = ThemeData(
      scaffoldBackgroundColor: backgroundColorDarkTheme,
      colorScheme: const ColorScheme.dark(),
      fontFamily: 'SegUI',
      primaryColor: whiteColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: whiteColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: whiteColor,
          fontSize: 16,
        ),
      ),
      iconTheme: const IconThemeData(color: whiteColor),
      cardColor: primaryColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        surfaceTintColor: primaryColor,
        titleTextStyle: TextStyle(
          color: whiteColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: indicatorColor2,
        color: indicatorColor1,
        refreshBackgroundColor: indicatorColor3,
      ),
      highlightColor: primaryColor.withValues(alpha: .2),
      shadowColor: Colors.transparent,
      canvasColor: Colors.black.withValues(alpha: .7), tabBarTheme: TabBarThemeData(indicatorColor: accentColor));

  static final lightTheme = ThemeData(
      scaffoldBackgroundColor: backgroundColorLightTheme,
      colorScheme: const ColorScheme.light(),
      fontFamily: 'SegUI',
      primarySwatch: primaryColors,
      primaryColor: primaryColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(color: primaryColor, fontSize: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
      ),
      iconTheme: const IconThemeData(color: primaryColor),
      cardColor: whiteColor,
      appBarTheme: const AppBarTheme(
        surfaceTintColor: whiteColor,
        backgroundColor: whiteColor,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: indicatorColor2,
        color: indicatorColor1,
        refreshBackgroundColor: indicatorColor3,
      ),
      highlightColor: primaryColor.withValues(alpha: .2),
      shadowColor: Colors.grey[400],
      canvasColor: Colors.white.withValues(alpha: .5), tabBarTheme: TabBarThemeData(indicatorColor: accentColor));
}
