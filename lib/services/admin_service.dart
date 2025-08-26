// 👑 Servicio de Administración - SOLO ADMIN
// Compatible con: https://gallerappback-production.up.railway.app

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pago_models.dart';

class AdminService {
  static const String baseUrl = 'https://gallerappback-production.up.railway.app';
  
  // 🔑 Headers con JWT token y UTF-8 (IGUAL QUE SUSCRIPCIONES)
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json; charset=utf-8',
      'Accept-Charset': 'utf-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ========================================
  // PAGOS PENDIENTES
  // ========================================

  /// 📋 Obtener pagos pendientes de verificación
  static Future<List<PagoPendiente>> obtenerPagosPendientes({
    String estado = 'verificando',
    int limit = 50,
  }) async {
    try {
      print('👑 [AdminService] Obteniendo pagos pendientes...');
      
      final headers = await _getAuthHeaders();
      // Construye una lista de intents (rutas alternativas) basado en el error del log
      final intents = <Uri>[
        // Ruta que funciona según los logs
        Uri.parse('$baseUrl/api/v1/admin/pagos')
            .replace(queryParameters: {'estado': estado.toUpperCase(), 'limit': '$limit'}),
        // Variante con minúscula
        Uri.parse('$baseUrl/api/v1/admin/pagos')
            .replace(queryParameters: {'estado': estado.toLowerCase(), 'limit': '$limit'}),
        // Sin filtro de estado, obtener todos
        Uri.parse('$baseUrl/api/v1/admin/pagos')
            .replace(queryParameters: {'limit': '$limit'}),
        // Ruta original que estaba en los logs como exitosa
        Uri.parse('$baseUrl/api/v1/admin/pagos-pendientes'),
        // Sin query parameters para admin pagos
        Uri.parse('$baseUrl/api/v1/admin/pagos'),
      ];

      AdminException? lastError;
      for (final uri in intents) {
        print('🌐 [AdminService] GET: $uri');
        final response = await http.get(uri, headers: headers);
        print('📡 Status Code: ${response.statusCode} para $uri');

        if (response.statusCode == 200) {
          final body = response.body;
          print('📄 [AdminService] Respuesta: ${body.length > 200 ? body.substring(0, 200) + "..." : body}');
          
          try {
            final decoded = jsonDecode(body);
            List<dynamic> jsonList = [];
            
            // Intentar diferentes estructuras que puede devolver el backend
            if (decoded is List) {
              jsonList = decoded;
            } else if (decoded is Map<String, dynamic>) {
              // Buscar en diferentes campos comunes
              jsonList = (decoded['data'] ?? 
                         decoded['items'] ?? 
                         decoded['pagos'] ?? 
                         decoded['results'] ?? 
                         []) as List;
            }
            
            print('📊 [AdminService] Procesando ${jsonList.length} elementos');
            
            // Filtrar por estado si es necesario (backend no lo hizo)
            final pagosFiltrados = <PagoPendiente>[];
            for (final json in jsonList) {
              try {
                final pago = PagoPendiente.fromJson(json);
                // Filtrar por estado si es necesario
                if (estado.isEmpty || 
                    pago.estado.toLowerCase() == estado.toLowerCase() ||
                    pago.estado.toLowerCase() == 'verificando') {
                  pagosFiltrados.add(pago);
                }
              } catch (e) {
                print('⚠️ Error procesando pago individual: $e');
                continue;
              }
            }
            
            print('✅ ${pagosFiltrados.length} pagos pendientes obtenidos de $uri');
            return pagosFiltrados;
          } catch (e) {
            print('❌ Error parseando JSON: $e');
            throw AdminException('Error parseando respuesta de $uri: $e', 200);
          }
        } else if (response.statusCode == 403) {
          throw AdminException('Acceso denegado. Solo administradores pueden acceder.', 403);
        } else if (response.statusCode == 404) {
          lastError = AdminException('No encontrado en $uri: ${response.body}', 404);
          continue; // prueba siguiente intento
        } else {
          throw AdminException('Error ${response.statusCode} en $uri: ${response.body}', response.statusCode);
        }
      }

      // Si agotamos los intents con 404
      if (lastError != null) throw lastError;
      throw AdminException('No se pudo obtener pagos pendientes (sin coincidencias de endpoint)');
    } catch (e) {
      print('❌ Error obteniendo pagos pendientes: $e');
      rethrow;
    }
  }

