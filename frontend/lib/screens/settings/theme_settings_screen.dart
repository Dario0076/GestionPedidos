import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/translated_text.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText('Configuración de Tema'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de modo de tema
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.brightness_6,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Modo de Tema',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildThemeModeOption(
                    context,
                    themeNotifier,
                    themeState,
                    AppThemeMode.light,
                    'Claro',
                    Icons.light_mode,
                  ),
                  _buildThemeModeOption(
                    context,
                    themeNotifier,
                    themeState,
                    AppThemeMode.dark,
                    'Oscuro',
                    Icons.dark_mode,
                  ),
                  _buildThemeModeOption(
                    context,
                    themeNotifier,
                    themeState,
                    AppThemeMode.system,
                    'Sistema',
                    Icons.settings_system_daydream,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sección de esquema de colores
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Esquema de Colores',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildColorOption(
                        context,
                        themeNotifier,
                        themeState,
                        AppColorScheme.blue,
                        'Azul',
                        const Color(0xFF2196F3),
                      ),
                      _buildColorOption(
                        context,
                        themeNotifier,
                        themeState,
                        AppColorScheme.green,
                        'Verde',
                        const Color(0xFF4CAF50),
                      ),
                      _buildColorOption(
                        context,
                        themeNotifier,
                        themeState,
                        AppColorScheme.purple,
                        'Morado',
                        const Color(0xFF9C27B0),
                      ),
                      _buildColorOption(
                        context,
                        themeNotifier,
                        themeState,
                        AppColorScheme.orange,
                        'Naranja',
                        const Color(0xFFFF9800),
                      ),
                      _buildColorOption(
                        context,
                        themeNotifier,
                        themeState,
                        AppColorScheme.red,
                        'Rojo',
                        const Color(0xFFF44336),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Vista previa del tema
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.preview,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vista Previa',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildThemePreview(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ThemeState themeState,
    AppThemeMode mode,
    String title,
    IconData icon,
  ) {
    final isSelected = themeState.themeMode == mode;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      selected: isSelected,
      onTap: () => themeNotifier.setThemeMode(mode),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ThemeState themeState,
    AppColorScheme colorScheme,
    String name,
    Color color,
  ) {
    final isSelected = themeState.colorScheme == colorScheme;

    return GestureDetector(
      onTap: () => themeNotifier.setColorScheme(colorScheme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 3,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              const Icon(Icons.check, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre del Usuario',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Vista previa del tema actual',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const TranslatedText('Botón Principal'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const TranslatedText('Botón Secundario'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
