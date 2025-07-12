import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../utils/constants.dart';

class ConnectionTestScreen extends ConsumerStatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  ConsumerState<ConnectionTestScreen> createState() =>
      _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends ConsumerState<ConnectionTestScreen> {
  final List<String> _testResults = [];
  bool _isLoading = false;

  Future<void> _runConnectionTests() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    // URLs a probar - usando la configuración actual
    final urlsToTest = [
      '${ApiConstants.baseUrl}/health',
      '${ApiConstants.baseUrl}/categories',
      '${ApiConstants.baseUrl}/products',
      'https://httpbin.org/get', // Test de conectividad general
    ];

    for (String url in urlsToTest) {
      try {
        _addResult('🟡 Probando: $url');

        final stopwatch = Stopwatch()..start();
        final response = await dio.get(url);
        stopwatch.stop();

        if (response.statusCode == 200) {
          _addResult('✅ OK ($url) - ${stopwatch.elapsedMilliseconds}ms');
          _addResult(
            '   Respuesta: ${response.data.toString().substring(0, response.data.toString().length > 100 ? 100 : response.data.toString().length)}...',
          );
        } else {
          _addResult('❌ Error ($url): Status ${response.statusCode}');
        }
      } catch (e) {
        _addResult('❌ Error ($url): ${e.toString()}');
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Test adicional: información del dispositivo
    _addResult('\n📱 Información del dispositivo:');
    _addResult('   API Base URL: ${ApiConstants.baseUrl}');

    setState(() {
      _isLoading = false;
    });
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Conexión'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración Actual:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('API URL: ${ApiConstants.baseUrl}'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _runConnectionTests,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.network_check),
                        label: Text(
                          _isLoading ? 'Probando...' : 'Ejecutar Pruebas',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Resultados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: _testResults.isEmpty
                    ? const Center(
                        child: Text(
                          'Pulsa "Ejecutar Pruebas" para comenzar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _testResults.length,
                        itemBuilder: (context, index) {
                          final result = _testResults[index];
                          Color? textColor;
                          if (result.startsWith('✅')) textColor = Colors.green;
                          if (result.startsWith('❌')) textColor = Colors.red;
                          if (result.startsWith('🟡')) {
                            textColor = Colors.orange;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              result,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: textColor,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
