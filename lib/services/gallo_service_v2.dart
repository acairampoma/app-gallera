// 📁 lib/services/gallo_service_v2.dart
// 🔥 GALLO SERVICE V2 COMPACTO - SOLO 50 LÍNEAS ÉPICAS
// Integración directa con tu backend Railway probado

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../config/constants.dart';

class GalloServiceV2 {
  static const String baseUrl = 'https://gallerappback-production.up.railway.app';

  // 🔥 MÉTODO ÉPICO PRINCIPAL - CREAR GALLO CON GENEALOGÍA
  static Future<Map<String, dynamic>> createGalloConGenealogiaEpico({
    required Map<String, dynamic> galloData,
    dynamic foto, // File o XFile
  }) async {
    try {
      print('🚀 Iniciando creación épica con genealogía...');
      
      // 1. Crear MultipartRequest
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/v1/gallos/con-pedigri'));
      
      // 2. Agregar JWT token
      final token = await _getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        print('🔑 Token JWT agregado');
      } else {
        print('⚠️ No se encontró token JWT');
      }
      
      // 3. Mapear datos al formato backend
      _buildFormDataEpico(request, galloData);
      
      // 4. Agregar foto si existe
      if (foto != null) {
        print('📸 Procesando foto...');
        await _addFotoToRequest(request, foto);
      } else {
        print('📸 No hay foto para subir');
      }
      
      print('📦 Request preparado - Fields: ${request.fields.length}, Files: ${request.files.length}');
      
      // 5. Enviar request
      final streamedResponse = await request.send().timeout(Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Response: ${response.statusCode} - ${response.body}');
      
      // 6. Procesar respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Éxito - Gallo creado con genealogía');
        return {'success': true, 'data': data, 'message': '🎉 Gallo creado exitosamente!'};
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error del servidor: ${errorData['message'] ?? 'Error desconocido'}');
        return {'success': false, 'message': errorData['message'] ?? 'Error del servidor'};
      }
      
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // 🔥 MÉTODO ÉPICO - ACTUALIZAR GALLO CON EXPANSIÓN GENEALÓGICA
  static Future<Map<String, dynamic>> updateGalloConExpansionEpico({
    required int galloId,
    required Map<String, dynamic> galloData,
    dynamic foto, // File o XFile - NUEVA FOTO (opcional)
  }) async {
    try {
      print('✏️ Iniciando actualización épica con expansión genealógica...');
      
      // 1. Crear MultipartRequest para PUT
      final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/v1/gallos/$galloId'));
      
      // 2. Agregar JWT token
      final token = await _getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        print('🔑 Token JWT agregado');
      } else {
        print('⚠️ No se encontró token JWT');
      }
      
      // 3. Mapear datos actualizados al formato backend
      _buildFormDataEpico(request, galloData);
      
      // 4. Agregar nueva foto si existe
      if (foto != null) {
        print('📸 Procesando nueva foto...');
        await _addFotoToRequest(request, foto);
      } else {
        print('📸 No hay nueva foto para subir');
      }
      
      print('📦 Update request preparado - Fields: ${request.fields.length}, Files: ${request.files.length}');
    print('🔍 DEBUG - Campos enviados al backend:');
    request.fields.forEach((key, value) {
      print('  $key: $value');
    });
      
      // 5. Enviar request
      final streamedResponse = await request.send().timeout(Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Response: ${response.statusCode} - ${response.body}');
      
      // 6. Procesar respuesta
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Éxito - Gallo actualizado con expansión genealógica');
        return {'success': true, 'data': data, 'message': '🎉 Gallo actualizado exitosamente!'};
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error del servidor: ${errorData['message'] ?? 'Error desconocido'}');
        return {'success': false, 'message': errorData['message'] ?? 'Error del servidor'};
      }
      
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // 🔑 Helper: Obtener JWT Token
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // 📤 Helper: Construir FormData según backend
  static void _buildFormDataEpico(http.MultipartRequest request, Map<String, dynamic> data) {
    // 🔍 DEBUG: Ver datos de entrada
    print('📊 === DEBUG _buildFormDataEpico ===');
    print('📝 Datos recibidos: ${data.keys.toList()}');
    data.forEach((key, value) {
      print('  $key: $value (${value.runtimeType})');
    });
    
    // OBLIGATORIOS
    request.fields['nombre'] = data['nombre']?.toString() ?? '';
    request.fields['codigo_identificacion'] = data['codigo_identificacion']?.toString() ?? 
        'AUTO_${DateTime.now().millisecondsSinceEpoch}';
    
    // OPCIONALES - Solo agregar si tienen valor
    final optionalFields = {
      'fecha_nacimiento': data['fecha_nacimiento'] is DateTime 
          ? (data['fecha_nacimiento'] as DateTime).toIso8601String().split('T')[0]
          : data['fecha_nacimiento']?.toString(),
      'peso': data['peso']?.toString(),
      'altura': data['altura']?.toString(),
      'color': data['color']?.toString(),
      'raza_id': data['raza_id']?.toString(), // 🔥 CORREGIDO: Enviar raza_id, no raza
      'color_patas': data['color_patas']?.toString(),
      'color_plumaje': data['color_plumaje']?.toString(), // Agregado campo faltante
      'color_placa': data['color_placa']?.toString(),
      'ubicacion_placa': data['ubicacion_placa']?.toString(),
      'criador': data['criador']?.toString(),
      'propietario_actual': data['propietario_actual']?.toString(),
      'observaciones': data['observaciones']?.toString(),
      'notas': data['notas']?.toString(),
      'estado': 'activo',
    };

    // 🔍 DEBUG: Ver campos antes de agregar
    print('🔍 === OPCIONAL FIELDS DEBUG ===');
    optionalFields.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        print('  ✅ $key: $value (agregando)');
        request.fields[key] = value;
      } else {
        print('  ❌ $key: $value (omitiendo)');
      }
    });

