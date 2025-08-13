import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'quick_nav_fab.dart';
import '../theme/app_colors.dart';
import '../../services/auth_service.dart';
import 'connection/connection_banner.dart';

class BaseScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final int currentIndex;
  final List<Widget>? actions;
  final bool showAppBar;
  final bool showBottomNavBar;
  final Widget? floatingActionButton;
  final bool showQuickNav;

  const BaseScreen({
    Key? key,
    required this.title,
    this.subtitle,
    required this.child,
    this.currentIndex = 0,
    this.actions,
    this.showAppBar = true,
    this.showBottomNavBar = true,
    this.floatingActionButton,
    this.showQuickNav = false,
  }) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🔥 FONDO BLANCO PURO
      body: Column(
        children: [
          // 🌐 Banner de conexión
          const ConnectionBanner(),
          
          // Contenido principal
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: widget.showAppBar
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: widget.actions,
            )
          : null,
              body: widget.child,
              bottomNavigationBar: widget.showBottomNavBar
          ? BottomNavBar(
              currentIndex: widget.currentIndex,
              onTap: (index) {
                // Navegación entre pantallas
                switch (index) {
                  case 0:
                    if (ModalRoute.of(context)?.settings.name != '/home') {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                    break;
                  case 1:
                    // Navegar a pantalla de Pedigrí (Gallos)
                    if (ModalRoute.of(context)?.settings.name != '/pedigri') {
                      Navigator.pushReplacementNamed(context, '/pedigri');
                    }
                    break;
                  case 2:
                    // Navegar a pantalla de Reportes
                    if (ModalRoute.of(context)?.settings.name != '/reportes') {
                      Navigator.pushReplacementNamed(context, '/reportes');
                    }
                    break;
                  case 3:
                    // Navegar a pantalla de Planes
                    if (ModalRoute.of(context)?.settings.name != '/planes') {
                      Navigator.pushReplacementNamed(context, '/planes');
                    }
                    break;
                  case 4:
                    // Navegar a pantalla de Perfil
                    if (ModalRoute.of(context)?.settings.name != '/perfil') {
                      Navigator.pushReplacementNamed(context, '/perfil');
                    }
                    break;
                }
              },
            )
          : null,
              floatingActionButton: widget.floatingActionButton ?? 
                  (widget.showQuickNav ? const QuickNavFAB() : null),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService.instance.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}