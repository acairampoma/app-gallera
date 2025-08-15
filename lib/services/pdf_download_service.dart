// 📥🔥 SERVICIO ÉPICO PARA DESCARGAR PDFs EN FLUTTER WEB Y MÓVIL
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Para web
import 'package:universal_html/html.dart' as html;

// Para móvil
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFDownloadService {
  /// 📥 DESCARGAR PDF DESDE BASE64 EN FLUTTER WEB Y MÓVIL
  static Future<void> downloadPDFFromBase64(String pdfBase64, String fileName, {BuildContext? context}) async {
    try {
      print('📥 === INICIANDO DESCARGA PDF ===');
      print('📄 Archivo: $fileName');
      print('📊 Base64 length: ${pdfBase64.length} chars');
      print('🔍 Plataforma: ${kIsWeb ? "WEB" : "MÓVIL"}');
      
      if (kIsWeb) {
        // 🌐 DESCARGA PARA FLUTTER WEB
        _downloadForWeb(pdfBase64, fileName);
      } else {
        // 📱 DESCARGA PARA MÓVIL
        await _downloadForMobile(pdfBase64, fileName, context: context);
      }
      
    } catch (e) {
      print('❌ Error descargando PDF: $e');
      rethrow;
    }
  }
  
  /// 🌐 DESCARGA ESPECÍFICA PARA WEB CON APERTURA AUTOMÁTICA
  static void _downloadForWeb(String pdfBase64, String fileName) {
    try {
      print('🌐 Procesando descarga para Flutter Web...');
      
      // Convertir base64 a bytes
      final bytes = base64Decode(pdfBase64);
      print('✅ PDF decodificado: ${bytes.length} bytes');
      
      // Crear blob con tipo MIME correcto
      final blob = html.Blob([bytes], 'application/pdf');
      print('✅ Blob creado exitosamente');
      
      // Crear URL del blob
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);
      print('✅ URL de blob creada: ${blobUrl.substring(0, 50)}...');
      
      // 🔥 ESTRATEGIA DUAL: ABRIR EN NUEVA TAB + DESCARGA
      
      // 1. Abrir PDF en nueva pestaña del navegador
      final newWindow = html.window.open(blobUrl, '_blank');
      if (newWindow != null) {
        print('✅ PDF abierto en nueva pestaña del navegador');
      } else {
        print('⚠️ Popup bloqueado, usando descarga directa');
      }
      
      // 2. También ofrecer descarga directa como fallback
      final anchor = html.AnchorElement(href: blobUrl)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      
      // Agregar al DOM
      html.document.body!.children.add(anchor);
      
      // Simular click para descarga (solo si la nueva pestaña falló)
      if (newWindow == null) {
        anchor.click();
        print('✅ Descarga directa iniciada como fallback');
      }
      
      // Limpiar después de un tiempo
      Future.delayed(const Duration(seconds: 5), () {
        try {
          html.document.body!.children.remove(anchor);
          html.Url.revokeObjectUrl(blobUrl);
          print('✅ Limpieza completada');
        } catch (e) {
          print('⚠️ Error en limpieza: $e');
        }
      });
      
      print('🎉 === PDF ABIERTO/DESCARGADO EXITOSAMENTE ===');
      
    } catch (e) {
      print('❌ Error en descarga web: $e');
      rethrow;
    }
  }
  
  /// 📱 DESCARGA ESPECÍFICA PARA MÓVIL
  static Future<void> _downloadForMobile(String pdfBase64, String fileName, {BuildContext? context}) async {
    try {
      print('📱 Procesando descarga para móvil...');
      
      // Solicitar permisos de almacenamiento
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        print('❌ Permisos de almacenamiento denegados');
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Se necesitan permisos de almacenamiento para descargar el PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Convertir base64 a bytes
      final bytes = base64Decode(pdfBase64);
      print('✅ PDF decodificado: ${bytes.length} bytes');
      
      // Obtener directorio de descarga
      Directory? directory;
      
      if (Platform.isAndroid) {
        // En Android, intentar usar Downloads
        try {
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Navegar a Downloads si es posible
            final downloadsPath = '/storage/emulated/0/Download';
            final downloadsDir = Directory(downloadsPath);
            if (await downloadsDir.exists()) {
              directory = downloadsDir;
              print('📂 Usando directorio Downloads: ${directory.path}');
            } else {
              print('📂 Usando directorio externo: ${directory.path}');
            }
          }
        } catch (e) {
          print('⚠️ Error accediendo directorio externo: $e');
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        // iOS u otras plataformas
        directory = await getApplicationDocumentsDirectory();
        print('📂 Usando directorio documentos: ${directory.path}');
      }
      
      if (directory == null) {
        throw Exception('No se pudo obtener directorio de descarga');
      }
      
      // Crear archivo
      final file = File('${directory.path}/$fileName');
      
      // Escribir bytes al archivo
      await file.writeAsBytes(bytes);
      print('✅ Archivo guardado en: ${file.path}');
      
      // 🔥 INTENTAR ABRIR AUTOMÁTICAMENTE EL PDF
      try {
        final Uri fileUri = Uri.file(file.path);
        final bool canLaunch = await canLaunchUrl(fileUri);
        
        if (canLaunch) {
          await launchUrl(fileUri, mode: LaunchMode.externalApplication);
          print('✅ PDF abierto automáticamente en visor externo');
        } else {
          print('⚠️ No se puede abrir automáticamente el PDF');
        }
      } catch (launchError) {
        print('⚠️ Error abriendo PDF automáticamente: $launchError');
      }

      // Mostrar confirmación
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('📱 PDF descargado y abierto'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Guardado en: ${file.path}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Abrir',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  final Uri fileUri = Uri.file(file.path);
                  await launchUrl(fileUri, mode: LaunchMode.externalApplication);
                  print('👆 Usuario abrió manualmente: ${file.path}');
                } catch (e) {
                  print('❌ Error abriendo PDF manualmente: $e');
                }
              },
            ),
          ),
        );
      }
      
      print('🎉 === DESCARGA MÓVIL COMPLETADA ===');
      
    } catch (e) {
      print('❌ Error en descarga móvil: $e');
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error descargando PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      
      rethrow;
    }
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