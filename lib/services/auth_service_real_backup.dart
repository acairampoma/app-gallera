import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static AuthService get instance => _instance;

  // Estado del usuario actual
  UserModel? _currentUser;
  ProfileModel? _currentProfile;
  bool _isAuthenticated = false;

  // Stream controllers para notificar cambios
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();

  // Getters
  UserModel? get currentUser => _currentUser;
  ProfileModel? get currentProfile => _currentProfile;
  bool get isAuthenticated => _isAuthenticated;
  Stream<bool> get authStateStream => _authStateController.stream;
  Stream<UserModel?> get userStream => _userController.stream;

  // 🚀 INICIALIZAR - Verificar si ya está logueado
  Future<void> initialize() async {
    try {
      final isLoggedIn = await hasValidToken();
      if (isLoggedIn) {
        await loadCurrentUser();
      }
    } catch (e) {
      print('Error inicializando AuthService: $e');
    }
  }
  
  // 🔍 VERIFICAR TOKEN
  static Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null;
  }

  // 📧 LOGIN con backend real
  Future<bool> login(String email, String password) async {
    try {
      final authResponse = await ApiService.login(email, password);
      
      _currentUser = authResponse.user;
      _isAuthenticated = true;
      
      // Cargar perfil (puede venir en la respuesta o cargar separadamente)
      if (authResponse.profile != null) {
        _currentProfile = authResponse.profile;
      } else {
        await loadCurrentProfile();
      }
      
      // Notificar cambios
      _authStateController.add(true);
      _userController.add(_currentUser);
      
      return true;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  // 🆕 REGISTRO con backend real
  Future<String?> register({
    required String email,
    required String password,
    required String nombreCompleto,
    String? telefono,
    String? nombreGalpon,
  }) async {
    try {
      final registerResponse = await ApiService.register(
        email: email,
        password: password,
        nombreCompleto: nombreCompleto,
        telefono: telefono,
        nombreGalpon: nombreGalpon,
      );
      
      return registerResponse.message;
    } catch (e) {
      print('Error en registro: $e');
      return null;
    }
  }

  // 👤 CARGAR USUARIO ACTUAL
  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await ApiService.getCurrentUser();
      _isAuthenticated = true;
      
      await loadCurrentProfile();
      
      _authStateController.add(true);
      _userController.add(_currentUser);
    } catch (e) {
      print('Error cargando usuario: $e');
      await logout();
    }
  }

  // 👤 CARGAR PERFIL ACTUAL
  Future<void> loadCurrentProfile() async {
    try {
      _currentProfile = await ApiService.getMyProfile();
    } catch (e) {
      print('Error cargando perfil: $e');
    }
  }

  // ✏️ ACTUALIZAR PERFIL
  Future<bool> updateProfile({
    String? nombreCompleto,
    String? telefono,
    String? nombreGalpon,
    String? direccion,
    String? ciudad,
    String? biografia,
  }) async {
    try {
      _currentProfile = await ApiService.updateProfile(
        nombreCompleto: nombreCompleto,
        telefono: telefono,
        nombreGalpon: nombreGalpon,
        direccion: direccion,
        ciudad: ciudad,
        biografia: biografia,
      );
      return true;
    } catch (e) {
      print('Error actualizando perfil: $e');
      return false;
    }
  }

  // 🚪 LOGOUT MEJORADO
  Future<LogoutResponse?> logout() async {
    print('🚀 [AuthService] Iniciando logout...');
    
    LogoutResponse? logoutResponse;
    
    // 🧙‍♀️ LIMPIAR ESTADO LOCAL PRIMERO (inmediato)
    _currentUser = null;
    _currentProfile = null;
    _isAuthenticated = false;
    
    // 📡 Notificar inmediatamente el cambio de estado
    _authStateController.add(false);
    _userController.add(null);
    
    print('✅ [AuthService] Estado local limpiado inmediatamente');
    
    // 🌐 Intentar logout del servidor (en segundo plano)
    try {
      logoutResponse = await ApiService.logout();
      if (logoutResponse != null) {
        print('✅ [AuthService] Logout del servidor exitoso: ${logoutResponse.message}');
      }
    } catch (e) {
      print('⚠️ [AuthService] Error en logout del servidor: $e');
      // Continuamos porque el estado local ya está limpio
    }
    
    print('✅ [AuthService] Logout completado - isAuthenticated: $_isAuthenticated');
    return logoutResponse;
  }

  // 📷 SUBIR AVATAR
  Future<bool> uploadAvatar(File imageFile) async {
    try {
      _currentProfile = await ApiService.uploadAvatar(imageFile);
      print('✅ Avatar actualizado en AuthService');
      return true;
    } catch (e) {
      print('Error subiendo avatar: $e');
      return false;
    }
  }
  
  // 🗑️ ELIMINAR AVATAR
  Future<bool> removeAvatar() async {
    try {
      await ApiService.removeAvatar();
      // Recargar perfil para actualizar el avatar a null
      await loadCurrentProfile();
      print('✅ Avatar eliminado en AuthService');
      return true;
    } catch (e) {
      print('Error eliminando avatar: $e');
      return false;
    }
  }
  
  // 🔐 CAMBIAR CONTRASEÑA
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await ApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      print('Error cambiando contraseña: $e');
      return false;
    }
  }
  
  // 🔄 REFRESH TOKEN
  Future<bool> refreshToken() async {
    return await ApiService.refreshToken();
  }

  // 🗑️ LIMPIAR RECURSOS
  void dispose() {
    _authStateController.close();
    _userController.close();
  }
}
