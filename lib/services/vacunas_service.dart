// 📁 lib/services/vacunas_service.dart
// 💉 Servicio para gestión de vacunas - DATOS REALES DEL BACKEND

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class VacunasService {
  static const String _baseUrl = 'https://gallerappback-production.up.railway.app';
  
  // 🔑 Obtener headers con JWT (mismo patrón que GalloService)
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 🔑 Headers para FormData (POST/PUT con formularios)
  static Future<Map<String, String>> _getAuthHeadersFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 🏷️ OBTENER TIPOS DE VACUNAS DISPONIBLES
  static Future<List<Map<String, dynamic>>> getTiposVacunas() async {
    print('🏷️ Obteniendo tipos de vacunas...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/vacunas/tipos'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status tipos: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> tipos = json.decode(response.body);
        print('✅ Tipos obtenidos: ${tipos.length}');
        return List<Map<String, dynamic>>.from(tipos);
      } else {
        print('❌ Error obteniendo tipos: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Excepción obteniendo tipos: $e');
      return [];
    }
  }

  // 📊 OBTENER ESTADÍSTICAS DE VACUNAS
  static Future<Map<String, dynamic>?> getEstadisticas() async {
    print('📊 Obteniendo estadísticas de vacunas...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/vacunas/stats'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status stats: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final stats = json.decode(response.body);
        print('✅ Estadísticas obtenidas');
        return Map<String, dynamic>.from(stats);
      } else {
        print('❌ Error stats: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Excepción stats: $e');
      return null;
    }
  }

  // 📋 LISTAR VACUNAS CON FILTROS
  static Future<List<Map<String, dynamic>>> getVacunas({
    int? galloId,
    String? tipoVacuna,
    int skip = 0,
    int limit = 100,
  }) async {
    print('📋 Obteniendo lista de vacunas...');
    
    try {
      final headers = await _getAuthHeaders();
      
      // Construir query parameters
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      
      if (galloId != null) queryParams['gallo_id'] = galloId.toString();
      if (tipoVacuna != null) queryParams['tipo_vacuna'] = tipoVacuna;
      
      final uri = Uri.parse('$_baseUrl/api/v1/vacunas').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      
      print('📡 Status vacunas: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> vacunas = json.decode(response.body);
        print('✅ Vacunas obtenidas: ${vacunas.length}');
        return List<Map<String, dynamic>>.from(vacunas);
      } else {
        print('❌ Error vacunas: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Excepción vacunas: $e');
      return [];
    }
  }

  // 🔜 OBTENER PRÓXIMAS VACUNAS
  static Future<List<Map<String, dynamic>>> getProximasVacunas({int diasAdelante = 30}) async {
    print('🔜 Obteniendo próximas vacunas...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/vacunas/proximas?dias_adelante=$diasAdelante'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status próximas: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> proximas = json.decode(response.body);
        print('✅ Próximas obtenidas: ${proximas.length}');
        return List<Map<String, dynamic>>.from(proximas);
      } else {
        print('❌ Error próximas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Excepción próximas: $e');
      return [];
    }
  }

  // 📊 HISTORIAL DE VACUNAS DE UN GALLO
  static Future<List<Map<String, dynamic>>> getHistorialGallo(int galloId) async {
    print('📊 Obteniendo historial del gallo $galloId...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/vacunas/gallo/$galloId/historial'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status historial: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> historial = json.decode(response.body);
        print('✅ Historial obtenido: ${historial.length} registros');
        return List<Map<String, dynamic>>.from(historial);
      } else {
        print('❌ Error historial: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Excepción historial: $e');
      return [];
    }
  }

  // ➕ CREAR NUEVA VACUNA
  static Future<Map<String, dynamic>?> crearVacuna({
    required int galloId,
    required String tipoVacuna,
    required String fechaAplicacion, // formato: YYYY-MM-DD
    String? laboratorio,
    String? proximaDosis, // formato: YYYY-MM-DD
    String? veterinarioNombre,
    String? clinica,
    String? dosis,
    String? notas,
  }) async {
    print('➕ Creando nueva vacuna...');
    
    try {
      final headers = await _getAuthHeadersFormData();
      
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/v1/vacunas'));
      request.headers.addAll(headers);
      
      // Campos obligatorios
      request.fields['gallo_id'] = galloId.toString();
      request.fields['tipo_vacuna'] = tipoVacuna;
      request.fields['fecha_aplicacion'] = fechaAplicacion;
      
      // Campos opcionales
      if (laboratorio != null) request.fields['laboratorio'] = laboratorio;
      if (proximaDosis != null) request.fields['proxima_dosis'] = proximaDosis;
      if (veterinarioNombre != null) request.fields['veterinario_nombre'] = veterinarioNombre;
      if (clinica != null) request.fields['clinica'] = clinica;
      if (dosis != null) request.fields['dosis'] = dosis;
      if (notas != null) request.fields['notas'] = notas;
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Status crear: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(response.body);
        print('✅ Vacuna creada exitosamente');
        return Map<String, dynamic>.from(result);
      } else {
        print('❌ Error crear: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Excepción crear: $e');
      return null;
    }
  }

  // ✏️ ACTUALIZAR VACUNA EXISTENTE
  static Future<Map<String, dynamic>?> actualizarVacuna(
    int vacunaId, {
    int? galloId,
    String? tipoVacuna,
    String? fechaAplicacion,
    String? laboratorio,
    String? proximaDosis,
    String? veterinarioNombre,
    String? clinica,
    String? dosis,
    String? notas,
  }) async {
    print('✏️ Actualizando vacuna $vacunaId...');
    
    try {
      final headers = await _getAuthHeadersFormData();
      
      final request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/api/v1/vacunas/$vacunaId'));
      request.headers.addAll(headers);
      
      // Solo agregar campos que no sean nulos
      if (galloId != null) request.fields['gallo_id'] = galloId.toString();
      if (tipoVacuna != null) request.fields['tipo_vacuna'] = tipoVacuna;
      if (fechaAplicacion != null) request.fields['fecha_aplicacion'] = fechaAplicacion;
      if (laboratorio != null) request.fields['laboratorio'] = laboratorio;
      if (proximaDosis != null) request.fields['proxima_dosis'] = proximaDosis;
      if (veterinarioNombre != null) request.fields['veterinario_nombre'] = veterinarioNombre;
      if (clinica != null) request.fields['clinica'] = clinica;
      if (dosis != null) request.fields['dosis'] = dosis;
      if (notas != null) request.fields['notas'] = notas;
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Status actualizar: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Vacuna actualizada');
        return Map<String, dynamic>.from(result);
      } else {
        print('❌ Error actualizar: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Excepción actualizar: $e');
      return null;
    }
  }

  // 🗑️ ELIMINAR VACUNA
  static Future<bool> eliminarVacuna(int vacunaId) async {
    print('🗑️ Eliminando vacuna $vacunaId...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/vacunas/$vacunaId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status eliminar: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Vacuna eliminada');
        return true;
      } else {
        print('❌ Error eliminar: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Excepción eliminar: $e');
      return false;
    }
  }

  // ⚡ REGISTRO RÁPIDO DE MÚLTIPLES VACUNAS
  static Future<Map<String, dynamic>?> registroRapido({
    required List<int> galloIds,
    required List<String> tipoVacunas,
    required String fechaAplicacion,
    String? veterinarioNombre,
    String? clinica,
    String? dosis,
    String? proximaDosis,
    String? notas,
  }) async {
    print('⚡ Registro rápido...');
    
    try {
      final headers = await _getAuthHeadersFormData();
      
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/v1/vacunas/registro-rapido'));
      request.headers.addAll(headers);
      
      // Convertir listas a strings separados por comas
      request.fields['gallo_ids'] = galloIds.join(',');
      request.fields['tipo_vacunas'] = tipoVacunas.join(',');
      request.fields['fecha_aplicacion'] = fechaAplicacion;
      
      // Campos opcionales
      if (veterinarioNombre != null) request.fields['veterinario_nombre'] = veterinarioNombre;
      if (clinica != null) request.fields['clinica'] = clinica;
      if (dosis != null) request.fields['dosis'] = dosis;
      if (proximaDosis != null) request.fields['proxima_dosis'] = proximaDosis;
      if (notas != null) request.fields['notas'] = notas;
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Status registro rápido: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(response.body);
        print('✅ Registro rápido exitoso: ${result['registros_creados']} registros');
        return Map<String, dynamic>.from(result);
      } else {
        print('❌ Error registro rápido: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Excepción registro rápido: $e');
      return null;
    }
  }
}