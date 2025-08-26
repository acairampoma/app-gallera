// 🚀 CONDITIONAL EXPORTS - FLUTTER RESUELVE AUTOMÁTICAMENTE LA PLATAFORMA
//
// ✅ iOS: Usará stub (sin PDF, Firebase, etc)
// ✅ Android: Usará mobile (con todas las funcionalidades)  
// ✅ Web: Usará web (con funcionalidades web nativas)
//
// 🔧 FUNCIONAMIENTO:
// - dart.library.io: Disponible en iOS/Android/Desktop 
// - dart.library.html: Disponible en Web
// - Si ninguno: Usa stub

export 'platform_implementations/platform_service_stub.dart'
    if (dart.library.io) 'platform_implementations/platform_service_mobile.dart'
    if (dart.library.html) 'platform_implementations/platform_service_web.dart';