import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enums para los temas
enum AppThemeMode { light, dark, system }
enum AppColorScheme { blue, green, purple, orange, red }

// Clase para manejar el estado del tema
class ThemeState {
  final AppThemeMode themeMode;
  final AppColorScheme colorScheme;
  final bool isSystemTheme;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.colorScheme = AppColorScheme.blue,
    this.isSystemTheme = true,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    AppColorScheme? colorScheme,
    bool? isSystemTheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      colorScheme: colorScheme ?? this.colorScheme,
      isSystemTheme: isSystemTheme ?? this.isSystemTheme,
    );
  }

  // Convertir a JSON para SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'colorScheme': colorScheme.index,
      'isSystemTheme': isSystemTheme,
    };
  }

  // Crear desde JSON
  factory ThemeState.fromJson(Map<String, dynamic> json) {
    return ThemeState(
      themeMode: AppThemeMode.values[json['themeMode'] ?? 0],
      colorScheme: AppColorScheme.values[json['colorScheme'] ?? 0],
      isSystemTheme: json['isSystemTheme'] ?? true,
    );
  }
}

// Clase para manejar los temas
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'app_theme_settings';
  
  ThemeNotifier() : super(const ThemeState()) {
    _loadThemeFromPrefs();
  }

  // Cargar tema desde SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeJson = prefs.getString(_themeKey);
      if (themeJson != null) {
        final themeData = Map<String, dynamic>.from(
          // En una app real usarías json.decode, aquí simulamos
          {'themeMode': 0, 'colorScheme': 0, 'isSystemTheme': true}
        );
        state = ThemeState.fromJson(themeData);
      }
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  // Guardar tema en SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // En una app real usarías json.encode
      await prefs.setString(_themeKey, 'theme_data');
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  // Cambiar modo de tema
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(
      themeMode: mode,
      isSystemTheme: mode == AppThemeMode.system,
    );
    await _saveThemeToPrefs();
  }

  // Cambiar esquema de colores
  Future<void> setColorScheme(AppColorScheme colorScheme) async {
    state = state.copyWith(colorScheme: colorScheme);
    await _saveThemeToPrefs();
  }

  // Toggle entre claro y oscuro
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
    await setThemeMode(newMode);
  }

  // Obtener el ThemeMode de Flutter
  ThemeMode get flutterThemeMode {
    switch (state.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Obtener colores para el esquema seleccionado
  Color get seedColor {
    switch (state.colorScheme) {
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

  // Crear tema claro
  ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }

  // Crear tema oscuro
  ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }
}

// Provider para el tema
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// Provider para acceder al notifier
final themeNotifierProvider = Provider<ThemeNotifier>((ref) {
  return ref.read(themeProvider.notifier);
});
