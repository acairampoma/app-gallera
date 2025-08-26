import 'package:flutter/material.dart';
import 'package:gallos_app_new/services/firebase_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DebugFCMButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        // Crear resultado detallado para mostrar en pantalla
        List<String> resultados = [];
        
        resultados.add('🔧 === DEBUG FCM INICIADO ===');
        
        try {
          // 1. Verificar SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final accessToken = prefs.getString('access_token');
          
          if (accessToken != null) {
            resultados.add('✅ Access Token: ENCONTRADO');
            resultados.add('📝 Preview: ${accessToken.substring(0, 20)}...');
          } else {
            resultados.add('❌ Access Token: NO ENCONTRADO');
          }
          
          // 2. Intentar Firebase
          try {
            await FirebaseNotificationService.initialize();
            resultados.add('✅ Firebase: INICIALIZADO');
            
            // 3. Verificar si hay token FCM
            final fcmToken = FirebaseNotificationService.currentToken;
            if (fcmToken != null) {
              resultados.add('✅ FCM Token: ENCONTRADO');
              resultados.add('📝 Preview: ${fcmToken.substring(0, 20)}...');
              
              // 4. INTENTAR LLAMAR API DIRECTO
              if (accessToken != null) {
                try {
                  final response = await http.post(
                    Uri.parse('https://gallerappback-production.up.railway.app/auth/register-fcm-token'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $accessToken',
                    },
                    body: jsonEncode({
                      'fcm_token': fcmToken,
                      'platform': 'android',
                      'device_info': 'DEBUG MANUAL MÓVIL',
                    }),
                  );
                  
                  resultados.add('📡 API Status: ${response.statusCode}');
                  resultados.add('📡 API Response: ${response.body}');
                } catch (e) {
                  resultados.add('❌ API Error: $e');
                }
              }
            } else {
              resultados.add('❌ FCM Token: NULL');
            }
          } catch (e) {
            resultados.add('❌ Firebase Error: $e');
          }
          
        } catch (e) {
          resultados.add('❌ General Error: $e');
        }
        
        // Mostrar resultados en pantalla completa
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('Debug FCM Results')),
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: resultados.map((resultado) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      resultado,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        color: resultado.startsWith('❌') ? Colors.red :
                               resultado.startsWith('✅') ? Colors.green :
                               Colors.black87,
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
          ),
        );
      },
      label: Text('DEBUG FCM'),
      icon: Icon(Icons.bug_report),
    );
  }
}