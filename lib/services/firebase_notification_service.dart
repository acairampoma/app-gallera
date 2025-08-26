// 🔥🔔 SERVICIO DE NOTIFICACIONES FIREBASE PUSH - GALLOAPP
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FirebaseNotificationService {
  static const String baseUrl = 'https://gallerappback-production.up.railway.app';
  
  // Singleton
  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  static FirebaseMessaging? _firebaseMessaging;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static String? _fcmToken;
  static bool _isInitialized = false;

  // Callbacks para manejar notificaciones
  static Function(String title, String body, Map<String, dynamic> data)? onNotificationReceived;
  static Function(Map<String, dynamic> data)? onNotificationTapped;

  /// 🚀 INICIALIZAR FIREBASE NOTIFICATIONS
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ Firebase Notifications ya inicializado');
      return;
    }

    try {
      print('🔥 === INICIALIZANDO FIREBASE NOTIFICATIONS ===');

      // 🌐 DETECTAR PLATAFORMA
      print('📱 Plataforma detectada: ${kIsWeb ? "WEB" : "MOBILE"}');
      
      if (kIsWeb) {
        print('⚠️ Firebase notifications no disponible en WEB - Saltando inicialización');
        return;
      }

      // 1. Inicializar Firebase Core si no está inicializado  
      print('🔄 Verificando apps Firebase existentes...');
      print('🔄 Firebase.apps.length: ${Firebase.apps.length}');
      
      if (Firebase.apps.isEmpty) {
        print('🔄 No hay apps Firebase, inicializando...');
        await Firebase.initializeApp();
        print('✅ Firebase Core inicializado desde FirebaseNotificationService');
      } else {
        print('✅ Firebase Core ya estaba inicializado (app: ${Firebase.apps.first.name})');
      }

      // 2. Inicializar Firebase Messaging
      _firebaseMessaging = FirebaseMessaging.instance;
      print('✅ Firebase Messaging obtenido');

      // 3. Solicitar permisos para notificaciones
      try {
        await _requestPermissions();
      } catch (e) {
        print('⚠️ Error en permisos, continuando: $e');
      }

      // 4. Inicializar notificaciones locales
      try {
        await _initializeLocalNotifications();
      } catch (e) {
        print('⚠️ Error en notificaciones locales, continuando: $e');
      }

      // 5. Obtener FCM token - ESTE ES CRÍTICO
      print('🔄 PASO 5: Obteniendo FCM token...');
      await _getFCMToken();
      print('🔄 PASO 5 COMPLETADO. Token: ${_fcmToken != null ? "✅ EXISTE" : "❌ NULL"}');

      // 6. Configurar listeners
      print('🔄 PASO 6: Configurando listeners...');
      try {
        _configurarListeners();
        print('🔄 PASO 6 COMPLETADO');
      } catch (e) {
        print('⚠️ Error en listeners, continuando: $e');
      }

      // 7. Registrar token en el backend - ESTE ES CRÍTICO
      print('🔄 PASO 7: Registrando token en backend...');
      await _registrarTokenEnBackend();
      print('🔄 PASO 7 COMPLETADO');

      _isInitialized = true;
      print('🎉 === FIREBASE NOTIFICATIONS INICIALIZADO EXITOSAMENTE ===');
      
    } catch (e) {
      print('❌ Error inicializando Firebase Notifications: $e');
      rethrow;
    }
  }

  /// 🔑 SOLICITAR PERMISOS
  static Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Permisos de notificaciones concedidos');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ Permisos provisionales concedidos');
      } else {
        print('❌ Permisos de notificaciones denegados');
      }
    } catch (e) {
      print('❌ Error solicitando permisos: $e');
    }
  }

  /// 📱 INICIALIZAR NOTIFICACIONES LOCALES
  static Future<void> _initializeLocalNotifications() async {
    try {
      _localNotifications = FlutterLocalNotificationsPlugin();

      // Configuración para Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Configuración para iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Cuando el usuario toca la notificación
          if (details.payload != null) {
            final data = jsonDecode(details.payload!);
            onNotificationTapped?.call(data);
          }
        },
      );

      print('✅ Notificaciones locales inicializadas');
    } catch (e) {
      print('❌ Error inicializando notificaciones locales: $e');
    }
  }

  /// 🔐 OBTENER FCM TOKEN
  static Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging!.getToken();
      print('🔑 FCM Token obtenido: ${_fcmToken?.substring(0, 20)}...');
      
      // Guardar token localmente
      final prefs = await SharedPreferences.getInstance();
      if (_fcmToken != null) {
        await prefs.setString('fcm_token', _fcmToken!);
      }
    } catch (e) {
      print('❌ Error obteniendo FCM token: $e');
    }
  }

  /// 👂 CONFIGURAR LISTENERS
  static void _configurarListeners() {
    try {
      // Cuando la app está en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📩 Notificación recibida en primer plano:');
        print('Título: ${message.notification?.title}');
        print('Cuerpo: ${message.notification?.body}');
        print('Data: ${message.data}');

        // Mostrar notificación local
        _showLocalNotification(message);

        // Callback personalizado
        onNotificationReceived?.call(
          message.notification?.title ?? 'Sin título',
          message.notification?.body ?? 'Sin mensaje',
          message.data,
        );
      });

      // Cuando el usuario toca la notificación y abre la app
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📲 App abierta desde notificación:');
        print('Data: ${message.data}');
        
        onNotificationTapped?.call(message.data);
      });

      // Cuando el token se actualiza
      _firebaseMessaging!.onTokenRefresh.listen((String token) {
        print('🔄 FCM Token actualizado');
        _fcmToken = token;
        _registrarTokenEnBackend();
      });

      print('✅ Listeners configurados');
    } catch (e) {
      print('❌ Error configurando listeners: $e');
    }
  }

  /// 🔔 MOSTRAR NOTIFICACIÓN LOCAL
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'galloapp_channel',
        'GalloApp Notifications',
        channelDescription: 'Notificaciones importantes de GalloApp',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications!.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.notification?.title ?? 'GalloApp',
        message.notification?.body ?? 'Nueva notificación',
        details,
        payload: jsonEncode(message.data),
      );

      print('✅ Notificación local mostrada');
    } catch (e) {
      print('❌ Error mostrando notificación local: $e');
    }
  }

  /// 🔐 Headers con token JWT - IGUAL QUE OTROS SERVICIOS
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// 📤 REGISTRAR TOKEN EN EL BACKEND - USANDO PATRÓN CORRECTO
  static Future<void> _registrarTokenEnBackend() async {
    print('🔄 === _registrarTokenEnBackend INICIADO ===');
    
    if (_fcmToken == null) {
      print('❌ _fcmToken es null, no se puede registrar');
      return;
    }

    print('🔑 FCM Token disponible: ${_fcmToken!.substring(0, 20)}...');

    try {
      // USAR EL PATRÓN CORRECTO COMO OTROS SERVICIOS
      final headers = await _getAuthHeaders();
      
      print('🔐 Headers preparados: $headers');
      
      if (!headers.containsKey('Authorization')) {
        print('⚠️ No hay Authorization header, no se puede registrar FCM token');
        return;
      }

      print('📡 Enviando request al backend: $baseUrl/auth/register-fcm-token');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register-fcm-token'),
        headers: headers,
        body: jsonEncode({
          'fcm_token': _fcmToken,
          'platform': defaultTargetPlatform.name,
          'device_info': 'Flutter App ${defaultTargetPlatform.name}',
        }),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ FCM token registrado en el backend EXITOSAMENTE');
      } else {
        print('⚠️ Error registrando FCM token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ EXCEPCIÓN registrando token en backend: $e');
    }
  }

  /// 📧 ENVIAR NOTIFICACIÓN A ADMIN (cuando usuario se suscribe)
  static Future<void> notificarSuscripcionAAdmin({
    required String nombreUsuario,
    required String emailUsuario,
    required String planElegido,
    required double monto,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      if (accessToken == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/notifications/admin/nueva-suscripcion'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'tipo': 'nueva_suscripcion',
          'usuario_nombre': nombreUsuario,
          'usuario_email': emailUsuario,
          'plan': planElegido,
          'monto': monto,
          'fecha': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Notificación enviada al admin');
      } else {
        print('⚠️ Error enviando notificación al admin: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error enviando notificación al admin: $e');
    }
  }

  /// 🏷️ SUSCRIBIRSE A TOPIC (para notificaciones grupales)
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging!.subscribeToTopic(topic);
      print('✅ Suscrito al topic: $topic');
    } catch (e) {
      print('❌ Error suscribiéndose al topic $topic: $e');
    }
  }

  /// 🚫 DESUSCRIBIRSE DE TOPIC
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging!.unsubscribeFromTopic(topic);
      print('✅ Desuscrito del topic: $topic');
    } catch (e) {
      print('❌ Error desuscribiéndose del topic $topic: $e');
    }
  }

  /// 🔍 OBTENER TOKEN ACTUAL
  static String? get currentToken => _fcmToken;

  /// ✅ VERIFICAR SI ESTÁ INICIALIZADO
  static bool get isInitialized => _isInitialized;

  /// 🔧 DEBUG COMPLETO - FORZAR REGISTRO MANUAL
  static Future<Map<String, dynamic>> debugCompleto() async {
    final result = <String, dynamic>{};
    
    try {
      // 1. Verificar plataforma
      result['platform'] = kIsWeb ? 'WEB' : 'MOBILE';
      
      // 2. Verificar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      result['has_access_token'] = accessToken != null;
      result['access_token_preview'] = accessToken?.substring(0, 20);
      
      // 3. Verificar Firebase token
      result['fcm_token'] = _fcmToken;
      result['has_fcm_token'] = _fcmToken != null;
      
      // 4. Si no hay Firebase, intentar inicializar SOLO Firebase Core
      if (_fcmToken == null && !kIsWeb) {
        try {
          await Firebase.initializeApp();
          _firebaseMessaging = FirebaseMessaging.instance;
          _fcmToken = await _firebaseMessaging!.getToken();
          result['firebase_retry'] = 'SUCCESS';
          result['new_fcm_token'] = _fcmToken?.substring(0, 20);
        } catch (e) {
          result['firebase_retry'] = 'ERROR: $e';
        }
      }
      
      // 5. FORZAR registro si tenemos todo
      if (accessToken != null && _fcmToken != null) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/auth/register-fcm-token'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'fcm_token': _fcmToken,
              'platform': 'android',
              'device_info': 'DEBUG MANUAL',
            }),
          );
          result['api_call'] = 'SUCCESS';
          result['api_response'] = response.body;
          result['api_status'] = response.statusCode;
        } catch (e) {
          result['api_call'] = 'ERROR: $e';
        }
      }
      
    } catch (e) {
      result['debug_error'] = e.toString();
    }
    
    return result;
  }

  /// 🛑 LIMPIAR RECURSOS
  static Future<void> dispose() async {
    try {
      _isInitialized = false;
      _fcmToken = null;
      onNotificationReceived = null;
      onNotificationTapped = null;
      print('✅ Firebase Notifications limpiado');
    } catch (e) {
      print('❌ Error limpiando recursos: $e');
    }
  }
}

/// 🔥 FUNCIÓN PARA MANEJAR NOTIFICACIONES EN BACKGROUND
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Notificación en background: ${message.notification?.title}');
}