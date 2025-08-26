// 🚀 ABSTRACT BASE CLASS - INTERFAZ COMÚN PARA TODAS LAS PLATAFORMAS

abstract class PlatformServiceBase {
  
  // 📄 PDF Operations
  Future<void> generateAndPrintPDF(String content, {String? fileName});
  Future<void> sharePDF(String pdfBase64, String fileName);
  Future<void> downloadPDF(String pdfBase64, String fileName);
  
  // 🔗 URL Operations  
  Future<void> openURL(String url);
  Future<bool> canLaunchURL(String url);
  
  // 🔔 Firebase Operations
  Future<void> initializeFirebase();
  Future<String?> getFirebaseToken();
  Future<void> subscribeToTopic(String topic);
  
  // 📤 Share Operations
  Future<void> shareText(String text);
  Future<void> shareFile(String filePath, {String? text});
  
  // 🔔 Local Notifications
  Future<void> showLocalNotification(String title, String body);
  Future<void> requestNotificationPermissions();
  
  // 📱 Device Info
  Future<Map<String, dynamic>> getDeviceInfo();
  Future<bool> requestStoragePermission();
  
  // 🎬 Video Operations  
  bool get supportsVideoPlayer;
  
  // 🌐 Platform Detection
  bool get isWeb;
  bool get isMobile;
  bool get isIOS;
  bool get isAndroid;
}