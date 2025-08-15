// 🐓 ÍCONOS CENTRALIZADOS DE LA APP - IMPLEMENTACIÓN SEGURA
import 'package:flutter/material.dart';

/// Clase centralizada para manejar todos los íconos de la app
/// VENTAJAS:
/// - Un solo lugar para cambiar íconos
/// - Fácil mantenimiento
/// - Consistencia en toda la app
class AppIcons {
  // Prevenir instanciación
  AppIcons._();
  
  // 📁 RUTAS DE IMÁGENES
  static const String galloImagePath = 'assets/images/icono/iconogallo.webp';
  
  // 🎨 COLORES ESTÁNDAR
  static const Color primaryColor = Color(0xFFD32F2F);
  static const Color inactiveColor = Colors.grey;
  
  // 🐓 MÉTODO PRINCIPAL - ÍCONO DE GALLO
  static Widget gallo({
    double size = 24.0,
    Color? color,
    bool isActive = false,
  }) {
    final iconColor = color ?? (isActive ? primaryColor : inactiveColor);
    
    return Image.asset(
      galloImagePath,
      width: size,
      height: size,
      color: iconColor,
      colorBlendMode: BlendMode.srcIn,
      // IMPORTANTE: Fallback si no encuentra la imagen
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.pets, // Fallback seguro
          size: size,
          color: iconColor,
        );
      },
    );
  }
  
  // 🔄 VERSIÓN CON ANIMACIÓN (OPCIONAL)
  static Widget galloAnimated({
    double size = 24.0,
    Color? color,
    bool isActive = false,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return AnimatedContainer(
      duration: duration,
      child: gallo(
        size: size,
        color: color,
        isActive: isActive,
      ),
    );
  }
  
  // 📱 PARA LA BARRA DE NAVEGACIÓN
  static Widget galloNavBar(bool isSelected) {
    return gallo(
      size: 32.0, // Tu tamaño preferido
      isActive: isSelected,
    );
  }
  
  // 📋 PARA LISTAS Y CARDS (SIEMPRE ROJO)
  static Widget galloListTile({Color? color}) {
    return gallo(
      size: 24.0,
      color: color ?? primaryColor, // Por defecto ROJO
    );
  }
  
  // 🔴 ESPECÍFICO PARA LISTA DE PEDIGRÍ (SIEMPRE ROJO)
  static Widget galloPedigriLista() {
    return gallo(
      size: 24.0,
      color: primaryColor, // SIEMPRE ROJO
    );
  }
  
  // 📝 PARA CARDS DE GALLOS (TAMAÑO MEDIANO, ROJO)
  static Widget galloCard() {
    return gallo(
      size: 40.0,
      color: primaryColor,
    );
  }
  
  // 🔍 PARA ESTADOS VACÍOS (GRANDE, GRIS)
  static Widget galloEmpty() {
    return gallo(
      size: 60.0,
      color: inactiveColor.withOpacity(0.3),
    );
  }
  
  // 📱 PARA DIÁLOGOS (GRANDE, ROJO)
  static Widget galloDialog() {
    return gallo(
      size: 60.0,
      color: primaryColor,
    );
  }
  
  // 🎯 OTROS ÍCONOS DE LA APP (PARA FUTURO)
  static IconData get home => Icons.home;
  static IconData get reports => Icons.bar_chart;
  static IconData get plans => Icons.star;
  static IconData get profile => Icons.person;
  
  // 🐓 ICONDATA PARA CAMPOS DE FORMULARIO (cuando requieren IconData)
  static IconData get galloIconData => Icons.pets; // Fallback para formularios
}