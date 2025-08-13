// 📁 lib/services/peleas_service.dart
// 🥊 Servicio para gestión de peleas - DATOS REALES DEL BACKEND

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PeleasService {
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

  // 📊 OBTENER ESTADÍSTICAS DE PELEAS
  static Future<Map<String, dynamic>?> getEstadisticas() async {
    print('📊 Obteniendo estadísticas de peleas...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/peleas/stats/'),
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

  // 📋 LISTAR PELEAS CON FILTROS
  static Future<List<Map<String, dynamic>>> getPeleas({
    int? galloId,
    String? resultado,
    int skip = 0,
    int limit = 100, // Máximo permitido por el backend
  }) async {
    print('📋 Obteniendo lista de peleas...');
    
    try {
      final headers = await _getAuthHeaders();
      
      // Construir URL con query parameters manualmente
      String url = '$_baseUrl/api/v1/peleas/?skip=$skip&limit=$limit';
      
      if (galloId != null) {
        url += '&gallo_id=$galloId';
        print('   Filtrando por gallo_id: $galloId');
      }
      if (resultado != null) {
        url += '&resultado=$resultado';
      }
      
      print('📡 URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status peleas: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> peleas = json.decode(response.body);
        print('✅ Peleas obtenidas: ${peleas.length}');
        return List<Map<String, dynamic>>.from(peleas);
      } else {
        print('❌ Error peleas: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Excepción peleas: $e');
      return [];
    }
  }

  // 🔍 OBTENER PELEA POR ID
  static Future<Map<String, dynamic>?> getPeleaPorId(int peleaId) async {
    print('🔍 Obteniendo pelea $peleaId...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/peleas/$peleaId/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status pelea: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final pelea = json.decode(response.body);
        print('✅ Pelea obtenida');
        return Map<String, dynamic>.from(pelea);
      } else {
        print('❌ Error pelea: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Excepción pelea: $e');
      return null;
    }
  }

  // ➕ CREAR NUEVA PELEA
  static Future<Map<String, dynamic>?> crearPelea({
    required int galloId,
    required String titulo,
    required DateTime fechaPelea,
    String? descripcion,
    String? ubicacion,
    String? oponenteNombre,
    String? oponenteGallo,
    String? resultado,
    String? notasResultado,
    File? video,
    // 🆕 NUEVOS PARÁMETROS OPCIONALES (8 campos)
    String? gallera,
    String? ciudad,
    String? miGalloNombre,
    String? miGalloPropietario,
    int? miGalloPeso,
    int? oponenteGalloPeso,
    String? premio,
    int? duracionMinutos,
  }) async {
    print('➕ Creando nueva pelea...');
    
    try {
      final headers = await _getAuthHeadersFormData();
      
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/v1/peleas/'));
      request.headers.addAll(headers);
      
      // Campos obligatorios
      request.fields['gallo_id'] = galloId.toString();
      request.fields['titulo'] = titulo;
      request.fields['fecha_pelea'] = fechaPelea.toIso8601String();
      
      // Campos opcionales
      if (descripcion != null && descripcion.isNotEmpty) request.fields['descripcion'] = descripcion;
      if (ubicacion != null && ubicacion.isNotEmpty) request.fields['ubicacion'] = ubicacion;
      if (oponenteNombre != null && oponenteNombre.isNotEmpty) request.fields['oponente_nombre'] = oponenteNombre;
      if (oponenteGallo != null && oponenteGallo.isNotEmpty) request.fields['oponente_gallo'] = oponenteGallo;
      if (resultado != null && resultado.isNotEmpty) request.fields['resultado'] = resultado;
      if (notasResultado != null && notasResultado.isNotEmpty) request.fields['notas_resultado'] = notasResultado;
      
      // 🆕 NUEVOS CAMPOS OPCIONALES (8 campos)
      if (gallera != null && gallera.isNotEmpty) request.fields['gallera'] = gallera;
      if (ciudad != null && ciudad.isNotEmpty) request.fields['ciudad'] = ciudad;
      if (miGalloNombre != null && miGalloNombre.isNotEmpty) request.fields['mi_gallo_nombre'] = miGalloNombre;
      if (miGalloPropietario != null && miGalloPropietario.isNotEmpty) request.fields['mi_gallo_propietario'] = miGalloPropietario;
      if (miGalloPeso != null) request.fields['mi_gallo_peso'] = miGalloPeso.toString();
      if (oponenteGalloPeso != null) request.fields['oponente_gallo_peso'] = oponenteGalloPeso.toString();
      if (premio != null && premio.isNotEmpty) request.fields['premio'] = premio;
      if (duracionMinutos != null) request.fields['duracion_minutos'] = duracionMinutos.toString();
      
      // Video (opcional)
      if (video != null) {
        request.files.add(await http.MultipartFile.fromPath('video', video.path));
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Status crear: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(response.body);
        print('✅ Pelea creada exitosamente');
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

  // ✏️ ACTUALIZAR PELEA EXISTENTE
  static Future<Map<String, dynamic>?> actualizarPelea(
    int peleaId, {
    String? titulo,
    DateTime? fechaPelea,
    String? descripcion,
    String? ubicacion,
    String? oponenteNombre,
    String? oponenteGallo,
    String? resultado,
    String? notasResultado,
    File? video,
    // 🆕 NUEVOS PARÁMETROS OPCIONALES (8 campos)
    String? gallera,
    String? ciudad,
    String? miGalloNombre,
    String? miGalloPropietario,
    int? miGalloPeso,
    int? oponenteGalloPeso,
    String? premio,
    int? duracionMinutos,
  }) async {
    print('✏️ Actualizando pelea $peleaId...');
    
    try {
      final headers = await _getAuthHeadersFormData();
      
      final request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/api/v1/peleas/$peleaId'));
      request.headers.addAll(headers);
      
      // Solo agregar campos que no sean nulos
      if (titulo != null) request.fields['titulo'] = titulo;
      if (fechaPelea != null) request.fields['fecha_pelea'] = fechaPelea.toIso8601String();
      if (descripcion != null) request.fields['descripcion'] = descripcion;
      if (ubicacion != null) request.fields['ubicacion'] = ubicacion;
      if (oponenteNombre != null) request.fields['oponente_nombre'] = oponenteNombre;
      if (oponenteGallo != null) request.fields['oponente_gallo'] = oponenteGallo;
      if (resultado != null) request.fields['resultado'] = resultado;
      if (notasResultado != null) request.fields['notas_resultado'] = notasResultado;
      
      // 🆕 NUEVOS CAMPOS OPCIONALES (8 campos)
      if (gallera != null) request.fields['gallera'] = gallera;
      if (ciudad != null) request.fields['ciudad'] = ciudad;
      if (miGalloNombre != null) request.fields['mi_gallo_nombre'] = miGalloNombre;
      if (miGalloPropietario != null) request.fields['mi_gallo_propietario'] = miGalloPropietario;
      if (miGalloPeso != null) request.fields['mi_gallo_peso'] = miGalloPeso.toString();
      if (oponenteGalloPeso != null) request.fields['oponente_gallo_peso'] = oponenteGalloPeso.toString();
      if (premio != null) request.fields['premio'] = premio;
      if (duracionMinutos != null) request.fields['duracion_minutos'] = duracionMinutos.toString();
      
      // Video (opcional)
      if (video != null) {
        request.files.add(await http.MultipartFile.fromPath('video', video.path));
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Status actualizar: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Pelea actualizada');
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

  // 🗑️ ELIMINAR PELEA
  static Future<bool> eliminarPelea(int peleaId) async {
    print('🗑️ Eliminando pelea $peleaId...');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/peleas/$peleaId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status eliminar: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ Pelea eliminada exitosamente');
        return true;
      } else {
        print('❌ Error eliminar - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Error eliminando pelea: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Excepción eliminar: $e');
      throw Exception('Error eliminando pelea: $e');
    }
  }

  // 📊 OBTENER PELEAS DE UN GALLO ESPECÍFICO
  static Future<List<Map<String, dynamic>>> getPeleasGallo(int galloId) async {
    print('📊 Obteniendo peleas del gallo $galloId...');
    
    // Usar el método getPeleas existente con el filtro de galloId (límite máximo: 100)
    return await getPeleas(galloId: galloId, limit: 100);
  }
}