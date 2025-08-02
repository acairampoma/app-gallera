// 📁 lib/shared/widgets/connection/connection_banner.dart
// 🌐 Banner que muestra el estado de conexión al servidor

import 'package:flutter/material.dart';
import '../../../services/connection_service.dart';

class ConnectionBanner extends StatefulWidget {
  const ConnectionBanner({super.key});

  @override
  State<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<ConnectionBanner> {
  final ConnectionService _connectionService = ConnectionService();
  ConnectionStatus _currentStatus = ConnectionStatus.checking;

  @override
  void initState() {
    super.initState();
    _listenToConnectionChanges();
    _checkInitialStatus();
  }

  void _listenToConnectionChanges() {
    _connectionService.connectionStatus.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });
      }
    });
  }

  void _checkInitialStatus() {
    setState(() {
      _currentStatus = _connectionService.currentStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStatus == ConnectionStatus.online) {
      // No mostrar banner cuando está online para ahorrar espacio
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getBackgroundColor(),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getMessage(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_currentStatus == ConnectionStatus.offline) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _retry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_currentStatus) {
      case ConnectionStatus.online:
        return Colors.green;
      case ConnectionStatus.offline:
        return Colors.orange.shade700;
      case ConnectionStatus.checking:
        return Colors.blue.shade600;
      case ConnectionStatus.syncing:
        return Colors.purple.shade600;
    }
  }

  IconData _getIcon() {
    switch (_currentStatus) {
      case ConnectionStatus.online:
        return Icons.wifi;
      case ConnectionStatus.offline:
        return Icons.wifi_off;
      case ConnectionStatus.checking:
        return Icons.wifi_find;
      case ConnectionStatus.syncing:
        return Icons.sync;
    }
  }

  String _getMessage() {
    switch (_currentStatus) {
      case ConnectionStatus.online:
        return '✅ Conectado al servidor';
      case ConnectionStatus.offline:
        return '📴 Modo sin cobertura - Datos de prueba';
      case ConnectionStatus.checking:
        return '🔄 Verificando conexión...';
      case ConnectionStatus.syncing:
        return '🔄 Sincronizando datos...';
    }
  }

  void _retry() async {
    setState(() {
      _currentStatus = ConnectionStatus.checking;
    });

    await _connectionService.checkConnection();
  }
}
