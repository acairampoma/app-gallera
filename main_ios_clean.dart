import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gallos_app_new/shared/theme/app_colors.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/perfil/screens/perfil_screen.dart';
import 'features/pedigri/screens/pedigri_screen.dart';
import 'features/pedigri/screens/add_gallo_multistep_screen.dart';
import 'features/reportes/screens/reportes_screen.dart';
import 'features/inversiones/screens/inversiones_screen.dart';
import 'features/planes/screens/planes_screen.dart';
import 'services/auth_service.dart';
import 'services/connection_service.dart';

// 🍎 CONFIGURACIÓN LIMPIA PARA iOS
// ❌ REMOVIDOS PARA COMPILACIÓN EXITOSA:
// - Firebase (firebase_core, firebase_messaging)  
// - PDF (printing, pdf)
// - Share (share_plus)
// - Notifications (flutter_local_notifications)
// - Permissions (permission_handler)
// - Video (video_player)
// - File operations (path_provider, url_launcher)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🍎 === INICIANDO CASTA DE GALLOS - iOS CLEAN ===');
  
  // 🚀 Inicializar servicios básicos SOLAMENTE
  await AuthService.instance.initialize();
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
      title: 'Casta de Gallos - iOS Clean Build',
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
        // ✅ CardTheme compatible con Flutter 3.16
        cardTheme: const CardTheme(
          elevation: 4,
          margin: EdgeInsets.all(8),
        ),
      ),
      
      // 🔐 NAVEGACIÓN SIMPLE Y DIRECTA
      initialRoute: AuthService.instance.isAuthenticated ? '/home' : '/login',
      
      // 🛣️ Rutas iOS LIMPIAS (sin funcionalidades problemáticas)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/pedigri': (context) => const PedigriScreen(),
        '/add-gallo-multistep': (context) => const AddGalloMultistepScreen(),
        '/reportes': (context) => const ReportesScreen(),
        '/inversiones': (context) => const InversionesScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/planes': (context) => const PlanesScreen(),
        // ❌ REMOVIDAS RUTAS QUE CAUSAN PROBLEMAS:
        // '/vacunas': VacunasScreenReal (usa PDF)
        // '/topes': TopesGallosScreen (usa PDF)  
        // '/peleas': PeleasGallosScreen (usa PDF)
        // '/admin-dashboard': AdminDashboardScreen (usa notifications)
      },
    );
  }
}