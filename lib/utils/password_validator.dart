class PasswordValidator {
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }

    List<String> errors = [];

    // Longitud mínima
    if (password.length < 6) {
      errors.add('debe tener al menos 6 caracteres');
    }

    // Longitud máxima
    if (password.length > 128) {
      errors.add('no puede tener más de 128 caracteres');
    }

    // Al menos una letra
    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) {
      errors.add('debe contener al menos una letra');
    }

    // Al menos un número
    if (!RegExp(r'\d').hasMatch(password)) {
      errors.add('debe contener al menos un número');
    }

    // No espacios en blanco
    if (password.contains(' ')) {
      errors.add('no puede contener espacios');
    }

    // Contraseñas comunes prohibidas
    List<String> weakPasswords = ['123456', '654321', 'password', 'qwerty', '111111', 'abc123'];
    if (weakPasswords.contains(password.toLowerCase())) {
      errors.add('no puede ser una contraseña común');
    }

    if (errors.isNotEmpty) {
      return 'La contraseña ${errors.join(', ')}';
    }

    return null; // null significa que es válida
  }

  static List<String> getPasswordRequirements() {
    return [
      '• Al menos 6 caracteres',
      '• Al menos una letra',
      '• Al menos un número', 
      '• Sin espacios',
      '• No usar contraseñas comunes',
    ];
  }

  static bool isPasswordStrong(String password) {
    return validatePassword(password) == null;
  }
}
