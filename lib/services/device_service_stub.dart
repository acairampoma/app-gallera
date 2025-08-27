// 🔧 DEVICE SERVICE STUB
// Implementación por defecto para plataformas no soportadas

import 'device_service.dart';

class DeviceServiceImpl extends DeviceService {
  @override
  Future<String> getDeviceId() async {
    return 'unknown';
  }

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      'platform': 'unknown',
      'version': '0.0.0',
      'model': 'unknown'
    };
  }

  @override
  Future<String> getPlatformName() async {
    return 'Unknown Platform';
  }

  @override
  bool get isWeb => false;

  @override
  bool get isIOS => false;

  @override
  bool get isAndroid => false;
}

DeviceService getDeviceService() => DeviceServiceImpl();