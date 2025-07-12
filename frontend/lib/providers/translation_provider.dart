import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/translation_service.dart';

// Estado del sistema de traducción
class TranslationState {
  final String currentLanguage;
  final bool isLoading;
  final Map<String, String> cachedTranslations;

  const TranslationState({
    this.currentLanguage = 'es',
    this.isLoading = false,
    this.cachedTranslations = const {},
  });

  TranslationState copyWith({
    String? currentLanguage,
    bool? isLoading,
    Map<String, String>? cachedTranslations,
  }) {
    return TranslationState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isLoading: isLoading ?? this.isLoading,
      cachedTranslations: cachedTranslations ?? this.cachedTranslations,
    );
  }
}

// Notifier para el sistema de traducción
class TranslationNotifier extends StateNotifier<TranslationState> {
  final TranslationService _translationService = TranslationService();

  TranslationNotifier() : super(const TranslationState()) {
    _initialize();
  }

  // Inicializar el servicio
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      await _translationService.initialize();
      state = state.copyWith(
        currentLanguage: _translationService.currentLanguage,
        isLoading: false,
      );
    } catch (e) {
      print('Error initializing translation service: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Cambiar idioma
  Future<void> setLanguage(String languageCode) async {
    if (!TranslationService.supportedLanguages.containsKey(languageCode)) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _translationService.setLanguage(languageCode);
      state = state.copyWith(currentLanguage: languageCode, isLoading: false);
    } catch (e) {
      print('Error setting language: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Traducir texto
  Future<String> translate(String text, {String? targetLanguage}) async {
    try {
      return await _translationService.translateText(
        text,
        targetLanguage: targetLanguage,
      );
    } catch (e) {
      print('Error translating text: $e');
      return text;
    }
  }

  // Obtener idiomas soportados
  Map<String, String> getSupportedLanguages() {
    return TranslationService.supportedLanguages;
  }

  // Obtener nombre del idioma actual
  String getCurrentLanguageName() {
    return _translationService.getCurrentLanguageName();
  }

  // Limpiar cache de traducciones
  Future<void> clearCache() async {
    state = state.copyWith(isLoading: true);

    try {
      await _translationService.clearCache();
      state = state.copyWith(cachedTranslations: {}, isLoading: false);
    } catch (e) {
      print('Error clearing cache: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Detectar idioma del texto
  Future<String> detectLanguage(String text) async {
    try {
      return await _translationService.detectLanguage(text);
    } catch (e) {
      print('Error detecting language: $e');
      return 'es';
    }
  }
}

// Providers
final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
      return TranslationNotifier();
    });

// Provider para acceso directo al servicio
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});
