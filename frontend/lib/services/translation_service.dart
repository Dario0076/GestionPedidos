import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static const String _languageKey = 'selected_language';
  static const String _cachePrefix = 'translation_cache_';

  final GoogleTranslator _translator = GoogleTranslator();

  // Idiomas soportados
  static const Map<String, String> supportedLanguages = {
    'es': 'Español',
    'en': 'English',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'ar': 'العربية',
    'hi': 'हिन्दी',
  };

  // Singleton
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // Idioma actual
  String _currentLanguage = 'es';
  String get currentLanguage => _currentLanguage;

  // Cache de traducciones
  final Map<String, String> _translationCache = {};

  // Inicializar el servicio
  Future<void> initialize() async {
    await _loadSavedLanguage();
    await _loadCachedTranslations();
  }

  // Cargar idioma guardado
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString(_languageKey) ?? 'es';
    } catch (e) {
      print('Error loading saved language: $e');
    }
  }

  // Cargar traducciones en cache
  Future<void> _loadCachedTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));

      for (String key in keys) {
        final value = prefs.getString(key);
        if (value != null) {
          final originalKey = key.substring(_cachePrefix.length);
          _translationCache[originalKey] = value;
        }
      }
    } catch (e) {
      print('Error loading cached translations: $e');
    }
  }

  // Cambiar idioma
  Future<void> setLanguage(String languageCode) async {
    if (supportedLanguages.containsKey(languageCode)) {
      _currentLanguage = languageCode;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
      } catch (e) {
        print('Error saving language: $e');
      }
    }
  }

  // Traducir texto usando Google Translator
  Future<String> translateText(String text, {String? targetLanguage}) async {
    final target = targetLanguage ?? _currentLanguage;

    // Si el idioma objetivo es español, devolver el texto original
    if (target == 'es') return text;

    // Crear clave de cache
    final cacheKey = '${text}_$target';

    // Verificar cache
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    try {
      // Usar Google Translate a través del paquete translator
      final translation = await _translator.translate(text, to: target);
      final result = translation.text;

      // Guardar en cache
      _translationCache[cacheKey] = result;
      await _saveCachedTranslation(cacheKey, result);

      return result;
    } catch (e) {
      print('Translation failed: $e');
      return text; // Devolver texto original si falla
    }
  }

  // Guardar traducción en cache
  Future<void> _saveCachedTranslation(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix$key', value);
    } catch (e) {
      print('Error saving cached translation: $e');
    }
  }

  // Traducir mapa de textos (útil para formularios)
  Future<Map<String, String>> translateMap(
    Map<String, String> texts, {
    String? targetLanguage,
  }) async {
    final Map<String, String> translatedMap = {};

    for (String key in texts.keys) {
      final originalText = texts[key]!;
      final translatedText = await translateText(
        originalText,
        targetLanguage: targetLanguage,
      );
      translatedMap[key] = translatedText;
    }

    return translatedMap;
  }

  // Limpiar cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));

      for (String key in keys) {
        await prefs.remove(key);
      }

      _translationCache.clear();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Detectar idioma del texto
  Future<String> detectLanguage(String text) async {
    try {
      final detection = await _translator.translate(text, to: 'en');
      return detection.sourceLanguage.code;
    } catch (e) {
      print('Language detection failed: $e');
      return 'es'; // Por defecto español
    }
  }

  // Obtener nombre del idioma actual
  String getCurrentLanguageName() {
    return supportedLanguages[_currentLanguage] ?? 'Español';
  }

  // Verificar si un idioma está soportado
  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.containsKey(languageCode);
  }
}
