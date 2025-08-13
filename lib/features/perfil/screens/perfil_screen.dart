import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import '../../../services/admin_service.dart';
import '../../../services/admin_notification_service.dart';
import '../../../utils/password_validator.dart';
import '../../auth/screens/login_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _isLoading = true;
  UserModel? _user;
  ProfileModel? _profile;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔐 CAMBIAR CONTRASEÑA
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Cambiar Contraseña'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña Actual',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    border: const OutlineInputBorder(),
                    helperText: 'Debe tener: letra + número, mín. 6 caracteres',
                    helperMaxLines: 2,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nueva Contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
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
                // 🔐 VALIDACIONES ROBUSTAS CON PasswordValidator
                
                // Validar contraseña actual
                if (currentPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Ingresa tu contraseña actual'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                // Validar nueva contraseña con validador robusto
                final passwordError = PasswordValidator.validatePassword(newPasswordController.text);
                if (passwordError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ $passwordError'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  return;
                }
                
                // Validar confirmación
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Las contraseñas no coinciden'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                // 🚀 USAR API REAL PARA CAMBIAR CONTRASEÑA
                Navigator.pop(context);
                
                // Mostrar loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('🔐 Cambiando contraseña...'),
                      ],
                    ),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 10),
                  ),
                );
                
                try {
                  final success = await AuthService.instance.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Contraseña cambiada exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Error: Contraseña actual incorrecta'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } on ApiException catch (e) {
                  if (mounted) {
                    String errorMessage;
                    if (e.message.contains('Not Found') || e.message.contains('404')) {
                      errorMessage = '❌ Endpoint no disponible. Haz deploy del backend actualizado.';
                    } else if (e.message.contains('actual incorrecta')) {
                      errorMessage = '❌ Contraseña actual incorrecta';
                    } else if (e.message.contains('6 caracteres') || e.message.contains('letra') || e.message.contains('número')) {
                      errorMessage = '❌ Nueva contraseña: ${e.message}';
                    } else {
                      errorMessage = '❌ Error: ${e.message}';
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error de conexión: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }

  // 📱 CONTACTAR WHATSAPP
  void _contactWhatsApp() async {
    const phoneNumber = '932259291';
    const message = '¡Hola! Necesito ayuda con la app Casta de Gallos';
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📱 Contactar por WhatsApp:'),
              Text('Teléfono: $phoneNumber'),
              Text('Mensaje: $message'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Abrir',
            textColor: Colors.white,
            onPressed: () {
              print('Abriendo WhatsApp: $whatsappUrl');
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error abriendo WhatsApp: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              _buildAdminButton(context),
              const SizedBox(height: 16),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }
  
  // 📷 TOMAR FOTO CON CÁMARA
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Compresión para optimizar subida
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image != null) {
        await _uploadAvatar(File(image.path));
      }
    } catch (e) {
      print('💥 Error tomando foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accediendo a la cámara: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // 🇬 ELEGIR DE GALERÍA
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compresión para optimizar subida
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image != null) {
        await _uploadAvatar(File(image.path));
      }
    } catch (e) {
      print('💥 Error seleccionando imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accediendo a la galería: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // ⬆️ SUBIR AVATAR A CLOUDINARY
  Future<void> _uploadAvatar(File imageFile) async {
    setState(() {
      _isUploadingAvatar = true;
    });
    
    try {
      // Mostrar mensaje de subida
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('📷 Subiendo imagen a Cloudinary...'),
            ],
          ),
          duration: Duration(seconds: 10),
          backgroundColor: Colors.blue,
        ),
      );
      
      // Subir avatar usando AuthService
      final success = await AuthService.instance.uploadAvatar(imageFile);
      
      setState(() {
        _isUploadingAvatar = false;
      });
      
      if (success && mounted) {
        // Actualizar perfil en UI
        setState(() {
          _profile = AuthService.instance.currentProfile;
        });
        
        // Mostrar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ Avatar actualizado exitosamente'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error subiendo avatar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingAvatar = false;
      });
      
      print('💥 Error subiendo avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // 🗑️ ELIMINAR AVATAR
  Future<void> _removeAvatar() async {
    try {
      // Mostrar diálogo de confirmación
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar Avatar'),
          content: const Text('¿Estás seguro que deseas eliminar tu avatar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      
      if (confirm == true) {
        // Mostrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('🗑️ Eliminando avatar...'),
              ],
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
        
        final success = await AuthService.instance.removeAvatar();
        
        if (success && mounted) {
          // Actualizar perfil en UI
          setState(() {
            _profile = AuthService.instance.currentProfile;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Avatar eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error eliminando avatar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('💥 Error eliminando avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            // Avatar con botón para cambiar
            Stack(
              children: [
                GestureDetector(
                  onTap: () => _showAvatarOptions(),
                  child: Container(
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
                // Botón de cámara
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: GestureDetector(
                    onTap: () => _showAvatarOptions(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 14,
                      ),
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
        color: Colors.blue,
        onTap: () => _showEditProfileDialog(),
      ),
      _MenuOption(
        icon: Icons.lock,
        title: 'Cambiar Contraseña',
        subtitle: 'Actualizar clave de acceso',
        color: Colors.orange,
        onTap: () => _showChangePasswordDialog(),
      ),
      _MenuOption(
        icon: Icons.support_agent,
        title: 'Ayuda y Soporte',
        subtitle: 'Contactar vía WhatsApp',
        color: Colors.green,
        onTap: () => _contactWhatsApp(),
      ),
      _MenuOption(
        icon: Icons.info,
        title: 'Acerca de',
        subtitle: 'Versión 1.0.0 - Backend Railway',
        color: Colors.grey,
        onTap: () => _showAboutDialog(context),
      ),
    ];

    return Column(
      children: menuOptions.map((option) => _buildMenuOptionCard(option)).toList(),
    );
  }

  Widget _buildMenuOptionCard(_MenuOption option) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: option.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            option.icon,
            color: option.color,
            size: 24,
          ),
        ),
        title: Text(
          option.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          option.subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: option.onTap,
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context) {
    // Solo mostrar si es admin real
    final userEmail = AuthService.instance.currentUser?.email;
    if (userEmail != 'juan.salas.nuevo@galloapp.com') {
      return const SizedBox.shrink();
    }
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AdminNotificationService.obtenerPagosPendientes(),
      builder: (context, snapshot) {
        final pagosPendientes = snapshot.data?.length ?? 0;
        
        return Container(
          width: double.infinity,
          child: Stack(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    print('[Perfil] Admin navegando a Panel Admin...');
                    await _navegarAPanelAdmin(context);
                    print('[Perfil] Admin regresó del Panel Admin');
                  } catch (e) {
                    print('[Perfil] Error al abrir Panel Admin: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir el Panel Admin. Intenta nuevamente.'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('👑 Panel de Administración'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Badge de notificaciones pendientes
              if (pagosPendientes > 0)
                Positioned(
                  right: 12,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Text(
                      '$pagosPendientes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cambiar Avatar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Tomar Foto'),
              subtitle: const Text('Usar cámara del dispositivo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Elegir de Galería'),
              subtitle: const Text('Seleccionar imagen existente'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            if (_profile?.avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar Avatar'),
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Casta de Gallos'),
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
            SizedBox(height: 8),
            Text('Contacto: 932259291'),
            SizedBox(height: 16),
            Text('© 2025 - Todos los derechos reservados'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
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
                // Cerrar diálogo
                Navigator.of(context).pop();
                
                // SOLUCIÓN DEFINITIVA: Guardar Navigator antes del logout
                final navigator = Navigator.of(context, rootNavigator: true);
                
                try {
                  // Ejecutar logout
                  await AuthService.instance.logout();
                  
                  // Limpiar SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  
                } catch (e) {
                  print('💥 Error en logout: $e');
                }
                
                // NAVEGAR SIEMPRE (con o sin error) usando el Navigator guardado
                // Esto evita el error "deactivated widget"
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
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

  // ========================================
  // MÉTODOS ADMIN
  // ========================================

  Future<bool> _esUsuarioAdmin() async {
    try {
      final userEmail = await AuthService.instance.getCurrentUserEmail();
      print('🔍 EMAIL ACTUAL: $userEmail');
      print('🔍 COMPARANDO CON: juan.salas.nuevo@galloapp.com');
      final esAdmin = userEmail == 'juan.salas.nuevo@galloapp.com';
      print('🔍 ES ADMIN: $esAdmin');
      return esAdmin;
    } catch (e) {
      print('❌ ERROR VERIFICANDO ADMIN: $e');
      return false;
    }
  }

  Future<void> _navegarAPanelAdmin(BuildContext context) async {
    try {
      print('🚀 INTENTANDO NAVEGAR AL PANEL ADMIN...');
      
      // Verificar email primero
      final userEmail = await AuthService.instance.getCurrentUserEmail();
      print('📧 Email del usuario: $userEmail');
      
      // Por ahora, navegar directamente para debug
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AdminDashboardScreen(),
        ),
      );
    } catch (e) {
      print('❌ ERROR NAVEGANDO AL PANEL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accediendo al panel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _MenuOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _MenuOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
