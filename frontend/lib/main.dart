import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/accessibility_provider.dart';
import 'services/api_service.dart';
import 'services/translation_service.dart';
import 'utils/app_themes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/admin/products/admin_products_screen.dart';
import 'screens/admin/categories/admin_categories_screen.dart';
import 'screens/admin/users/admin_users_screen.dart';
import 'screens/admin/orders/admin_orders_screen.dart';
import 'screens/connection_test_screen.dart';
import 'screens/debug_login_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/language_settings_screen.dart';
import 'screens/settings/translation_demo_screen.dart';
import 'utils/app_localizations.dart';

// Providers para los nuevos sistemas
final accessibilityProviderNotifier =
    ChangeNotifierProvider<AccessibilityProvider>((ref) {
      return AccessibilityProvider();
    });

final localeProviderNotifier = ChangeNotifierProvider<LocaleProvider>((ref) {
  return LocaleProvider();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar servicios
  ApiService().init();

  // Inicializar sistema de traducción
  await TranslationService().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProviderNotifier);

    return MaterialApp.router(
      title: 'Gestión de Pedidos',
      debugShowCheckedModeBanner: false,

      // Temas - CORREGIDO PARA QUE RESPONDA A CAMBIOS
      theme: AppThemes.lightTheme(themeState),
      darkTheme: AppThemes.darkTheme(themeState),
      themeMode: AppThemes.getThemeMode(themeState),

      // Localización
      locale: localeState.locale,
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routerConfig: _createRouter(authState.isAuthenticated),
    );
  }

  GoRouter _createRouter(bool isAuthenticated) {
    return GoRouter(
      initialLocation: isAuthenticated ? '/home' : '/login',
      redirect: (context, state) {
        final isLoggedIn = isAuthenticated;
        final isLoggingIn =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // Si no está logueado y no está en pantalla de auth, redirigir a login
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // Si está logueado y está en pantalla de auth, redirigir a home
        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        // Rutas de autenticación
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Rutas principales
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/settings/language',
          builder: (context, state) => const LanguageSettingsScreen(),
        ),
        GoRoute(
          path: '/settings/translation-demo',
          builder: (context, state) => const TranslationDemoScreen(),
        ),

        // Rutas de administrador
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminScreen(),
        ),
        GoRoute(
          path: '/admin/products',
          builder: (context, state) => const AdminProductsScreen(),
        ),
        GoRoute(
          path: '/admin/categories',
          builder: (context, state) => const AdminCategoriesScreen(),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: '/admin/orders',
          builder: (context, state) => const AdminOrdersScreen(),
        ),

        // Pantalla de test de conexión
        GoRoute(
          path: '/connection-test',
          builder: (context, state) => const ConnectionTestScreen(),
        ),

        // Pantalla de debug de login
        GoRoute(
          path: '/debug-login',
          builder: (context, state) => const DebugLoginScreen(),
        ),

        // Ruta raíz
        GoRoute(
          path: '/',
          redirect: (context, state) => isAuthenticated ? '/home' : '/login',
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Página no encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.fullPath ?? 'Ruta desconocida',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
