import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/connection_status_widget.dart';
import '../../utils/constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          context.go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al iniciar sesión. Verifica tus credenciales.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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
            Text('Probando conexión...'),
            SizedBox(height: 8),
            Text('Esto puede tardar 30-60 segundos', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
      
      print('Testing connection to: ${ApiConstants.baseUrl}/health');
      final stopwatch = Stopwatch()..start();
      
      final response = await dio.get('${ApiConstants.baseUrl}/health');
      
      stopwatch.stop();
      Navigator.of(context).pop();
      
      if (response.statusCode == 200) {
        _showResult('✅ Conexión Exitosa', 
          'Backend respondió en ${stopwatch.elapsedMilliseconds}ms\n\n${response.data}\n\n• Estado: FUNCIONANDO\n• Latencia: ${stopwatch.elapsedMilliseconds}ms\n• Servidor: Render.com', Colors.green);
      } else {
        _showResult('⚠️ Respuesta Inesperada', 
          'Status HTTP: ${response.statusCode}\nTiempo: ${stopwatch.elapsedMilliseconds}ms', Colors.orange);
      }
    } catch (e) {
      Navigator.of(context).pop();
      print('Connection error details: $e');
      
      String errorMessage;
      String troubleshooting = '';
      
      if (e.toString().contains('timeout') || e.toString().contains('SocketException')) {
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
      } else if (e.toString().contains('network') || e.toString().contains('connection') || e.toString().contains('resolve')) {
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
      } else if (e.toString().contains('certificate') || e.toString().contains('handshake')) {
        errorMessage = '🔒 ERROR DE CERTIFICADO SSL';
        troubleshooting = '''🛡️ PROBLEMA DE SEGURIDAD

El dispositivo no puede verificar el certificado SSL.

✅ SOLUCIONES:
• Verifica que la fecha/hora del dispositivo sea correcta
• Actualiza el sistema operativo Android
• Prueba con una red diferente''';
      } else {
        errorMessage = '❌ ERROR DESCONOCIDO';
        troubleshooting = '''🔍 DETALLES TÉCNICOS:
${e.toString()}

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
        title: Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text('🔧 Información Técnica:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    Text('🌐 URL: ${ApiConstants.baseUrl}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                    const SizedBox(height: 4),
                    Text('📱 Dispositivo: Android', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('⏰ Timestamp: ${DateTime.now().toString()}', style: const TextStyle(fontSize: 12)),
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
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('💡 CONSEJO IMPORTANTE:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                      SizedBox(height: 4),
                      Text('Si este es tu primer intento, espera 1-2 minutos. Los servidores gratuitos de Render tardan en "despertar".', 
                        style: TextStyle(fontSize: 12)),
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
            child: const Text('Cerrar'),
          ),
          if (color == Colors.red)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _testConnection();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo y título
                Icon(
                  Icons.shopping_cart,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Gestión de Pedidos',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
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
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
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
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _isObscured = !_isObscured),
                          ),
                          border: const OutlineInputBorder(),
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
                              : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Botón de test de conexión - MEJORADO
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
                              Text('Test de Conexión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
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
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '👥 Usuarios de Prueba',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      const Text('🔑 Administrador:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Email: admin@admin.com'),
                      const Text('Password: admin123'),
                      const SizedBox(height: 8),
                      const Text('👤 Usuario Regular:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Email: user@user.com'),
                      const Text('Password: user123'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '💡 Si es tu primera vez, usa el "Test de Conexión" primero. El servidor puede tardar 1-2 minutos en despertar.',
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
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
    );
  }
}
