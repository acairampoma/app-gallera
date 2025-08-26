// 📱 MOBILE IMPLEMENTATION - iOS/Android con todas las funcionalidades
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'platform_service_base.dart';

class PlatformServiceImpl implements PlatformServiceBase {
  
  // 📄 PDF Operations - FULL MOBILE IMPLEMENTATION
  @override
  Future<void> generateAndPrintPDF(String content, {String? fileName}) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  text: fileName ?? 'Documento',
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  content,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            );
          },
        ),
      );
      
      // Generar y mostrar PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: fileName ?? 'documento.pdf',
        format: PdfPageFormat.a4,
      );
      
      print('✅ PDF generado y mostrado exitosamente');
    } catch (e) {
      print('❌ Error generando PDF: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> sharePDF(String pdfBase64, String fileName) async {
    try {
      final bytes = base64Decode(pdfBase64);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Compartiendo documento: $fileName',
      );
      
      print('✅ PDF compartido exitosamente');
    } catch (e) {
      print('❌ Error compartiendo PDF: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> downloadPDF(String pdfBase64, String fileName) async {
    try {
      // Solicitar permisos si es necesario
      if (Platform.isAndroid) {
        final hasPermission = await requestStoragePermission();
        if (!hasPermission) {
          throw Exception('Permisos de almacenamiento denegados');
        }
      }
      
      final bytes = base64Decode(pdfBase64);
      
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        throw Exception('No se pudo acceder al directorio');
      }
      
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      print('✅ PDF descargado en: ${file.path}');
    } catch (e) {
      print('❌ Error descargando PDF: $e');
      rethrow;
    }
  }
  
  // 🔗 URL Operations - MOBILE
  @override
  Future<void> openURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('No se puede abrir la URL: $url');
    }
  }
  
  @override
  Future<bool> canLaunchURL(String url) async {
    final uri = Uri.parse(url);
    return await canLaunchUrl(uri);
  }
  
  // 🔔 Firebase Operations - MOBILE
  @override
  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print('✅ Firebase inicializado exitosamente');
    } catch (e) {
      print('❌ Error inicializando Firebase: $e');
      rethrow;
    }
  }
  
  @override
  Future<String?> getFirebaseToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('✅ Token FCM obtenido: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      print('❌ Error obteniendo token FCM: $e');
      return null;
    }
  }
  
  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('✅ Suscrito al topic: $topic');
    } catch (e) {
      print('❌ Error suscribiendo al topic $topic: $e');
      rethrow;
    }
  }
  
  // 📤 Share Operations - MOBILE
  @override
  Future<void> shareText(String text) async {
    await Share.share(text);
  }
  
  @override
  Future<void> shareFile(String filePath, {String? text}) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: text,
    );
  }
  
  // 🔔 Local Notifications - MOBILE
  @override
  Future<void> showLocalNotification(String title, String body) async {
    final FlutterLocalNotificationsPlugin notifications = 
        FlutterLocalNotificationsPlugin();
    
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
      'gallos_channel',
      'Casta de Gallos',
      channelDescription: 'Notificaciones de Casta de Gallos',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = 
        DarwinNotificationDetails();
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformDetails,
    );
  }
  
  @override
  Future<void> requestNotificationPermissions() async {
    final FlutterLocalNotificationsPlugin notifications = 
        FlutterLocalNotificationsPlugin();
    
    if (Platform.isAndroid) {
      await notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    
    if (Platform.isIOS) {
      await notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }
  
  // 📱 Device Info - MOBILE
  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'android',
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
        'androidId': androidInfo.id,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'platform': 'ios',
        'model': iosInfo.model,
        'name': iosInfo.name,
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
        'identifierForVendor': iosInfo.identifierForVendor,
      };
    }
    
    return {'platform': 'unknown'};
  }
  
  @override
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status == PermissionStatus.granted;
    }
    return true; // iOS no necesita permisos explícitos para Documents
  }
  
  // 🎬 Video Operations - MOBILE
  @override
  bool get supportsVideoPlayer => true;
  
  // 🌐 Platform Detection - MOBILE
  @override
  bool get isWeb => false;
  
  @override
  bool get isMobile => true;
  
  @override
  bool get isIOS => Platform.isIOS;
  
  @override
  bool get isAndroid => Platform.isAndroid;
}