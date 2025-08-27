// 🌐 WEB IMPLEMENTATION STUB - Firebase disabled for build
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'platform_service_base.dart';

class PlatformServiceImpl implements PlatformServiceBase {
  
  // Platform detection - WEB
  @override
  bool get isWeb => true;
  
  @override
  bool get isMobile => false;
  
  @override
  bool get isIOS => false;
  
  @override
  bool get isAndroid => false;
  
  @override
  bool get supportsVideoPlayer => true;
  
  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      'platform': 'web',
      'userAgent': 'disabled_for_build',
      'version': '1.0.0'
    };
  }
  // 📱 Permissions - WEB STUBS
  @override
  Future<void> requestNotificationPermissions() async {
    print('Notification permissions DISABLED for Firebase-free build');
  }
  
  @override
  Future<bool> requestStoragePermission() async {
    print('Storage permission DISABLED for Firebase-free build');
    return true;
  }
  
  @override
  Future<void> showLocalNotification(String title, String body) async {
    print('Local notification DISABLED: $title - $body');
  }
  
  // 📤 File sharing - WEB STUBS
  @override
  Future<void> shareFile(String filePath, {String? text}) async {
    print('File sharing DISABLED for Firebase-free build');
  }
  @override
  Future<void> generateAndPrintPDF(String content, {String? fileName}) async {
    print('PDF generation DISABLED for Firebase-free build');
  }
  
  @override
  Future<void> sharePDF(String pdfBase64, String fileName) async {
    print('PDF sharing DISABLED for Firebase-free build');
  }
  
  @override
  Future<void> downloadPDF(String pdfBase64, String fileName) async {
    print('PDF download DISABLED for Firebase-free build');
  }
  
  // 🔗 URL Operations - WEB
  @override
  Future<void> openURL(String url) async {
    html.window.open(url, '_blank');
  }
  
  @override
  Future<bool> canLaunchURL(String url) async {
    return true;
  }
  
  // FIREBASE OPERATIONS DISABLED FOR XCODE 16 BUILD
  @override
  Future<void> initializeFirebase() async {
    print('Firebase initialization DISABLED for build');
  }
  
  @override
  Future<String?> getFirebaseToken() async {
    print('Firebase token DISABLED for build');
    return 'disabled_token_for_build';
  }
  
  @override
  Future<void> subscribeToTopic(String topic) async {
    print('Firebase topic subscription DISABLED for build: $topic');
  }
  
  // 📤 Share Operations - WEB
  @override
  Future<void> shareText(String text) async {
    print('Share text DISABLED for Firebase-free build');
  }
  
  Future<void> _copyToClipboard(String text) async {
    // Stub implementation
    print('Clipboard copy DISABLED for Firebase-free build');
  }
}
