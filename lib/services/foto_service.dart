// 📁 lib/services/foto_service.dart
// 📸 Servicio para gestión de fotos con Cloudinary

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'connection_service.dart';
import 'offline_queue_service.dart';

class FotoService {
  static const String _baseUrl = 'https://gallerappback-production.up.railway.app';
  static final ConnectionService _connectionService = ConnectionService();
  
  // 🔑 Obtener headers con JWT
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // 📸 SUBIR FOTO PRINCIPAL DEL GALLO
  static Future<Map<String, dynamic>> subirFotoPrincipal({
    required int galloId,
    required String imagePath,
  }) async {
    print('📸 Subiendo foto principal del gallo $galloId...');
    
    // Si estamos offline, guardar localmente
    if (_connectionService.isOffline) {
      print('📴 Modo offline - Guardando foto localmente...');
      
      await OfflineQueueService.encolarOperacion({
        'tipo': 'subir_foto',
        'galloId': galloId,
        'fotoPath': imagePath,
        'numeroFoto': 'principal',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Guardar referencia local
      await _guardarFotoLocal(galloId, imagePath, 'principal');
      
      return {
        'success': true,
        'offline': true,
        'message': 'Foto guardada localmente. Se subirá cuando haya conexión.',
        'local_path': imagePath,
      };
    }
    
    try {
      final headers = await _getAuthHeaders();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/gallos/$galloId/foto'),
      );
      
      request.headers.addAll(headers);
      
      // Agregar archivo
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw Exception('El archivo no existe');
      }
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          imagePath,
          filename: path.basename(imagePath),
        ),
      );
      
