// 📁 constants.dart
// 🔥 CONSTANTES PARA CLOUDINARY Y CONFIGURACIÓN

class Constants {
  // 📸 CLOUDINARY CONFIGURATION
  static const String cloudinaryCloudName = 'tu-cloud-name'; // ⚠️ CAMBIAR POR TU CLOUD NAME
  static const String cloudinaryUploadPreset = 'gallos_preset'; // ⚠️ CAMBIAR POR TU PRESET
  
  // 🌐 API CONFIGURATION
  static const String baseApiUrl = 'https://gallerappback-production.up.railway.app/api/v1'; // 🚀 Railway Backend
  
  // 📱 APP CONFIGURATION
  static const String appName = 'GallosPro';
  static const String appVersion = '1.0.0';
  
  // 🔒 DEFAULTS
  static const int requestTimeout = 30; // segundos
  static const int maxImageSize = 5; // MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
}
