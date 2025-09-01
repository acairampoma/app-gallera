// 📱🔥 SERVICIO NATIVO DE COMPARTIR - SIN THIRD-PARTY SDKs
// Windsurf Strategy: iOS MethodChannel + Android MethodChannel + Web wa.me
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class NativeShareService {
  static const MethodChannel _channel = MethodChannel('native_share');
  
  /// 🔥 COMPARTIR PDF MULTIPLATAFORMA
  static Future<void> sharePDF({
    required Uint8List pdfBytes,
    required String fileName,
    required String nombreGallo,
    String? phoneNumber,
  }) async {
    try {
      print('📱 === COMPARTIR PDF NATIVO ===');
      print('📄 Archivo: $fileName');
      print('🐓 Gallo: $nombreGallo');
      print('📊 PDF bytes: ${pdfBytes.length}');
      print('🔍 Plataforma: ${_getPlatformName()}');
      
      if (kIsWeb) {
        // 🌐 WEB: Descarga + WhatsApp link
        await _shareWebStrategy(pdfBytes, fileName, nombreGallo, phoneNumber);
      } else if (Platform.isIOS) {
        // 📱 iOS: UIActivityViewController nativo
        await _shareIOS(pdfBytes, fileName, nombreGallo);
      } else if (Platform.isAndroid) {
        // 🤖 Android: Intent.ACTION_SEND nativo
        await _shareAndroid(pdfBytes, fileName, nombreGallo);
      } else {
        throw UnsupportedError('Plataforma no soportada: ${Platform.operatingSystem}');
      }
      
      print('✅ Compartir completado exitosamente');
      
    } catch (e) {
      print('❌ Error compartiendo PDF: $e');
      rethrow;
    }
  }
  
  /// 🌐 ESTRATEGIA WEB: Descarga local + WhatsApp Web link
  static Future<void> _shareWebStrategy(
    Uint8List pdfBytes, 
    String fileName, 
    String nombreGallo,
    String? phoneNumber,
  ) async {
    try {
      print('🌐 Ejecutando estrategia Web...');
      
      // 1. Descargar PDF localmente
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      
      html.document.body!.children.add(anchor);
      anchor.click();
      
      print('✅ PDF descargado localmente');
      
      // 2. Abrir WhatsApp Web con mensaje
      final message = 'Te comparto la ficha de mi gallo $nombreGallo. '
          'El archivo PDF se descargó en tu computadora: $fileName';
      
      String whatsappUrl;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
      } else {
        whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
      }
      
      // Abrir WhatsApp Web
      final whatsappUri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        print('✅ WhatsApp Web abierto con mensaje');
      } else {
        print('⚠️ No se puede abrir WhatsApp Web');
      }
      
      // Limpiar después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        print('✅ Limpieza web completada');
      });
      
    } catch (e) {
      print('❌ Error en estrategia web: $e');
      rethrow;
    }
  }
  
  /// 📱 COMPARTIR iOS NATIVO
  static Future<void> _shareIOS(Uint8List pdfBytes, String fileName, String nombreGallo) async {
    try {
      print('📱 Compartiendo en iOS nativo...');
      
      // iOS usa sharePDF como método unificado
      final result = await _channel.invokeMethod('sharePDF', {
        'pdfBytes': pdfBytes,
        'fileName': fileName,
        'text': 'Ficha de $nombreGallo',
        'subject': 'Ficha de Gallo - $nombreGallo',
      });
      
      print('✅ iOS share completado');
      
    } catch (e) {
      print('❌ Error compartiendo iOS: $e');
      rethrow;
    }
  }
  
  /// 🤖 COMPARTIR ANDROID NATIVO
  static Future<void> _shareAndroid(Uint8List pdfBytes, String fileName, String nombreGallo) async {
    try {
      print('🤖 Compartiendo en Android nativo...');
      
      // Android también usa sharePDF como método unificado
      final result = await _channel.invokeMethod('sharePDF', {
        'pdfBytes': pdfBytes,
        'fileName': fileName,
        'text': 'Ficha de $nombreGallo',
        'mimeType': 'application/pdf',
      });
      
      print('✅ Android share completado');
      
    } catch (e) {
      print('❌ Error compartiendo Android: $e');
      rethrow;
    }
  }
  
  /// 🔍 OBTENER NOMBRE DE PLATAFORMA
  static String _getPlatformName() {
    if (kIsWeb) return 'WEB';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'ANDROID';
    return Platform.operatingSystem;
  }
  
  /// 📱 COMPARTIR SOLO WHATSAPP (DIRECTO)
  static Future<void> shareToWhatsApp({
    required String message,
    String? phoneNumber,
    Uint8List? pdfBytes,
    String? fileName,
  }) async {
    try {
      print('📱 Compartir directo a WhatsApp...');
      
      if (kIsWeb) {
        // Web: Solo texto via wa.me
        String url;
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
        } else {
          url = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
        }
        
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        
      } else {
        // Móvil: Usar esquema whatsapp://
        String url;
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          url = 'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}';
        } else {
          url = 'whatsapp://send?text=${Uri.encodeComponent(message)}';
        }
        
        final whatsappUri = Uri.parse(url);
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          print('✅ WhatsApp abierto directamente');
        } else {
          print('⚠️ WhatsApp no instalado, usando web fallback');
          await shareToWhatsApp(
            message: message, 
            phoneNumber: phoneNumber,
          );
        }
      }
      
    } catch (e) {
      print('❌ Error compartiendo a WhatsApp: $e');
      rethrow;
    }
  }
  
  /// 🧪 TEST DE COMPARTIR
  static Future<void> testShare() async {
    try {
      print('🧪 Testing native share...');
      
      // Crear PDF de prueba
      final testPdf = 'JVBERi0xLjQKMSAwIG9iago8PAovVHlwZSAvQ2F0YWxvZwovUGFnZXMgMiAwIFIKPj4KZW5kb2JqCjIgMCBvYmoKPDwKL1R5cGUgL1BhZ2VzCi9LaWRzIFszIDAgUl0KL0NvdW50IDEKPD4KZW5kb2JqCjMgMCBvYmoKPDwKL1R5cGUgL1BhZ2UKL1BhcmVudCAyIDAgUgovTWVkaWFCb3ggWzAgMCA2MTIgNzkyXQovUmVzb3VyY2VzIDw8Ci9Gb250IDw8Ci9GMSA0IDAgUgo+Pgo+PgovQ29udGVudHMgNSAwIFIKPj4KZW5kb2JqCjQgMCBvYmoKPDwKL1R5cGUgL0ZvbnQKL1N1YnR5cGUgL1R5cGUxCi9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2JqCjUgMCBvYmoKPDwKL0xlbmd0aCA0NAo+PgpzdHJlYW0KQlQKL0YxIDEyIFRmCjEwMCA3MDAgVGQKKEhlbGxvIFdvcmxkKSBUagpFVApzdHJlYW0KZW5kb2JqCnhyZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDAwOSAwMDAwMCBuIAowMDAwMDAwMDU4IDAwMDAwIG4gCjAwMDAwMDAxMTUgMDAwMDAgbiAKMDAwMDAwMDI0NSAwMDAwMCBuIAowMDAwMDAwMzIyIDAwMDAwIG4gCnRyYWlsZXIKPDwKL1NpemUgNgovUm9vdCAxIDAgUgo+PgpzdGFydHhyZWYKNDE0CiUlRU9G';
      final pdfBytes = base64Decode(testPdf);
      
      await sharePDF(
        pdfBytes: pdfBytes,
        fileName: 'test_gallo.pdf',
        nombreGallo: 'Campeón de Prueba',
      );
      
    } catch (e) {
      print('❌ Error en test: $e');
    }
  }
}