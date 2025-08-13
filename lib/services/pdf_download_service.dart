// 📥🔥 SERVICIO ÉPICO PARA DESCARGAR PDFs EN FLUTTER WEB
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Solo importar para web
import 'package:universal_html/html.dart' as html;

class PDFDownloadService {
  /// 📥 DESCARGAR PDF DESDE BASE64 EN FLUTTER WEB
  static void downloadPDFFromBase64(String pdfBase64, String fileName) {
    try {
      print('📥 === INICIANDO DESCARGA PDF ===');
      print('📄 Archivo: $fileName');
      print('📊 Base64 length: ${pdfBase64.length} chars');
      
      if (kIsWeb) {
        // 🌐 DESCARGA PARA FLUTTER WEB
        _downloadForWeb(pdfBase64, fileName);
      } else {
        // 📱 PARA MÓVIL (FUTURO)
        print('📱 Descarga móvil no implementada aún');
        // TODO: Implementar para móvil con path_provider
      }
      
    } catch (e) {
      print('❌ Error descargando PDF: $e');
    }
  }
  
  /// 🌐 DESCARGA ESPECÍFICA PARA WEB
  static void _downloadForWeb(String pdfBase64, String fileName) {
    try {
      print('🌐 Procesando descarga para Flutter Web...');
      
      // Convertir base64 a bytes
      final bytes = base64Decode(pdfBase64);
      print('✅ PDF decodificado: ${bytes.length} bytes');
      
      // Crear blob
      final blob = html.Blob([bytes], 'application/pdf');
      print('✅ Blob creado exitosamente');
      
      // Crear URL de descarga
      final url = html.Url.createObjectUrlFromBlob(blob);
      print('✅ URL de descarga creada: ${url.substring(0, 50)}...');
      
      // Crear elemento anchor para descarga
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      
      // Agregar al DOM y simular click
      html.document.body!.children.add(anchor);
      print('✅ Anchor agregado al DOM');
      
      // Simular click para iniciar descarga
      anchor.click();
      print('✅ Click simulado - Iniciando descarga...');
      
      // Limpiar después de un tiempo
      Future.delayed(const Duration(seconds: 2), () {
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        print('✅ Limpieza completada');
      });
      
      print('🎉 === DESCARGA INICIADA EXITOSAMENTE ===');
      
    } catch (e) {
      print('❌ Error en descarga web: $e');
      rethrow;
    }
  }
  
  /// 📱 DESCARGA PARA MÓVIL (FUTURO)
  static Future<void> _downloadForMobile(String pdfBase64, String fileName) async {
    // TODO: Implementar con path_provider y File.writeAsBytes
    print('📱 Descarga móvil no implementada');
  }
  
  /// 🧪 TEST DE DESCARGA
  static void testDownload() {
    try {
      print('🧪 Testing PDF download...');
      
      // Crear PDF simple de prueba
      const testBase64 = 'JVBERi0xLjQKMSAwIG9iago8PAovVHlwZSAvQ2F0YWxvZwovUGFnZXMgMiAwIFIKPj4KZW5kb2JqCjIgMCBvYmoKPDwKL1R5cGUgL1BhZ2VzCi9LaWRzIFszIDAgUl0KL0NvdW50IDEKPD4KZW5kb2JqCjMgMCBvYmoKPDwKL1R5cGUgL1BhZ2UKL1BhcmVudCAyIDAgUgovTWVkaWFCb3ggWzAgMCA2MTIgNzkyXQovUmVzb3VyY2VzIDw8Ci9Gb250IDw8Ci9GMSA0IDAgUgo+Pgo+PgovQ29udGVudHMgNSAwIFIKPj4KZW5kb2JqCjQgMCBvYmoKPDwKL1R5cGUgL0ZvbnQKL1N1YnR5cGUgL1R5cGUxCi9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2JqCjUgMCBvYmoKPDwKL0xlbmd0aCA0NAo+PgpzdHJlYW0KQlQKL0YxIDEyIFRmCjEwMCA3MDAgVGQKKEhlbGxvIFdvcmxkKSBUagpFVApzdHJlYW0KZW5kb2JqCnhyZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDAwOSAwMDAwMCBuIAowMDAwMDAwMDU4IDAwMDAwIG4gCjAwMDAwMDAxMTUgMDAwMDAgbiAKMDAwMDAwMDI0NSAwMDAwMCBuIAowMDAwMDAwMzIyIDAwMDAwIG4gCnRyYWlsZXIKPDwKL1NpemUgNgovUm9vdCAxIDAgUgo+PgpzdGFydHhyZWYKNDE0CiUlRU9G';
      
      downloadPDFFromBase64(testBase64, 'test_pdf.pdf');
      
    } catch (e) {
      print('❌ Error en test: $e');
    }
  }
}