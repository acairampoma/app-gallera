// 🌐🐓 CONFIGURACIÓN ÉPICA DE API
class ApiConfig {
  // 🚀 URL BASE DEL BACKEND RAILWAY
  static const String baseUrl = 'https://gallerappback-production.up.railway.app';
  
  // ⏱️ TIMEOUTS
  static const int defaultTimeout = 30; // segundos
  static const int longTimeout = 60; // para reportes pesados
  
  // 📊 ENDPOINTS DE REPORTES
  static const String reportesEndpoint = '/api/v1/reportes';
  static const String dashboardEndpoint = '$reportesEndpoint/dashboard';
  static const String rankingsEndpoint = '$reportesEndpoint/rankings';
  static const String periodosEndpoint = '$reportesEndpoint/periodos-disponibles';
  static const String fichaEndpoint = '$reportesEndpoint/gallo';
  static const String testEndpoint = '$reportesEndpoint/test';
  
  // 🔒 HEADERS COMUNES
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // 🏠 OTROS ENDPOINTS EXISTENTES
  static const String authEndpoint = '/auth';
  static const String gallosEndpoint = '/api/v1/gallos';
  static const String peleasEndpoint = '/api/v1/peleas';
  static const String topesEndpoint = '/api/v1/topes';
  static const String vacunasEndpoint = '/api/v1/vacunas';
  static const String inversionesEndpoint = '/api/v1/inversiones';
  
  // 🌍 CONFIGURACIÓN DE ENTORNO
  static const String environment = 'production'; // development, staging, production
  
  // 📱 CONFIGURACIÓN DE APP
  static const String appVersion = '1.0.0';
  static const String userAgent = 'GallosApp/$appVersion';
}