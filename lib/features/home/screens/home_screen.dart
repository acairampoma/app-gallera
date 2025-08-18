import 'package:flutter/material.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/admin_notification_service.dart';
import '../../../services/user_notification_service.dart';
import '../../../features/planes/screens/planes_screen.dart'; // ✅ CAMBIADO A PLANES REAL

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _notificationsInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeNotifications();
  }

  Future<void> _loadUserData() async {
    try {
      // Cargar datos del usuario desde el backend
      await AuthService.instance.loadCurrentUser();
      if (mounted) {
        setState(() {}); // Actualizar UI
      }
    } catch (e) {
      print('💥 Error cargando datos usuario: $e');
    }
  }
  
  Future<void> _initializeNotifications() async {
    if (_notificationsInitialized) return;
    
    print('🚀 [HomeScreen] Inicializando notificaciones...');
    
    // Esperar un poco a que el HomeScreen se cargue completamente
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!mounted) {
      print('⚠️ [HomeScreen] Widget no montado - cancelando notificaciones');
      return;
    }
    
    try {
      final isAdmin = AuthService.instance.isAdmin;
      print('🚀 [HomeScreen] Usuario admin: $isAdmin');
      
      // 🔔 FIREBASE NOTIFICACIONES YA INICIALIZADAS EN LOGIN
      print('🔥 [HomeScreen] Usando Firebase para notificaciones - polling deshabilitado');
      
      // Ya no necesitamos polling - Firebase maneja todo automáticamente
      
      _notificationsInitialized = true;
      print('✅ [HomeScreen] Notificaciones inicializadas exitosamente');
      
    } catch (e) {
      print('❌ [HomeScreen] Error inicializando notificaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Casta de Gallos',
      subtitle: 'Gestión Profesional de Gallos de Pelea',
      currentIndex: 0,
      showQuickNav: true,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildMenuGrid(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserName() {
    final user = AuthService.instance.currentUser;
    final profile = AuthService.instance.currentProfile;
    
    return Text(
      profile?.nombreCompleto ?? user?.email ?? 'Usuario',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildWelcomeCard() {
    final user = AuthService.instance.currentUser;
    final profile = AuthService.instance.currentProfile;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 📷 AVATAR CON FOTO DE PERFIL (igual que ProfileScreen)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: profile?.avatarUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.network(
                        profile!.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 35,
                            color: AppColors.primary,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 35,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildUserName(),
                  // 🏠 MOSTRAR GALPÓN SI EXISTE
                  if (profile?.nombreGalpon != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.home,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Galpon ${profile!.nombreGalpon!}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // 👑 BADGE DE ESTADO (Premium/Verificado)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: user?.isPremium == true ? Colors.amber : Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                user?.isPremium == true ? Icons.star : Icons.verified,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menuItems = [
      _MenuItem(
        title: 'Pedigrí',
        imagePath: 'assets/images/modulos/PEDIGRI.webp',
        color: Colors.blue,
        subtitle: 'Registro genealógico',
        onTap: () {
          Navigator.pushNamed(context, '/pedigri');
        },
      ),
      _MenuItem(
        title: 'Vacunas',
        imagePath: 'assets/images/modulos/VACUNAS.webp',
        color: Colors.green,
        subtitle: 'Control sanitario',
        onTap: () {
          Navigator.pushNamed(context, '/vacunas');
        },
      ),
      _MenuItem(
        title: 'Topes',
        imagePath: 'assets/images/modulos/TOPES.webp',
        color: Colors.orange,
        subtitle: 'Entrenamientos',
        onTap: () {
          Navigator.pushNamed(context, '/topes');
        },
      ),
      _MenuItem(
        title: 'Peleas',
        imagePath: 'assets/images/modulos/PELEA.webp',
        color: Colors.red,
        subtitle: 'Combates',
        onTap: () {
          Navigator.pushNamed(context, '/peleas');
        },
      ),
      _MenuItem(
        title: 'Reportes',
        imagePath: 'assets/images/modulos/REPORTES.webp',
        color: Colors.purple,
        subtitle: 'Estadísticas',
        onTap: () {
          Navigator.pushNamed(context, '/reportes');
        },
      ),
      _MenuItem(
        title: 'Inversiones',
        imagePath: 'assets/images/modulos/INVERSION.webp',
        color: Colors.teal,
        subtitle: 'Gastos mensuales',
        onTap: () {
          Navigator.pushNamed(context, '/inversiones');
        },
      ),
      _MenuItem(
        title: 'Suscripciones',
        imagePath: 'assets/images/modulos/SUSCRIPCION.webp',
        color: Colors.amber,
        subtitle: 'Planes y precios',
        onTap: () async {
          try {
            print('[Home] Navegando a SuscripcionScreen...');
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlanesScreen(), // ✅ CAMBIADO A PLANES REAL
              ),
            );
            print('[Home] Regresó de PlanesScreen (API Railway)');
          } catch (e) {
            print('[Home] Error al navegar a SuscripcionScreen: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo abrir Suscripciones. Intenta nuevamente.'),
                ),
              );
            }
          }
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItemCard(item);
      },
    );
  }

  Widget _buildMenuItemCard(_MenuItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ IMAGEN DEL MÓDULO CON TAMAÑO PERFECTO
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    item.imagePath!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 🚨 FALLBACK SI NO ENCUENTRA LA IMAGEN
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 30,
                          color: item.color,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (item.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final String? imagePath; // 🖼️ REEMPLAZAMOS IconData por imagePath
  final Color color;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.title,
    this.imagePath, // 🖼️ OPCIONAL para mantener compatibilidad
    required this.color,
    this.subtitle,
    required this.onTap,
  });
}