  /// 📊 Obtener estadísticas del admin
  static Future<Map<String, dynamic>> obtenerEstadisticasAdmin() async {
    try {
      print('👑 [AdminService] Obteniendo estadísticas admin...');
      
      final headers = await _getAuthHeaders();
      final intents = <Uri>[
        Uri.parse('$baseUrl/api/v1/admin/estadisticas'),
        Uri.parse('$baseUrl/api/v1/admin/dashboard'),
        Uri.parse('$baseUrl/api/v1/admin/stats'),
      ];

      AdminException? lastError;
      for (final uri in intents) {
        print('🌐 [AdminService] GET: $uri');
        final response = await http.get(uri, headers: headers);
        print('📡 Status Code: ${response.statusCode} para $uri');

        if (response.statusCode == 200) {
          try {
            final jsonData = jsonDecode(response.body);
            print('✅ Estadísticas obtenidas de $uri');
            
            // Asegurar que tenga los campos necesarios
            Map<String, dynamic> stats = jsonData as Map<String, dynamic>;
            stats.putIfAbsent('pagos_pendientes', () => 0);
            stats.putIfAbsent('aprobados_hoy', () => 0);
            stats.putIfAbsent('ingresos_mes', () => 0.0);
            
            return stats;
          } catch (e) {
            print('⚠️ Error parseando stats, usando por defecto: $e');
            return {
              'pagos_pendientes': 0,
              'aprobados_hoy': 0,
              'ingresos_mes': 0.0,
            };
          }
        } else if (response.statusCode == 403) {
          throw AdminException('Acceso denegado. Solo administradores pueden acceder.', 403);
        } else if (response.statusCode == 404) {
          lastError = AdminException('No encontrado en $uri: ${response.body}', 404);
          continue;
        } else {
          throw AdminException('Error ${response.statusCode} en $uri: ${response.body}', response.statusCode);
        }
      }

      if (lastError != null) throw lastError;
      throw AdminException('No se pudieron obtener estadísticas (sin coincidencias de endpoint)');
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      rethrow;
    }
  }

  // ========================================
  // ACCIONES DE APROBACIÓN
  // ========================================

