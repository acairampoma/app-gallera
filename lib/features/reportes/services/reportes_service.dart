// 📊🐓 SERVICIO ÉPICO PARA REPORTES - CONEXIÓN REAL CON API
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../shared/services/api_service.dart';

class ReportesService {
  static final ReportesService _instance = ReportesService._internal();
  factory ReportesService() => _instance;
  ReportesService._internal();

  final ApiService _apiService = ApiService();

  // 📊 OBTENER DASHBOARD CON FILTROS
  Future<Map<String, dynamic>> getDashboard({
    int? ano,
    int? mes,
  }) async {
    try {
      print('🔥 Obteniendo dashboard ano: $ano, mes: $mes');

      // Construir URL con parámetros
      String url = '${ApiConfig.baseUrl}/api/v1/reportes/dashboard';
      List<String> params = [];
      
      if (ano != null) params.add('ano=$ano');
      if (mes != null) params.add('mes=$mes');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('📡 URL completa: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await _apiService.headers,
      ).timeout(const Duration(seconds: 30));

      print('📊 Dashboard response status: ${response.statusCode}');
      print('📊 Dashboard response body (primeros 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('✅ Dashboard JSON parseado exitosamente');
        print('🔍 Keys principales: ${data.keys.toList()}');
        
        // Verificar estructura crítica
        if (data['resumen_periodo'] != null) {
          print('📊 resumen_periodo keys: ${(data['resumen_periodo'] as Map).keys.toList()}');
          print('📊 total_gallos value: ${data['resumen_periodo']['total_gallos']} (${data['resumen_periodo']['total_gallos'].runtimeType})');
        } else {
          print('⚠️ resumen_periodo es NULL!');
        }
        
        return data;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo dashboard: $e');
      rethrow;
    }
  }

  // 🏆 OBTENER RANKINGS CON FILTROS
  Future<Map<String, dynamic>> getRankings({
    required String tipo, // gallos, padrillos, madres
    int? ano,
    int? mes,
    int limite = 10,
  }) async {
    try {
      print('🏆 Obteniendo rankings tipo: $tipo');

      // Construir URL con parámetros
      String url = '${ApiConfig.baseUrl}/api/v1/reportes/rankings';
      List<String> params = ['tipo=$tipo', 'limite=$limite'];
      
      if (ano != null) params.add('ano=$ano');
      if (mes != null) params.add('mes=$mes');
      
      url += '?${params.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: await _apiService.headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('✅ Rankings cargados');
        
        return data;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo rankings: $e');
      rethrow;
    }
  }

  // 📅 OBTENER PERÍODOS DISPONIBLES
  Future<Map<String, dynamic>> getPeriodosDisponibles() async {
    try {
      print('📅 Obteniendo períodos disponibles');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/reportes/periodos-disponibles'),
        headers: await _apiService.headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('✅ Períodos cargados');
        
        return data;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo períodos: $e');
      rethrow;
    }
  }

  // 🐓 OBTENER FICHA COMPLETA DE GALLO
  Future<Map<String, dynamic>> getFichaCompleta(int galloId) async {
    try {
      print('🐓 Obteniendo ficha completa galloId: $galloId');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/reportes/gallo/$galloId/ficha-completa'),
        headers: await _apiService.headers,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('✅ Ficha completa obtenida');
        
        return data;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo ficha completa: $e');
      rethrow;
    }
  }

  // 🧪 TEST DE CONEXIÓN
  Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🧪 Testing conexión reportes');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/reportes/test'),
        headers: await _apiService.headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Test exitoso: ${data['mensaje']}');
        return data;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en test: $e');
      rethrow;
    }
  }

  // 📤 EXPORTAR REPORTE (FUTURO)
  Future<String> exportarReporte({
    required String tipo, // pdf, excel
    required String template, // financiero, operativo
    Map<String, dynamic>? filtros,
  }) async {
    try {
      print('📤 Exportando reporte tipo: $tipo');

      final body = {
        'tipo': tipo,
        'template': template,
        'filtros': filtros ?? {},
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/reportes/exportar'),
        headers: await _apiService.headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 60)); // Más tiempo para generar PDF

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final downloadUrl = data['download_url'];
        
        print('✅ Reporte exportado');
        
        return downloadUrl;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error exportando reporte: $e');
      rethrow;
    }
  }

  // 🗓️ HELPER: OBTENER NOMBRE DEL MES
  static String getNombreMes(int mes) {
    const meses = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return mes >= 1 && mes <= 12 ? meses[mes] : 'Mes $mes';
  }

  // 📊 HELPER: FORMATEAR MONEDA
  static String formatearMoneda(double valor) {
    if (valor >= 1000000) {
      return 'S/ ${(valor / 1000000).toStringAsFixed(1)}M';
    } else if (valor >= 1000) {
      return 'S/ ${(valor / 1000).toStringAsFixed(1)}K';
    } else {
      return 'S/ ${valor.toStringAsFixed(0)}';
    }
  }

  // 🎨 HELPER: COLOR POR EFECTIVIDAD
  static Color getColorPorEfectividad(double efectividad) {
    if (efectividad >= 80) return const Color(0xFF4CAF50); // Verde
    if (efectividad >= 60) return const Color(0xFFFF9800); // Naranja  
    if (efectividad >= 40) return const Color(0xFFFFC107); // Amarillo
    return const Color(0xFFF44336); // Rojo
  }

  // 📄🐓 EXPORTAR FICHA DE GALLO A PDF
  Future<Map<String, dynamic>> exportarFichaGallo(int galloId) async {
    try {
      print('📄 === EXPORTANDO FICHA DE GALLO ===');
      print('🐓 Gallo ID: $galloId');
      
      // Construir URL
      String url = '${ApiConfig.baseUrl}/api/v1/gallos/$galloId/exportar-ficha';
      
      print('📡 URL: $url');
      print('🔑 Obteniendo headers de autenticación...');
      
      final headers = await _apiService.headers;
      
      print('📤 Enviando petición POST...');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      print('📊 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('✅ Ficha exportada exitosamente');
        print('📋 Datos recibidos:');
        print('   - Gallo: ${data['data']['gallo']['nombre']}');
        print('   - Estadísticas: ${data['data']['estadisticas']}');
        print('   - PDF URL: ${data['pdf_url'] ?? "No generado aún"}');
        print('   - PDF Disponible: ${data['pdf_available'] ?? false}');
        print('   - PDF Base64: ${data['pdf_base64'] != null ? "SÍ (${data['pdf_base64'].toString().length} chars)" : "NO"}');
        
        return data;
      } else if (response.statusCode == 404) {
        print('❌ Gallo no encontrado');
        throw Exception('Gallo no encontrado');
      } else if (response.statusCode == 401) {
        print('❌ No autorizado');
        throw Exception('No tienes permisos para exportar esta ficha');
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Error exportando ficha: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error exportando ficha de gallo: $e');
      rethrow;
    }
  }

  // 📥🔥 DESCARGAR PDF DIRECTO
  Future<List<int>?> descargarPDFDirecto(int galloId) async {
    try {
      print('📥 === DESCARGANDO PDF DIRECTO ===');
      print('🐓 Gallo ID: $galloId');
      
      // Construir URL para descarga directa
      String url = '${ApiConfig.baseUrl}/api/v1/gallos/$galloId/descargar-pdf';
      
      print('📡 URL descarga: $url');
      print('🔑 Obteniendo headers...');
      
      final headers = await _apiService.headers;
      
      print('📤 Enviando petición GET para PDF...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 60)); // Más tiempo para PDFs
      
      print('📊 Status: ${response.statusCode}');
      print('📄 Content-Type: ${response.headers['content-type']}');
      
      if (response.statusCode == 200) {
        final pdfBytes = response.bodyBytes;
        
        print('✅ PDF descargado exitosamente');
        print('📄 Tamaño PDF: ${pdfBytes.length} bytes');
        
        return pdfBytes;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error descargando PDF directo: $e');
      return null;
    }
  }

  // 💾 GUARDAR PDF DESDE BASE64
  Future<bool> guardarPDFDesdeBase64(String pdfBase64, String nombreArchivo) async {
    try {
      print('💾 Guardando PDF desde base64...');
      print('📄 Nombre archivo: $nombreArchivo');
      print('📊 Tamaño base64: ${pdfBase64.length} chars');
      
      // En Flutter web esto se manejará diferente que en móvil
      // Por ahora solo confirmamos que recibimos el PDF
      
      // TODO: Implementar descarga real según plataforma
      // - Web: usar html.AnchorElement con download
      // - Móvil: usar path_provider + File.writeAsBytes
      
      print('✅ PDF base64 procesado correctamente');
      return true;
      
    } catch (e) {
      print('❌ Error guardando PDF: $e');
      return false;
    }
  }
}