import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/constants.dart';

class DebugLoginScreen extends StatefulWidget {
  const DebugLoginScreen({super.key});

  @override
  State<DebugLoginScreen> createState() => _DebugLoginScreenState();
}

class _DebugLoginScreenState extends State<DebugLoginScreen> {
  final _emailController = TextEditingController(text: 'admin@admin.com');
  final _passwordController = TextEditingController(text: 'admin123');
  final List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print(message); // También imprime en consola
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    _addLog('🔍 Iniciando test de login...');
    _addLog('📧 Email: ${_emailController.text}');
    _addLog('🔗 URL Base: ${ApiConstants.baseUrl}');

    try {
      // Crear instancia de Dio simple
      final dio = Dio();
      dio.options.baseUrl = ApiConstants.baseUrl;
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      _addLog('🌐 Haciendo petición POST a /auth/login');

      final response = await dio.post(
        '/auth/login',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      _addLog('✅ Respuesta recibida: ${response.statusCode}');
      _addLog('📦 Tipo de datos: ${response.data.runtimeType}');
      _addLog('📄 Contenido: ${response.data.toString()}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _addLog('🎉 LOGIN EXITOSO!');

        // Mostrar diálogo de éxito
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('¡Login Exitoso!'),
              content: Text('Respuesta del servidor:\n${response.data}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        _addLog('❌ Error: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      _addLog('❌ DioException: ${e.type}');
      _addLog('❌ Mensaje: ${e.message}');
      if (e.response != null) {
        _addLog('❌ Status: ${e.response!.statusCode}');
        _addLog('❌ Data: ${e.response!.data}');
      }
    } catch (e) {
      _addLog('❌ Error general: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    _addLog('🔍 Probando conectividad...');
    _addLog('🔗 URL: ${ApiConstants.baseUrl}/health');

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get('${ApiConstants.baseUrl}/health');

      _addLog('✅ Conectividad OK: ${response.statusCode}');
      _addLog('📄 Respuesta: ${response.data}');
    } catch (e) {
      _addLog('❌ Error de conectividad: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campos de entrada
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Botones
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testConnection,
                    child: const Text('Test Conexión'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Test Login'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              'Logs de Debug:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Logs
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          'Presiona un botón para ver los logs...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          Color color = Colors.black;
                          if (log.contains('❌')) color = Colors.red;
                          if (log.contains('✅')) color = Colors.green;
                          if (log.contains('🔍')) color = Colors.blue;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Text(
                              log,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