      print('📤 Enviando foto al servidor...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body.isNotEmpty ? json.decode(response.body) : {};
        print('✅ Foto subida exitosamente a Cloudinary');
        
        // Guardar URL en caché
        if (data['url'] != null) {
          await _guardarUrlFotoEnCache(galloId, data['url'], 'principal');
        }
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ Error del servidor: ${response.body}');
        throw Exception('Error al subir foto: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al subir foto: $e');
      rethrow;
    }
  }
  
  // 📸 SUBIR FOTO ADICIONAL (hasta 4 fotos)
  static Future<Map<String, dynamic>> subirFotoAdicional({
    required int galloId,
    required String imagePath,
    required int numeroFoto, // 1, 2, 3 o 4
  }) async {
    print('📸 Subiendo foto adicional #$numeroFoto del gallo $galloId...');
    
    if (numeroFoto < 1 || numeroFoto > 4) {
      throw Exception('Número de foto debe ser entre 1 y 4');
    }
    
    // Si estamos offline, guardar localmente
    if (_connectionService.isOffline) {
      print('📴 Modo offline - Guardando foto localmente...');
      
      await OfflineQueueService.encolarOperacion({
        'tipo': 'subir_foto',
        'galloId': galloId,
        'fotoPath': imagePath,
        'numeroFoto': numeroFoto,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await _guardarFotoLocal(galloId, imagePath, 'foto$numeroFoto');
      
      return {
        'success': true,
        'offline': true,
        'message': 'Foto guardada localmente. Se subirá cuando haya conexión.',
        'local_path': imagePath,
      };
    }
    
    // Lógica similar a subirFotoPrincipal pero con endpoint diferente
    try {
      final headers = await _getAuthHeaders();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/gallos/$galloId/foto'),
      );
      
      request.headers.addAll(headers);
      request.fields['numero'] = numeroFoto.toString();
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          imagePath,
          filename: path.basename(imagePath),
        ),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body.isNotEmpty ? json.decode(response.body) : {};
        print('✅ Foto adicional #$numeroFoto subida exitosamente');
        return {
          'success': true,
          'data': data,
        };
      } else {
        throw Exception('Error al subir foto: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al subir foto adicional: $e');
      rethrow;
    }
  }
  
  // 📸 MÉTODO ÉPICO PARA FORMULARIO - COPIA EXACTA DEL PERFIL
  static Future<String?> uploadGalloPhoto(dynamic imageFile, String galloCode) async {
    try {
      print('📸 FotoService: Subiendo foto del gallo $galloCode...');
      print('📁 Tipo de archivo: ${imageFile.runtimeType}');
      
      // 🎆 COPIA EXACTA DE ApiService.uploadAvatar() pero para gallos
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      final authHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      if (kIsWeb) {
        // 🌐 VERSIÓN WEB: Usar bytes (igual que perfil)
        print('🌐 Subiendo foto desde WEB...');
        
        final bytes = await (imageFile as XFile).readAsBytes();
        
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/api/v1/gallos/foto'), // 🔥 Endpoint de tu backend
        );
        
        request.headers.addAll({
          if (token != null) 'Authorization': 'Bearer $token',
        });
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // Nombre del campo que espera tu backend
            bytes,
            filename: 'gallo_${galloCode}.jpg',
          ),
        );
        
        print('📤 Enviando foto Web al backend...');
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        print('📡 Web response status: ${response.statusCode}');
        print('📄 Web response body: ${response.body}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          final imageUrl = data['foto_url'] ?? data['url'] ?? data['secure_url'];
          print('✅ Foto subida exitosamente desde WEB: $imageUrl');
          return imageUrl;
        } else {
          final error = json.decode(response.body);
          print('❌ Error Web: ${error['message']}');
          return null;
        }
      } else {
        // 📱 VERSIÓN MÓVIL: Usar path (igual que perfil)
        print('📱 Subiendo foto desde MÓVIL...');
        
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/api/v1/gallos/foto'), // 🔥 Endpoint de tu backend
        );
        
        request.headers.addAll({
          if (token != null) 'Authorization': 'Bearer $token',
        });
        
        final multipartFile = await http.MultipartFile.fromPath(
          'file',
          (imageFile as File).path,
          filename: 'gallo_${galloCode}.jpg',
        );
        request.files.add(multipartFile);
        
        print('📤 Enviando foto Móvil al backend...');
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        print('📡 Móvil response status: ${response.statusCode}');
        print('📄 Móvil response body: ${response.body}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          final imageUrl = data['foto_url'] ?? data['url'] ?? data['secure_url'];
          print('✅ Foto subida exitosamente desde MÓVIL: $imageUrl');
          return imageUrl;
        } else {
          final error = json.decode(response.body);
          print('❌ Error Móvil: ${error['message']}');
          return null;
        }
      }
      
    } catch (e) {
      print('❌ Error en uploadGalloPhoto: $e');
      return null;
    }
  }
  
  // 📸 OBTENER TODAS LAS FOTOS DE UN GALLO
  static Future<Map<String, dynamic>> obtenerFotos(int galloId) async {
    print('📸 Obteniendo fotos del gallo $galloId...');
    
    // Si estamos offline, obtener fotos locales
    if (_connectionService.isOffline) {
      print('📴 Modo offline - Obteniendo fotos locales...');
      return await _obtenerFotosLocales(galloId);
    }
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/gallos/$galloId/fotos'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Fotos obtenidas exitosamente');
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ Error al obtener fotos: ${response.statusCode}');
        return await _obtenerFotosLocales(galloId);
      }
    } catch (e) {
      print('❌ Error al obtener fotos: $e');
      return await _obtenerFotosLocales(galloId);
    }
  }
  
  // 🗑️ ELIMINAR FOTO
  static Future<bool> eliminarFoto(int galloId, int numeroFoto) async {
    print('🗑️ Eliminando foto #$numeroFoto del gallo $galloId...');
    
    if (_connectionService.isOffline) {
      print('📴 Modo offline - Encolando eliminación...');
      
      await OfflineQueueService.encolarOperacion({
        'tipo': 'eliminar_foto',
        'galloId': galloId,
        'numeroFoto': numeroFoto,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Eliminar referencia local
      await _eliminarFotoLocal(galloId, numeroFoto);
      
      return true;
    }
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/gallos/$galloId/fotos/$numeroFoto'),
        headers: headers,
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Foto eliminada exitosamente');
        return true;
      } else {
        print('❌ Error al eliminar foto: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error al eliminar foto: $e');
      return false;
    }
  }
  
  // 💾 MÉTODOS DE ALMACENAMIENTO LOCAL
  
  // Guardar referencia de foto local
  static Future<void> _guardarFotoLocal(int galloId, String imagePath, String tipo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'foto_local_${galloId}_$tipo';
      await prefs.setString(key, imagePath);
      print('💾 Foto guardada localmente: $key');
    } catch (e) {
      print('❌ Error al guardar foto local: $e');
    }
  }
  
  // Guardar URL de foto en caché
  static Future<void> _guardarUrlFotoEnCache(int galloId, String url, String tipo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'foto_url_${galloId}_$tipo';
      await prefs.setString(key, url);
      print('💾 URL de foto guardada en caché: $key');
    } catch (e) {
      print('❌ Error al guardar URL en caché: $e');
    }
  }
  
  // Obtener fotos locales
  static Future<Map<String, dynamic>> _obtenerFotosLocales(int galloId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fotos = <String, String?>{};
      
      // Buscar foto principal
      fotos['principal'] = prefs.getString('foto_local_${galloId}_principal') ??
                          prefs.getString('foto_url_${galloId}_principal');
      
      // Buscar fotos adicionales
      for (int i = 1; i <= 4; i++) {
        fotos['foto$i'] = prefs.getString('foto_local_${galloId}_foto$i') ??
                          prefs.getString('foto_url_${galloId}_foto$i');
      }
      
      return {
        'success': true,
        'offline': true,
        'data': fotos,
      };
    } catch (e) {
      print('❌ Error al obtener fotos locales: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Eliminar foto local
  static Future<void> _eliminarFotoLocal(int galloId, int numeroFoto) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tipo = numeroFoto == 0 ? 'principal' : 'foto$numeroFoto';
      final key = 'foto_local_${galloId}_$tipo';
      await prefs.remove(key);
      print('🗑️ Foto local eliminada: $key');
    } catch (e) {
      print('❌ Error al eliminar foto local: $e');
    }
  }
  
  // 🧹 Limpiar caché de fotos antiguas
  static Future<void> limpiarCacheFotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int eliminadas = 0;
      
      for (var key in keys) {
        if (key.startsWith('foto_local_') || key.startsWith('foto_url_')) {
          await prefs.remove(key);
          eliminadas++;
        }
      }
      
      print('🧹 Caché de fotos limpiado. Eliminadas: $eliminadas');
    } catch (e) {
      print('❌ Error al limpiar caché de fotos: $e');
    }
  }
}