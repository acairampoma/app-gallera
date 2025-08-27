/// 🎨 CONFIGURACIÓN UI ADAPTATIVA SIMPLIFICADA
/// Aplica ajustes básicos basados en plataforma y tamaño de pantalla
/// 
/// REFACTORIZADO: Ahora usa DeviceService en lugar de ChineseDeviceDetector
///
/// Autor: Alan Cairampoma  
/// Fecha: 27 Agosto 2025

import 'package:flutter/material.dart';
import '../services/device_service.dart';

/// 🎯 Niveles de ajuste UI simplificados
enum UIAdaptationLevel {
  STANDARD,    // Móvil estándar
  COMPACT,     // Pantallas pequeñas
  COMFORTABLE, // Pantallas grandes
  WEB,         // Versión web
}

/// 🎨 Configuración UI específica por nivel
class AdaptiveUIConfig {
  final double fontSize;
  final double gridSpacing;
  final double cardPadding;
  final double buttonHeight;
  final double iconSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final double lineHeight;
  final EdgeInsets screenPadding;
  final BorderRadius borderRadius;
  final double elevation;
  final Color? textColor;
  final Map<String, dynamic> specificFixes;

  const AdaptiveUIConfig({
    required this.fontSize,
    required this.gridSpacing,
    required this.cardPadding,
    required this.buttonHeight,
    required this.iconSize,
    required this.fontWeight,
    required this.letterSpacing,
    required this.lineHeight,
    required this.screenPadding,
    required this.borderRadius,
    required this.elevation,
    this.textColor,
    this.specificFixes = const {},
  });

  /// ✅ Configuración estándar móvil
  factory AdaptiveUIConfig.standard() {
    return AdaptiveUIConfig(
      fontSize: 16.0,
      gridSpacing: 16.0,
      cardPadding: 16.0,
      buttonHeight: 48.0,
      iconSize: 24.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      lineHeight: 1.4,
      screenPadding: const EdgeInsets.all(20.0),
      borderRadius: BorderRadius.circular(12.0),
      elevation: 2.0,
      specificFixes: {
        'adaptation_level': 'standard',
        'platform_optimized': true,
      },
    );
  }

  /// 📱 Configuración para pantallas compactas
  factory AdaptiveUIConfig.compact() {
    return AdaptiveUIConfig(
      fontSize: 14.0,
      gridSpacing: 12.0,
      cardPadding: 14.0,
      buttonHeight: 44.0,
      iconSize: 20.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      lineHeight: 1.3,
      screenPadding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(10.0),
      elevation: 1.5,
      specificFixes: {
        'adaptation_level': 'compact',
        'space_optimized': true,
      },
    );
  }

  /// 🖥️ Configuración para pantallas grandes
  factory AdaptiveUIConfig.comfortable() {
    return AdaptiveUIConfig(
      fontSize: 18.0,
      gridSpacing: 20.0,
      cardPadding: 20.0,
      buttonHeight: 52.0,
      iconSize: 28.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      lineHeight: 1.5,
      screenPadding: const EdgeInsets.all(24.0),
      borderRadius: BorderRadius.circular(14.0),
      elevation: 3.0,
      specificFixes: {
        'adaptation_level': 'comfortable',
        'large_screen_optimized': true,
      },
    );
  }

  /// 🌐 Configuración para web
  factory AdaptiveUIConfig.web() {
    return AdaptiveUIConfig(
      fontSize: 16.0,
      gridSpacing: 18.0,
      cardPadding: 18.0,
      buttonHeight: 50.0,
      iconSize: 26.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.05,
      lineHeight: 1.45,
      screenPadding: const EdgeInsets.all(22.0),
      borderRadius: BorderRadius.circular(13.0),
      elevation: 2.5,
      specificFixes: {
        'adaptation_level': 'web',
        'web_optimized': true,
        'hover_effects': true,
      },
    );
  }
}

/// 🎯 Manager simplificado para configuración adaptativa
class AdaptiveUIManager {
  static AdaptiveUIConfig? _cachedConfig;
  static String? _cachedPlatform;

