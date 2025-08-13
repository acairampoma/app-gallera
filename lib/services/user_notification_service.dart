// 🎉 Servicio de Notificaciones ÉPICO para Usuarios
// Sistema bidireccional: Admin aprueba → Usuario recibe notificación automática

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserNotificationService {
  static const String baseUrl = 'https://gallerappback-production.up.railway.app';
  static Timer? _pollingTimer;
  static String? _ultimoEstadoPago;
  static BuildContext? _currentContext;
  
  // Singleton
  static final UserNotificationService _instance = UserNotificationService._internal();
  factory UserNotificationService() => _instance;
  UserNotificationService._internal();
  
  // 🔑 Headers con JWT token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // 📊 Verificar estado de suscripción del usuario
  static Future<Map<String, dynamic>?> verificarEstadoSuscripcion() async {
    try {
      final headers = await _getAuthHeaders();
      
      // Intentar múltiples endpoints
      final endpoints = [
        '/api/v1/suscripciones/actual',
        '/api/v1/suscripciones/mi-suscripcion', 
        '/api/v1/pagos/mis-pagos',
      ];
      
      for (final endpoint in endpoints) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
          );
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            
            // Si es el endpoint de pagos, buscar el más reciente
            if (endpoint.contains('pagos')) {
              if (data is List && data.isNotEmpty) {
                return data.first; // Pago más reciente
              }
            } else {
              return data;
            }
          }
        } catch (e) {
          print('⚠️ Error en endpoint $endpoint: $e');
          continue;
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error verificando suscripción: $e');
      return null;
    }
  }
  
  // 🔄 Iniciar polling INTELIGENTE para usuario normal
  static Future<void> iniciarPollingUsuario(BuildContext context) async {
    print('🎉 [UserNotification] Iniciando polling inteligente para usuario...');
    print('🎉 [UserNotification] URL base: $baseUrl');
    
    _currentContext = context;
    
    // Cargar último estado conocido
    final prefs = await SharedPreferences.getInstance();
    _ultimoEstadoPago = prefs.getString('ultimo_estado_pago');
    print('🎉 [UserNotification] Último estado conocido: $_ultimoEstadoPago');
    
    // Verificar inmediatamente al iniciar
    await _verificarCambiosSuscripcion(context, esVerificacionInicial: true);
    
    // Polling cada 30 segundos (optimizado para usuarios)
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_currentContext != null && _currentContext!.mounted) {
        await _verificarCambiosSuscripcion(_currentContext!);
      }
    });
    
    print('✅ [UserNotification] Polling iniciado correctamente');
  }
  
  // 🔍 Verificar si hay cambios en la suscripción
  static Future<void> _verificarCambiosSuscripcion(BuildContext context, {bool esVerificacionInicial = false}) async {
    try {
      final suscripcion = await verificarEstadoSuscripcion();
      
      if (suscripcion == null) {
        print('⚠️ [UserNotification] No se pudo obtener datos de suscripción');
        return;
      }
      
      // Buscar estado en diferentes campos posibles
      final estadoActual = suscripcion['estado'] ?? 
                          suscripcion['estado_pago'] ?? 
                          suscripcion['status'] ??
                          'pendiente';
      
      print('📊 [UserNotification] Estado actual: $estadoActual (anterior: $_ultimoEstadoPago)');
      print('📊 [UserNotification] Datos recibidos: ${suscripcion.keys.toList()}');
      
      // Detectar cambio a APROBADO
      if (_ultimoEstadoPago != null && 
          _ultimoEstadoPago != estadoActual && 
          (estadoActual.toString().toLowerCase() == 'aprobado' || 
           estadoActual.toString().toLowerCase() == 'activo')) {
        
        print('🎉 [UserNotification] ¡PAGO APROBADO! Mostrando popup épico');
        
        // Vibración fuerte y popup épico
        HapticFeedback.heavyImpact();
        await _mostrarPopupPagoAprobado(context, suscripcion);
      }
      
      // Actualizar último estado conocido
      if (estadoActual.toString() != _ultimoEstadoPago) {
        _ultimoEstadoPago = estadoActual.toString();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('ultimo_estado_pago', estadoActual.toString());
        print('💾 [UserNotification] Estado actualizado: $_ultimoEstadoPago');
      }
      
    } catch (e) {
      print('❌ [UserNotification] Error verificando cambios: $e');
    }
  }
  
  // 🎉 Mostrar popup ÉPICO de pago aprobado
  static Future<void> _mostrarPopupPagoAprobado(BuildContext context, Map<String, dynamic> suscripcion) async {
    if (!context.mounted) return;
    
    // Vibración épica
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
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
              // 🔴 Header ROJO épico
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53E3E), // 🔴 ROJO PROFESIONAL
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Icono animado en BLANCO sobre rojo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Título épico en BLANCO
                    const Text(
                      '🎉 ¡SUSCRIPCIÓN CONFIRMADA!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtítulo en BLANCO
                    const Text(
                      'Tu pago ha sido aprobado exitosamente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // 📊 Detalles de la suscripción
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDetailRowPopup('📋 Plan Activado', suscripcion['plan_nombre'] ?? suscripcion['plan_codigo'] ?? 'Plan Premium'),
                    _buildDetailRowPopup('💰 Monto Pagado', 'S/. ${suscripcion['monto'] ?? '15.00'}'),
                    _buildDetailRowPopup('⚡ Estado', 'Activo y funcionando'),
                    _buildDetailRowPopup('🚀 Beneficios', 'Límites aumentados'),
                  ],
                ),
              ),
              
              // ✨ Mensaje motivacional
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC), // Gris muy claro
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🎯 ¡Ya puedes aprovechar todas las funcionalidades!',
                      style: TextStyle(
                        color: Color(0xFF2D3748), // Texto oscuro
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Más gallos registrados\\n• Entrenamientos ilimitados\\n• Funciones premium activadas',
                      style: TextStyle(
                        color: Color(0xFF4A5568), // Texto gris
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // 🔥 Botón de acción épico
              Container(
                margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    
                    // 🔄 REFRESH AUTOMÁTICO DE LA APP
                    await _refreshearEstadoApp(context);
                    
                    // Mostrar confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Tu suscripción está ahora activa - ¡Disfrútala!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E), // Botón rojo
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Entendido - ¡Empezar a usar!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 📋 Widget para detalles en el popup
  static Widget _buildDetailRowPopup(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  // 🔄 REFRESH AUTOMÁTICO del estado de la app
  static Future<void> _refreshearEstadoApp(BuildContext context) async {
    try {
      print('🔄 [UserNotification] Refrescando estado de la app...');
      
      // Hacer una llamada para refrescar los límites y suscripciones
      final headers = await _getAuthHeaders();
      
      // Llamadas paralelas para actualizar todo
      final futures = [
        http.get(Uri.parse('$baseUrl/api/v1/suscripciones/actual'), headers: headers),
        http.get(Uri.parse('$baseUrl/api/v1/suscripciones/limites'), headers: headers),
      ];
      
      await Future.wait(futures);
      print('✅ [UserNotification] Estado de la app refrescado');
      
      // Opcional: Forzar rebuild de widgets que muestran límites
      // Esto se puede hacer enviando un evento global o usando Provider/Bloc
      
    } catch (e) {
      print('⚠️ [UserNotification] Error refrescando estado: $e');
    }
  }
  
  // 🛑 Detener polling
  static void detenerPolling() {
    print('🎉 [UserNotification] Deteniendo polling...');
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentContext = null;
  }
  
  // 🔄 Resetear último estado para testing
  static Future<void> resetearUltimoEstado() async {
    print('🔄 [UserNotification] Reseteando último estado...');
    _ultimoEstadoPago = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('ultimo_estado_pago');
  }
  
  // 📊 Obtener estado actual para debug
  static Future<Map<String, dynamic>> getEstadoDebug() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'ultimo_estado_pago': _ultimoEstadoPago,
      'ultimo_estado_stored': prefs.getString('ultimo_estado_pago'),
      'polling_activo': _pollingTimer != null && _pollingTimer!.isActive,
      'base_url': baseUrl,
    };
  }
}
