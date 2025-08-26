import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gallos_app_new/shared/theme/app_colors.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/perfil/screens/perfil_screen.dart';
import 'features/pedigri/screens/pedigri_screen.dart';
import 'features/pedigri/screens/add_gallo_multistep_screen.dart'; // 🆕 NUEVA PANTALLA
import 'features/vacunas/screens/vacunas_screen_real.dart';
import 'features/topes/screens/topes_gallos_screen.dart';
import 'features/peleas/screens/peleas_gallos_screen.dart';
import 'features/reportes/screens/reportes_screen.dart';
import 'features/inversiones/screens/inversiones_screen.dart';
import 'features/planes/screens/planes_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/connection_service.dart';
import 'services/firebase_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 INICIALIZAR FIREBASE Y OBTENER TOKEN REAL
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase Core inicializado CON OPCIONES CORRECTAS');
    
    // Obtener token FCM real
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('🎯 TOKEN FCM REAL GENERADO:');
      print(token);
      print('📋 COPIA ESTE TOKEN PARA FIREBASE CONSOLE');
    } else {
      print('❌ No se pudo generar token FCM');
    }
  } catch (e) {
    print('⚠️ Error con Firebase: $e');
  }
  
  // 🚀 Inicializar AuthService REAL
  await AuthService.instance.initialize();
  
  // 🌐 Inicializar ConnectionService
  await ConnectionService().initialize();
  
  runApp(const CastaDeGallosApp());
}

class CastaDeGallosApp extends StatelessWidget {
  const CastaDeGallosApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurar statusBar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Casta de Gallos - Criadores Profesionales',
      debugShowCheckedModeBanner: false,
      
      // 🌐 LOCALIZACIONES HABILITADAS
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés
      ],
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          accentColor: AppColors.accent,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: AppColors.surface,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
      
      // 🔐 NAVEGACIÓN SIMPLE Y DIRECTA usando initialRoute
      initialRoute: AuthService.instance.isAuthenticated ? '/home' : '/login',
      
      // 🛣️ Rutas COMPLETAS
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/pedigri': (context) => const PedigriScreen(),
        '/add-gallo-multistep': (context) => const AddGalloMultistepScreen(),
        '/reportes': (context) => const ReportesScreen(),
        '/inversiones': (context) => const InversionesScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/vacunas': (context) => const VacunasScreenReal(),
        '/topes': (context) => const TopesGallosScreen(),
        '/peleas': (context) => const PeleasGallosScreen(),
        '/planes': (context) => const PlanesScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        // Suscripciones se navega directamente con MaterialPageRoute
      },
    );
  }
}
