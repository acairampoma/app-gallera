// 📁 lib/services/connection_service.dart
// 🌐 Servicio para monitorear el estado de conexión y gestionar modo online/offline

import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart'; // Comentado temporalmente
import 'package:http/http.dart' as http;

enum ConnectionStatus {
  checking,    // ⏳ Verificando conexión
  online,      // ✅ Conectado al backend
  offline,     // 📴 Sin conexión - Modo mock
  syncing      // 🔄 Sincronizando datos pendientes
}

class ConnectionService {
  // 🎯 Singleton pattern
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  // 🌐 URL del backend Railway
  static const String _backendUrl = 'https://gallerappback-production.up.railway.app';
  
  // 🔄 Stream para notificar cambios de estado
  final _connectionStatusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get connectionStatus => _connectionStatusController.stream;
  
  // 📊 Estado actual
  ConnectionStatus _currentStatus = ConnectionStatus.checking;
  ConnectionStatus get currentStatus => _currentStatus;
  
  // ⏱️ Timer para chequeo periódico
  Timer? _connectivityTimer;
  // final Connectivity _connectivity = Connectivity(); // Comentado temporalmente
  // StreamSubscription<ConnectivityResult>? _connectivitySubscription; // Comentado temporalmente

  // 🚀 Inicializar servicio
  Future<void> initialize() async {
    print('🌐 Inicializando ConnectionService...');
    
    // Escuchar cambios de conectividad del dispositivo - Comentado temporalmente
    // _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) {
    //   checkConnection();
    // });
    
    // Chequeo inicial
    await checkConnection();
    
    // Chequeo periódico cada 30 segundos
    _connectivityTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_currentStatus == ConnectionStatus.offline) {
        checkConnection();
      }
    });
  }

  // 🔍 Verificar conexión con el backend
  Future<void> checkConnection() async {
    _updateStatus(ConnectionStatus.checking);
    
    try {
      // Primero verificar conectividad del dispositivo
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        print('📴 Sin conexión a internet');
        _updateStatus(ConnectionStatus.offline);
        return;
      }
      
      // Intentar conectar con el backend
      print('🔍 Verificando conexión con backend...');
      final response = await http.get(
        Uri.parse('$_backendUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        print('✅ Conectado al backend');
        _updateStatus(ConnectionStatus.online);
        
        // Si venimos de offline, iniciar sincronización
        if (_currentStatus == ConnectionStatus.offline) {
          _iniciarSincronizacion();
        }
      } else {
        print('⚠️ Backend no responde correctamente');
        _updateStatus(ConnectionStatus.offline);
      }
    } catch (e) {
      print('❌ Error al conectar con backend: $e');
      _updateStatus(ConnectionStatus.offline);
    }
  }

  // 🔄 Actualizar estado y notificar
  void _updateStatus(ConnectionStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _connectionStatusController.add(newStatus);
      print('📊 Estado de conexión: ${_getStatusMessage(newStatus)}');
    }
  }

  // 📝 Mensaje descriptivo del estado
  String _getStatusMessage(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.checking:
        return '⏳ Verificando conexión...';
      case ConnectionStatus.online:
        return '✅ Conectado al servidor';
      case ConnectionStatus.offline:
        return '📴 Modo sin cobertura - Datos de prueba';
      case ConnectionStatus.syncing:
        return '🔄 Sincronizando datos...';
    }
  }

  // 🔄 Iniciar sincronización de datos pendientes
  Future<void> _iniciarSincronizacion() async {
    _updateStatus(ConnectionStatus.syncing);
    
    try {
      // Aquí llamaremos a OfflineQueueService.syncPendingData()
      print('🔄 Iniciando sincronización de datos pendientes...');
      
      // Simular sync (será implementado con OfflineQueueService)
      await Future.delayed(const Duration(seconds: 2));
      
      print('✅ Sincronización completada');
      _updateStatus(ConnectionStatus.online);
    } catch (e) {
      print('❌ Error en sincronización: $e');
      _updateStatus(ConnectionStatus.online); // Aunque falle el sync, estamos online
    }
  }

  // 🛑 Limpiar recursos
  void dispose() {
    _connectivityTimer?.cancel();
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }

  // 🎯 Métodos de utilidad
  bool get isOnline => _currentStatus == ConnectionStatus.online;
  bool get isOffline => _currentStatus == ConnectionStatus.offline;
  bool get isSyncing => _currentStatus == ConnectionStatus.syncing;
  
  // 📊 Obtener información de estado para UI
  ConnectionInfo getConnectionInfo() {
    return ConnectionInfo(
      status: _currentStatus,
      message: _getStatusMessage(_currentStatus),
      color: _getStatusColor(_currentStatus),
      icon: _getStatusIcon(_currentStatus),
    );
  }
  
  // 🎨 Color según estado
  int _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.checking:
        return 0xFF2196F3; // Azul
      case ConnectionStatus.online:
        return 0xFF4CAF50; // Verde
      case ConnectionStatus.offline:
        return 0xFFFF9800; // Naranja
      case ConnectionStatus.syncing:
        return 0xFF9C27B0; // Púrpura
    }
  }
  
  // 🎯 Icono según estado
  String _getStatusIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.checking:
        return '⏳';
      case ConnectionStatus.online:
        return '🌐';
      case ConnectionStatus.offline:
        return '📴';
      case ConnectionStatus.syncing:
        return '🔄';
    }
  }
}

// 📊 Clase para información de conexión
class ConnectionInfo {
  final ConnectionStatus status;
  final String message;
  final int color;
  final String icon;
  
  ConnectionInfo({
    required this.status,
    required this.message,
    required this.color,
    required this.icon,
  });
}