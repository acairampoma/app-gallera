// 🚫 STUB IMPLEMENTATION - FALLBACK CUANDO NO HAY IMPLEMENTACIÓN ESPECÍFICA
import 'dart:async';
import 'platform_service_base.dart';

class PlatformServiceImpl implements PlatformServiceBase {
  
  // 📄 PDF Operations - STUB
  @override
  Future<void> generateAndPrintPDF(String content, {String? fileName}) async {
    throw UnsupportedError(
      '🚫 PDF generation is not supported on this platform. '
      'Please use Android or Desktop version for PDF functionality.'
    );
  }
  
  @override
  Future<void> sharePDF(String pdfBase64, String fileName) async {
    throw UnsupportedError(
      '🚫 PDF sharing is not supported on this platform'
    );
  }
  
  @override
  Future<void> downloadPDF(String pdfBase64, String fileName) async {
    throw UnsupportedError(
      '🚫 PDF download is not supported on this platform'
    );
  }
  
  // 🔗 URL Operations - STUB
  @override
  Future<void> openURL(String url) async {
    throw UnsupportedError(
      '🚫 URL launcher is not supported on this platform'
    );
  }
  
  @override
  Future<bool> canLaunchURL(String url) async {
    return false; // Always return false for stub
  }
  
  // 🔔 Firebase Operations - STUB
  @override
  Future<void> initializeFirebase() async {
    print('⚠️ Firebase not initialized - stub implementation');
    // No-op para evitar crashes
  }
  
  @override
  Future<String?> getFirebaseToken() async {
    print('⚠️ Firebase token not available - stub implementation');
    return null;
  }
  
  @override
  Future<void> subscribeToTopic(String topic) async {
    print('⚠️ Firebase topic subscription not available - stub implementation');
    // No-op para evitar crashes
  }
  
  // 📤 Share Operations - STUB
  @override
  Future<void> shareText(String text) async {
    throw UnsupportedError(
      '🚫 Share functionality is not supported on this platform'
    );
  }
  
  @override
  Future<void> shareFile(String filePath, {String? text}) async {
    throw UnsupportedError(
      '🚫 File sharing is not supported on this platform'
    );
  }
  
  // 🔔 Local Notifications - STUB
  @override
  Future<void> showLocalNotification(String title, String body) async {
    print('⚠️ Local notifications not supported - showing in console:');
    print('📱 $title: $body');
    // No-op para evitar crashes
  }
  
  @override
  Future<void> requestNotificationPermissions() async {
    print('⚠️ Notification permissions not available - stub implementation');
    // No-op para evitar crashes
  }
  
  // 📱 Device Info - STUB
  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      'platform': 'stub',
      'isPhysicalDevice': false,
      'model': 'Unknown',
      'manufacturer': 'Unknown',
    };
  }
  
  @override
  Future<bool> requestStoragePermission() async {
    return false; // Always denied for stub
  }
  
  // 🎬 Video Operations - STUB
  @override
  bool get supportsVideoPlayer => false;
  
  // 🌐 Platform Detection - STUB
  @override
  bool get isWeb => false;
  
  @override
  bool get isMobile => false;
  
  @override
  bool get isIOS => false;
  
  @override
  bool get isAndroid => false;
}