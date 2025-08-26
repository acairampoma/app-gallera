// 🌐 WEB IMPLEMENTATION - Funcionalidades específicas para navegadores
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'platform_service_base.dart';

class PlatformServiceImpl implements PlatformServiceBase {
  
  // 📄 PDF Operations - WEB IMPLEMENTATION
  @override
  Future<void> generateAndPrintPDF(String content, {String? fileName}) async {
    try {
      // Crear PDF simple en web y abrirlo para imprimir
      final pdfContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <title>${fileName ?? 'Documento'}</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          h1 { color: #d32f2f; }
          .content { line-height: 1.6; }
        </style>
      </head>
      <body>
        <h1>${fileName ?? 'Documento'}</h1>
        <div class="content">
          ${content.replaceAll('\n', '<br>')}
        </div>
        <script>
          window.onload = function() {
            window.print();
          }
        </script>
      </body>
      </html>
      ''';
      
      final blob = html.Blob([pdfContent], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      html.window.open(url, '_blank');
      
      print('✅ Documento abierto para imprimir en web');
    } catch (e) {
      print('❌ Error generando PDF en web: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> sharePDF(String pdfBase64, String fileName) async {
    try {
      final bytes = base64Decode(pdfBase64);
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Usar Web Share API si está disponible
      if (html.window.navigator.share != null) {
        await html.window.navigator.share({
          'title': fileName,
          'text': 'Compartiendo documento PDF',
          'url': url,
        });
      } else {
        // Fallback: descargar archivo
        final anchor = html.AnchorElement()
          ..href = url
          ..download = fileName
          ..click();
      }
      
      print('✅ PDF compartido en web');
    } catch (e) {
      print('❌ Error compartiendo PDF en web: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> downloadPDF(String pdfBase64, String fileName) async {
    try {
      final bytes = base64Decode(pdfBase64);
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.AnchorElement()
        ..href = url
        ..download = fileName
        ..click();
      
      // Limpiar URL después de un tiempo
      Timer(Duration(seconds: 5), () {
        html.Url.revokeObjectUrl(url);
      });
      
      print('✅ PDF descargado en web');
    } catch (e) {
      print('❌ Error descargando PDF en web: $e');
      rethrow;
    }
  }
  
  // 🔗 URL Operations - WEB
  @override
  Future<void> openURL(String url) async {
    html.window.open(url, '_blank');
  }
  
  @override
  Future<bool> canLaunchURL(String url) async {
    // En web siempre podemos "lanzar" URLs
    return true;
  }
  
  // 🔔 Firebase Operations - WEB
  @override
  Future<void> initializeFirebase() async {
    try {
      // En web, Firebase se inicializa con las credenciales del proyecto
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyB8-2NH2j7lt8V5tbXYn9L0UFvbFozHw0k',
          appId: '1:590199670157:web:de99dfd48c04183c81a9c4',
          messagingSenderId: '590199670157',
          projectId: 'galloapp-notifications',
          storageBucket: 'galloapp-notifications.firebasestorage.app',
        ),
      );
      print('✅ Firebase inicializado en web');
    } catch (e) {
      print('❌ Error inicializando Firebase en web: $e');
      rethrow;
    }
  }
  
  @override
  Future<String?> getFirebaseToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('✅ Token FCM web obtenido: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      print('❌ Error obteniendo token FCM en web: $e');
      return null;
    }
  }
  
  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('✅ Suscrito al topic en web: $topic');
    } catch (e) {
      print('❌ Error suscribiendo al topic en web $topic: $e');
      rethrow;
    }
  }
  
  // 📤 Share Operations - WEB
  @override
  Future<void> shareText(String text) async {
    if (html.window.navigator.share != null) {
      await html.window.navigator.share({
        'text': text,
      });
    } else {
      // Fallback: copiar al clipboard
      await _copyToClipboard(text);
      print('✅ Texto copiado al portapapeles');
    }
  }
  
  @override
  Future<void> shareFile(String filePath, {String? text}) async {
    // En web, los archivos se manejan diferente
    // Por ahora, solo compartimos el texto
    if (text != null) {
      await shareText(text);
    }
  }
  
  // 🔔 Local Notifications - WEB
  @override
  Future<void> showLocalNotification(String title, String body) async {
    if (html.window.navigator.permissions != null) {
      try {
        // Solicitar permiso si no lo tenemos
        final permission = await html.window.navigator.permissions!.query({
          'name': 'notifications'
        });
        
        if (permission.state == 'granted') {
          html.Notification(title, body: body);
        } else {
          // Fallback: mostrar alerta
          html.window.alert('$title: $body');
        }
      } catch (e) {
        // Fallback: mostrar en consola
        print('📱 Notificación: $title - $body');
      }
    }
  }
  
  @override
  Future<void> requestNotificationPermissions() async {
    try {
      if (html.Notification.supported) {
        await html.Notification.requestPermission();
      }
    } catch (e) {
      print('⚠️ No se pudieron solicitar permisos de notificación en web');
    }
  }
  
  // 📱 Device Info - WEB
  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final navigator = html.window.navigator;
    return {
      'platform': 'web',
      'userAgent': navigator.userAgent,
      'language': navigator.language,
      'cookieEnabled': navigator.cookieEnabled,
      'onLine': navigator.onLine,
      'vendor': navigator.vendor,
    };
  }
  
  @override
  Future<bool> requestStoragePermission() async {
    // En web no necesitamos permisos especiales para descargas
    return true;
  }
  
  // 🎬 Video Operations - WEB
  @override
  bool get supportsVideoPlayer => true;
  
  // 🌐 Platform Detection - WEB
  @override
  bool get isWeb => true;
  
  @override
  bool get isMobile => false;
  
  @override
  bool get isIOS => false;
  
  @override
  bool get isAndroid => false;
  
  // Helper Methods
  Future<void> _copyToClipboard(String text) async {
    try {
      await html.window.navigator.clipboard?.writeText(text);
    } catch (e) {
      // Fallback: usar método deprecated pero funcional
      final textArea = html.TextAreaElement();
      textArea.value = text;
      html.document.body?.append(textArea);
      textArea.select();
      html.document.execCommand('copy');
      textArea.remove();
    }
  }
}