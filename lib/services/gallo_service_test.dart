// 📁 lib/services/gallo_service_test.dart
// 🧪 Servicio de prueba para verificar conexión con backend

import 'dart:convert';
import 'package:http/http.dart' as http;

class GalloServiceTest {
  static const String _baseUrl = 'https://gallerappback-production.up.railway.app';
  
  // 🧪 PROBAR CONEXIÓN BÁSICA
  static Future<void> testConnection() async {
    print('\n🧪 === INICIANDO PRUEBA DE CONEXIÓN ===\n');
    
    // 1. Probar endpoint de health
    try {
      print('1️⃣ Probando /health...');
      final healthResponse = await http.get(
        Uri.parse('$_baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      print('   ✅ Status: ${healthResponse.statusCode}');
      print('   ✅ Body: ${healthResponse.body}');
    } catch (e) {
      print('   ❌ Error: $e');
    }
    
    // 2. Probar endpoint de gallos SIN autenticación
    try {
      print('\n2️⃣ Probando /api/v1/gallos SIN token...');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/gallos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      print('   📡 Status: ${response.statusCode}');
      print('   📡 Headers: ${response.headers}');
      
      if (response.statusCode == 401) {
        print('   ⚠️ Requiere autenticación (esperado)');
      } else if (response.statusCode == 200) {
        print('   ✅ No requiere autenticación!');
        final data = json.decode(response.body);
        print('   ✅ Gallos recibidos: ${data.length}');
      }
    } catch (e) {
      print('   ❌ Error: $e');
    }
    
    // 3. Probar con token falso
    try {
      print('\n3️⃣ Probando /api/v1/gallos CON token falso...');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/gallos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer token_falso_123',
        },
      ).timeout(const Duration(seconds: 5));
      
      print('   📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 401) {
        print('   ✅ Token rechazado correctamente');
      }
    } catch (e) {
      print('   ❌ Error: $e');
    }
    
    print('\n🧪 === FIN DE PRUEBAS ===\n');
  }
  
  // 🧪 LISTAR GALLOS SIMPLE (sin ConnectionService)
  static Future<List<Map<String, dynamic>>> getGallosSimple() async {
    print('🧪 getGallosSimple() - Conectando directamente...');
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/gallos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final gallosList = List<Map<String, dynamic>>.from(data);
        print('✅ Gallos obtenidos: ${gallosList.length}');
        return gallosList;
      } else if (response.statusCode == 401) {
        print('⚠️ Necesitas hacer login primero');
        throw Exception('No autenticado. Por favor inicia sesión.');
      } else {
        print('❌ Error del servidor: ${response.statusCode}');
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      throw e;
    }
  }
}