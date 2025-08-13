// 📋 Servicio de Suscripciones - Integración Completa con Railway API
// Compatible con: https://gallerappback-production.up.railway.app

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../models/suscripcion_models.dart';
import '../models/pago_models.dart';

class SuscripcionService {
  // 🌐 Usar la misma base URL que ApiService existente
  static const String baseUrl = 'https://gallerappback-production.up.railway.app';
  
  // 🔑 Headers con JWT token y UTF-8
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
  // SUSCRIPCIONES - INFORMACIÓN
  // ========================================

  /// 📋 Obtener suscripción actual del usuario
  static Future<Suscripcion> obtenerSuscripcionActual() async {
    try {
      print('🔍 [SuscripcionService] Obteniendo suscripción actual...');
      
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/suscripciones/actual'),
        headers: headers,
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 explícito
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(responseBody);
        final suscripcion = Suscripcion.fromJson(jsonData);
        
        // Guardar en cache local para offline
        await _guardarSuscripcionCache(suscripcion);
        
        print('✅ Suscripción obtenida: ${suscripcion.planName}');
        return suscripcion;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo suscripción: $e');
      
      // Intentar cargar desde cache si hay error de red
      final suscripcionCache = await _cargarSuscripcionCache();
      if (suscripcionCache != null) {
        print('📱 Usando suscripción desde cache');
        return suscripcionCache;
      }
      
      rethrow;
    }
  }

  /// 📊 Obtener límites y uso actual
  static Future<EstadoLimites> obtenerLimitesActuales() async {
    try {
      print('🔍 [SuscripcionService] Obteniendo límites actuales...');
      
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/suscripciones/limites'),
        headers: headers,
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 explícito
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(responseBody);
        final limites = EstadoLimites.fromJson(jsonData);
        
        print('✅ Límites obtenidos: ${limites.gallos.usado}/${limites.gallos.limite} gallos');
        return limites;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo límites: $e');
      rethrow;
    }
  }

  /// 🔍 Validar si puede crear un recurso específico
  static Future<ValidacionLimite> validarLimite({
    required String recursoTipo,
    int? galloId,
  }) async {
    try {
      print('🔍 [SuscripcionService] Validando límite para $recursoTipo${galloId != null ? ' (gallo $galloId)' : ''}');
      
      final headers = await _getAuthHeaders();
      final body = ValidacionLimiteRequest(
        recursoTipo: recursoTipo,
        galloId: galloId,
      ).toJson();

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/suscripciones/validar-limite'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 explícito
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(responseBody);
        final validacion = ValidacionLimite.fromJson(jsonData);
        
        print('${validacion.puedeCrear ? '✅' : '❌'} Validación: ${validacion.puedeCrear ? 'Puede crear' : validacion.mensajeError}');
        return validacion;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error validando límite: $e');
      rethrow;
    }
  }

  // ========================================
  // PLANES - CATÁLOGO
  // ========================================

  /// 📋 Obtener todos los planes disponibles
  static Future<List<PlanCatalogo>> obtenerPlanesDisponibles({
    bool incluirGratuito = false,
  }) async {
    try {
      print('🔍 [SuscripcionService] Obteniendo planes disponibles...');
      
      final uri = Uri.parse('$baseUrl/api/v1/suscripciones/planes')
          .replace(queryParameters: {
        if (incluirGratuito) 'incluir_gratuito': 'true',
      });

      final response = await http.get(uri);

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 explícito
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonList = jsonDecode(responseBody) as List;
        final planes = jsonList.map((json) => PlanCatalogo.fromJson(json)).toList();
        
        print('✅ ${planes.length} planes obtenidos');
        return planes;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo planes: $e');
      rethrow;
    }
  }

  /// 📋 Obtener detalles de un plan específico
  static Future<PlanCatalogo> obtenerPlanDetalle(String planCodigo) async {
    try {
      print('🔍 [SuscripcionService] Obteniendo plan $planCodigo...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/suscripciones/planes/$planCodigo'),
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 explícito
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(responseBody);
        final plan = PlanCatalogo.fromJson(jsonData);
        
        print('✅ Plan obtenido: ${plan.nombre}');
        return plan;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo plan: $e');
      rethrow;
    }
  }

  // ========================================
  // UPGRADE - PROCESO DE ACTUALIZACIÓN
  // ========================================

  /// 🚀 Solicitar upgrade a plan premium
  static Future<UpgradeResponse> solicitarUpgrade(String planCodigo) async {
    try {
      print('🚀 [SuscripcionService] Solicitando upgrade a $planCodigo...');
      
      final headers = await _getAuthHeaders();
      final body = UpgradeRequest(planCodigo: planCodigo).toJson();

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/suscripciones/upgrade'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 explícito
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(responseBody);
        final upgrade = UpgradeResponse.fromJson(jsonData);
        
        print('✅ Upgrade solicitado: ${upgrade.mensaje}');
        return upgrade;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error solicitando upgrade: $e');
      rethrow;
    }
  }

