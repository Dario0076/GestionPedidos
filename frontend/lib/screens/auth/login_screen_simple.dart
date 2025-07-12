import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/connection_status_widget.dart';

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('LoginScreen: Attempting login with email: \${_emailController.text.trim()}');
      
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
                onPressed: _testConnection,
              ),
            ),
          );
                Text('Detalles: \${e.toString()}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                const Text('💡 Verifica:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('• Conexión a internet\\n• Credenciales correctas\\n• Estado del servidor', 
// Eliminado: test de conexión, configuración y usuarios de prueba
            Text('Probando conexión...'),
            SizedBox(height: 8),
            Text('Esto puede tardar 30-60 segundos', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    )

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 60);
      dio.options.receiveTimeout = const Duration(seconds: 60);
      dio.options.sendTimeout = const Duration(seconds: 60);
  // Eliminado: función de test de conexión y textos relacionados
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🌐 URL: \${ApiConstants.baseUrl}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                    const SizedBox(height: 4),
                    Text('📱 Dispositivo: Android', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('⏰ Timestamp: \${DateTime.now().toString()}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (color == Colors.red) {
                [
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
              ]
              },
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
    )
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
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
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
                              Text('Test de Conexión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          label: const Text('Configuración', style: TextStyle(fontSize: 16)),
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
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👥 Usuarios de Prueba',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 12),
                      Text('🔑 Administrador:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Email: admin@test.com'),
                      Text('Password: admin123'),
                      SizedBox(height: 8),
                      Text('👤 Usuario Regular:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Email: user@user.com'),
                      Text('Password: user123'),
                      SizedBox(height: 12),
                      Text(
                        '💡 Si es tu primera vez, usa el "Test de Conexión" primero. El servidor puede tardar 1-2 minutos en despertar.',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
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
