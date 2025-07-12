import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/translation_provider.dart';

/// Widget que traduce automáticamente el texto mostrado
class TranslatedText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool softWrap;
  final String? targetLanguage;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap = true,
    this.targetLanguage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationNotifier = ref.read(translationProvider.notifier);
    final translationState = ref.watch(translationProvider);

    // Si el idioma es español o está cargando, mostrar texto original
    if (translationState.currentLanguage == 'es' ||
        translationState.isLoading) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        softWrap: softWrap,
      );
    }

    return FutureBuilder<String>(
      future: translationNotifier.translate(
        text,
        targetLanguage: targetLanguage,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar texto original mientras carga
          return Text(
            text,
            style: style?.copyWith(color: Colors.grey),
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
            softWrap: softWrap,
          );
        }

        if (snapshot.hasError) {
          // Si hay error, mostrar texto original
          return Text(
            text,
            style: style,
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
            softWrap: softWrap,
          );
        }

        return Text(
          snapshot.data ?? text,
          style: style,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
          softWrap: softWrap,
        );
      },
    );
  }
}

/// Widget para mostrar hints traducidos en formularios
class TranslatedHint extends ConsumerWidget {
  final String hintText;
  final String? targetLanguage;

  const TranslatedHint(this.hintText, {super.key, this.targetLanguage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationNotifier = ref.read(translationProvider.notifier);
    final translationState = ref.watch(translationProvider);

    if (translationState.currentLanguage == 'es') {
      return Text(hintText);
    }

    return FutureBuilder<String>(
      future: translationNotifier.translate(
        hintText,
        targetLanguage: targetLanguage,
      ),
      builder: (context, snapshot) {
        return Text(snapshot.data ?? hintText);
      },
    );
  }
}

/// Extensión para traducir strings fácilmente
extension StringTranslation on String {
  Widget translated({
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool softWrap = true,
    String? targetLanguage,
  }) {
    return TranslatedText(
      this,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
      targetLanguage: targetLanguage,
    );
  }
}

/// Widget para seleccionar idioma
class LanguageSelector extends ConsumerWidget {
  final bool showFlag;
  final bool showName;

  const LanguageSelector({
    super.key,
    this.showFlag = true,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationProvider);
    final translationNotifier = ref.read(translationProvider.notifier);
    final supportedLanguages = translationNotifier.getSupportedLanguages();

    return PopupMenuButton<String>(
      onSelected: (String languageCode) {
        translationNotifier.setLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) {
        return supportedLanguages.entries.map((entry) {
          final isSelected = entry.key == translationState.currentLanguage;

          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                if (showFlag) ...[
                  Text(
                    _getFlag(entry.key),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                ],
                if (showName)
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(Icons.check, color: Colors.green),
                ],
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFlag) ...[
              Text(
                _getFlag(translationState.currentLanguage),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
            ],
            if (showName)
              Text(
                supportedLanguages[translationState.currentLanguage] ??
                    'Español',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  String _getFlag(String languageCode) {
    const flags = {
      'es': '🇪🇸',
      'en': '🇺🇸',
      'fr': '🇫🇷',
      'de': '🇩🇪',
      'it': '🇮🇹',
      'pt': '🇵🇹',
      'ru': '🇷🇺',
      'zh': '🇨🇳',
      'ja': '🇯🇵',
      'ko': '🇰🇷',
      'ar': '🇸🇦',
      'hi': '🇮🇳',
    };
    return flags[languageCode] ?? '🌍';
  }
}

/// Widget de carga para traducciones
class TranslationLoader extends StatelessWidget {
  final Widget child;

  const TranslationLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final translationState = ref.watch(translationProvider);

        if (translationState.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando traducciones...'),
              ],
            ),
          );
        }

        return child;
      },
    );
  }
}
