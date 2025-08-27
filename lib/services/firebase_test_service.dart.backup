// 🔧 FIREBASE TEST SERVICE - PARA DEBUGGEAR
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseTestService {
  static const String baseUrl = 'https://gallerappback-production.up.railway.app';
  
  /// 🧪 TEST COMPLETO DE FIREBASE
  static Future<Map<String, dynamic>> testCompleto() async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': {}
    };
    
    print('🧪 === INICIANDO TESTS FIREBASE ===');
    
    // 1. Test plataforma
    results['tests']['platform'] = {
      'is_web': kIsWeb,
      'platform': kIsWeb ? 'WEB' : 'MOBILE',
      'status': kIsWeb ? 'SKIP' : 'OK'
    };
    print('✅ Test 1 - Plataforma: ${results['tests']['platform']['platform']}');
    
    if (kIsWeb) {
      results['tests']['firebase_core'] = {'status': 'SKIPPED', 'reason': 'Web platform'};
      results['tests']['fcm_token'] = {'status': 'SKIPPED', 'reason': 'Web platform'};
      results['tests']['backend_call'] = {'status': 'SKIPPED', 'reason': 'Web platform'};
      return results;
    }
    
    // 2. Test Firebase Core
    try {
      print('🔄 Test 2 - Inicializando Firebase Core...');
      await Firebase.initializeApp();
      results['tests']['firebase_core'] = {
        'status': 'SUCCESS',
        'apps_count': Firebase.apps.length,
        'default_app': Firebase.app().name
      };
      print('✅ Test 2 - Firebase Core: SUCCESS');
    } catch (e) {
      results['tests']['firebase_core'] = {
        'status': 'ERROR',
        'error': e.toString()
      };
      print('❌ Test 2 - Firebase Core: ERROR - $e');
      return results; // No continuar si Firebase Core falla
    }
    
    // 3. Test Firebase Messaging
    try {
      print('🔄 Test 3 - Inicializando Firebase Messaging...');
      final messaging = FirebaseMessaging.instance;
      results['tests']['firebase_messaging'] = {
        'status': 'SUCCESS',
        'messaging_instance': messaging.toString()
      };
      print('✅ Test 3 - Firebase Messaging: SUCCESS');
      
      // 4. Test FCM Token
      try {
        print('🔄 Test 4 - Obteniendo FCM Token...');
        final token = await messaging.getToken();
        if (token != null) {
          results['tests']['fcm_token'] = {
            'status': 'SUCCESS',
            'token_length': token.length,
            'token_preview': token.substring(0, 20) + '...',
            'full_token': token // Para debug
          };
          print('✅ Test 4 - FCM Token: SUCCESS (${token.length} chars)');
          
          // 5. Test Permisos
          try {
            print('🔄 Test 5 - Verificando permisos...');
            final settings = await messaging.requestPermission();
            results['tests']['permissions'] = {
              'status': 'SUCCESS',
              'authorization': settings.authorizationStatus.toString(),
              'alert': settings.alert.toString(),
              'badge': settings.badge.toString(),
              'sound': settings.sound.toString()
            };
            print('✅ Test 5 - Permisos: ${settings.authorizationStatus}');
          } catch (e) {
            results['tests']['permissions'] = {
              'status': 'ERROR',
              'error': e.toString()
            };
            print('⚠️ Test 5 - Permisos: ERROR - $e');
          }
          
          // 6. Test SharedPreferences (Access Token)
          try {
            print('🔄 Test 6 - Verificando access token...');
            final prefs = await SharedPreferences.getInstance();
            final accessToken = prefs.getString('access_token');
            results['tests']['access_token'] = {
              'status': accessToken != null ? 'SUCCESS' : 'ERROR',
              'has_token': accessToken != null,
              'token_preview': accessToken?.substring(0, 20)
            };
            print('✅ Test 6 - Access Token: ${accessToken != null ? "FOUND" : "NOT FOUND"}');
            
            // 7. Test API Call
            if (accessToken != null) {
              try {
                print('🔄 Test 7 - Llamando API backend...');
                final response = await http.post(
                  Uri.parse('$baseUrl/auth/register-fcm-token'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $accessToken',
                  },
                  body: jsonEncode({
                    'fcm_token': token,
                    'platform': 'android',
                    'device_info': 'Firebase Test Service'
                  }),
                );
                
                results['tests']['backend_call'] = {
                  'status': response.statusCode == 200 ? 'SUCCESS' : 'ERROR',
                  'status_code': response.statusCode,
                  'response_body': response.body,
                  'url': '$baseUrl/auth/register-fcm-token'
                };
                print('✅ Test 7 - API Call: ${response.statusCode} - ${response.body}');
              } catch (e) {
                results['tests']['backend_call'] = {
                  'status': 'ERROR',
                  'error': e.toString()
                };
                print('❌ Test 7 - API Call: ERROR - $e');
              }
            } else {
              results['tests']['backend_call'] = {
                'status': 'SKIPPED',
                'reason': 'No access token'
              };
              print('⚠️ Test 7 - API Call: SKIPPED (no access token)');
            }
          } catch (e) {
            results['tests']['access_token'] = {
              'status': 'ERROR',
              'error': e.toString()
            };
            print('❌ Test 6 - Access Token: ERROR - $e');
          }
        } else {
          results['tests']['fcm_token'] = {
            'status': 'ERROR',
            'error': 'FCM token is null'
          };
          print('❌ Test 4 - FCM Token: NULL');
        }
      } catch (e) {
        results['tests']['fcm_token'] = {
          'status': 'ERROR',
          'error': e.toString()
        };
        print('❌ Test 4 - FCM Token: ERROR - $e');
      }
    } catch (e) {
      results['tests']['firebase_messaging'] = {
        'status': 'ERROR',
        'error': e.toString()
      };
      print('❌ Test 3 - Firebase Messaging: ERROR - $e');
    }
    
    print('🧪 === TESTS COMPLETADOS ===');
    return results;
  }
}