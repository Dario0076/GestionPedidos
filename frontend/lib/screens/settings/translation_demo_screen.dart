import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/translated_text.dart';
import '../../providers/translation_provider.dart';

class TranslationDemoScreen extends ConsumerWidget {
  const TranslationDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText('Demo de Traducción'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Selector de idioma en la barra superior
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const LanguageSelector(showName: false),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información del idioma actual
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      const TranslatedText(
                        'Información del Sistema',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const TranslatedText(
                    'Este es un ejemplo de cómo funciona el sistema de traducción automática '
                    'usando Google Translate. Todos los textos se traducen automáticamente '
                    'al idioma seleccionado.',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const TranslatedText('Idioma actual: '),
                      Text(
                        translationState.currentLanguage.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Ejemplos de textos traducidos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.translate, color: Colors.green),
                      const SizedBox(width: 8),
                      const TranslatedText(
                        'Ejemplos de Traducción',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTranslationExample(
                    'Bienvenido a nuestra aplicación',
                    Icons.waving_hand,
                  ),
                  _buildTranslationExample(
                    'Gestión de Pedidos Inteligente',
                    Icons.shopping_cart,
                  ),
                  _buildTranslationExample(
                    'Productos disponibles en el catálogo',
                    Icons.inventory,
                  ),
                  _buildTranslationExample(
                    'Configuraciones de usuario avanzadas',
                    Icons.settings,
                  ),
                  _buildTranslationExample(
                    'Sistema de notificaciones en tiempo real',
                    Icons.notifications,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Formulario de ejemplo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note, color: Colors.orange),
                      const SizedBox(width: 8),
                      const TranslatedText(
                        'Formulario de Ejemplo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      hintText: 'Ingresa tu nombre completo',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'ejemplo@correo.com',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Mensaje',
                      hintText: 'Escribe tu mensaje aquí...',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.message),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                      label: const TranslatedText('Enviar Mensaje'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Opciones adicionales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.more_horiz, color: Colors.purple),
                      const SizedBox(width: 8),
                      const TranslatedText(
                        'Opciones Adicionales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const TranslatedText('Configuración Avanzada'),
                    subtitle: const TranslatedText(
                      'Personalizar opciones de traducción',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.push('/settings/language');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const TranslatedText('Recargar Traducciones'),
                    subtitle: const TranslatedText(
                      'Limpiar caché y obtener nuevas traducciones',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ref.read(translationProvider.notifier).clearCache();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: TranslatedText(
                            'Cache limpiado correctamente',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationExample(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: TranslatedText(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
