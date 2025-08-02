import 'package:flutter/material.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/auth_service_real.dart';
import '../../../services/api_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _isLoading = true;
  UserModel? _user;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      await AuthService.instance.loadCurrentUser();
      setState(() {
        _user = AuthService.instance.currentUser;
        _profile = AuthService.instance.currentProfile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return BaseScreen(
      title: 'Mi Perfil',
      subtitle: 'Conectado al Backend Railway',
      currentIndex: 3, // Perfil section
      child: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildBackendInfo(),
              const SizedBox(height: 24),
              _buildStatsCard(),
              const SizedBox(height: 24),
              _buildMenuOptions(context),
              const SizedBox(height: 24),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: _profile?.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            _profile!.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primary,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _user?.isPremium == true ? Colors.amber : Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _user?.isPremium == true ? Icons.star : Icons.verified,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Nombre
            Text(
              _profile?.nombreCompleto ?? 'Usuario',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Email
            Text(
              _user?.email ?? 'email@ejemplo.com',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            
            // Galpón
            if (_profile?.nombreGalpon != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🏠 ${_profile!.nombreGalpon}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Stats básicos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('ID Usuario', '${_user?.id ?? 0}'),
                _buildStatItem('Ciudad', _profile?.ciudad ?? 'Lima'),
                _buildStatItem('Estado', _user?.isActive == true ? 'Activo' : 'Inactivo'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackendInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_done, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Conectado al Backend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('🌐 API:', 'Railway PostgreSQL'),
            _buildInfoRow('🔐 Auth:', 'JWT Token Activo'),
            _buildInfoRow('📧 Verificado:', _user?.isVerified == true ? 'Sí' : 'No'),
            _buildInfoRow('💎 Premium:', _user?.isPremium == true ? 'Sí' : 'No'),
            _buildInfoRow('📅 Registro:', _formatDate(_user?.createdAt)),
            _buildInfoRow('🔄 Último Login:', _formatDate(_user?.lastLogin)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas (Próximamente)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStat(
                    'Gallos',
                    '0',
                    Icons.pets,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickStat(
                    'Peleas',
                    '0',
                    Icons.sports_mma,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    final menuOptions = [
      _MenuOption(
        icon: Icons.edit,
        title: 'Editar Perfil',
        subtitle: 'Actualizar información personal',
        onTap: () => _showEditProfileDialog(),
      ),
      _MenuOption(
        icon: Icons.refresh,
        title: 'Actualizar Datos',
        subtitle: 'Sincronizar con el servidor',
        onTap: () => _loadUserData(),
      ),
      _MenuOption(
        icon: Icons.cloud_upload,
        title: 'Subir Avatar',
        subtitle: 'Cambiar foto de perfil (Próximamente)',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload de avatar próximamente')),
          );
        },
      ),
      _MenuOption(
        icon: Icons.notifications,
        title: 'Notificaciones',
        subtitle: 'Configurar alertas y recordatorios',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuración de notificaciones próximamente')),
          );
        },
      ),
      _MenuOption(
        icon: Icons.help,
        title: 'Ayuda y Soporte',
        subtitle: 'Guías de uso y contacto',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Centro de ayuda próximamente')),
          );
        },
      ),
      _MenuOption(
        icon: Icons.info,
        title: 'Acerca de',
        subtitle: 'Versión 1.0.0 - Backend Railway',
        onTap: () {
          _showAboutDialog(context);
        },
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: menuOptions.map((option) => _buildMenuOption(option)).toList(),
      ),
    );
  }

  Widget _buildMenuOption(_MenuOption option) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          option.icon,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        option.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(option.subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: option.onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nombreController = TextEditingController(text: _profile?.nombreCompleto);
    final telefonoController = TextEditingController(text: _profile?.telefono);
    final galponController = TextEditingController(text: _profile?.nombreGalpon);
    final biografiaController = TextEditingController(text: _profile?.biografia);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: galponController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Galpón',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: biografiaController,
                decoration: const InputDecoration(
                  labelText: 'Biografía',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await AuthService.instance.updateProfile(
                nombreCompleto: nombreController.text.trim().isNotEmpty 
                    ? nombreController.text.trim() 
                    : null,
                telefono: telefonoController.text.trim().isNotEmpty 
                    ? telefonoController.text.trim() 
                    : null,
                nombreGalpon: galponController.text.trim().isNotEmpty 
                    ? galponController.text.trim() 
                    : null,
                biografia: biografiaController.text.trim().isNotEmpty 
                    ? biografiaController.text.trim() 
                    : null,
              );

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Perfil actualizado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadUserData();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Error actualizando perfil'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GalloApp Pro'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versión: 1.0.0'),
            SizedBox(height: 8),
            Text('Backend: Railway PostgreSQL + JWT'),
            SizedBox(height: 8),
            Text('Storage: Cloudinary CDN'),
            SizedBox(height: 8),
            Text('API: FastAPI Python'),
            SizedBox(height: 16),
            Text('Aplicación profesional para gestión integral de gallos de pelea con backend real.'),
            SizedBox(height: 16),
            Text('Desarrollado por:'),
            Text('Alan Cairampoma Carrillo', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('© 2025 - Todos los derechos reservados'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
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
          content: const Text('¿Estás seguro que deseas cerrar sesión?\n\nEsto te desconectará del backend.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Mostrar loading
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cerrando sesión...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Logout del backend
                await AuthService.instance.logout();
                
                if (context.mounted) {
                  // Navegar al login
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}

class _MenuOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _MenuOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
