// 💰 Servicio para gestionar inversiones (gastos mensuales)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InversionService {
  // 🌐 URL BASE - COPIADA DEL PAGO_SERVICE QUE FUNCIONA
  static const String baseUrl = 'https://gallerappback-production.up.railway.app';
  
  // 🔑 Headers con JWT token - COPIADA DEL PAGO_SERVICE QUE FUNCIONA
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 📊 Obtener inversiones de un mes específico
  static Future<Map<String, double>> obtenerInversiones(int anio, int mes) async {
    try {
      final headers = await _getAuthHeaders();

      // 🔍 URL CORRECTA con query parameters encoded
      final url = Uri.parse('$baseUrl/api/v1/inversiones/?a%C3%B1o=${anio}&mes=${mes}');

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📋 Datos recibidos del API: $data');
        
        // Convertir respuesta del API a Map<String, double>
        final Map<String, double> inversiones = {};
        if (data is List) {
          if (data.isEmpty) {
            print('🔍 Lista vacía - no hay inversiones para este mes');
            return {};
          }
          
          print('📋 Procesando ${data.length} inversiones...');
          
          for (final item in data) {
            if (item['tipo_gasto'] != null && item['costo'] != null) {
              // 🔧 PARSING ROBUSTO - El API devuelve strings "550.00"
              final String tipoGasto = item['tipo_gasto'].toString();
              final String costoString = item['costo'].toString();
              final double costo = double.tryParse(costoString) ?? 0.0;
              
              inversiones[tipoGasto] = costo;
              print('📊 Parseado: $tipoGasto = S/. $costo');
            }
          }
        }
        
        print('🎉 Inversiones finales parseadas: $inversiones');
        return inversiones;
      } else if (response.statusCode == 404) {
        // No hay datos para este mes - retornar vacío
        return {};
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo inversiones: $e');
      throw Exception('Error obteniendo inversiones: $e');
    }
  }

  // 💾 Guardar inversiones del mes - ESTRATEGIA 1: REQUESTS EN PARALELO 🚀
  static Future<bool> guardarInversiones(
    int anio,
    int mes,
    Map<String, double> inversiones,
  ) async {
    try {
      // 🔑 OBTENER HEADERS - COPIADO DEL PAGO_SERVICE QUE FUNCIONA
      final headers = await _getAuthHeaders();
      print('🔑 Headers: $headers');

      // 🚀 CREAR LISTA DE REQUESTS EN PARALELO
      final List<Future<http.Response>> requests = [];
      
      print('🚀 Preparando requests para ${inversiones.length} tipos de gasto...');
      
      inversiones.forEach((tipoGasto, costo) {
        if (costo > 0) {
          final payload = {
            'año': anio,
            'mes': mes,
            'tipo_gasto': tipoGasto,  // ← UNO POR VEZ
            'costo': costo,
          };
          
          print('📤 Preparando request para $tipoGasto: S/. $costo');
          print('📦 Payload: $payload');
          
          // Crear request individual - CON SLASH FINAL como en las pruebas
          final request = http.post(
            Uri.parse('$baseUrl/api/v1/inversiones/'),
            headers: headers,
            body: json.encode(payload),
          );
          requests.add(request);
        }
      });

      // Si no hay inversiones, no enviar nada
      if (requests.isEmpty) {
        print('ℹ️ No hay inversiones para guardar');
        return true;
      }

      print('⚡ Enviando ${requests.length} requests en paralelo...');
      
      // ⚡ ENVIAR TODAS EN PARALELO
      final responses = await Future.wait(requests);
      
      print('📥 Recibidas ${responses.length} respuestas');
      
      // ✅ VALIDAR TODAS LAS RESPUESTAS
      for (int i = 0; i < responses.length; i++) {
        final response = responses[i];
        print('📋 Respuesta ${i + 1}: Status ${response.statusCode}');
        print('📋 Body ${i + 1}: ${response.body}');
        
        if (response.statusCode != 200 && response.statusCode != 201) {
          print('❌ Error en request ${i + 1}: Status ${response.statusCode}');
          print('❌ Error body: ${response.body}');
          
          try {
            final errorData = json.decode(response.body);
            throw Exception('Error en request ${i + 1}: ${errorData['detail'] ?? response.body}');
          } catch (jsonError) {
            throw Exception('Error en request ${i + 1}: ${response.body}');
          }
        } else {
          print('✅ Request ${i + 1} exitoso');
        }
      }
      
      print('✅ Todas las inversiones guardadas exitosamente');
      return true;
      
    } catch (e) {
      print('❌ Error guardando inversiones: $e');
      throw Exception('Error guardando inversiones: $e');
    }
  }

  // 📈 Obtener resumen de inversiones por año
  static Future<Map<String, dynamic>> obtenerResumenAnual(int anio) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/inversiones/resumen/$anio'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // No hay datos para este año
        return {
          'total_anual': 0.0,
          'meses': [],
          'por_tipo': {
            'alimento': 0.0,
            'medicina': 0.0,
            'limpieza_galpon': 0.0,
            'entrenador': 0.0,
          }
        };
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo resumen anual: $e');
      throw Exception('Error obteniendo resumen anual: $e');
    }
  }
}