import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

enum ConnectionStatus { unknown, checking, connected, disconnected, error }

class ConnectionState {
  final ConnectionStatus status;
  final String? message;
  final DateTime? lastCheck;

  const ConnectionState({required this.status, this.message, this.lastCheck});

  ConnectionState copyWith({
    ConnectionStatus? status,
    String? message,
    DateTime? lastCheck,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      message: message ?? this.message,
      lastCheck: lastCheck ?? this.lastCheck,
    );
  }
}

class ConnectionNotifier extends StateNotifier<ConnectionState> {
  ConnectionNotifier()
    : super(const ConnectionState(status: ConnectionStatus.unknown));

  Future<void> checkConnection() async {
    try {
      state = state.copyWith(
        status: ConnectionStatus.checking,
        lastCheck: DateTime.now(),
      );

      // Crear una instancia temporal de Dio para la prueba
      final dio = Dio();
      dio.options.connectTimeout = const Duration(
        seconds: 30,
      ); // Increased for Render cold start
      dio.options.receiveTimeout = const Duration(
        seconds: 30,
      ); // Increased for Render cold start

      // Lista de URLs a probar en orden de prioridad
      final urlsToTry = [
        'https://n6sj7k57-3000.brs.devtunnels.ms/api/health', // Túnel de desarrollo (principal)
        'http://192.168.1.4:3000/api/health', // IP real del host (backup local)
        'http://172.23.208.1:3000/api/health', // WSL (Hyper-V) (backup local)
        'http://10.0.2.2:3000/api/health', // Emulador Android estándar
        'http://127.0.0.1:3000/api/health', // Localhost
        'http://localhost:3000/api/health', // Localhost alternativo
      ];

      Response? response;
      String? successUrl;

      for (String url in urlsToTry) {
        try {
          print('Trying connection to: $url');
          response = await dio.get(url);
          if (response.statusCode == 200) {
            successUrl = url;
            print('Success with: $url');
            break;
          }
        } catch (e) {
          print('Failed with $url: $e');
          continue;
        }
      }

      if (response != null &&
          response.statusCode == 200 &&
          successUrl != null) {
        state = state.copyWith(
          status: ConnectionStatus.connected,
          message: 'Backend conectado en $successUrl',
          lastCheck: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          status: ConnectionStatus.error,
          message: 'No se pudo conectar a ninguna URL',
          lastCheck: DateTime.now(),
        );
      }
    } catch (e) {
      print('Connection error: $e');
      state = state.copyWith(
        status: ConnectionStatus.disconnected,
        message: 'Error: ${e.toString()}',
        lastCheck: DateTime.now(),
      );
    }
  }

  void reset() {
    state = const ConnectionState(status: ConnectionStatus.unknown);
  }
}

final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
      return ConnectionNotifier();
    });
