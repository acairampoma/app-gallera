import 'package:flutter/material.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/widgets/adaptive_layout_builder.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../features/planes/screens/planes_screen.dart';
import '../../../config/adaptive_ui_config.dart';

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
    return AdaptiveLayoutBuilder(
      mobile: _buildMobileContent(context),
      tablet: _buildTabletContent(context),
    );
  }
  
  Widget _buildMobileContent(BuildContext context) {
    return FutureBuilder<AdaptiveUIConfig>(
      future: AdaptiveUIManager.getOptimalConfig(),
      builder: (context, snapshot) {
        final config = snapshot.data ?? AdaptiveUIConfig.standard();
        
        return SingleChildScrollView(
          padding: config.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: config.gridSpacing * 0.5),
              _buildWelcomeCard(),
              SizedBox(height: config.gridSpacing * 1.5),
              _buildMenuGrid(context),
              SizedBox(height: config.gridSpacing * 1.5),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTabletContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // 🎨 Layout horizontal para tablet
          ResponsiveRowColumn(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel izquierdo: Bienvenida y perfil
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildTabletWelcomeCard(),
                    const SizedBox(height: 24),
                    _buildTabletStatsCard(),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              
              // Panel derecho: Menú principal
              Expanded(
                flex: 2,
                child: _buildTabletMenuGrid(context),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
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
                Text(
                  'Bienvenido',
                  style: TextStyle(
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

  Widget _buildTabletWelcomeCard() {
    final user = AuthService.instance.currentUser;
    final profile = AuthService.instance.currentProfile;
    
    return ResponsiveCard(
      child: Column(
        children: [
          // Avatar más grande para tablet
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
            ),
            child: profile?.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      profile!.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(height: 20),
          
          // Información del usuario
          ResponsiveText(
            'Bienvenido',
            baseFontSize: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          
          ResponsiveText(
            profile?.nombreCompleto ?? user?.email ?? 'Usuario',
            baseFontSize: 20,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          
          if (profile?.nombreGalpon != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  ResponsiveText(
                    profile!.nombreGalpon!,
                    baseFontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Badge de estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: user?.isPremium == true ? Colors.amber : Colors.green,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: (user?.isPremium == true ? Colors.amber : Colors.green).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user?.isPremium == true ? Icons.star : Icons.verified,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                ResponsiveText(
                  user?.isPremium == true ? 'Premium' : 'Verificado',
                  baseFontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabletStatsCard() {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Estadísticas Rápidas',
            baseFontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          
          _buildStatItem(
            icon: Icons.pets,
            label: 'Gallos',
            value: '12',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildStatItem(
            icon: Icons.medical_services,
            label: 'Vacunas',
            value: '8',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildStatItem(
            icon: Icons.sports_martial_arts,
            label: 'Peleas',
            value: '5',
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildStatItem(
            icon: Icons.trending_up,
            label: 'Victorias',
            value: '3',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                label,
                baseFontSize: 12,
                color: Colors.grey.shade600,
              ),
              ResponsiveText(
                value,
                baseFontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTabletMenuGrid(BuildContext context) {
    final menuItems = _getMenuItems(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Módulos del Sistema',
          baseFontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 24),
        
        ResponsiveGrid(
          children: menuItems.map((item) => _buildTabletMenuItemCard(item)).toList(),
          spacing: 24.0,
          runSpacing: 24.0,
          forceColumns: 3,
        ),
      ],
    );
  }
  
  Widget _buildTabletMenuItemCard(_MenuItem item) {
    return ResponsiveCard(
      elevation: 4.0,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen más grande para tablet
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    item.imagePath!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: item.color,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Título más grande para tablet
              ResponsiveText(
                item.title,
                baseFontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<_MenuItem> _getMenuItems(BuildContext context) {
    return [
      _MenuItem(
        title: 'Pedigrí',
        imagePath: 'assets/images/modulos/PEDIGRI.webp',
        color: Colors.blue,
        onTap: () => Navigator.pushNamed(context, '/pedigri'),
      ),
      _MenuItem(
        title: 'Vacunas',
        imagePath: 'assets/images/modulos/VACUNAS.webp',
        color: Colors.green,
        onTap: () => Navigator.pushNamed(context, '/vacunas'),
      ),
      _MenuItem(
        title: 'Topes',
        imagePath: 'assets/images/modulos/TOPES.webp',
        color: Colors.orange,
        onTap: () => Navigator.pushNamed(context, '/topes'),
      ),
      _MenuItem(
        title: 'Peleas',
        imagePath: 'assets/images/modulos/PELEA.webp',
        color: Colors.red,
        onTap: () => Navigator.pushNamed(context, '/peleas'),
      ),
      _MenuItem(
        title: 'Reportes',
        imagePath: 'assets/images/modulos/REPORTES.webp',
        color: Colors.purple,
        onTap: () => Navigator.pushNamed(context, '/reportes'),
      ),
      _MenuItem(
        title: 'Inversiones',
        imagePath: 'assets/images/modulos/INVERSION.webp',
        color: Colors.teal,
        onTap: () => Navigator.pushNamed(context, '/inversiones'),
      ),
      _MenuItem(
        title: 'Suscripciones',
        imagePath: 'assets/images/modulos/SUSCRIPCION.webp',
        color: Colors.amber,
        onTap: () async {
          try {
            print('[Home] Navegando a SuscripcionScreen...');
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlanesScreen(),
              ),
            );
            print('[Home] Regresó de PlanesScreen (API Railway)');
          } catch (e) {
            print('[Home] Error al navegar a SuscripcionScreen: $e');
            if (context.mounted) {
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
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menuItems = _getMenuItems(context);

    return FutureBuilder<AdaptiveUIConfig>(
      future: AdaptiveUIManager.getOptimalConfig(),
      builder: (context, snapshot) {
        final config = snapshot.data ?? AdaptiveUIConfig.standard();
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: config.gridSpacing,
            mainAxisSpacing: config.gridSpacing,
            childAspectRatio: 1.2,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return _buildMenuItemCard(item);
          },
        );
      },
    );
  }

  Widget _buildMenuItemCard(_MenuItem item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 📐 RESPONSIVE: Calcular tamaños basados en espacio disponible
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = constraints.maxWidth;
        
        // 🎯 TAMAÑOS ADAPTATIVOS BASADOS EN ANCHO DE PANTALLA
        double imageSize;
        double titleFontSize;
        double spacing;
        
        if (screenWidth < 360) {
          // 📱 Pantallas muy pequeñas (iPhone SE, Android compactos)
          imageSize = cardWidth * 0.4;  // Reducido de 0.5
          titleFontSize = 11.0;  // Reducido de 12
          spacing = 6.0;  // Reducido de 8
        } else if (screenWidth < 400) {
          // 📱 Pantallas pequeñas estándar
          imageSize = cardWidth * 0.45;  // Reducido de 0.55
          titleFontSize = 12.0;  // Reducido de 13
          spacing = 8.0;  // Reducido de 10
        } else if (screenWidth < 600) {
          // 📱 Pantallas normales (mayoría Android/iPhone)
          imageSize = cardWidth * 0.48;  // Reducido de 0.6
          titleFontSize = 13.0;  // Reducido de 14
          spacing = 10.0;  // Reducido de 12
        } else {
          // 📱 Pantallas grandes (tablets)
          imageSize = cardWidth * 0.38;  // Reducido de 0.45
          titleFontSize = 14.0;  // Reducido de 15
          spacing = 12.0;  // Reducido de 14
        }
        
        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(spacing),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🖼️ IMAGEN MÁS PEQUEÑA PARA DAR ESPACIO AL TÍTULO
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item.imagePath!,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              size: imageSize * 0.4,
                              color: item.color,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 0.6),
                  
                  // 📝 TÍTULO CON PADDING HORIZONTAL PARA EVITAR DESBORDE
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final String title;
  final String? imagePath; // 🖼️ REEMPLAZAMOS IconData por imagePath
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.title,
    this.imagePath, // 🖼️ OPCIONAL para mantener compatibilidad
    required this.color,
    required this.onTap,
  });
}
