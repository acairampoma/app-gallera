// 🔧 SHARE SERVICE WEB
// Implementación para plataforma web

import 'package:flutter/foundation.dart';
import 'share_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareServiceWeb extends ShareService {
  @override
  Future<bool> shareText(String text, {String? subject}) async {
    try {
      // Para web usar Web Share API si está disponible
      print('🌐 Web Share: $text');
      
      // Fallback: abrir en nueva ventana
      final String encodedText = Uri.encodeComponent(text);
      final Uri uri = Uri.parse('mailto:?subject=${Uri.encodeComponent(subject ?? 'Shared content')}&body=$encodedText');
      
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('❌ Web Share error: $e');
      return false;
    }
  }

  @override
  Future<bool> shareFile(String filePath, {String? text}) async {
    try {
      print('📁 Web File share: $filePath');
      // Para web, compartir como texto
      return await shareText(text ?? 'File: $filePath');
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> shareWhatsApp(String message) async {
    try {
      final String encodedMessage = Uri.encodeComponent(message);
      final Uri webUri = Uri.parse('https://api.whatsapp.com/send?text=$encodedMessage');
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('❌ Web WhatsApp share error: $e');
      return false;
    }
  }

  @override
  bool get isSupported => true;
}

ShareService getShareService() => ShareServiceWeb();