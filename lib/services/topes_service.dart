// 📁 lib/services/topes_service.dart
// 🏋️ Servicio para gestión de topes (entrenamientos) - DATOS REALES DEL BACKEND

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TopesService {
  static const String _baseUrl = 'https://gallerappback-production.up.railway.app';
  
  // 🔑 Obtener headers con JWT
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

  // 📊 OBTENER ESTADÍSTICAS DE TOPES
  static Future<Map<String, dynamic>?> getEstadisticas() async {
    print('📊 Obteniendo estadísticas de topes...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/topes/stats/'),
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

  // 📋 LISTAR TOPES CON FILTROS
  static Future<List<Map<String, dynamic>>> getTopes({
    int? galloId,
    String? tipoEntrenamiento,
    int skip = 0,
    int limit = 100, // Máximo permitido por el backend
  }) async {
    print('📋 Obteniendo lista de topes...');
    
    try {
      final headers = await _getAuthHeaders();
      
      // Construir URL con query parameters manualmente
      String url = '$_baseUrl/api/v1/topes/?skip=$skip&limit=$limit';
      
      if (galloId != null) {
        url += '&gallo_id=$galloId';
        print('   Filtrando por gallo_id: $galloId');
      }
      if (tipoEntrenamiento != null) {
        url += '&tipo_entrenamiento=$tipoEntrenamiento';
      }
      
      print('📡 URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status topes: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> topes = json.decode(response.body);
        print('✅ Topes obtenidos: ${topes.length}');
        return List<Map<String, dynamic>>.from(topes);
      } else {
        print('❌ Error topes: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Excepción topes: $e');
      return [];
    }
  }

  // 🔍 OBTENER TOPE POR ID
  static Future<Map<String, dynamic>?> getTopePorId(int topeId) async {
    print('🔍 Obteniendo tope $topeId...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/topes/$topeId/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status tope: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final tope = json.decode(response.body);
        print('✅ Tope obtenido');
        return Map<String, dynamic>.from(tope);
      } else {
        print('❌ Error tope: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Excepción tope: $e');
      return null;
    }
  }

  // ➕ CREAR NUEVO TOPE
  static Future<Map<String, dynamic>?> crearTope({
    required int galloId,
    required String titulo,
    required String tipoEntrenamiento,
    required DateTime fechaTope,
    int? duracionMinutos,
    String? descripcion,
    String? desSparring,
    String? tipoResultado,
    String? tipoCondicionFisica,
    String? pesoPostTope,
    DateTime? fechaProximo,
    String? notas,
    File? video,
  }) async {
    print('➕ Creando nuevo tope...');
    
    try {
      final headers = await _getAuthHeadersFormData();
      
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/v1/topes/'));
      request.headers.addAll(headers);
      
      // Campos obligatorios
      request.fields['gallo_id'] = galloId.toString();
      request.fields['titulo'] = titulo;
      request.fields['tipo_entrenamiento'] = tipoEntrenamiento;
      request.fields['fecha_tope'] = fechaTope.toIso8601String();
      
      // Campos opcionales
      if (duracionMinutos != null) request.fields['duracion_minutos'] = duracionMinutos.toString();
      if (descripcion != null && descripcion.isNotEmpty) request.fields['descripcion'] = descripcion;
      if (desSparring != null && desSparring.isNotEmpty) request.fields['des_sparring'] = desSparring;
      if (tipoResultado != null && tipoResultado.isNotEmpty) request.fields['tipo_resultado'] = tipoResultado;
      if (tipoCondicionFisica != null && tipoCondicionFisica.isNotEmpty) request.fields['tipo_condicion_fisica'] = tipoCondicionFisica;
      if (pesoPostTope != null && pesoPostTope.isNotEmpty) request.fields['peso_post_tope'] = pesoPostTope;
      if (fechaProximo != null) request.fields['fecha_proximo'] = fechaProximo.toIso8601String();
      if (notas != null && notas.isNotEmpty) {
        request.fields['observaciones'] = notas;
        print('📝 Enviando observaciones: "$notas"');
      }
      
      // Video (opcional)
      if (video != null) {
        print('🎬 Agregando video: ${video.path}');
        request.files.add(await http.MultipartFile.fromPath('video', video.path));
        print('✅ Video agregado al request');
      } else {
        print('❌ No hay video para agregar');
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Status crear: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(response.body);
        print('✅ Tope creado exitosamente');
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

  // ✏️ ACTUALIZAR TOPE EXISTENTE
  static Future<Map<String, dynamic>?> actualizarTope(
    int topeId, {
    int? galloId,
    String? titulo,
    String? tipoEntrenamiento,
    DateTime? fechaTope,
    int? duracionMinutos,
    String? descripcion,
    String? desSparring,
    String? tipoResultado,
    String? tipoCondicionFisica,
    String? pesoPostTope,
    DateTime? fechaProximo,
    String? notas,
    File? video,
  }) async {
    print('✏️ Actualizando tope $topeId...');
    
    try {
      final headers = await _getAuthHeadersFormData();
      
      final request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/api/v1/topes/$topeId'));
      request.headers.addAll(headers);
      
      // Solo agregar campos que no sean nulos
      if (galloId != null) request.fields['gallo_id'] = galloId.toString();
      if (titulo != null) request.fields['titulo'] = titulo;
      if (tipoEntrenamiento != null) request.fields['tipo_entrenamiento'] = tipoEntrenamiento;
      if (fechaTope != null) request.fields['fecha_tope'] = fechaTope.toIso8601String();
      if (duracionMinutos != null) request.fields['duracion_minutos'] = duracionMinutos.toString();
      if (descripcion != null) request.fields['descripcion'] = descripcion;
      if (desSparring != null) request.fields['des_sparring'] = desSparring;
      if (tipoResultado != null) request.fields['tipo_resultado'] = tipoResultado;
      if (tipoCondicionFisica != null) request.fields['tipo_condicion_fisica'] = tipoCondicionFisica;
      if (pesoPostTope != null) request.fields['peso_post_tope'] = pesoPostTope;
      if (fechaProximo != null) request.fields['fecha_proximo'] = fechaProximo.toIso8601String();
      if (notas != null) request.fields['observaciones'] = notas;
      
      // Video (opcional)
      if (video != null) {
        request.files.add(await http.MultipartFile.fromPath('video', video.path));
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Status actualizar: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Tope actualizado');
        return Map<String, dynamic>.from(result);
      } else {
        print('❌ Error actualizar: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Excepción actualizar: $e');
      return null;
    }
  }

  // 🗑️ ELIMINAR TOPE
  static Future<bool> eliminarTope(int topeId) async {
    print('🗑️ Eliminando tope $topeId...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/topes/$topeId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status eliminar: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ Tope eliminado exitosamente');
        return true;
      } else {
        print('❌ Error eliminar - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Error eliminando tope: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Excepción eliminar: $e');
      throw Exception('Error eliminando tope: $e');
    }
  }

  // 📊 OBTENER TOPES DE UN GALLO ESPECÍFICO
  static Future<List<Map<String, dynamic>>> getTopesGallo(int galloId) async {
    print('📊 Obteniendo topes del gallo $galloId...');
    
    // Usar el método getTopes existente con el filtro de galloId (límite máximo: 100)
    return await getTopes(galloId: galloId, limit: 100);
  }
}