// 🔔 Servicio de Notificaciones para Admin
// Simula notificaciones push sin Firebase

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';

class AdminNotificationService {
  // 🏗️ Configuración
  static const String baseUrl = 'https://gallerappback-production.up.railway.app';
  static const String prefsKeyUltimoId = 'ultimo_pago_visto_id';
  static const String prefsKeyToken = 'access_token';
  
  // 🎯 Estado interno
  static Timer? _pollingTimer;
  static int _ultimoPagoVistoId = 0;
  static BuildContext? _currentContext;
  static bool _pausado = false; // Control de pausa para panel admin
  
  // 🔧 Singleton pattern
  static final AdminNotificationService _instance = AdminNotificationService._internal();
  factory AdminNotificationService() => _instance;
  AdminNotificationService._internal();
  
  // 📢 Callback para nuevos pagos
  Function(int count, List<Map<String, dynamic>> pagos)? onNuevosPagos;
  
  // 🔑 Headers con autenticación JWT
  static Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(prefsKeyToken);
      
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('❌ Error obteniendo headers: $e');
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }
  
  // 🧪 FUNCIÓN DE TEST DIRECTO - SOLO PARA DEBUG
  static Future<void> testEndpointDirecto() async {
    print('🧪 [TEST] === PROBANDO ENDPOINT DIRECTO ===');
    
    try {
      final headers = await _getAuthHeaders();
      print('🧪 [TEST] Headers: $headers');
      
      final url = '$baseUrl/api/v1/admin/pagos';
      print('🧪 [TEST] URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      
      print('🧪 [TEST] Status: ${response.statusCode}');
      print('🧪 [TEST] Headers respuesta: ${response.headers}');
      print('🧪 [TEST] Body completo: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🧪 [TEST] Datos parseados: $data');
        print('🧪 [TEST] Tipo de datos: ${data.runtimeType}');
        
        if (data is List) {
          print('🧪 [TEST] ✅ Es una lista con ${data.length} elementos');
          if (data.isNotEmpty) {
            print('🧪 [TEST] Primer elemento: ${data[0]}');
          }
        } else if (data is Map) {
          print('🧪 [TEST] ✅ Es un mapa con keys: ${data.keys.toList()}');
        }
      } else {
        print('🧪 [TEST] ❌ Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🧪 [TEST] ❌ Excepción: $e');
      print('🧪 [TEST] ❌ Tipo: ${e.runtimeType}');
    }
    
    print('🧪 [TEST] === FIN TEST DIRECTO ===');
  }
  
  // 📊 Obtener pagos pendientes desde API
  static Future<List<Map<String, dynamic>>> obtenerPagosPendientes() async {
    print('🔍 [AdminNotification] === INICIANDO obtenerPagosPendientes ===');
    
    try {
      print('🔑 [AdminNotification] Obteniendo headers de autenticación...');
      final headers = await _getAuthHeaders();
      print('🔑 [AdminNotification] Headers obtenidos: ${headers.keys.toList()}');
      
      // 🎯 USAR ENDPOINT CORRECTO: /admin/dashboard
      final url = '$baseUrl/api/v1/admin/dashboard';
      print('🌐 [AdminNotification] Haciendo request a: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📊 [AdminNotification] Status Code: ${response.statusCode}');
      print('📊 [AdminNotification] Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 [AdminNotification] JSON parseado exitosamente');
        
        // 🔍 EXTRAER CANTIDAD DE PAGOS PENDIENTES
        final pagosRequierenAtencion = data['pagos_requieren_atencion'] as int? ?? 0;
        print('📋 [AdminNotification] Pagos que requieren atención: $pagosRequierenAtencion');
        
        // Solo devolver lista vacía si no hay pagos reales
        if (pagosRequierenAtencion == 0) {
          print('📋 [AdminNotification] No hay pagos pendientes reales');
          return [];
        }
        
        // Si hay pagos reales pero no tenemos los detalles, crear estructura básica
        final List<Map<String, dynamic>> pagosBasicos = [];
        for (int i = 0; i < pagosRequierenAtencion; i++) {
          pagosBasicos.add({
            'id': i + 1,
            'info': 'Pago pendiente ${i + 1}',
          });
        }
        
        print('📋 [AdminNotification] Retornando ${pagosBasicos.length} pagos');
        return pagosBasicos;
      }
      
      print('⚠️ [AdminNotification] Respuesta inesperada: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ [AdminNotification] Error obteniendo pagos: $e');
      return [];
    }
  }
  
  // 🔄 Resetear último ID visto
  static Future<void> resetearUltimoIdVisto() async {
    try {
      _ultimoPagoVistoId = 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(prefsKeyUltimoId, 0);
      print('✅ Último ID visto reseteado');
    } catch (e) {
      print('❌ Error reseteando último ID: $e');
    }
  }
  
  // 🚀 Mostrar popup de notificaciones después del login admin
  static Future<void> mostrarPopupInicialAdmin(BuildContext context) async {
    print('👑 [AdminNotification] === INICIANDO mostrarPopupInicialAdmin ===');
    print('👑 [AdminNotification] Context type: ${context.runtimeType}');
    print('👑 [AdminNotification] Context mounted: ${context.mounted}');
    
    if (!_isContextValid(context)) {
      print('❌ [AdminNotification] Context inválido para popup inicial');
      return;
    }
    
    print('👑 [AdminNotification] Iniciando detección de pagos pendientes...');
    
    try {
      // 🧪 PRIMERO: TEST DIRECTO DEL ENDPOINT
      print('🧪 [AdminNotification] EJECUTANDO TEST DIRECTO...');
      await testEndpointDirecto();
      
      print('📋 [AdminNotification] Llamando obtenerPagosPendientes()...');
      // PASO 1: Obtener pagos pendientes REALES del backend
      final pagosReales = await obtenerPagosPendientes();
      print('📋 [AdminNotification] Pagos obtenidos: ${pagosReales.length}');
      
      // PASO 2: Si hay pagos pendientes, mostrar popup épico
      if (pagosReales.isNotEmpty) {
        print('🔔 [AdminNotification] ${pagosReales.length} pagos pendientes detectados');
        print('🔔 [AdminNotification] Primer pago: ${pagosReales[0]}');
        
        // Vibración para llamar la atención
        await HapticFeedback.heavyImpact();
        
        // Delay para que el usuario vea primero el HomeScreen
        print('⏰ [AdminNotification] Esperando 2 segundos antes del popup...');
        await Future.delayed(const Duration(seconds: 2));
        
        // Verificar context nuevamente después del delay
        if (_isContextValid(context)) {
          print('🎆 [AdminNotification] Mostrando popup de notificaciones...');
          await _mostrarPopupNotificaciones(context, pagosReales);
          print('✅ [AdminNotification] Popup mostrado exitosamente');
        } else {
          print('❌ [AdminNotification] Context inválido después del delay');
        }
      } else {
        print('📝 [AdminNotification] No hay pagos pendientes - No mostrar popup');
        // NO mostrar popup si no hay pagos reales
      }
      
    } catch (e) {
      print('❌ [AdminNotification] Error verificando pagos pendientes: $e');
      print('❌ [AdminNotification] Stack trace: ${e.toString()}');
      // NO mostrar popup si hay error
    }
    
    print('👑 [AdminNotification] === FIN mostrarPopupInicialAdmin ===');
  }
  
  // 🎉 Mostrar popup básico de bienvenida (fallback)
  static Future<void> _mostrarPopupBienvenidaBasico(BuildContext context) async {
    if (!_isContextValid(context)) return;
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (!_isContextValid(context)) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header rojo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53E3E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '👑 PANEL ADMIN ACTIVADO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Modo administrador habilitado',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Bienvenido Administrador',
                      style: TextStyle(
                        color: Color(0xFF2D3748),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Estarás monitoreando suscripciones y pagos automáticamente.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Botón
              Container(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53E3E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 🔔 Mostrar popup de notificaciones con pagos pendientes
  static Future<void> _mostrarPopupNotificaciones(
    BuildContext context, 
    List<Map<String, dynamic>> pagos,
  ) async {
    if (!_isContextValid(context)) return;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // No permitir cerrar sin acción
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white, // 🎨 FONDO BLANCO
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔴 HEADER ROJO
              _buildHeaderRojo(pagos),
              
              // 📋 CONTENIDO BLANCO
              _buildContenidoActivaciones(pagos),
              
              // 🎛️ BOTONES DE ACCIÓN
              _buildBotonesAccion(dialogContext),
            ],
          ),
        ),
      ),
    );
  }
  
  // 🔴 Construir header rojo épico
  static Widget _buildHeaderRojo(List<Map<String, dynamic>> pagos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), // 🔴 REDUCIDO
      decoration: const BoxDecoration(
        color: Color(0xFFE53E3E), // 🔴 ROJO PROFESIONAL
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row( // 🔄 CAMBIADO A ROW PARA SER MÁS COMPACTO
        children: [
          // Icono de alerta
          Container(
            padding: const EdgeInsets.all(8), // 🔴 REDUCIDO
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 24, // 🔴 REDUCIDO
            ),
          ),
          const SizedBox(width: 16),
          
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚨 ACTIVACIONES PENDIENTES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // 🔴 REDUCIDO
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pagos.length} ${pagos.length == 1 ? 'suscripción' : 'suscripciones'} por activar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13, // 🔴 REDUCIDO
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 📋 Construir contenido de activaciones
  static Widget _buildContenidoActivaciones(List<Map<String, dynamic>> pagos) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Mensaje principal
          const Text(
            '⚡ ¡Atención Administrador!',
            style: TextStyle(
              color: Color(0xFF2D3748),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            'Hay usuarios esperando la activación de sus suscripciones premium. Revísalas y actívalas desde el panel administrativo.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Estadística visual
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pending_actions,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pagos.length} Activaciones',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'Pendientes de revisar',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 🎛️ Construir botones de acción épicos
  static Widget _buildBotonesAccion(BuildContext dialogContext) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Botón principal - IR AL PANEL ADMIN
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                print('🎯 [AdminNotification] ¡BOTÓN PRESIONADO!');
                _irAPanelAdmin(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E), // ROJO
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'IR AL PANEL ADMINISTRATIVO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Botón secundario - Más tarde
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Revisar más tarde',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 🎯 Ir al panel administrativo
  static void _irAPanelAdmin(BuildContext dialogContext) {
    print('🎯 [AdminNotification] Navegando DIRECTO al panel admin...');
    
    try {
      Navigator.of(dialogContext).pop();
      print('🎯 [AdminNotification] Popup cerrado');
      
      // NAVEGACIÓN DIRECTA AL AdminDashboardScreen - SIN PASOS INTERMEDIOS
      Navigator.of(dialogContext).push(
        MaterialPageRoute(
          builder: (context) {
            print('🎯 [AdminNotification] Construyendo AdminDashboardScreen DIRECTO...');
            return const AdminDashboardScreen();
          },
        ),
      ).then((result) {
        print('🎯 [AdminNotification] Dashboard cargado exitosamente');
      }).catchError((error) {
        print('❌ [AdminNotification] Error cargando dashboard: $error');
        
        // Solo si falla, mostrar error simple
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text('Error cargando panel admin: $error'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _irAPanelAdmin(dialogContext),
            ),
          ),
        );
      });
      
    } catch (e) {
      print('❌ [AdminNotification] Error en navegación: $e');
    }
  }
  
  // 🔄 Iniciar polling de notificaciones
  static Future<void> iniciarPolling(BuildContext context) async {
    _currentContext = context;
    print('🔔 [AdminNotification] Polling de notificaciones iniciado');
    
    // Cargar último ID visto desde SharedPreferences
    await _cargarUltimoIdVisto();
    
    // Iniciar polling cada 15 segundos
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      // Solo verificar si NO está pausado
      if (!_pausado) {
        print('🔍 [AdminNotification] Verificando pagos (no pausado)...');
        _verificarNuevosPagos();
      } else {
        print('⏸️ [AdminNotification] Verificación saltada (pausado en panel admin)');
      }
    });
  }
  
  // 📥 Cargar último ID visto
  static Future<void> _cargarUltimoIdVisto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ultimoPagoVistoId = prefs.getInt(prefsKeyUltimoId) ?? 0;
      print('📥 Último ID visto cargado: $_ultimoPagoVistoId');
    } catch (e) {
      print('❌ Error cargando último ID: $e');
    }
  }
  
  // 🔍 Verificar nuevos pagos pendientes
  static Future<void> _verificarNuevosPagos() async {
    if (!_isContextValid(_currentContext)) {
      print('⚠️ Context inválido - deteniendo verificación');
      return;
    }
    
    try {
      final pagos = await obtenerPagosPendientes();
      
      if (pagos.isNotEmpty) {
        // Filtrar pagos nuevos (con ID mayor al último visto)
        final pagosNuevos = pagos.where((pago) {
          final pagoId = pago['id'] as int? ?? 0;
          return pagoId > _ultimoPagoVistoId;
        }).toList();
        
        if (pagosNuevos.isNotEmpty) {
          print('🔔 ${pagosNuevos.length} nuevos pagos detectados');
          
          // Actualizar último ID visto
          final maxId = pagos.map((p) => p['id'] as int? ?? 0).reduce((a, b) => a > b ? a : b);
          await _actualizarUltimoIdVisto(maxId);
          
          // Mostrar popup de notificaciones
          if (_isContextValid(_currentContext)) {
            await _mostrarPopupNotificaciones(_currentContext!, pagosNuevos);
          }
        }
      }
    } catch (e) {
      print('❌ Error verificando nuevos pagos: $e');
    }
  }
  
  // 💾 Actualizar último ID visto
  static Future<void> _actualizarUltimoIdVisto(int nuevoId) async {
    try {
      _ultimoPagoVistoId = nuevoId;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(prefsKeyUltimoId, nuevoId);
      print('💾 Último ID actualizado: $nuevoId');
    } catch (e) {
      print('❌ Error actualizando último ID: $e');
    }
  }
  
  // ⏸️ Pausar notificaciones (cuando entra al panel admin)
  static void pausarEnPanelAdmin() {
    _pausado = true;
    print('⏸️ [AdminNotification] Notificaciones PAUSADAS (en panel admin)');
  }
  
  // ▶️ Reanudar notificaciones (cuando sale del panel admin)
  static void reanudarEnHome() {
    _pausado = false;
    print('▶️ [AdminNotification] Notificaciones REANUDADAS (en home)');
  }
  
  // 🛑 Detener polling de notificaciones
  static void detenerPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentContext = null;
    _pausado = false;
    print('🔔 [AdminNotification] Polling detenido');
  }
  
  // 🔍 Validar si el context está montado y es válido
  static bool _isContextValid(BuildContext? context) {
    return context != null && context.mounted;
  }
  
  // 🧹 Limpiar recursos y estado
  static void dispose() {
    detenerPolling();
    _ultimoPagoVistoId = 0;
    print('🧹 AdminNotificationService disposed');
  }
}