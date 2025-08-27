// 🔧 SHARE SERVICE - MULTIPLATAFORMA COMPATIBLE
// Servicio que maneja el compartir contenido con conditional imports
// para evitar conflictos de compilación entre plataformas

import 'package:flutter/foundation.dart';

// Conditional imports
import 'share_service_stub.dart'
    if (dart.library.io) 'share_service_mobile.dart'
    if (dart.library.html) 'share_service_web.dart';

abstract class ShareService {
  static ShareService get instance => getShareService();
  
  Future<bool> shareText(String text, {String? subject});
  Future<bool> shareFile(String filePath, {String? text});
  Future<bool> shareWhatsApp(String message);
  bool get isSupported;
}

class ShareResult {
  final bool success;
  final String? error;
  
  ShareResult({required this.success, this.error});
}