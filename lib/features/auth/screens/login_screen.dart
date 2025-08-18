import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../services/auth_service.dart';
import '../../../services/admin_notification_service.dart';
import '../../../services/user_notification_service.dart';
import '../../../utils/password_validator.dart';
import '../../home/screens/home_screen.dart';
import 'forgot_password_screen.dart';

// ==========================================
// 🏆 MÓDULO DE USUARIOS ÉPICO Y COMPLETO
// ==========================================
// Transformación épica de 200 líneas a 1200+ líneas
// Basado en el prototipo HTML profesional

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  // ==========================================
  // 🎯 ESTADO Y CONTROLADORES PRINCIPALES
  // ==========================================
  
  // Navegación entre pantallas
  PageController _pageController = PageController();
  int _currentScreen = 0; // 0: Login, 1: Registro, 2: Dashboard, 3: Stats
  
  // Controladores de login
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();
  bool _isLoginLoading = false;
  bool _obscureLoginPassword = true;
  
  // Controladores de registro épico
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  final _regGalponController = TextEditingController();
  final _regPropietarioController = TextEditingController();
  final _regTelefonoController = TextEditingController();
  final _regFormKey = GlobalKey<FormState>();
  bool _isRegisterLoading = false;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;
  
  // Validaciones en tiempo real
  Map<String, ValidationState> _validations = {
    'email': ValidationState(),
    'password': ValidationState(),
    'confirmPassword': ValidationState(),
    'telefono': ValidationState(),
    'galpon': ValidationState(),
    'propietario': ValidationState(),
  };
  bool _showValidations = false;
  
  // Animaciones épicas
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  // Usuarios mock (simulando base de datos)
  List<UserData> _usuarios = [
    UserData(
      id: 1,
      email: 'juan@gallos.com',
      password: '123456',
      telefono: '987654321',
      nombreGalpon: 'El Palenque Real',
      nombrePropietario: 'Juan Carlos Mendoza',
      fechaRegistro: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];
  
  UserData? _registeredUser; // Para mostrar en pantalla de éxito

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initTestData();
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _regGalponController.dispose();
    _regPropietarioController.dispose();
    _regTelefonoController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
    _fadeController.forward();
  }
  
  void _initTestData() {
    // Formulario limpio para producción
    // _loginEmailController.text = '';
    // _loginPasswordController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildLoginScreen(),
            _buildRegistroScreen(),
            _buildDashboardScreen(),
            _buildEstadisticasScreen(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 🚀 PANTALLA DE LOGIN ÉPICA
  // ==========================================
  
  Widget _buildLoginScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo épico con animación
                  _buildAnimatedLogo(),
                  const SizedBox(height: 40),
                  
                  // Formulario de login épico
                  _buildLoginForm(),
                  const SizedBox(height: 24),
                  
                  // Botón de login épico
                  _buildLoginButton(),
                  const SizedBox(height: 16),
                  
                  // Link de contraseña olvidada
                  _buildForgotPasswordLink(),
                  const SizedBox(height: 20),
                  
                  // Link de registro mejorado
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnimatedLogo() {
    return Container(
      width: 220,
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/logo/logo2.webp',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback si no encuentra la imagen
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🐓', style: TextStyle(fontSize: 56)),
                  SizedBox(height: 8),
                  Text('🎆', style: TextStyle(fontSize: 40)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  // ==========================================
  // 🚀 MÉTODOS DE NAVEGACIÓN Y LÓGICA
  // ==========================================
  
  void _navigateToScreen(int screen) {
    setState(() {
      _currentScreen = screen;
    });
    _pageController.animateToPage(
      screen,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoginLoading = true;
      });

      try {
        final email = _loginEmailController.text.trim();
        final password = _loginPasswordController.text;

        print('🚀 Login con backend real: $email');

        // 🔥 LOGIN REAL CON BACKEND
        final success = await AuthService.instance.login(email, password);

        setState(() {
          _isLoginLoading = false;
        });

        if (success && mounted) {
          // Login exitoso
          final user = AuthService.instance.currentUser;
          final profile = AuthService.instance.currentProfile;
          final isAdmin = AuthService.instance.isAdmin;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isAdmin 
                ? '👑 ¡Bienvenido Administrador!'
                : '¡Bienvenido, ${profile?.nombreCompleto ?? user?.email}!'),
              backgroundColor: isAdmin ? Colors.orange : AppColors.success,
            ),
          );
          
          // Navegar al HomeScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else if (mounted) {
          // Error en login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credenciales incorrectas'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('💥 Error login: $e');
        setState(() {
          _isLoginLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error de conexión: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  void _handleRegister() async {
    if (_regFormKey.currentState!.validate()) {
      setState(() {
        _isRegisterLoading = true;
      });

      final navigator = Navigator.of(context, rootNavigator: true);

      try {
        final email = _regEmailController.text.trim();
        final password = _regPasswordController.text;
        final nombreCompleto = _regPropietarioController.text.trim();
        final telefono = _regTelefonoController.text.trim();
        final nombreGalpon = _regGalponController.text.trim();

        print('🚀 Registro con backend real: $email');

        // REGISTRO REAL CON BACKEND
        final registerResponse = await AuthService.instance.register(
          email: email,
          password: password,
          nombreCompleto: nombreCompleto,
          telefono: telefono.isNotEmpty ? telefono : null,
          nombreGalpon: nombreGalpon.isNotEmpty ? nombreGalpon : null,
        );

        if (registerResponse != null) {
          print('✅ Usuario registrado exitosamente');
          
          // AUTO-LOGIN INMEDIATO
          print('🔄 Iniciando auto-login...');
          final loginSuccess = await AuthService.instance.login(email, password);

          setState(() {
            _isRegisterLoading = false;
          });

          if (loginSuccess) {
            final user = AuthService.instance.currentUser;
            final profile = AuthService.instance.currentProfile;
            
            // Limpiar formulario
            _regEmailController.clear();
            _regPasswordController.clear();
            _regConfirmPasswordController.clear();
            _regGalponController.clear();
            _regPropietarioController.clear();
            _regTelefonoController.clear();

            // NAVEGACIÓN DIRECTA AL HOME
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
              (route) => false,
            );

            // MOSTRAR BIENVENIDA
            await Future.delayed(const Duration(milliseconds: 800));
            
            final currentContext = navigator.context;
            if (currentContext.mounted) {
              ScaffoldMessenger.of(currentContext).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🎉 ¡Bienvenido a GalloApp Pro!', 
                           style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('👤 Usuario: ${profile?.nombreCompleto ?? nombreCompleto}'),
                      Text('🏠 Galpón: ${profile?.nombreGalpon ?? nombreGalpon}'),
                      Text('✅ Cuenta creada y sesión iniciada automáticamente'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          } else {
            // Si falla el auto-login, redirigir al login con credenciales
            print('⚠️ Auto-login falló, redirigiendo a login...');
            
            _loginEmailController.text = email;
            _loginPasswordController.text = password;
            
            _navigateToScreen(0);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✅ ¡Cuenta creada exitosamente!'),
                      Text('👤 Usuario: $nombreCompleto'),
                      Text('📧 Email: $email'),
                      Text('🚀 Credenciales listas - Solo presiona "Iniciar Sesión"'),
                    ],
                  ),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        } else {
          setState(() {
            _isRegisterLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Error en el registro. Inténtalo nuevamente'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('💥 Error registro: $e');
        setState(() {
          _isRegisterLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error de registro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildLoginForm() {
    return Container(
      width: 320,
      child: Column(
        children: [
          // Email épico
          _buildEpicTextField(
            controller: _loginEmailController,
            label: 'Email o Usuario',
            hint: 'juan@gallos.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email o usuario';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Contraseña épica
          _buildEpicTextField(
            controller: _loginPasswordController,
            label: 'Contraseña',
            hint: '••••••••',
            icon: Icons.lock_outlined,
            isPassword: true,
            obscureText: _obscureLoginPassword,
            onTogglePassword: () {
              setState(() {
                _obscureLoginPassword = !_obscureLoginPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildEpicTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoginButton() {
    return Container(
      width: 320,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoginLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: _isLoginLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
  
  Widget _buildForgotPasswordLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta? ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToScreen(1),
          child: Text(
            'Regístrate aquí',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildRegistroScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _navigateToScreen(0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crear Cuenta Nueva',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Únete a Casta de Reyes',
              style: TextStyle(
                fontSize: 12, 
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _regFormKey,
          child: Column(
            children: [
              // Sección Datos de Acceso
              _buildFormSection(
                title: 'Datos de Acceso',
                icon: Icons.lock_outlined,
                children: [
                  _buildEpicTextField(
                    controller: _regEmailController,
                    label: 'Correo Electrónico',
                    hint: 'tu@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El email es obligatorio';
                      }
                      if (!value.contains('@')) {
                        return 'Ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEpicTextField(
                    controller: _regPasswordController,
                    label: 'Contraseña',
                    hint: '••••••••',
                    icon: Icons.lock_outlined,
                    isPassword: true,
                    obscureText: _obscureRegPassword,
                    onTogglePassword: () {
                      setState(() {
                        _obscureRegPassword = !_obscureRegPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La contraseña es obligatoria';
                      }
                      if (value.length < 8) {
                        return 'Mínimo 8 caracteres';
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Debe contener al menos una mayúscula';
                      }
                      if (!value.contains(RegExp(r'[a-z]'))) {
                        return 'Debe contener al menos una minúscula';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Debe contener al menos un número';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'Debe contener al menos un símbolo especial';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirements(),
                  const SizedBox(height: 16),
                  _buildEpicTextField(
                    controller: _regConfirmPasswordController,
                    label: 'Confirmar Contraseña',
                    hint: '••••••••',
                    icon: Icons.lock_outlined,
                    isPassword: true,
                    obscureText: _obscureRegConfirmPassword,
                    onTogglePassword: () {
                      setState(() {
                        _obscureRegConfirmPassword = !_obscureRegConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      if (value != _regPasswordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Sección Datos del Galpón
              _buildFormSection(
                title: 'Datos del Galpón',
                icon: Icons.home_outlined,
                children: [
                  _buildEpicTextField(
                    controller: _regGalponController,
                    label: 'Nombre del Galpón',
                    hint: 'Ej: El Palenque Real',
                    icon: Icons.home_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre del galpón es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEpicTextField(
                    controller: _regPropietarioController,
                    label: 'Nombre del Propietario',
                    hint: 'Tu nombre completo',
                    icon: Icons.person_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tu nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEpicTextField(
                    controller: _regTelefonoController,
                    label: 'Teléfono',
                    hint: '987654321',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El teléfono es obligatorio';
                      }
                      if (value.length != 9) {
                        return 'Debe tener 9 dígitos';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Botón de registro
              _buildRegisterButton(),
              const SizedBox(height: 16),
              
              // Link a login
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La contraseña debe tener:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Mínimo 8 caracteres\n• Una mayúscula y una minúscula\n• Un número y un símbolo especial',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isRegisterLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
        child: _isRegisterLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Crear Cuenta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
  
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToScreen(0),
          child: Text(
            'Inicia sesión',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDashboardScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Sistema activo',
              style: TextStyle(
                fontSize: 12, 
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _navigateToScreen(0),
          ),
        ],
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          '📊 Dashboard épico próximamente\n\nIncluirá:\n• Lista de usuarios\n• Estadísticas\n• Gráficos\n• Acciones rápidas',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
  
  Widget _buildEstadisticasScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _navigateToScreen(2),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas del Sistema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Métricas de usuarios',
              style: TextStyle(
                fontSize: 12, 
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          '📈 Estadísticas épicas próximamente\n\nIncluirá:\n• Métricas de usuarios\n• Registros recientes\n• Estado de seguridad\n• Gráficos interactivos',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// ==========================================
// 📊 MODELOS DE DATOS ÉPICOS
// ==========================================

class UserData {
  final int id;
  final String email;
  final String password;
  final String telefono;
  final String nombreGalpon;
  final String nombrePropietario;
  final DateTime fechaRegistro;

  UserData({
    required this.id,
    required this.email,
    required this.password,
    required this.telefono,
    required this.nombreGalpon,
    required this.nombrePropietario,
    required this.fechaRegistro,
  });
}

class ValidationState {
  bool isValid;
  String message;

  ValidationState({
    this.isValid = false,
    this.message = '',
  });
}