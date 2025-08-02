// 📁 lib/services/gallo_service.dart
// 🐓 Servicio principal para gestión de gallos con técnica épica de pedigrí

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'connection_service.dart';
import 'offline_queue_service.dart';

class GalloService {
  static const String _baseUrl = 'https://gallerappback-production.up.railway.app';
  static final ConnectionService _connectionService = ConnectionService();
  
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

  // 🐓 LISTAR GALLOS - DIRECTO AL BACKEND
  static Future<List<Map<String, dynamic>>> getGallos() async {
    print('🐓 GalloService.getGallos() - Conectando al backend...');
    
    try {
      final headers = await _getAuthHeaders();
      print('📡 URL: $_baseUrl/api/v1/gallos');
      print('🔑 Headers enviados: $headers'); // 🔥 DEBUG NUEVO
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/gallos'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}'); // 🔥 DEBUG NUEVO
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // 🔥 NUEVO: Manejar estructura del backend Railway
        List<Map<String, dynamic>> gallosList;
        
        if (data is Map && data['data'] != null && data['data']['gallos'] != null) {
          // Estructura Railway: {"success": true, "data": {"gallos": [...]}}
          gallosList = List<Map<String, dynamic>>.from(data['data']['gallos']);
          print('✅ Parsing Railway exitoso: ${data['data']['total']} gallos del usuario ${data['data']['user_id']}');
        } else if (data is List) {
          // Estructura simple: [...]
          gallosList = List<Map<String, dynamic>>.from(data);
          print('✅ Parsing simple exitoso');
        } else {
          print('⚠️ Estructura de respuesta no reconocida: $data');
          throw Exception('Estructura de respuesta no válida del servidor');
        }
        
        // Guardar en caché
        await _guardarGallosEnCache(gallosList);
        
        print('✅ ÉXITO: ${gallosList.length} gallos del BACKEND');
        return gallosList;
      } else if (response.statusCode == 401) {
        print('⚠️ ERROR 401: No autenticado - Inicia sesión primero');
        print('🔑 Token usado: ${headers['Authorization']}'); // 🔥 DEBUG NUEVO
        throw Exception('Error 401: Token inválido o expirado. Inicia sesión nuevamente');
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      print('🔥 NO FALLBACK - SOLO DATOS REALES');
      rethrow; // 🔥 PROPAGAR ERROR SIN FALLBACK
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
    
    // Si estamos offline, encolar la operación
    if (_connectionService.isOffline) {
      print('📴 Modo offline - Encolando operación...');
      
      final operacion = {
        'tipo': 'crear_gallo_pedigri',
        'datos': {
          'datosGallo': datosGallo,
          'crearPadre': crearPadre,
          'crearMadre': crearMadre,
          'datosPadre': datosPadre,
          'datosMadre': datosMadre,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await OfflineQueueService.encolarOperacion(operacion);
      
      // Crear respuesta simulada con IDs temporales
      final idTemporal = DateTime.now().millisecondsSinceEpoch;
      return {
        'success': true,
        'offline': true,
        'message': 'Guardado localmente. Se sincronizará cuando haya conexión.',
        'data': {
          'gallo': {
            'id': idTemporal,
            'nombre': datosGallo['nombre'],
            'tipo_registro': 'principal',
            'temporal': true,
          },
          'padre': crearPadre ? {
            'id': idTemporal + 1,
            'nombre': datosPadre?['nombre'] ?? 'Padre ${datosGallo['nombre']}',
            'tipo_registro': 'padre_generado',
            'temporal': true,
          } : null,
          'madre': crearMadre ? {
            'id': idTemporal + 2,
            'nombre': datosMadre?['nombre'] ?? 'Madre ${datosGallo['nombre']}',
            'tipo_registro': 'madre_generada',
            'temporal': true,
          } : null,
        }
      };
    }
    
    try {
      final headers = await _getAuthHeaders();
      headers.remove('Content-Type'); // FormData maneja su propio content-type
      
      // Construir FormData para el endpoint épico
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/gallos/con-pedigri'),
      );
      
      // Headers
      request.headers.addAll(headers);
      
      // Datos del gallo principal
      request.fields['nombre'] = datosGallo['nombre'];
      request.fields['codigo_identificacion'] = datosGallo['codigo_identificacion'];
      request.fields['peso'] = datosGallo['peso'].toString();
      request.fields['altura'] = datosGallo['altura'].toString();
      request.fields['color'] = datosGallo['color'] ?? '';
      if (datosGallo['raza_id'] != null) {
        request.fields['raza_id'] = datosGallo['raza_id'].toString();
      }
      
      // 🔥 TÉCNICA ÉPICA - Flags para crear padres
      request.fields['crear_padre'] = crearPadre.toString();
      request.fields['crear_madre'] = crearMadre.toString();
      
      // Datos del padre si se va a crear
      if (crearPadre && datosPadre != null) {
        request.fields['padre_nombre'] = datosPadre['nombre'];
        request.fields['padre_codigo'] = datosPadre['codigo_identificacion'] ?? 'PAD-AUTO';
      }
      
      // Datos de la madre si se va a crear
      if (crearMadre && datosMadre != null) {
        request.fields['madre_nombre'] = datosMadre['nombre'];
        request.fields['madre_codigo'] = datosMadre['codigo_identificacion'] ?? 'MAD-AUTO';
      }
      
      print('📤 Enviando request épico al backend...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ ÉXITO ÉPICO: ${crearPadre && crearMadre ? "3" : "1"} gallos creados');
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ Error del servidor: ${response.body}');
        throw Exception('Error al crear gallo: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en técnica épica: $e');
      rethrow;
    }
  }

  // 🌳 OBTENER ÁRBOL GENEALÓGICO COMPLETO
  static Future<Map<String, dynamic>> getGenealogiaCompleta(int galloId) async {
    print('🌳 Obteniendo árbol genealógico del gallo $galloId...');
    
    if (_connectionService.isOffline) {
      print('📴 Modo offline - Construyendo árbol desde mock...');
      return await _construirArbolDesdeMock(galloId);
    }
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/gallos/$galloId/genealogia'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Árbol genealógico cargado');
        return data;
      } else {
        print('❌ Error al cargar genealogía: ${response.statusCode}');
        return await _construirArbolDesdeMock(galloId);
      }
    } catch (e) {
      print('❌ Error al obtener genealogía: $e');
      return await _construirArbolDesdeMock(galloId);
    }
  }

  // 📝 ACTUALIZAR GALLO
  static Future<Map<String, dynamic>> updateGallo(int galloId, Map<String, dynamic> datos) async {
    print('📝 Actualizando gallo $galloId...');
    
    if (_connectionService.isOffline) {
      print('📴 Modo offline - Encolando actualización...');
      
      await OfflineQueueService.encolarOperacion({
        'tipo': 'actualizar_gallo',
        'galloId': galloId,
        'datos': datos,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return {
        'success': true,
        'offline': true,
        'message': 'Actualización guardada. Se sincronizará cuando haya conexión.',
      };
    }
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/api/v1/gallos/$galloId'),
        headers: headers,
        body: json.encode(datos),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Gallo actualizado exitosamente');
        return {
          'success': true,
          'data': data,
        };
      } else {
        throw Exception('Error al actualizar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al actualizar gallo: $e');
      rethrow;
    }
  }

  // 🗑️ ELIMINAR GALLO
  static Future<bool> deleteGallo(int galloId) async {
    print('🗑️ Eliminando gallo $galloId...');
    
    if (_connectionService.isOffline) {
      print('📴 Modo offline - Encolando eliminación...');
      
      await OfflineQueueService.encolarOperacion({
        'tipo': 'eliminar_gallo',
        'galloId': galloId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return true;
    }
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/gallos/$galloId'),
        headers: headers,
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Gallo eliminado exitosamente');
        return true;
      } else {
        print('❌ Error al eliminar: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error al eliminar gallo: $e');
      return false;
    }
  }

  // 📱 MÉTODOS DE CACHÉ Y MOCK

  // Cargar gallos desde mock JSON
  static Future<List<Map<String, dynamic>>> _cargarGallosMock() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/data/mock/gallos_mock.json');
      final data = json.decode(jsonString);
      final gallos = List<Map<String, dynamic>>.from(data['gallos'] ?? []);
      
      // Marcar como datos mock
      for (var gallo in gallos) {
        gallo['is_mock'] = true;
      }
      
      print('📁 Cargados ${gallos.length} gallos del mock');
      return gallos;
    } catch (e) {
      print('❌ Error al cargar mock: $e');
      return [];
    }
  }

  // Guardar gallos en caché local
  static Future<void> _guardarGallosEnCache(List<Map<String, dynamic>> gallos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gallosJson = json.encode(gallos);
      await prefs.setString('gallos_cache', gallosJson);
      print('💾 Guardados ${gallos.length} gallos en caché');
    } catch (e) {
      print('❌ Error al guardar caché: $e');
    }
  }

  // Cargar gallos desde caché
  static Future<List<Map<String, dynamic>>> _cargarGallosDesdeCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gallosJson = prefs.getString('gallos_cache');
      
      if (gallosJson != null) {
        final gallos = List<Map<String, dynamic>>.from(json.decode(gallosJson));
        print('💾 Cargados ${gallos.length} gallos desde caché');
        return gallos;
      }
      
      // Si no hay caché, cargar mock
      return await _cargarGallosMock();
    } catch (e) {
      print('❌ Error al cargar caché: $e');
      return await _cargarGallosMock();
    }
  }

  // Construir árbol genealógico desde mock
  static Future<Map<String, dynamic>> _construirArbolDesdeMock(int galloId) async {
    try {
      final gallos = await _cargarGallosMock();
      final gallo = gallos.firstWhere((g) => g['id'] == galloId, orElse: () => {});
      
      if (gallo.isEmpty) {
        return {'error': 'Gallo no encontrado'};
      }
      
      // Construir árbol recursivamente
      Map<String, dynamic> construirNodo(Map<String, dynamic> g) {
        final nodo = Map<String, dynamic>.from(g);
        
        // Buscar padre
        if (g['padre_id'] != null) {
          final padre = gallos.firstWhere(
            (p) => p['id'] == g['padre_id'],
            orElse: () => {},
          );
          if (padre.isNotEmpty) {
            nodo['padre'] = construirNodo(padre);
          }
        }
        
        // Buscar madre
        if (g['madre_id'] != null) {
          final madre = gallos.firstWhere(
            (m) => m['id'] == g['madre_id'],
            orElse: () => {},
          );
          if (madre.isNotEmpty) {
            nodo['madre'] = construirNodo(madre);
          }
        }
        
        return nodo;
      }
      
      return construirNodo(gallo);
    } catch (e) {
      print('❌ Error al construir árbol desde mock: $e');
      return {};
    }
  }

  // ==========================================
  // 🔥 MÉTODOS PARA FORMULARIOS MULTISTEP
  // ==========================================
  
  // 📝 CREAR GALLO SIMPLE
  static Future<Map<String, dynamic>> createGallo(Map<String, dynamic> galloData) async {
    print('🔥 GalloService.createGallo() - Creando gallo...');
    
    try {
      final headers = await _getAuthHeaders();
      print('📡 URL: $_baseUrl/api/v1/gallos');
      print('📤 Datos enviados: $galloData');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/gallos'),
        headers: headers,
        body: json.encode(galloData),
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Gallo creado exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al crear gallo',
        };
      }
      
    } catch (e) {
      print('❌ Error en createGallo: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  // 🧬 CREAR GALLO CON GENEALOGÍA (TÉCNICA RECURSIVA) - FORMATO FORM DATA
  static Future<Map<String, dynamic>> createWithGenealogy(Map<String, dynamic> galloData) async {
    print('🧬 GalloService.createWithGenealogy() - Técnica recursiva con FormData...');
    
    try {
      final headers = await _getAuthHeaders();
      headers.remove('Content-Type'); // FormData maneja su propio content-type
      
      print('📡 URL: $_baseUrl/api/v1/gallos/con-pedigri');
      print('📤 Datos genealógicos a enviar como FormData: $galloData');
      
      // 🔥 CREAR MULTIPART REQUEST PARA FORM DATA
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/gallos/con-pedigri'),
      );
      
      // Agregar headers de autenticación
      request.headers.addAll(headers);
      
      // 🔥 AGREGAR CAMPOS COMO FORM DATA
      
      // DATOS PRINCIPALES OBLIGATORIOS
      request.fields['nombre'] = galloData['nombre'].toString();
      request.fields['codigo_identificacion'] = galloData['codigo_identificacion'].toString();
      request.fields['fecha_nacimiento'] = galloData['fecha_nacimiento'].toString();
      
      // DATOS FÍSICOS
      if (galloData['peso'] != null) {
        request.fields['peso'] = galloData['peso'].toString();
      }
      if (galloData['altura'] != null) {
        request.fields['altura'] = galloData['altura'].toString();
      }
      if (galloData['color'] != null) {
        request.fields['color'] = galloData['color'].toString();
      }
      if (galloData['raza_id'] != null) {
        request.fields['raza_id'] = galloData['raza_id'].toString();
      }
      
      // DATOS ADICIONALES OPCIONALES
      if (galloData['color_patas'] != null) {
        request.fields['color_patas'] = galloData['color_patas'].toString();
      }
      if (galloData['color_placa'] != null) {
        request.fields['color_placa'] = galloData['color_placa'].toString();
      }
      if (galloData['ubicacion_placa'] != null) {
        request.fields['ubicacion_placa'] = galloData['ubicacion_placa'].toString();
      }
      if (galloData['criador'] != null) {
        request.fields['criador'] = galloData['criador'].toString();
      }
      if (galloData['propietario_actual'] != null) {
        request.fields['propietario_actual'] = galloData['propietario_actual'].toString();
      }
      if (galloData['observaciones'] != null) {
        request.fields['observaciones'] = galloData['observaciones'].toString();
      }
      if (galloData['notas'] != null) {
        request.fields['notas'] = galloData['notas'].toString();
      }
      
      // 🧬 TÉCNICA GENEALÓGICA RECURSIVA
      request.fields['crear_padre'] = galloData['crear_padre'].toString();
      request.fields['crear_madre'] = galloData['crear_madre'].toString();
      
      // DATOS DEL PADRE (si se va a crear)
      if (galloData['crear_padre'] == true) {
        if (galloData['padre_nombre'] != null) {
          request.fields['padre_nombre'] = galloData['padre_nombre'].toString();
        }
        if (galloData['padre_codigo_identificacion'] != null) {
          request.fields['padre_codigo'] = galloData['padre_codigo_identificacion'].toString();
        }
        if (galloData['padre_fecha_nacimiento'] != null) {
          request.fields['padre_fecha_nacimiento'] = galloData['padre_fecha_nacimiento'].toString();
        }
        if (galloData['padre_color_placa'] != null) {
          request.fields['padre_color_placa'] = galloData['padre_color_placa'].toString();
        }
        if (galloData['padre_ubicacion_placa'] != null) {
          request.fields['padre_ubicacion_placa'] = galloData['padre_ubicacion_placa'].toString();
        }
      }
      
      // DATOS DE LA MADRE (si se va a crear)
      if (galloData['crear_madre'] == true) {
        if (galloData['madre_nombre'] != null) {
          request.fields['madre_nombre'] = galloData['madre_nombre'].toString();
        }
        if (galloData['madre_codigo_identificacion'] != null) {
          request.fields['madre_codigo'] = galloData['madre_codigo_identificacion'].toString();
        }
        if (galloData['madre_fecha_nacimiento'] != null) {
          request.fields['madre_fecha_nacimiento'] = galloData['madre_fecha_nacimiento'].toString();
        }
        if (galloData['madre_color_placa'] != null) {
          request.fields['madre_color_placa'] = galloData['madre_color_placa'].toString();
        }
        if (galloData['madre_ubicacion_placa'] != null) {
          request.fields['madre_ubicacion_placa'] = galloData['madre_ubicacion_placa'].toString();
        }
      }
      
      print('📤 Enviando FormData al backend...');
      
      // ENVIAR REQUEST
      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
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
      print('❌ Error en createWithGenealogy: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  // ✏️ ACTUALIZAR GALLO CON EXPANSIÓN GENEALÓGICA
  static Future<Map<String, dynamic>> updateGalloWithExpansion(int galloId, Map<String, dynamic> galloData) async {
    print('✏️ GalloService.updateGalloWithExpansion() - Expandiendo genealogía...');
    
    try {
      final headers = await _getAuthHeaders();
      print('📡 URL: $_baseUrl/api/v1/gallos/$galloId');
      print('📤 Datos de expansión enviados: $galloData');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/api/v1/gallos/$galloId'),
        headers: headers,
        body: json.encode(galloData),
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Gallo actualizado exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al actualizar gallo',
        };
      }
      
    } catch (e) {
      print('❌ Error en updateGalloWithExpansion: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  // 📷 SUBIR FOTO DE GALLO - FUNCIONA CON File Y XFile
  static Future<Map<String, dynamic>> uploadGalloPhoto(int galloId, dynamic imageFile) async {
    print('📷 GalloService.uploadGalloPhoto() - Subiendo foto al gallo $galloId...');
    
    try {
      final headers = await _getAuthHeaders();
      headers.remove('Content-Type'); // MultipartFile maneja su propio content-type
      
      print('📡 URL: $_baseUrl/api/v1/gallos/$galloId/foto');
      
      // Crear MultipartRequest para tu endpoint de foto
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/gallos/$galloId/foto'),
      );
      
      // Agregar headers de autenticación
      request.headers.addAll(headers);
      
      // Agregar archivo de imagen según el tipo
      http.MultipartFile multipartFile;
      
      if (kIsWeb && imageFile is XFile) {
        // Para Web - usar XFile
        final bytes = await imageFile.readAsBytes();
        print('📷 Web - Nombre archivo: ${imageFile.name}');
        print('📷 Web - Tamaño bytes: ${bytes.length}');
        print('📷 Web - Path: ${imageFile.path}');
        
        multipartFile = http.MultipartFile.fromBytes(
          'foto',
          bytes,
          filename: imageFile.name ?? 'gallo_${galloId}_foto.jpg',
        );
        print('📱 Subiendo desde Web (XFile) - Filename: ${imageFile.name}');
      } else if (imageFile is File) {
        // Para Móvil - usar File
        print('📷 Móvil - Path: ${imageFile.path}');
        final exists = await imageFile.exists();
        print('📷 Móvil - Existe: $exists');
        
        multipartFile = await http.MultipartFile.fromPath(
          'foto',
          imageFile.path,
          filename: 'gallo_${galloId}_foto.jpg',
        );
        print('📱 Subiendo desde Móvil (File): ${imageFile.path}');
      } else {
        throw Exception('Tipo de archivo no soportado: ${imageFile.runtimeType}');
      }
      
      request.files.add(multipartFile);
      
      // AGREGAR descripción como tu API lo espera
      request.fields['descripcion'] = 'Foto del gallo subida desde Flutter';
      
      print('📤 Enviando foto al backend...');
      print('📤 Headers: ${request.headers}');
      print('📤 Fields: ${request.fields}');
      print('📤 Files: ${request.files.length}');
      
      // Enviar request
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Foto subida exitosamente: ${data['data']?['cloudinary']?['secure_url'] ?? 'URL no disponible'}');
        return {
          'success': true,
          'data': data,
          'foto_url': data['data']?['cloudinary']?['secure_url'],
          'message': data['message'] ?? 'Foto subida exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error del servidor: ${errorData['message']}');
        return {
          'success': false,
          'message': errorData['message'] ?? errorData['detail'] ?? 'Error al subir foto',
        };
      }
      
    } catch (e) {
      print('❌ Error en uploadGalloPhoto: $e');
      return {
        'success': false,
        'message': 'Error de conexión al subir foto: $e',
      };
    }
  }
}