// TEMP STUB FOR FIREBASE DISABLED BUILD
class FirebaseNotificationService {
  static Future<void> initialize() async {
    print('Firebase notifications DISABLED for Xcode 16 build');
  }
  
  static Future<void> notificarSuscripcionAAdmin({
    dynamic suscripcion,
    String? nombreUsuario,
    String? emailUsuario,
    String? planElegido,
    dynamic monto,
    dynamic usuario,
    dynamic planId,
    dynamic metodoPago,
  }) async {
    print('Firebase notification DISABLED - would have sent admin notification');
    print('User: $nombreUsuario, Monto: $monto (DISABLED)');
  }
}
