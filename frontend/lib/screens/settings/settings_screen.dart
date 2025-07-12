import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/accessibility_provider.dart';
import '../../widgets/responsive_widgets.dart';
import '../../utils/animations.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/translated_text.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final localizations = AppLocalizations(
      Localizations.localeOf(context).languageCode,
    );

    return ResponsiveSafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.settings),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: const Icon(Icons.palette), text: 'Tema'),
              Tab(icon: const Icon(Icons.language), text: 'Idioma'),
              Tab(icon: const Icon(Icons.accessibility), text: 'Accesibilidad'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildThemeSettings(context, localizations),
            _buildLanguageSettings(context, localizations),
            _buildAccessibilitySettings(context, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettings(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return ResponsiveBuilder(
      mobile: _buildMobileThemeSettings(context, localizations),
      tablet: _buildTabletThemeSettings(context, localizations),
      desktop: _buildDesktopThemeSettings(context, localizations),
    );
  }

  Widget _buildMobileThemeSettings(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final themeState = ref.watch(themeProvider);

    return SingleChildScrollView(
      padding: ScreenSize.responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCard(
            child: _buildThemeModeSection(
              themeNotifier,
              themeState,
              localizations,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedCard(
            delay: const Duration(milliseconds: 100),
            child: _buildColorSchemeSection(
              themeNotifier,
              themeState,
              localizations,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletThemeSettings(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final themeState = ref.watch(themeProvider);

    return SingleChildScrollView(
      child: ResponsivePadding(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AnimatedCard(
                child: _buildThemeModeSection(
                  themeNotifier,
                  themeState,
                  localizations,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedCard(
                delay: const Duration(milliseconds: 100),
                child: _buildColorSchemeSection(
                  themeNotifier,
                  themeState,
                  localizations,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopThemeSettings(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return AdaptiveContainer(
      desktopMaxWidth: 800,
      child: _buildTabletThemeSettings(context, localizations),
    );
  }

  Widget _buildThemeModeSection(
    ThemeNotifier themeNotifier,
    ThemeState themeState,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('theme_mode'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...AppThemeMode.values.map((mode) {
              return RadioListTile<AppThemeMode>(
                title: Text(_getThemeModeLabel(mode, localizations)),
                value: mode,
                groupValue: themeState.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeNotifier.setThemeMode(value);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSchemeSection(
    ThemeNotifier themeNotifier,
    ThemeState themeState,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.colorScheme,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppColorScheme.values.map((scheme) {
                final isSelected = themeState.colorScheme == scheme;
                return GestureDetector(
                  onTap: () => themeNotifier.setColorScheme(scheme),
                  child: AnimatedContainer(
                    duration: AppAnimations.medium,
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getColorForScheme(scheme),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 4)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _getColorForScheme(
                                  scheme,
                                ).withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 30)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSettings(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return SingleChildScrollView(
      child: ResponsivePadding(
        child: Column(
          children: [
            AnimatedCard(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Idioma',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...LocaleProvider.supportedLocales.map((locale) {
                        return Consumer(
                          builder: (context, ref, child) {
                            final localeProvider = ref.watch(
                              localeProviderNotifier,
                            );
                            final isSelected = localeProvider.locale == locale;

                            return ListTile(
                              title: Text(
                                LocaleProvider.languageNames[locale
                                        .languageCode] ??
                                    locale.languageCode,
                              ),
                              subtitle: Text(locale.languageCode.toUpperCase()),
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[300],
                                child: Text(
                                  locale.languageCode.toUpperCase().substring(
                                    0,
                                    2,
                                  ),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                ref
                                    .read(localeProviderNotifier.notifier)
                                    .setLocale(locale);
                              },
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 16),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.translate),
                        title: const TranslatedText('Traducción Automática'),
                        subtitle: const Text(
                          'Traducir toda la app con Google Translate',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          context.push('/settings/language');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilitySettings(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return SingleChildScrollView(
      child: ResponsivePadding(
        child: Column(
          children: [
            AnimatedCard(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('accessibility'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Consumer(
                        builder: (context, ref, child) {
                          final accessibilityProvider = ref.watch(
                            accessibilityProviderNotifier,
                          );

                          return Column(
                            children: [
                              SwitchListTile(
                                title: Text(
                                  localizations.translate('high_contrast'),
                                ),
                                subtitle: Text(
                                  localizations.translate('improve_visibility'),
                                ),
                                value: accessibilityProvider.useHighContrast,
                                onChanged: (value) {
                                  ref
                                      .read(
                                        accessibilityProviderNotifier.notifier,
                                      )
                                      .toggleHighContrast();
                                },
                              ),
                              SwitchListTile(
                                title: Text(
                                  localizations.translate('vibration'),
                                ),
                                subtitle: Text(
                                  localizations.translate('haptic_feedback'),
                                ),
                                value: accessibilityProvider.enableVibration,
                                onChanged: (value) {
                                  ref
                                      .read(
                                        accessibilityProviderNotifier.notifier,
                                      )
                                      .toggleVibration();
                                },
                              ),
                              SwitchListTile(
                                title: Text(localizations.translate('sounds')),
                                subtitle: Text(
                                  localizations.translate('system_sounds'),
                                ),
                                value: accessibilityProvider.enableSounds,
                                onChanged: (value) {
                                  ref
                                      .read(
                                        accessibilityProviderNotifier.notifier,
                                      )
                                      .toggleSounds();
                                },
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  localizations.translate('text_scale'),
                                ),
                                subtitle: Slider(
                                  value: accessibilityProvider.textScaleFactor,
                                  min: 0.8,
                                  max: 2.0,
                                  divisions: 12,
                                  label:
                                      '${(accessibilityProvider.textScaleFactor * 100).round()}%',
                                  onChanged: (value) {
                                    ref
                                        .read(
                                          accessibilityProviderNotifier
                                              .notifier,
                                        )
                                        .setTextScaleFactor(value);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeLabel(AppThemeMode mode, AppLocalizations localizations) {
    switch (mode) {
      case AppThemeMode.light:
        return localizations.lightMode;
      case AppThemeMode.dark:
        return localizations.darkMode;
      case AppThemeMode.system:
        return localizations.translate('system_theme');
    }
  }

  Color _getColorForScheme(AppColorScheme scheme) {
    switch (scheme) {
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

// Providers para accessibility y locale
final accessibilityProviderNotifier =
    ChangeNotifierProvider<AccessibilityProvider>((ref) {
      return AccessibilityProvider();
    });

final localeProviderNotifier = ChangeNotifierProvider<LocaleProvider>((ref) {
  return LocaleProvider();
});
