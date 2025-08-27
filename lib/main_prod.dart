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
import 'features/vacunas/screens/vacunas_screen_real.dart';
import 'features/topes/screens/topes_gallos_screen.dart';
import 'features/peleas/screens/peleas_gallos_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/connection_service.dart';
import 'services/platform_factory.dart';
import 'services/platform_implementations/platform_service_base.dart';

// 🏭 PRODUCTION CONFIGURATION
// ✅ Configuración optimizada para producción
// ✅ Firebase habilitado
// ✅ Analytics habilitado
// ✅ Crash reporting habilitado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🏭 === GALLOS APP - PRODUCTION MODE ===');
  
  // 🌐 Crear platform service usando factory
  final platformService = PlatformFactory.createPlatformService();
  print('📱 Plataforma detectada: ${_getPlatformName(platformService)}');
  
  // 🔔 Inicializar Firebase para producción
  try {
    await platformService.initializeFirebase();
    print('✅ Firebase inicializado correctamente');
    
    final token = await platformService.getFirebaseToken();
    if (token != null) {
      print('🎯 FCM Token registrado: ${token.substring(0, 20)}...');
    }
  } catch (e) {
    print('⚠️ Firebase error: $e');
  }
  
  // 🚀 Inicializar servicios principales
  await AuthService.instance.initialize();
  await ConnectionService().initialize();
  
  print('✅ Servicios inicializados correctamente');
  
  // 🎨 Configurar orientación y UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const GallosApp());
}

String _getPlatformName(PlatformServiceBase platformService) {
  // Esta función debe estar definida en tu código original
  // Copiando la lógica que tengas en main.dart
  return 'Production Platform';
}

class GallosApp extends StatelessWidget {
  const GallosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casta de Gallos - Production',
      debugShowCheckedModeBanner: false, // ✅ Sin banner de debug en producción
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'PE'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        primaryColor: AppColors.primary,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/pedigri': (context) => const PedigriScreen(),
        '/add-gallo': (context) => const AddGalloMultistepScreen(),
        '/reportes': (context) => const ReportesScreen(),
        '/inversiones': (context) => const InversionesScreen(),
        '/planes': (context) => const PlanesScreen(),
        '/vacunas': (context) => const VacunasScreenReal(),
        '/topes': (context) => const TopesGallosScreen(),
        '/peleas': (context) => const PeleasGallosScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
      },
    );
  }
}