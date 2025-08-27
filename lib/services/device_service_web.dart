// 🔧 DEVICE SERVICE WEB
// Implementación para plataforma web

import 'package:flutter/foundation.dart';
import 'device_service.dart';

class DeviceServiceWeb extends DeviceService {
  @override
  Future<String> getDeviceId() async {
    return 'web_device_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      'platform': 'Web',
      'version': 'Browser',
      'model': 'Web Browser',
      'userAgent': 'Web User Agent'
    };
  }

  @override
  Future<String> getPlatformName() async {
    return 'Web 🌐';
  }

  @override
  bool get isWeb => true;

  @override
  bool get isIOS => false;

  @override
  bool get isAndroid => false;
}

DeviceService getDeviceService() => DeviceServiceWeb();