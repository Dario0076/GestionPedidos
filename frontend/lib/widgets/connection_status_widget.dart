import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connection_provider.dart';

class ConnectionStatusWidget extends ConsumerStatefulWidget {
  const ConnectionStatusWidget({super.key});

  @override
  ConsumerState<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends ConsumerState<ConnectionStatusWidget> {
  @override
  void initState() {
    super.initState();
    // Verificar conexión después de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(connectionProvider.notifier).checkConnection();
      } catch (e) {
        print('Error checking connection: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionProvider);

    return GestureDetector(
      onTap: () {
        try {
          // Verificar conexión cuando se toque
          ref.read(connectionProvider.notifier).checkConnection();
        } catch (e) {
          print('Error on tap: $e');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: _getStatusColor(connectionState.status),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(connectionState.status).withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getStatusIcon(connectionState.status),
            const SizedBox(width: 4),
            Text(
              _getStatusText(connectionState.status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.checking:
        return Colors.orange;
      case ConnectionStatus.unknown:
        return Colors.grey;
    }
  }

  Widget _getStatusIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return const Icon(Icons.wifi, color: Colors.white, size: 12);
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return const Icon(Icons.wifi_off, color: Colors.white, size: 12);
      case ConnectionStatus.checking:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case ConnectionStatus.unknown:
        return const Icon(Icons.help_outline, color: Colors.white, size: 12);
    }
  }

  String _getStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'API';
      case ConnectionStatus.disconnected:
        return 'SIN API';
      case ConnectionStatus.error:
        return 'ERROR';
      case ConnectionStatus.checking:
        return 'VERIFICANDO';
      case ConnectionStatus.unknown:
        return 'API?';
    }
  }
}
