import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../services/auth_service_real.dart';
import '../../../services/api_service.dart';
import '../../home/screens/home_screen.dart';

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
  int _currentScreen = 0; // 0: Login, 1: Registro
  
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
  
  // Animaciones épicas
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

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
    // Pre-llenar datos de prueba con usuarios del backend
    _loginEmailController.text = 'juan.salas.nuevo@galloapp.com';
    _loginPasswordController.text = '123456';
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
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 🚀 PANTALLA DE LOGIN ÉPICA CON BACKEND REAL
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
                  
                  // Info de usuario de prueba mejorada
                  _buildTestUserCard(),
                  const SizedBox(height: 24),
                  
                  // Formulario de login épico
                  _buildLoginForm(),
                  const SizedBox(height: 24),
                  
                  // Botón de login épico
                  _buildLoginButton(),
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
                  Text('🏆', style: TextStyle(fontSize: 40)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildTestUserCard() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🌐', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'BACKEND REAL CONECTADO',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Usuarios de Railway PostgreSQL:\n• juan.salas.nuevo@galloapp.com\n• alan.cairampoma.nuevo@galloapp.com\nPassword: 123456',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoginForm() {
    return Container(
      width: 320,
      child: Column(
        children: [
          // Email épico
          _buildEpicTextField(
            controller: _loginEmailController,
            label: 'Email',
            hint: 'juan.salas.nuevo@galloapp.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              if (!value.contains('@')) {
                return 'Ingresa un email válido';
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
        onPressed: _isLoginLoading ? null : _handleRealLogin,
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Iniciar Sesión con Backend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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

  // ==========================================
  // 🔥 LOGIN REAL CON BACKEND JWT
  // ==========================================
  
  void _handleRealLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoginLoading = true;
      });

      try {
        final email = _loginEmailController.text.trim();
        final password = _loginPasswordController.text;

        // 🚀 LOGIN REAL CON BACKEND
        final success = await AuthService.instance.login(email, password);

        setState(() {
          _isLoginLoading = false;
        });

        if (success && mounted) {
          // 🎉 LOGIN EXITOSO
          final user = AuthService.instance.currentUser;
          final profile = AuthService.instance.currentProfile;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido, ${profile?.nombreCompleto ?? user?.email}!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Navegar al HomeScreen real
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else if (mounted) {
          // ❌ ERROR EN LOGIN
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Credenciales incorrectas. Verifica email y contraseña.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoginLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error de conexión: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  // ==========================================
  // 🔥 REGISTRO REAL CON BACKEND
  // ==========================================
  
  void _handleRealRegister() async {
    if (_regFormKey.currentState!.validate()) {
      setState(() {
        _isRegisterLoading = true;
      });

      try {
        // 🚀 REGISTRO REAL CON BACKEND
        final message = await AuthService.instance.register(
          email: _regEmailController.text.trim(),
          password: _regPasswordController.text,
          nombreCompleto: _regPropietarioController.text.trim(),
          telefono: _regTelefonoController.text.trim(),
          nombreGalpon: _regGalponController.text.trim(),
        );

        setState(() {
          _isRegisterLoading = false;
        });

        if (message != null && mounted) {
          // 🎉 REGISTRO EXITOSO
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $message'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );

          // Limpiar formulario
          _regEmailController.clear();
          _regPasswordController.clear();
          _regConfirmPasswordController.clear();
          _regGalponController.clear();
          _regPropietarioController.clear();
          _regTelefonoController.clear();

          // Regresar a login para que inicie sesión
          _navigateToScreen(0);
          
          // Mensaje para que haga login
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Ahora puedes iniciar sesión con tu nueva cuenta!'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          });
        } else if (mounted) {
          // ❌ ERROR EN REGISTRO
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error en el registro. Verifica los datos.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isRegisterLoading = false;
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

  // ==========================================
  // 📝 PANTALLA DE REGISTRO
  // ==========================================
  
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crear Cuenta Nueva',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Conectado a Backend Railway',
              style: TextStyle(fontSize: 12, color: Colors.white70),
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
                      if (value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
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
                    controller: _regPropietarioController,
                    label: 'Nombre Completo',
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
                    controller: _regTelefonoController,
                    label: 'Teléfono',
                    hint: '987654321',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El teléfono es obligatorio';
                      }
                      if (value.length < 9) {
                        return 'Debe tener al menos 9 dígitos';
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
  
  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isRegisterLoading ? null : _handleRealRegister,
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Crear Cuenta en Backend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
}
