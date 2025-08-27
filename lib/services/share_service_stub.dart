// 🔧 SHARE SERVICE STUB
// Implementación por defecto para plataformas no soportadas

import 'share_service.dart';

class ShareServiceImpl extends ShareService {
  @override
  Future<bool> shareText(String text, {String? subject}) async {
    print('Share not supported on this platform: $text');
    return false;
  }

  @override
  Future<bool> shareFile(String filePath, {String? text}) async {
    print('File share not supported on this platform: $filePath');
    return false;
  }

  @override
  Future<bool> shareWhatsApp(String message) async {
    print('WhatsApp share not supported on this platform: $message');
    return false;
  }

  @override
  bool get isSupported => false;
}

ShareService getShareService() => ShareServiceImpl();