import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/usuario.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  Usuario? _currentUser;
  Usuario? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // 🔥 DATOS SIMULADOS PARA DEMO WEB
  final List<Map<String, dynamic>> _usuariosFake = [
    {
      'id': 1,
      'nombre': 'Juan',
      'apellido': 'Salas',
      'email': 'juan@gallos.com',
      'password': 'e10adc3949ba59abbe56e057f20f883e', // 123456 en MD5
      'telefono': '987654321',
      'direccion': 'Lima, Perú',
      'activo': true,
      'fecha_registro': '2025-01-01T00:00:00.000Z',
      'created_at': '2025-01-01T00:00:00.000Z',
      'updated_at': '2025-01-01T00:00:00.000Z',
      'avatar': null,
    },
    {
      'id': 2,
      'nombre': 'Alan',
      'apellido': 'Cairampoma',
      'email': 'alan@gallos.com', 
      'password': 'e10adc3949ba59abbe56e057f20f883e', // 123456 en MD5
      'telefono': '987654322',
      'direccion': 'Lima, Perú',
      'activo': true,
      'fecha_registro': '2025-01-01T00:00:00.000Z',
      'created_at': '2025-01-01T00:00:00.000Z',
      'updated_at': '2025-01-01T00:00:00.000Z',
      'avatar': null,
    },
    {
      'id': 3,
      'nombre': 'Admin',
      'apellido': 'Sistema',
      'email': 'admin@gallos.com',
      'password': 'e10adc3949ba59abbe56e057f20f883e', // 123456 en MD5
      'telefono': '987654323',
      'direccion': 'Sistema',
      'activo': true,
      'fecha_registro': '2025-01-01T00:00:00.000Z',
      'created_at': '2025-01-01T00:00:00.000Z',
      'updated_at': '2025-01-01T00:00:00.000Z',
      'avatar': null,
    },
  ];

  String _encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = md5.convert(bytes);
    return digest.toString();
  }

  Future<LoginResult> login(String email, String password) async {
    try {
      print('🔐 [DEMO] Simulando login para: $email');
      
      await Future.delayed(Duration(milliseconds: 800));
      
      final encryptedPassword = _encryptPassword(password);
      print('🔐 [DEMO] Password encriptado: $encryptedPassword');
      
      // Permitir login con email completo o solo nombre de usuario
      final userData = _usuariosFake.where(
        (user) => (
          user['email'] == email || 
          user['nombre'].toString().toLowerCase() == email.toLowerCase()
        ) && 
        user['password'] == encryptedPassword &&
        user['activo'] == true,
      ).toList();

      if (userData.isEmpty) {
        print('❌ [DEMO] Credenciales incorrectas');
        return LoginResult.failure('Email o contraseña incorrectos');
      }

      _currentUser = Usuario.fromMap(userData.first);
      print('✅ [DEMO] Login exitoso: ${_currentUser!.nombreCompleto}');
      
      return LoginResult.success(_currentUser!);
      
    } catch (e) {
      print('❌ [DEMO] Error en login: $e');
      return LoginResult.failure('Error de conexión simulado');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    print('👋 [DEMO] Sesión cerrada');
  }
}

class LoginResult {
  final bool success;
  final String? message;
  final Usuario? user;

  LoginResult._({required this.success, this.message, this.user});

  factory LoginResult.success(Usuario user) {
    return LoginResult._(success: true, user: user, message: 'Login exitoso');
  }

  factory LoginResult.failure(String message) {
    return LoginResult._(success: false, message: message);
  }
}