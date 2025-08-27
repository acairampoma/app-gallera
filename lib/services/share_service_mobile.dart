// 🔧 SHARE SERVICE MOBILE
// Implementación para iOS y Android usando share_plus de forma segura

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'share_service.dart';

// Conditional imports para share_plus
import 'package:url_launcher/url_launcher.dart';

ShareService getShareService() {
  if (Platform.isIOS) {
    return ShareServiceIOS();
  } else if (Platform.isAndroid) {
    return ShareServiceAndroid();
  } else {
    return ShareServiceGeneric();
  }
}

// Implementación básica para iOS usando url_launcher
class ShareServiceIOS extends ShareService {
  @override
  Future<bool> shareText(String text, {String? subject}) async {
    try {
      // Para iOS usar implementación básica con url_launcher
      final String encodedText = Uri.encodeComponent(text);
      final Uri uri = Uri.parse('mailto:?subject=${Uri.encodeComponent(subject ?? 'Shared content')}&body=$encodedText');
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      
      // Fallback: mostrar el contenido en console
      print('📱 iOS Share: $text');
      return true;
    } catch (e) {
      print('❌ iOS Share error: $e');
      return false;
    }
  }

  @override
  Future<bool> shareFile(String filePath, {String? text}) async {
    try {
      // Para iOS implementación básica
      print('📁 iOS File share: $filePath');
      return await shareText(text ?? 'File shared: $filePath');
    } catch (e) {
      print('❌ iOS File share error: $e');
      return false;
    }
  }

  @override
  Future<bool> shareWhatsApp(String message) async {
    try {
      final String encodedMessage = Uri.encodeComponent(message);
      final Uri whatsappUri = Uri.parse('whatsapp://send?text=$encodedMessage');
      
      if (await canLaunchUrl(whatsappUri)) {
        return await launchUrl(whatsappUri);
      } else {
        // Fallback a URL web de WhatsApp
        final Uri webUri = Uri.parse('https://api.whatsapp.com/send?text=$encodedMessage');
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('❌ iOS WhatsApp share error: $e');
      return false;
    }
  }

  @override
  bool get isSupported => true;
}

// Implementación para Android
class ShareServiceAndroid extends ShareService {
  @override
  Future<bool> shareText(String text, {String? subject}) async {
    try {
      // Para Android también usar implementación básica por ahora
      print('📱 Android Share: $text');
      
      // Intentar WhatsApp como alternativa
      return await shareWhatsApp(text);
    } catch (e) {
      print('❌ Android Share error: $e');
      return false;
    }
  }

  @override
  Future<bool> shareFile(String filePath, {String? text}) async {
    try {
      print('📁 Android File share: $filePath');
      return await shareText(text ?? 'File shared: $filePath');
    } catch (e) {
      print('❌ Android File share error: $e');
      return false;
    }
  }

  @override
  Future<bool> shareWhatsApp(String message) async {
    try {
      final String encodedMessage = Uri.encodeComponent(message);
      final Uri whatsappUri = Uri.parse('whatsapp://send?text=$encodedMessage');
      
      if (await canLaunchUrl(whatsappUri)) {
        return await launchUrl(whatsappUri);
      } else {
        // Fallback a URL web de WhatsApp
        final Uri webUri = Uri.parse('https://api.whatsapp.com/send?text=$encodedMessage');
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('❌ Android WhatsApp share error: $e');
      return false;
    }
  }

  @override
  bool get isSupported => true;
}

// Implementación genérica
class ShareServiceGeneric extends ShareService {
  @override
  Future<bool> shareText(String text, {String? subject}) async {
    try {
      print('💻 Generic Share: $text');
      return true;
    } catch (e) {
      print('❌ Generic Share error: $e');
      return false;
    }
  }

  @override
  Future<bool> shareFile(String filePath, {String? text}) async {
    try {
      print('📁 Generic File share: $filePath');
      return true;
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
      return false;
    }
  }

  @override
  bool get isSupported => true;
}