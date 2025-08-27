// 🔧 DEVICE SERVICE - MULTIPLATAFORMA COMPATIBLE
// Servicio que maneja información del dispositivo con conditional imports
// para evitar conflictos de compilación entre plataformas

import 'package:flutter/foundation.dart';

// Conditional imports
import 'device_service_stub.dart'
    if (dart.library.io) 'device_service_mobile.dart'
    if (dart.library.html) 'device_service_web.dart';

abstract class DeviceService {
  static DeviceService get instance => getDeviceService();
  
  Future<String> getDeviceId();
  Future<Map<String, dynamic>> getDeviceInfo();
  Future<String> getPlatformName();
  bool get isWeb;
  bool get isIOS;
  bool get isAndroid;
}