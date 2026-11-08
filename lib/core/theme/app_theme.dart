import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ────────── Font Sizes ──────────

class AppSize {
  static const double xs = 11;
  static const double sm = 12;
  static const double base = 14;
  static const double xl = 18;
  static const double xxl = 22;

  // Aliases for backward compatibility
  static const double s = sm;
  static const double m = sm;
  static const double l = base;
}

class AppColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFFE5E5E5);
  static const Color darkGrey = Color(0xFF202020);
  static const Color charcoal = Color(0xFF151515);
  static const Color mediumGrey = Color(0xFF515151);
  static const Color background = Color.fromARGB(255, 236, 236, 236);
  static const Color card = Color(0xFF1E1E1E);
}

// ────────── Theme Provider ──────────

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}

// ────────── Flutter ThemeData ──────────

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'ADLaMDisplay',
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        surface: AppColors.white,
        surfaceContainerHighest: AppColors.white,
        surfaceDim: AppColors.grey,
        outlineVariant: AppColors.grey,
        outline: AppColors.mediumGrey,
        surfaceBright: AppColors.charcoal,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'ADLaMDisplay',
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: ColorScheme.dark(
        surface: AppColors.charcoal, // card
        surfaceContainerHighest: AppColors.white,
        surfaceDim: AppColors.mediumGrey, // background in card
        outlineVariant: AppColors.black, // border card
        outline: AppColors.mediumGrey, // line && description
        surfaceBright: AppColors.charcoal, // navigation bar
      ),
    );
  }
}
