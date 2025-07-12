import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class AppThemes {
  static ThemeData lightTheme(ThemeState themeState) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _getSeedColor(themeState.colorScheme),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: _getSeedColor(themeState.colorScheme),
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.white,
        textColor: Colors.black87,
        iconColor: Colors.black54,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Color(0xFF757575),
      ),
      dividerColor: const Color(0xFFE0E0E0),
    );
  }

  static ThemeData darkTheme(ThemeState themeState) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _getSeedColor(themeState.colorScheme),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: _getSeedColor(themeState.colorScheme),
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: Color(0xFF1E1E1E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Color(0xFF1E1E1E),
        textColor: Colors.white,
        iconColor: Colors.white70,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFF9E9E9E),
      ),
      dividerColor: const Color(0xFF3E3E3E),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),
    );
  }

  static ThemeMode getThemeMode(ThemeState themeState) {
    switch (themeState.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  static Color _getSeedColor(AppColorScheme colorScheme) {
    switch (colorScheme) {
      case AppColorScheme.blue:
        return const Color(0xFF2196F3);
      case AppColorScheme.green:
        return const Color(0xFF4CAF50);
      case AppColorScheme.purple:
        return const Color(0xFF9C27B0);
      case AppColorScheme.orange:
        return const Color(0xFFFF9800);
      case AppColorScheme.red:
        return const Color(0xFFF44336);
    }
  }
}
