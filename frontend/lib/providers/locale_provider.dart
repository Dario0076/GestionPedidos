import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('es'); // Español por defecto
  static const String _localeKey = 'app_locale';

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  // Cargar idioma guardado
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'es';
    _locale = Locale(localeCode);
    notifyListeners();
  }

  // Guardar idioma
  Future<void> _saveLocale(String localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, localeCode);
  }

  // Cambiar idioma
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    await _saveLocale(locale.languageCode);
    notifyListeners();
  }

  // Alternar entre español e inglés
  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'es' 
        ? const Locale('en') 
        : const Locale('es');
    await setLocale(newLocale);
  }

  // Idiomas soportados
  static const List<Locale> supportedLocales = [
    Locale('es'), // Español
    Locale('en'), // Inglés
  ];

  // Nombres de los idiomas
  static const Map<String, String> languageNames = {
    'es': 'Español',
    'en': 'English',
  };

  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  String get currentLanguageName => getLanguageName(_locale.languageCode);

  // Helper para obtener traducciones
  AppLocalizations getLocalizations() {
    return AppLocalizations(_locale.languageCode);
  }
}
