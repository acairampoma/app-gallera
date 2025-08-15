// 🐓 ÍCONO PERSONALIZADO DEL GALLO - REUTILIZABLE
import 'package:flutter/material.dart';

class GalloIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool? isSelected;

  const GalloIcon({
    Key? key,
    this.size = 24.0,
    this.color,
    this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determinar color basado en selección o usar color personalizado
    Color iconColor;
    
    if (color != null) {
      iconColor = color!;
    } else if (isSelected != null) {
      iconColor = isSelected! 
          ? const Color(0xFFD32F2F) // Rojo cuando seleccionado
          : Colors.grey.withOpacity(0.6); // Gris opaco cuando no
    } else {
      iconColor = Colors.grey; // Color por defecto
    }

    return Image.asset(
      'assets/images/icono/iconogallo.webp',
      width: size,
      height: size,
      color: iconColor,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (context, error, stackTrace) {
        // Fallback si no encuentra la imagen
        return Icon(
          Icons.pets,
          size: size,
          color: iconColor,
        );
      },
    );
  }
}

// 🔧 HELPER FUNCTION PARA USAR EN CUALQUIER LUGAR
Widget galloIcon({
  double size = 24.0,
  Color? color,
  bool? isSelected,
}) {
  return GalloIcon(
    size: size,
    color: color,
    isSelected: isSelected,
  );
}