  // ========================================
  // CACHE LOCAL - PARA MODO OFFLINE
  // ========================================

  /// 💾 Guardar suscripción en cache local
  static Future<void> _guardarSuscripcionCache(Suscripcion suscripcion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final suscripcionJson = jsonEncode(suscripcion.toJson());
      await prefs.setString('suscripcion_cache', suscripcionJson);
      await prefs.setString('suscripcion_cache_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      print('⚠️ Error guardando cache de suscripción: $e');
    }
  }

  /// 📱 Cargar suscripción desde cache local
  static Future<Suscripcion?> _cargarSuscripcionCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final suscripcionJson = prefs.getString('suscripcion_cache');
      final timestamp = prefs.getString('suscripcion_cache_timestamp');
      
      if (suscripcionJson != null && timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final ahora = DateTime.now();
        
        // Cache válido por 1 hora
        if (ahora.difference(cacheTime).inHours < 1) {
          final jsonData = jsonDecode(suscripcionJson);
          return Suscripcion.fromJson(jsonData);
        }
      }
      
      return null;
    } catch (e) {
      print('⚠️ Error cargando cache de suscripción: $e');
      return null;
    }
  }

  // ========================================
  // UTILIDADES - VALIDACIÓN MANUAL
  // ========================================

  /// 🔒 Interceptar errores HTTP 402 (Payment Required)
  static bool esErrorLimiteAlcanzado(dynamic error) {
    if (error is http.Response && error.statusCode == 402) {
      return true;
    }
    
    if (error is Exception) {
      final errorString = error.toString();
      return errorString.contains('402') || 
             errorString.contains('Payment Required') ||
             errorString.contains('upgrade_plan');
    }
    
    return false;
  }

  /// 📋 Parsear error de límite desde HTTP 402
  static LimiteSuperadoError? parsearErrorLimite(dynamic error) {
    try {
      if (error is http.Response && error.statusCode == 402) {
        final jsonData = jsonDecode(error.body);
        if (jsonData['detail'] is Map) {
          return LimiteSuperadoError.fromJson(jsonData['detail']);
        }
      }
      return null;
    } catch (e) {
      print('⚠️ Error parseando límite superado: $e');
      return null;
    }
  }

  /// 🎨 Obtener color del plan por código
  static String obtenerColorPlan(String planCodigo) {
    switch (planCodigo.toLowerCase()) {
      case 'gratuito': return '#95a5a6';  // Gris
      case 'basico': return '#3498db';    // Azul
      case 'premium': return '#e74c3c';   // Rojo
      case 'profesional': return '#f39c12'; // Dorado
      default: return '#95a5a6';
    }
  }

  /// 🏆 Obtener nombre amigable del plan
  static String obtenerNombrePlan(String planCodigo) {
    switch (planCodigo.toLowerCase()) {
      case 'gratuito': return 'Plan Gratuito';
      case 'basico': return 'Plan Básico';
      case 'premium': return 'Plan Premium';
      case 'profesional': return 'Plan Profesional';
      default: return planCodigo;
    }
  }

  /// ⭐ Obtener icono del plan
  static String obtenerIconoPlan(String planCodigo) {
    switch (planCodigo.toLowerCase()) {
      case 'gratuito': return '🆓';
      case 'basico': return '⭐';
      case 'premium': return '💎';
      case 'profesional': return '👑';
      default: return '📋';
    }
  }

  // ========================================
  // VALIDACIONES HELPER PARA WIDGETS
  // ========================================

  /// 🔍 Validar antes de crear gallo
  static Future<bool> puedeCrearGallo() async {
    try {
      final validacion = await validarLimite(recursoTipo: 'gallos');
      return validacion.puedeCrear;
    } catch (e) {
      return false; // En caso de error, no permitir
    }
  }

  /// 🏋️ Validar antes de crear tope/entrenamiento
  static Future<bool> puedeCrearTope(int galloId) async {
    try {
      final validacion = await validarLimite(
        recursoTipo: 'topes',
        galloId: galloId,
      );
      return validacion.puedeCrear;
    } catch (e) {
      return false;
    }
  }

  /// 🥊 Validar antes de crear pelea
  static Future<bool> puedeCrearPelea(int galloId) async {
    try {
      final validacion = await validarLimite(
        recursoTipo: 'peleas',
        galloId: galloId,
      );
      return validacion.puedeCrear;
    } catch (e) {
      return false;
    }
  }

  /// 💉 Validar antes de crear vacuna
  static Future<bool> puedeCrearVacuna(int galloId) async {
    try {
      final validacion = await validarLimite(
        recursoTipo: 'vacunas',
        galloId: galloId,
      );
      return validacion.puedeCrear;
    } catch (e) {
      return false;
    }
  }
}