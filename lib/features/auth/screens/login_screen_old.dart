import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../services/auth_service.dart';
import '../../home/screens/home_screen.dart';

// ==========================================
// 🏆 MÓDULO DE USUARIOS ÉPICO Y COMPLETO
// ==========================================
// Transformación épica de 200 líneas a 1000+ líneas
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
    // Pre-llenar datos de prueba
    _loginEmailController.text = 'juan@gallos.com';
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo con iconos épicos
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                'USUARIO DE PRUEBA',
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
            'Email: juan@gallos.com\nContraseña: 123456',
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
  // 📝 PANTALLA DE REGISTRO ÉPICA
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
              'Únete a Casta de Reyes',
              style: TextStyle(fontSize: 12, opacity: 0.9),
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
                  _buildValidatedTextField(
                    controller: _regEmailController,
                    label: 'Correo Electrónico',
                    hint: 'tu@email.com',
                    icon: Icons.email_outlined,
                    validationKey: 'email',
                    keyboardType: TextInputType.emailAddress,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildValidatedTextField(
                    controller: _regPasswordController,
                    label: 'Contraseña',
                    hint: '••••••••',
                    icon: Icons.lock_outlined,
                    validationKey: 'password',
                    isPassword: true,
                    obscureText: _obscureRegPassword,
                    onTogglePassword: () {
                      setState(() {
                        _obscureRegPassword = !_obscureRegPassword;
                      });
                    },
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirements(),
                  const SizedBox(height: 16),
                  _buildValidatedTextField(
                    controller: _regConfirmPasswordController,
                    label: 'Confirmar Contraseña',
                    hint: '••••••••',
                    icon: Icons.lock_outlined,
                    validationKey: 'confirmPassword',
                    isPassword: true,
                    obscureText: _obscureRegConfirmPassword,
                    onTogglePassword: () {
                      setState(() {
                        _obscureRegConfirmPassword = !_obscureRegConfirmPassword;
                      });
                    },
                    required: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Sección Datos del Galpón
              _buildFormSection(
                title: 'Datos del Galpón',
                icon: Icons.home_outlined,
                children: [
                  _buildValidatedTextField(
                    controller: _regGalponController,
                    label: 'Nombre del Galpón',
                    hint: 'Ej: El Palenque Real',
                    icon: Icons.home_outlined,
                    validationKey: 'galpon',
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildValidatedTextField(
                    controller: _regPropietarioController,
                    label: 'Nombre del Propietario',
                    hint: 'Tu nombre completo',
                    icon: Icons.person_outlined,
                    validationKey: 'propietario',
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildValidatedTextField(
                    controller: _regTelefonoController,
                    label: 'Teléfono',
                    hint: '987654321',
                    icon: Icons.phone_outlined,
                    validationKey: 'telefono',
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    required: true,
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
  }'👑', style: TextStyle(fontSize: 24)),
                SizedBox(width: 4),
                Text('🐓', style: TextStyle(fontSize: 28)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Casta de Reyes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sistema de Gestión Gallera',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTestUserCard() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('👤', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'USUARIO DE PRUEBA',
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
            'Email: juan@gallos.com\\nContraseña: 123456',
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