import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/connection_status_widget.dart';
import '../../widgets/translated_text.dart';
import '../../widgets/translated_form_fields.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
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
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    try {
      print(
        'LoginScreen: Attempting login with email: \${_emailController.text.trim()}',
      );

      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          print('LoginScreen: Login successful, navigating to home');
          context.go('/home');
        } else {
          print('LoginScreen: Login failed');
          final authState = ref.read(authProvider);
          final errorMessage =
              authState.error ??
              'Error al iniciar sesión. Verifica tus credenciales.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Probar Conexión',
                textColor: Colors.white,
                onPressed: _testConnection,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('LoginScreen: Exception during login: \$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText('❌ Error de Login'),
                const SizedBox(height: 4),
                Text(
                  'Detalles: \${e.toString()}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text(
                  '💡 Verifica:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '• Conexión a internet\\n• Credenciales correctas\\n• Estado del servidor',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Test Conexión',
              textColor: Colors.white,
              onPressed: _testConnection,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testConnection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            TranslatedText('Probando conexión...'),
            SizedBox(height: 8),
            Text(
              'Esto puede tardar 30-60 segundos',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 60);
      dio.options.receiveTimeout = const Duration(seconds: 60);
      dio.options.sendTimeout = const Duration(seconds: 60);

      dio.options.headers = {
        'User-Agent': 'GestionPedidos-Mobile/1.0',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      print('Testing connection to: \${ApiConstants.baseUrl}/health');
      final stopwatch = Stopwatch()..start();

      final response = await dio.get('\${ApiConstants.baseUrl}/health');

      stopwatch.stop();
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        _showResult(
          '✅ Conexión Exitosa',
          'Backend respondió en \${stopwatch.elapsedMilliseconds}ms\\n\\n\${response.data}\\n\\n• Estado: FUNCIONANDO\\n• Latencia: \${stopwatch.elapsedMilliseconds}ms\\n• Servidor: Render.com',
          Colors.green,
        );
      } else {
        _showResult(
          '⚠️ Respuesta Inesperada',
          'Status HTTP: \${response.statusCode}\\nTiempo: \${stopwatch.elapsedMilliseconds}ms',
          Colors.orange,
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      print('Connection error details: \$e');

      String errorMessage;
      String troubleshooting = '';

      if (e.toString().contains('timeout') ||
          e.toString().contains('SocketException')) {
        errorMessage = '⏰ TIMEOUT DE CONEXIÓN';
        troubleshooting = '''🔄 COLD START DE RENDER DETECTADO

Render pone el servidor en "sleep" después de inactividad.
La primera conexión puede tardar 30-60 segundos.

✅ SOLUCIONES:
• Espera 1-2 minutos y vuelve a intentar
• El servidor está "despertando"
• Esto es completamente normal

🌐 VERIFICACIONES ADICIONALES:
• Confirma que tienes internet
• Prueba cambiar de WiFi a datos móviles
• Verifica que no haya restricciones de firewall''';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection') ||
          e.toString().contains('resolve')) {
        errorMessage = '🌐 ERROR DE RED';
        troubleshooting = '''❌ PROBLEMA DE CONECTIVIDAD

🔍 DIAGNÓSTICO:
• Tu dispositivo no puede alcanzar el servidor
• Puede ser problema de DNS o firewall

✅ SOLUCIONES:
• Cambia de WiFi a datos móviles (o viceversa)
• Verifica que tengas internet funcional
• Prueba abrir https://google.com en tu navegador
• Reinicia tu conexión de red
• Contacta a tu proveedor de internet si persiste''';
      } else {
        errorMessage = '❌ ERROR DESCONOCIDO';
        troubleshooting = '''🔍 DETALLES TÉCNICOS:
\${e.toString()}

✅ SOLUCIONES GENERALES:
• Reinicia la aplicación
• Verifica tu conexión a internet
• Prueba con datos móviles
• Contacta soporte si persiste''';
      }

      _showResult(errorMessage, troubleshooting, Colors.red);
    }
  }

  void _showResult(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                '🔧 Información Técnica:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌐 URL: \${ApiConstants.baseUrl}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📱 Dispositivo: Android',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⏰ Timestamp: \${DateTime.now().toString()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (color == Colors.red) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange[300] ?? Colors.orange,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 CONSEJO IMPORTANTE:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Si este es tu primer intento, espera 1-2 minutos. Los servidores gratuitos de Render tardan en "despertar".',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const TranslatedText('Cerrar'),
          ),
          if (color == Colors.red)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _testConnection();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo y título mejorado
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TranslatedText(
                    'Gestión de Pedidos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TranslatedText(
                    'Inicia sesión para continuar',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Widget de estado de conexión
                  const ConnectionStatusWidget(),
                  const SizedBox(height: 24),

                  // Formulario de login
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TranslatedTextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          labelText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo';
                            }
                            if (!value.contains('@')) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TranslatedTextFormField(
                          controller: _passwordController,
                          obscureText: _isObscured,
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                setState(() => _isObscured = !_isObscured),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Botón de login
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const TranslatedText(
                                    'Iniciar Sesión',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botón de test de conexión
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _testConnection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wifi_find, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Test de Conexión',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botón de configuración
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton.icon(
                            onPressed: () => context.push('/settings'),
                            icon: const Icon(Icons.settings),
                            label: const Text(
                              'Configuración',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Información de usuarios de prueba
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue[200] ?? Colors.blue,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '👥 Usuarios de Prueba',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '🔑 Administrador:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TranslatedText('Email: admin@test.com'),
                        TranslatedText('Password: admin123'),
                        SizedBox(height: 8),
                        Text(
                          '👤 Usuario Regular:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TranslatedText('Email: user@user.com'),
                        TranslatedText('Password: user123'),
                        SizedBox(height: 12),
                        Text(
                          '💡 Si es tu primera vez, usa el "Test de Conexión" primero. El servidor puede tardar 1-2 minutos en despertar.',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
