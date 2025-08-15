// 📁 lib/services/gallo_service.dart
// 🐓 Servicio principal para gestión de gallos - SOLO DATOS REALES

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class GalloService {
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

  // 🎯 OBTENER UN GALLO POR ID - DATOS COMPLETOS
  static Future<Map<String, dynamic>?> getGalloById(int galloId) async {
    print('🔥 === OBTENIENDO GALLO POR ID: $galloId ===');
    
    final endpoint = '$_baseUrl/api/v1/gallos/';
    final headers = await _getAuthHeaders();
    
    try {
      print('🔍 Llamando: $endpoint');
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> gallosList = [];
        
        // Parsear respuesta según estructura
        if (data is List) {
          gallosList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          if (data['data'] != null && data['data']['gallos'] != null) {
            gallosList = List<Map<String, dynamic>>.from(data['data']['gallos']);
          } else if (data['gallos'] != null) {
            gallosList = List<Map<String, dynamic>>.from(data['gallos']);
          } else if (data['data'] is List) {
            gallosList = List<Map<String, dynamic>>.from(data['data']);
          }
        }
        
        // Buscar el gallo específico por ID
        for (var gallo in gallosList) {
          if (gallo['id'] == galloId) {
            print('✅ Gallo encontrado con TODOS los campos');
            print('📊 Campos disponibles: ${gallo.keys.toList()}');
            return gallo;
          }
        }
        
        print('⚠️ Gallo con ID $galloId no encontrado');
        return null;
        
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error en getGalloById: $e');
      return null;
    }
  }

  // 🐓 LISTAR GALLOS - SOLO BACKEND REAL (SIN FALLBACK)
  static Future<List<Map<String, dynamic>>> getGallos() async {
    print('🔥 === GALLO SERVICE - PROBANDO ENDPOINTS ===');
    print('🌐 Conectando a Railway backend...');
    
    // 🔍 ENDPOINT CORRECTO DEL BACKEND
    final endpoint = '$_baseUrl/api/v1/gallos/';  // Este es el correcto según main.py
    
    final headers = await _getAuthHeaders();
    final token = headers['Authorization'];
    
    print('🔑 Token presente: ${token != null ? "SÍ" : "NO"}');
    
    try {
      print('🔍 Llamando: $endpoint');
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ ¡GALLOS OBTENIDOS!');
        print('📝 Body preview: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
        
        final data = json.decode(response.body);
        
        List<Map<String, dynamic>> gallosList = [];
        
        // Intentar diferentes estructuras de respuesta
        if (data is List) {
          gallosList = List<Map<String, dynamic>>.from(data);
          print('✅ Estructura: Array directo - ${gallosList.length} gallos');
          } else if (data is Map) {
            if (data['data'] != null && data['data']['gallos'] != null) {
              gallosList = List<Map<String, dynamic>>.from(data['data']['gallos']);
              print('✅ Estructura Railway: ${gallosList.length} gallos del usuario ${data['data']['user_id']}');
            } else if (data['gallos'] != null) {
              gallosList = List<Map<String, dynamic>>.from(data['gallos']);
              print('✅ Estructura simple: ${gallosList.length} gallos');
            } else if (data['data'] is List) {
              gallosList = List<Map<String, dynamic>>.from(data['data']);
              print('✅ Estructura data array: ${gallosList.length} gallos');
            } else {
              print('❌ Estructura no reconocida: ${data.keys}');
              gallosList = []; // Lista vacía si no reconocemos la estructura
            }
          } else {
            print('❌ Tipo de respuesta no válido: ${data.runtimeType}');
            gallosList = [];
          }
          
          print('✅ === ÉXITO: ${gallosList.length} GALLOS DEL BACKEND ===');
          return gallosList;
          
      } else if (response.statusCode == 401) {
        print('🚫 ERROR 401: Token inválido');
        throw Exception('Token de autenticación inválido');
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Error obteniendo gallos: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error en getGallos: $e');
      throw Exception('Error conectando con el servidor: $e');
    }
  }

  // 🌳 LISTAR SOLO GALLOS PRINCIPALES (CABEZAS DE ÁRBOL) - NUEVO ENDPOINT ÉPICO
  static Future<List<Map<String, dynamic>>> getGallosPrincipales() async {
    print('🔥 === GALLO SERVICE - OBTENIENDO GALLOS PRINCIPALES ===');
    print('🌐 Conectando a nuevo endpoint /principales...');
    
    // 🔍 ENDPOINT NUEVO PARA GALLOS PRINCIPALES
    final endpoint = '$_baseUrl/api/v1/gallos/principales';
    
    final headers = await _getAuthHeaders();
    final token = headers['Authorization'];
    
    print('🔑 Token presente: ${token != null ? "SÍ" : "NO"}');
    
    try {
      print('🔍 Llamando: $endpoint');
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ ¡GALLOS PRINCIPALES OBTENIDOS!');
        print('📝 Body preview: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
        
        final data = json.decode(response.body);
        
        List<Map<String, dynamic>> gallosList = [];
        
        // Manejar la respuesta del nuevo endpoint
        if (data is Map && data['success'] == true) {
          if (data['data'] != null && data['data']['gallos'] != null) {
            gallosList = List<Map<String, dynamic>>.from(data['data']['gallos']);
            print('✅ Estructura principales: ${gallosList.length} gallos principales del usuario ${data['data']['user_id']}');
            print('🌳 Tipo de filtro: ${data['data']['tipo']}');
          } else {
            print('❌ Estructura de respuesta no contiene gallos');
            gallosList = [];
          }
        } else {
          print('❌ Respuesta no exitosa o estructura incorrecta: ${data['success']}');
          gallosList = [];
        }
        
        print('✅ === ÉXITO PRINCIPALES: ${gallosList.length} GALLOS PRINCIPALES DEL BACKEND ===');
        return gallosList;
        
      } else if (response.statusCode == 401) {
        print('🚫 ERROR 401: Token inválido');
        throw Exception('Token de autenticación inválido');
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Error obteniendo gallos principales: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error en getGallosPrincipales: $e');
      throw Exception('Error conectando con el servidor: $e');
    }
  }

  // 🐓 CREAR GALLO - SOLO BACKEND REAL
  static Future<Map<String, dynamic>> crearGallo(Map<String, dynamic> galloData) async {
    print('🆕 Creando gallo en backend...');
    
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/gallos'),
        headers: headers,
        body: json.encode(galloData),
      );
      
      print('📡 Status: ${response.statusCode}');
      print('📝 Response: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creando gallo: $e');
      rethrow;
    }
  }

  // 🐓 ACTUALIZAR GALLO - SOLO BACKEND REAL
  static Future<Map<String, dynamic>> updateGallo(int id, Map<String, dynamic> galloData) async {
    print('✏️ Actualizando gallo $id en backend...');
    
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('$_baseUrl/api/v1/gallos/$id'),
        headers: headers,
        body: json.encode(galloData),
      );
      
      print('📡 Status: ${response.statusCode}');
      print('📝 Response: ${response.body}');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error actualizando gallo: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // 🔥 CREAR GALLO CON PEDIGRÍ - Técnica épica (1 → 3 registros)
  static Future<Map<String, dynamic>> crearGalloConPedigri({
    required Map<String, dynamic> datosGallo,
    bool crearPadre = false,
    bool crearMadre = false,
    Map<String, dynamic>? datosPadre,
    Map<String, dynamic>? datosMadre,
  }) async {
    print('🔥 TÉCNICA ÉPICA - Creando gallo con pedigrí...');
    
    try {
      final headers = await _getAuthHeaders();
      headers.remove('Content-Type'); // FormData maneja su propio content-type
      
      // Construir FormData para el endpoint épico
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/gallos/create-with-genealogy'),
      );
      
      request.headers.addAll(headers);
      
      // DATOS DEL GALLO PRINCIPAL
      if (datosGallo['nombre'] != null) {
        request.fields['nombre'] = datosGallo['nombre'].toString();
      }
      if (datosGallo['codigo_identificacion'] != null) {
        request.fields['codigo_identificacion'] = datosGallo['codigo_identificacion'].toString();
      }
      if (datosGallo['fecha_nacimiento'] != null) {
        request.fields['fecha_nacimiento'] = datosGallo['fecha_nacimiento'].toString();
      }
      if (datosGallo['raza_id'] != null) {
        request.fields['raza_id'] = datosGallo['raza_id'].toString();
      }
      if (datosGallo['peso'] != null) {
        request.fields['peso'] = datosGallo['peso'].toString();
      }
      if (datosGallo['altura'] != null) {
        request.fields['altura'] = datosGallo['altura'].toString();
      }
      if (datosGallo['color'] != null) {
        request.fields['color'] = datosGallo['color'].toString();
      }
      
      // FLAGS DE CREACIÓN
      request.fields['crear_padre'] = crearPadre.toString();
      request.fields['crear_madre'] = crearMadre.toString();
      
      // DATOS DEL PADRE (si se va a crear)
      if (crearPadre && datosPadre != null) {
        if (datosPadre['nombre'] != null) {
          request.fields['padre_nombre'] = datosPadre['nombre'].toString();
        }
        if (datosPadre['codigo_identificacion'] != null) {
          request.fields['padre_codigo'] = datosPadre['codigo_identificacion'].toString();
        }
      }
      
      // DATOS DE LA MADRE (si se va a crear)
      if (crearMadre && datosMadre != null) {
        if (datosMadre['nombre'] != null) {
          request.fields['madre_nombre'] = datosMadre['nombre'].toString();
        }
        if (datosMadre['codigo_identificacion'] != null) {
          request.fields['madre_codigo'] = datosMadre['codigo_identificacion'].toString();
        }
      }
      
      print('📤 Enviando FormData al backend...');
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Response status: ${response.statusCode}');
      print('📝 Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Gallos genealógicos creados exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? errorData['detail'] ?? 'Error al crear genealogía',
        };
      }
      
    } catch (e) {
      print('❌ Error en crearGalloConPedigri: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // 🗑️ ELIMINAR GALLO - SOLO BACKEND REAL
  static Future<bool> deleteGallo(int id) async {
    print('🗑️ Eliminando gallo $id del backend...');
    
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/gallos/$id'),
        headers: headers,
      );
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Gallo eliminado exitosamente');
        return true;
      } else {
        print('❌ Error eliminando: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error eliminando gallo: $e');
      return false;
    }
  }

  // 🐓 ACTUALIZAR GALLO CON EXPANSIÓN - PEDIGRÍ
  static Future<Map<String, dynamic>> updateGalloWithExpansion(int id, Map<String, dynamic> galloData) async {
    print('🔥 Actualizando gallo $id con expansión de pedigrí...');
    
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('$_baseUrl/api/v1/gallos/$id/expansion'),
        headers: headers,
        body: json.encode(galloData),
      );
      
      print('📡 Status: ${response.statusCode}');
      print('📝 Response: ${response.body}');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error en expansión: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // 🌳 OBTENER GENEALOGÍA COMPLETA
  static Future<Map<String, dynamic>> getGenealogiaCompleta(int galloId) async {
    print('🌳 Obteniendo genealogía del gallo $galloId...');
    
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/gallos/$galloId/genealogia'),
        headers: headers,
      );
      
      print('📡 Status: ${response.statusCode}');
      print('📝 Response length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // 🔍 DEBUG: Ver estructura de la respuesta
        print('🔍 Response keys: ${responseData.keys.toList()}');
        
        // ✅ FIX: El backend devuelve {success, data, message}
        // Necesitamos devolver la estructura correcta
        if (responseData['success'] == true && responseData['data'] != null) {
          return {
            'success': true,
            'data': responseData['data'],  // ← Aquí estaba el error
          };
        } else {
          // Si no viene en el formato esperado, devolver como estaba
          return {
            'success': true,
            'data': responseData,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error obteniendo genealogía: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