  /// 🎨 Obtiene configuración óptima basada en plataforma y pantalla
  static Future<AdaptiveUIConfig> getOptimalConfig([BuildContext? context]) async {
    // Cache básico
    if (_cachedConfig != null && _cachedPlatform != null) {
      return _cachedConfig!;
    }

    final deviceService = DeviceService.instance;
    final platformName = await deviceService.getPlatformName();
    _cachedPlatform = platformName;

    // Determinar configuración basada en plataforma y contexto
    if (deviceService.isWeb) {
      _cachedConfig = AdaptiveUIConfig.web();
    } else if (context != null) {
      // Usar MediaQuery para determinar el mejor ajuste
      final screenWidth = MediaQuery.of(context).size.width;
      
      if (screenWidth < 360) {
        _cachedConfig = AdaptiveUIConfig.compact();
      } else if (screenWidth > 600) {
        _cachedConfig = AdaptiveUIConfig.comfortable();
      } else {
        _cachedConfig = AdaptiveUIConfig.standard();
      }
    } else {
      // Fallback estándar
      _cachedConfig = AdaptiveUIConfig.standard();
    }

    return _cachedConfig!;
  }

  /// 📱 Obtiene información básica del dispositivo
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceService = DeviceService.instance;
    return await deviceService.getDeviceInfo();
  }

  /// 🔄 Limpia cache
  static void clearCache() {
    _cachedConfig = null;
    _cachedPlatform = null;
  }

  /// 📊 Información de debug simplificada
  static Future<Map<String, dynamic>> getDebugInfo([BuildContext? context]) async {
    final config = await getOptimalConfig(context);
    final deviceInfo = await getDeviceInfo();

    return {
      'device_info': deviceInfo,
      'config_applied': {
        'font_size': config.fontSize,
        'grid_spacing': config.gridSpacing,
        'font_weight': config.fontWeight.toString(),
        'adaptation_level': config.specificFixes['adaptation_level'],
      },
      'screen_info': context != null ? {
        'width': MediaQuery.of(context).size.width,
        'height': MediaQuery.of(context).size.height,
        'pixel_ratio': MediaQuery.of(context).devicePixelRatio,
      } : null,
    };
  }
}

/// 🎨 Widget helper para aplicar configuración automáticamente
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final bool useAdaptivePadding;
  final bool useAdaptiveSpacing;

  const AdaptiveContainer({
    Key? key,
    required this.child,
    this.useAdaptivePadding = true,
    this.useAdaptiveSpacing = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdaptiveUIConfig>(
      future: AdaptiveUIManager.getOptimalConfig(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return child; // Fallback estándar
        }

        final config = snapshot.data!;
        
        return Container(
          padding: useAdaptivePadding ? config.screenPadding : null,
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: config.fontSize,
              fontWeight: config.fontWeight,
              letterSpacing: config.letterSpacing,
              height: config.lineHeight,
              color: config.textColor,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// 📱 Text adaptativo con configuración automática
class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AdaptiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdaptiveUIConfig>(
      future: AdaptiveUIManager.getOptimalConfig(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(text, style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow);
        }

        final config = snapshot.data!;
        
        final adaptiveStyle = TextStyle(
          fontSize: config.fontSize,
          fontWeight: config.fontWeight,
          letterSpacing: config.letterSpacing,
          height: config.lineHeight,
          color: config.textColor,
        ).merge(style);

        return Text(
          text,
          style: adaptiveStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// 🔲 Card adaptativo
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final VoidCallback? onTap;

  const AdaptiveCard({
    Key? key,
    required this.child,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdaptiveUIConfig>(
      future: AdaptiveUIManager.getOptimalConfig(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(child: child);
        }

        final config = snapshot.data!;
        
        return Card(
          elevation: config.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: config.borderRadius,
          ),
          color: color,
          child: InkWell(
            onTap: onTap,
            borderRadius: config.borderRadius,
            child: Padding(
              padding: EdgeInsets.all(config.cardPadding),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// 🎯 Helper para obtener configuración de manera estática
class ResponsiveHelper {
  /// 📱 Determina si es pantalla pequeña
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
  
  /// 📟 Determina si es tablet/desktop
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }
  
  /// 🎯 Obtiene número de columnas recomendadas
  static int getRecommendedColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 1;
    if (width < 800) return 2;
    if (width < 1200) return 3;
    return 4;
  }
  
  /// 📐 Obtiene padding adaptativo básico
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isLargeScreen(context)) {
      return const EdgeInsets.all(24.0);
    }
    return const EdgeInsets.all(16.0);
  }
}