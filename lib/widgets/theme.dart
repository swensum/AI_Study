import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  final Color background;
  final Color surface;
  final Color card;

  final Color text;
  final Color subtext;
  final Color hint;

  final Color border;
  final Color icon;

  final Color primary;

  const AppColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.text,
    required this.subtext,
    required this.hint,
    required this.border,
    required this.icon,
    required this.primary,
  });
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  // =========================
  // LIGHT COLORS
  // =========================

  static const AppColors lightColors = AppColors(
    background: Colors.white,
    surface: Colors.white,
    card: Color(0xFFF8F8F8),

    text: Color(0xFF1F1F1F),
    subtext: Color(0xFF666666),
    hint: Color(0xFF999999),

    border: Color(0xFFE0E0E0),

    icon: Color(0xFF1F1F1F),

    primary: Colors.deepPurple,
  );

  // =========================
  // DARK COLORS
  // =========================

  static const AppColors darkColors = AppColors(
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF1E1E1E),
    card: Color(0xFF252525),

    text: Color(0xFFF5F5F5),
    subtext: Color(0xFFAAAAAA),
    hint: Color(0xFF777777),

    border: Color(0xFF333333),

    icon: Colors.white,

    primary: Colors.deepPurple,
  );

  AppColors get colors => _isDarkMode ? darkColors : lightColors;

  // =========================
  // LOAD THEME
  // =========================

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    notifyListeners();
  }

  // =========================
  // TOGGLE THEME
  // =========================

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }

  // =========================
  // LIGHT THEME
  // =========================

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,

      primaryColor: lightColors.primary,

      scaffoldBackgroundColor: lightColors.background,

      appBarTheme: AppBarTheme(
        backgroundColor: lightColors.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: lightColors.icon,
        ),
        titleTextStyle: TextStyle(
          color: lightColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: lightColors.card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: lightColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: lightColors.background,
      ),

      colorScheme: ColorScheme.light(
        primary: lightColors.primary,
        secondary: Colors.deepPurpleAccent,
        surface: lightColors.surface,
      ),
    );
  }

  // =========================
  // DARK THEME
  // =========================

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,

      primaryColor: darkColors.primary,

      scaffoldBackgroundColor: darkColors.background,

      appBarTheme: AppBarTheme(
        backgroundColor: darkColors.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: darkColors.icon,
        ),
        titleTextStyle: TextStyle(
          color: darkColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: darkColors.card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: darkColors.background,
      ),

      colorScheme: ColorScheme.dark(
        primary: darkColors.primary,
        secondary: Colors.deepPurpleAccent,
        surface: darkColors.surface,
      ),
    );
  }
}