    // GENEALOGÍA
    request.fields['crear_padre'] = (data['crear_padre'] == true).toString();
    request.fields['crear_madre'] = (data['crear_madre'] == true).toString();
    
    if (data['crear_padre'] == true && data['padre_nombre']?.toString().isNotEmpty == true) {
      request.fields['padre_nombre'] = data['padre_nombre'].toString();
      if (data['padre_codigo']?.toString().isNotEmpty == true) {
        request.fields['padre_codigo'] = data['padre_codigo'].toString();
      }
      if (data['padre_fecha_nacimiento'] != null) {
        request.fields['padre_fecha_nacimiento'] = data['padre_fecha_nacimiento'] is DateTime
            ? (data['padre_fecha_nacimiento'] as DateTime).toIso8601String().split('T')[0]
            : data['padre_fecha_nacimiento'].toString();
      }
    }
    
    if (data['crear_madre'] == true && data['madre_nombre']?.toString().isNotEmpty == true) {
      request.fields['madre_nombre'] = data['madre_nombre'].toString();
      if (data['madre_codigo']?.toString().isNotEmpty == true) {
        request.fields['madre_codigo'] = data['madre_codigo'].toString();
      }
      if (data['madre_fecha_nacimiento'] != null) {
        request.fields['madre_fecha_nacimiento'] = data['madre_fecha_nacimiento'] is DateTime
            ? (data['madre_fecha_nacimiento'] as DateTime).toIso8601String().split('T')[0]
            : data['madre_fecha_nacimiento'].toString();
      }
    }
    
    // 🔍 DEBUG FINAL: Campos que se van a enviar
    print('🚀 === CAMPOS FINALES AL BACKEND ===');
    request.fields.forEach((key, value) {
      if (key == 'raza_id') {
        print('  🔥 $key: $value (¡CAMPO PROBLEMA!)');
      } else {
        print('  🔑 $key: $value');
      }
    });
    print('==========================================');
  }

  // 📸 Helper: Agregar foto al request
  static Future<void> _addFotoToRequest(http.MultipartRequest request, dynamic foto) async {
    try {
      if (kIsWeb && foto is XFile) {
        // WEB - XFile (blob URL)
        final bytes = await foto.readAsBytes();
        
        // MÚLTIPLES INTENTOS DE CAMPOS PARA WEB
        request.files.add(http.MultipartFile.fromBytes(
          'foto_principal', // Campo principal
          bytes, 
          filename: foto.name ?? 'gallo_web.jpg',
        ));
        
        // TAMBIÉN INTENTAR CON OTROS NOMBRES DE CAMPO
        request.files.add(http.MultipartFile.fromBytes(
          'file', // Campo alternativo 1
          bytes, 
          filename: foto.name ?? 'gallo_web.jpg',
        ));
        
        request.files.add(http.MultipartFile.fromBytes(
          'foto', // Campo alternativo 2
          bytes, 
          filename: foto.name ?? 'gallo_web.jpg',
        ));
        
        request.files.add(http.MultipartFile.fromBytes(
          'image', // Campo alternativo 3
          bytes, 
          filename: foto.name ?? 'gallo_web.jpg',
        ));
        
        print('📸 Foto WEB agregada: ${foto.name} (${bytes.length} bytes)');
        print('📸 Intentando múltiples campos: foto_principal, file, foto, image');
        
      } else if (foto is File) {
        // MÓVIL - File path
        request.files.add(await http.MultipartFile.fromPath(
          'foto_principal', // Campo exacto del backend
          foto.path,
          filename: 'gallo_mobile.jpg'
        ));
        print('📸 Foto MÓVIL agregada: ${foto.path}');
      }
      
      print('✅ Foto agregada al request - Total archivos: ${request.files.length}');
      
    } catch (e) {
      print('⚠️ Error agregando foto: $e');
      // No bloquear la creación si falla la foto
    }
  }
}
