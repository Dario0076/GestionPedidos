import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/accessibility_provider.dart';
import '../../widgets/connection_status_widget.dart';
import '../../widgets/responsive_widgets.dart';
import '../../utils/animations.dart';
import '../../utils/app_localizations.dart';

// Provider para accessibility
final accessibilityProviderNotifier =
    ChangeNotifierProvider<AccessibilityProvider>((ref) {
      return AccessibilityProvider();
    });

class EnhancedLoginScreen extends ConsumerStatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  ConsumerState<EnhancedLoginScreen> createState() =>
      _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends ConsumerState<EnhancedLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);

      // Primero intentar con el método simple
      print('🔍 Login: Intentando con método simple');
      bool success = await authNotifier.loginSimple(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Si el método simple falla, intentar con el método original
      if (!success) {
        print('🔍 Login: Método simple falló, intentando método original');
        success = await authNotifier.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (mounted) {
        if (success) {
          // Agregar feedback háptico
          ref.read(accessibilityProviderNotifier).provideMediumFeedback();
          print('🔍 Login: Éxito, navegando a /home');
          context.go('/home');
        } else {
          ref.read(accessibilityProviderNotifier).provideHeavyFeedback();
          print('🔍 Login: Credenciales inválidas');
          _showErrorSnackBar('Credenciales inválidas');
        }
      }
    } catch (e, stackTrace) {
      print('🔍 Login: Excepción capturada: $e');
      print('🔍 Login: Stack trace: $stackTrace');
      if (mounted) {
        ref.read(accessibilityProviderNotifier).provideHeavyFeedback();
        _showErrorSnackBar('Error de conexión: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _fillTestData() {
    setState(() {
      _emailController.text = 'admin@test.com';
      _passwordController.text = 'admin123';
    });
    ref.read(accessibilityProviderNotifier).provideSelectionFeedback();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations(
      Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      body: ResponsiveSafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: ResponsivePadding(
                mobilePadding: const EdgeInsets.all(24.0),
                tabletPadding: const EdgeInsets.all(48.0),
                desktopPadding: const EdgeInsets.all(64.0),
                child: AdaptiveContainer(
                  mobileMaxWidth: double.infinity,
                  tabletMaxWidth: 500,
                  desktopMaxWidth: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // Logo y título animados
                      AnimatedCard(
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          children: [
                            PulseAnimation(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shopping_cart,
                                  size: ScreenSize.responsive(
                                    context,
                                    mobile: 60.0,
                                    tablet: 70.0,
                                    desktop: 80.0,
                                  ),
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              localizations.appName,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                    fontSize: ScreenSize.responsiveFontSize(
                                      context,
                                      mobile: 24,
                                      tablet: 28,
                                      desktop: 32,
                                    ),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Inicia sesión para continuar',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Widget de estado de conexión
                      AnimatedCard(
                        delay: const Duration(milliseconds: 300),
                        child: const ConnectionStatusWidget(),
                      ),

                      const SizedBox(height: 24),

                      // Formulario de login animado
                      AnimatedCard(
                        delay: const Duration(milliseconds: 400),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AccessibleTextField(
                                controller: _emailController,
                                labelText: localizations.email,
                                semanticLabel: 'Campo de correo electrónico',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El correo electrónico es requerido';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Formato de correo inválido';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              AccessibleTextField(
                                controller: _passwordController,
                                labelText: localizations.password,
                                semanticLabel: 'Campo de contraseña',
                                obscureText: _isObscured,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La contraseña es requerida';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 8),

                              // Checkbox para mostrar/ocultar contraseña
                              Row(
                                children: [
                                  Checkbox(
                                    value: !_isObscured,
                                    onChanged: (value) {
                                      setState(() {
                                        _isObscured = !value!;
                                      });
                                      ref
                                          .read(accessibilityProviderNotifier)
                                          .provideSelectionFeedback();
                                    },
                                  ),
                                  Text('Mostrar contraseña'),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Botón de login
                              SizedBox(
                                width: double.infinity,
                                height: ScreenSize.responsiveButtonHeight(
                                  context,
                                ),
                                child: AccessibleButton(
                                  onPressed: _isLoading ? null : _login,
                                  semanticLabel: localizations.loginButton,
                                  child: _isLoading
                                      ? const LoadingDots(color: Colors.white)
                                      : Text(
                                          localizations.loginButton,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Enlaces adicionales
                      AnimatedCard(
                        delay: const Duration(milliseconds: 500),
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: Text('Crear cuenta nueva'),
                            ),
                            TextButton(
                              onPressed: () => context.push('/settings'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.settings, size: 16),
                                  const SizedBox(width: 4),
                                  Text(localizations.settings),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botones de prueba (solo en debug)
                      if (kDebugMode) ...[
                        AnimatedCard(
                          delay: const Duration(milliseconds: 600),
                          child: _buildTestButtons(context, localizations),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestButtons(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Herramientas de Desarrollo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _fillTestData,
                    icon: const Icon(Icons.person, size: 16),
                    label: const Text('Admin', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/connection-test'),
                    icon: const Icon(Icons.network_check, size: 16),
                    label: const Text('Test', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/debug-login'),
                    icon: const Icon(Icons.bug_report, size: 16),
                    label: const Text('Debug', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '👥 Usuarios de Prueba',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '🔑 Administrador: admin@test.com / admin123',
                    style: TextStyle(fontSize: 12),
                  ),
                  const Text(
                    '👤 Usuario: user@user.com / user123',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '💡 El servidor puede tardar 1-2 minutos en despertar',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
