import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/app_colors.dart';
import 'services/auth_service_real.dart';
import 'features/auth/screens/login_screen_real.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🚀 Inicializar AuthService
  await AuthService.instance.initialize();
  
  runApp(const GalloAppReal());
}

class GalloAppReal extends StatelessWidget {
  const GalloAppReal({super.key});

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
      title: 'GalloApp Pro - Backend Real',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // 🔐 Verificar estado de autenticación inicial
      home: StreamBuilder<bool>(
        stream: AuthService.instance.authStateStream,
        initialData: AuthService.instance.isAuthenticated,
        builder: (context, snapshot) {
          final isAuthenticated = snapshot.data ?? false;
          
          if (isAuthenticated) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      
      // 🛣️ Rutas
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
