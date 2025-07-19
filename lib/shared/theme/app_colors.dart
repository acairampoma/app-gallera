import 'package:flutter/material.dart';

class AppColors {
  // Colores principales - tema rural gallero
  static const Color primary = Color(0xFFD32F2F);      // Rojo gallero
  static const Color primaryDark = Color(0xFFB71C1C);  // Rojo oscuro
  static const Color secondary = Color(0xFFCD853F);     // Marrón tierra
  static const Color accent = Color(0xFFDAA520);        // Dorado
  
  // Estados
  static const Color success = Color(0xFF228B22);       // Verde victoria
  static const Color error = Color(0xFFDC143C);         // Rojo derrota
  static const Color warning = Color(0xFFFF8C00);       // Naranja empate
  
  // Fondos
  static const Color background = Color(0xFFF5F5DC);    // Beige rural
  static const Color surface = Color(0xFFFFFFFF);       // Blanco
  static const Color cardBg = Color(0xFFFAFAFA);        // Gris claro
  
  // Textos
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surface],
  );
}