  /// ✅ Aprobar pago pendiente
  static Future<Map<String, dynamic>> aprobarPago(int pagoId) async {
    try {
      print('✅ [AdminService] Aprobando pago ID: $pagoId');
      
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'accion': 'aprobar',
        'notas': 'Pago aprobado desde panel admin Flutter',
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/admin/pagos/$pagoId/aprobar'),
        headers: headers,
        body: body,
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 explícito (IGUAL QUE SUSCRIPCIONES)
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(responseBody);
        
        print('✅ Pago aprobado exitosamente');
        print('📝 Respuesta: ${jsonData}');
        
        return jsonData;
      } else if (response.statusCode == 403) {
        throw AdminException('Acceso denegado. Solo administradores pueden aprobar pagos.', 403);
      } else if (response.statusCode == 404) {
        throw AdminException('Pago no encontrado o ya procesado', 404);
      } else {
        throw AdminException('Error ${response.statusCode}: ${response.body}', response.statusCode);
      }
    } catch (e) {
      print('❌ Error aprobando pago: $e');
      rethrow;
    }
  }

  /// ❌ Rechazar pago pendiente
  static Future<Map<String, dynamic>> rechazarPago(int pagoId, String motivo) async {
    try {
      print('❌ [AdminService] Rechazando pago ID: $pagoId');
      print('💬 Motivo: $motivo');
      
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'accion': 'rechazar',
        'notas': motivo,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/admin/pagos/$pagoId/rechazar'),
        headers: headers,
        body: body,
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        print('❌ Pago rechazado exitosamente');
        print('📝 Respuesta: ${jsonData}');
        
        return jsonData;
      } else if (response.statusCode == 403) {
        throw AdminException('Acceso denegado. Solo administradores pueden rechazar pagos.', 403);
      } else if (response.statusCode == 404) {
        throw AdminException('Pago no encontrado o ya procesado', 404);
      } else {
        throw AdminException('Error ${response.statusCode}: ${response.body}', response.statusCode);
      }
    } catch (e) {
      print('❌ Error rechazando pago: $e');
      rethrow;
    }
  }

  // ========================================
  // NOTIFICACIONES ADMIN
  // ========================================

  /// 🔔 Obtener notificaciones del admin
  static Future<List<Map<String, dynamic>>> obtenerNotificacionesAdmin({int limit = 20}) async {
    try {
      print('🔔 [AdminService] Obteniendo notificaciones admin...');
      
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('$baseUrl/api/v1/admin/notificaciones')
          .replace(queryParameters: {'limit': limit.toString()});

      final response = await http.get(uri, headers: headers);

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        
        print('✅ ${jsonList.length} notificaciones obtenidas');
        return jsonList.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 403) {
        throw AdminException('Acceso denegado. Solo administradores pueden ver notificaciones.', 403);
      } else {
        throw AdminException('Error ${response.statusCode}: ${response.body}', response.statusCode);
      }
    } catch (e) {
      print('❌ Error obteniendo notificaciones: $e');
      rethrow;
    }
  }

  /// ✅ Marcar notificación como leída
  static Future<void> marcarNotificacionLeida(int notificacionId) async {
    try {
      print('✅ [AdminService] Marcando notificación $notificacionId como leída');
      
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/api/v1/admin/notificaciones/$notificacionId/leida'),
        headers: headers,
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Notificación marcada como leída');
      } else if (response.statusCode == 403) {
        throw AdminException('Acceso denegado', 403);
      } else {
        throw AdminException('Error ${response.statusCode}: ${response.body}', response.statusCode);
      }
    } catch (e) {
      print('❌ Error marcando notificación: $e');
      rethrow;
    }
  }

  // ========================================
  // REPORTES ADMIN
  // ========================================

  /// 📊 Obtener reporte de suscripciones
  static Future<Map<String, dynamic>> obtenerReporteSuscripciones({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      print('📊 [AdminService] Obteniendo reporte de suscripciones...');
      
      final headers = await _getAuthHeaders();
      final queryParams = <String, String>{};
      
      if (fechaInicio != null) {
        queryParams['fecha_inicio'] = fechaInicio.toIso8601String();
      }
      if (fechaFin != null) {
        queryParams['fecha_fin'] = fechaFin.toIso8601String();
      }
      
      final uri = Uri.parse('$baseUrl/api/v1/admin/reporte-suscripciones')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        print('✅ Reporte de suscripciones obtenido');
        return jsonData;
      } else if (response.statusCode == 403) {
        throw AdminException('Acceso denegado', 403);
      } else {
        throw AdminException('Error ${response.statusCode}: ${response.body}', response.statusCode);
      }
    } catch (e) {
      print('❌ Error obteniendo reporte: $e');
      rethrow;
    }
  }

  // ========================================
  // UTILIDADES
  // ========================================

  /// 🔐 Verificar si el usuario actual es admin
  static Future<bool> esUsuarioAdmin() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/admin/verificar-acceso'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Error verificando admin: $e');
      return false;
    }
  }

  /// 📱 Obtener información del usuario actual
  static Future<Map<String, dynamic>?> obtenerInfoUsuarioActual() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/usuarios/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('⚠️ Error obteniendo info usuario: $e');
      return null;
    }
  }
}

// ========================================
// EXCEPCIONES PERSONALIZADAS
// ========================================

class AdminException implements Exception {
  final String message;
  final int? statusCode;

  AdminException(this.message, [this.statusCode]);

  @override
  String toString() => 'AdminException: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}';

  /// Es un error de acceso denegado
  bool get esAccesoDenegado => statusCode == 403;

  /// Es un error de no encontrado
  bool get esNoEncontrado => statusCode == 404;

  /// Es un error de servidor
  bool get esErrorServidor => statusCode != null && statusCode! >= 500;
}