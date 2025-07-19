import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showShadow;
  
  const AppLogo({
    Key? key,
    this.size = 150,
    this.showText = true,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🖼️ LOGO CONTAINER CON TU IMAGEN WEBP
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.15),
            boxShadow: showShadow ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ] : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.15),
            child: Image.asset(
              'assets/images/logo/logo.webp', // 🔥 TU LOGO REAL
              fit: BoxFit.contain,
              width: size,
              height: size,
              errorBuilder: (context, error, stackTrace) {
                print('❌ Error cargando logo: $error');
                // 🔄 Fallback épico si no encuentra la imagen
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(size * 0.15),
                  ),
                  child: Icon(
                    Icons.pets,
                    size: size * 0.5,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        
        // 📝 TEXTO DEL LOGO
        if (showText) ...[
          SizedBox(height: size * 0.1),
          Text(
            'GallosPro',
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            'Gestión Profesional de Gallos',
            style: TextStyle(
              fontSize: size * 0.11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}