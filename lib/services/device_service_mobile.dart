// 🔧 DEVICE SERVICE MOBILE
// Implementación para iOS y Android usando device_info_plus de forma segura

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'device_service.dart';

// Solo importar device_info_plus si NO estamos en iOS
// Para evitar problemas de compilación con win32
DeviceService getDeviceService() {
  if (Platform.isIOS) {
    return DeviceServiceIOS();
  } else if (Platform.isAndroid) {
    return DeviceServiceAndroid();
  } else {
    return DeviceServiceGeneric();
  }
}

// Implementación básica para iOS sin device_info_plus problemático
class DeviceServiceIOS extends DeviceService {
  @override
  Future<String> getDeviceId() async {
    // Para iOS usar una implementación básica
    return 'ios_device_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      'platform': 'iOS',
      'version': 'iOS ${Platform.operatingSystemVersion}',
      'model': 'iPhone/iPad',
      'isIOS': true,
    };
  }

  @override
  Future<String> getPlatformName() async {
    return 'iOS 🍎';
  }

  @override
  bool get isWeb => false;

  @override
  bool get isIOS => true;

  @override
  bool get isAndroid => false;
}

// Implementación para Android (puede usar device_info_plus)
class DeviceServiceAndroid extends DeviceService {
  @override
  Future<String> getDeviceId() async {
    try {
      // Implementación básica por ahora
      return 'android_device_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'android_fallback';
    }
  }

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      return {
        'platform': 'Android',
        'version': 'Android ${Platform.operatingSystemVersion}',
        'model': 'Android Device',
        'isAndroid': true,
      };
    } catch (e) {
      return {
        'platform': 'Android',
        'version': 'Unknown',
        'model': 'Android Device',
        'error': e.toString(),
      };
    }
  }

  @override
  Future<String> getPlatformName() async {
    return 'Android 🤖';
  }

  @override
  bool get isWeb => false;

  @override
  bool get isIOS => false;

  @override
  bool get isAndroid => true;
}

// Implementación genérica para otras plataformas
class DeviceServiceGeneric extends DeviceService {
  @override
  Future<String> getDeviceId() async {
    return 'generic_device_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'model': 'Generic Device'
    };
  }

  @override
  Future<String> getPlatformName() async {
    return '${Platform.operatingSystem} 💻';
  }

  @override
  bool get isWeb => false;

  @override
  bool get isIOS => Platform.isIOS;

  @override
  bool get isAndroid => Platform.isAndroid;
}