import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/translation_provider.dart';
import '../../widgets/translated_text.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationProvider);
    final translationNotifier = ref.read(translationProvider.notifier);
    final supportedLanguages = translationNotifier.getSupportedLanguages();

    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText('Configuración de Idioma'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              translationNotifier.clearCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: TranslatedText('Cache de traducciones limpiado'),
                ),
              );
            },
            tooltip: 'Limpiar cache de traducciones',
          ),
        ],
      ),
      body: translationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Información actual
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.language,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Idioma Actual',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getFlag(translationState.currentLanguage),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                supportedLanguages[translationState
                                        .currentLanguage] ??
                                    'Español',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de idiomas disponibles
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.translate,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Idiomas Disponibles',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...supportedLanguages.entries.map((entry) {
                          final isSelected =
                              entry.key == translationState.currentLanguage;

                          return ListTile(
                            leading: Text(
                              _getFlag(entry.key),
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(entry.value),
                            subtitle: entry.key == 'es'
                                ? const TranslatedText('Idioma original')
                                : const TranslatedText(
                                    'Traducción automática con Google Translate',
                                  ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  )
                                : null,
                            selected: isSelected,
                            onTap: () async {
                              if (!isSelected) {
                                await translationNotifier.setLanguage(
                                  entry.key,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: TranslatedText(
                                        'Idioma cambiado a ${entry.value}',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Información sobre las traducciones
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Información',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const TranslatedText(
                          'Las traducciones se realizan automáticamente usando Google Translate. '
                          'Los textos se almacenan en caché para mejorar el rendimiento.',
                          style: TextStyle(height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        const TranslatedText(
                          '• El idioma original de la aplicación es español\n'
                          '• Las traducciones se cargan la primera vez que se muestran\n'
                          '• El caché se guarda localmente en el dispositivo\n'
                          '• Puedes limpiar el caché para obtener nuevas traducciones',
                          style: TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botones de acción
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await translationNotifier.clearCache();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: TranslatedText(
                                      'Cache limpiado correctamente',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.clear_all),
                            label: const TranslatedText(
                              'Limpiar Cache de Traducciones',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              translationNotifier.setLanguage('es');
                            },
                            icon: const Icon(Icons.home),
                            label: const TranslatedText('Volver al Español'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              context.push('/settings/translation-demo');
                            },
                            icon: const Icon(Icons.preview),
                            label: const TranslatedText(
                              'Ver Demo de Traducción',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
