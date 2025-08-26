/// 🎨 CONFIGURACIÓN UI ADAPTATIVA PARA DISPOSITIVOS CHINOS
/// Aplica fixes específicos basados en el nivel de riesgo detectado
/// 
/// Basado en problemas reales:
/// - OPPO: Reducir tamaños, aumentar weights
/// - Xiaomi: Ajustar DPI, manejar HyperOS
/// - Vivo: Similar a OPPO pero menos agresivo
///
/// Autor: Alan Cairampoma  
/// Fecha: 19 Agosto 2025

import 'package:flutter/material.dart';
import '../utils/chinese_device_detector.dart';

/// 🎨 Configuración UI específica por nivel de riesgo
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

  /// ✅ Configuración estándar (Samsung, Motorola, etc.)
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
        'needs_workarounds': false,
        'rendering_mode': 'standard',
      },
    );
  }

  /// 🚨 Configuración para OPPO (Riesgo CRÍTICO)
  factory AdaptiveUIConfig.forOPPO() {
    return AdaptiveUIConfig(
      fontSize: 14.0,          // Reducido por problemas rendering
      gridSpacing: 12.0,       // Más compacto
      cardPadding: 14.0,       // Menos padding
      buttonHeight: 44.0,      // Más pequeño
      iconSize: 20.0,          // Iconos más pequeños
      fontWeight: FontWeight.w600, // Más bold para legibilidad
      letterSpacing: 0.5,      // Mejor separación
      lineHeight: 1.2,         // Más compacto
      screenPadding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(8.0), // Bordes más simples
      elevation: 1.0,          // Menos sombras
      specificFixes: {
        'needs_workarounds': true,
        'rendering_mode': 'oppo_safe',
        'disable_impeller': true,
        'avoid_androidview': true,
        'force_software_rendering': true,
        'reduce_animations': true,
        'simplify_shadows': true,
      },
    );
  }

  /// 🔴 Configuración para Xiaomi HyperOS (Riesgo ALTO)
  factory AdaptiveUIConfig.forXiaomiHyperOS() {
    return AdaptiveUIConfig(
      fontSize: 15.0,          // Intermedio
      gridSpacing: 14.0,       
      cardPadding: 15.0,       
      buttonHeight: 46.0,      
      iconSize: 22.0,          
      fontWeight: FontWeight.w500, // Medium weight
      letterSpacing: 0.3,      
      lineHeight: 1.3,         
      screenPadding: const EdgeInsets.all(18.0),
      borderRadius: BorderRadius.circular(10.0),
      elevation: 1.5,          
      specificFixes: {
        'needs_workarounds': true,
        'rendering_mode': 'hyperos_compatible',
        'force_utf8_encoding': true,
        'handle_surfacecontrol_errors': true,
        'adjust_text_rendering': true,
        'prevent_page_slide_crashes': true,
        'chinese_char_specific_fixes': true,
      },
    );
  }

  /// 🟡 Configuración para Xiaomi MIUI (Riesgo MEDIO)  
  factory AdaptiveUIConfig.forXiaomiMIUI() {
    return AdaptiveUIConfig(
      fontSize: 15.5,          
      gridSpacing: 15.0,       
      cardPadding: 16.0,       
      buttonHeight: 47.0,      
      iconSize: 23.0,          
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,      
      lineHeight: 1.35,        
      screenPadding: const EdgeInsets.all(19.0),
      borderRadius: BorderRadius.circular(11.0),
      elevation: 2.0,          
      specificFixes: {
        'needs_workarounds': true,
        'rendering_mode': 'miui_optimized',
        'adjust_dpi_scaling': true,
        'modify_font_weights': true,
        'miui_compatible_spacing': true,
        'handle_aggressive_optimizations': true,
      },
    );
  }

  /// 🔴 Configuración para Vivo (Riesgo ALTO)
  factory AdaptiveUIConfig.forVivo() {
    return AdaptiveUIConfig(
      fontSize: 14.5,          // Ligeramente más grande que OPPO
      gridSpacing: 13.0,       
      cardPadding: 14.5,       
      buttonHeight: 45.0,      
      iconSize: 21.0,          
      fontWeight: FontWeight.w600, // Bold como OPPO
      letterSpacing: 0.4,      
      lineHeight: 1.25,        
      screenPadding: const EdgeInsets.all(17.0),
      borderRadius: BorderRadius.circular(9.0),
      elevation: 1.2,          
      specificFixes: {
        'needs_workarounds': true,
        'rendering_mode': 'vivo_safe',
        'avoid_androidview': true,
        'funtouch_specific_fixes': true,
        'alternative_webview_handling': true,
        'reduce_complex_animations': true,
      },
    );
  }

  /// 🟡 Configuración para Honor/Huawei (Riesgo MEDIO)
  factory AdaptiveUIConfig.forHonorHuawei() {
    return AdaptiveUIConfig(
      fontSize: 15.5,          
      gridSpacing: 15.5,       
      cardPadding: 16.5,       
      buttonHeight: 47.5,      
      iconSize: 23.5,          
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,      
      lineHeight: 1.37,        
      screenPadding: const EdgeInsets.all(19.5),
      borderRadius: BorderRadius.circular(11.5),
      elevation: 2.2,          
      specificFixes: {
        'needs_workarounds': true,
        'rendering_mode': 'emui_compatible',
        'handle_emui_inheritance': true,
        'magic_ui_adjustments': true,
        'harmonyos_transition_support': true,
      },
    );
  }
}

/// 🎯 Manager principal para configuración adaptativa
class AdaptiveUIManager {
  static AdaptiveUIConfig? _cachedConfig;
  static ChineseDeviceProfile? _cachedProfile;

  /// 🎨 Obtiene configuración óptima para el dispositivo actual
  static Future<AdaptiveUIConfig> getOptimalConfig() async {
    // Cache para evitar múltiples detecciones
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }

    final profile = await ChineseDeviceDetector.detectCurrentDevice();
    _cachedProfile = profile;

    switch (profile.riskLevel) {
      case ChineseDeviceRiskLevel.CRITICAL:
        // OPPO, Realme, OnePlus con ColorOS
        _cachedConfig = AdaptiveUIConfig.forOPPO();
        break;

      case ChineseDeviceRiskLevel.HIGH:
        // Vivo, Xiaomi HyperOS
        if (profile.deviceOS == 'HyperOS') {
          _cachedConfig = AdaptiveUIConfig.forXiaomiHyperOS();
        } else {
          _cachedConfig = AdaptiveUIConfig.forVivo();
        }
        break;

      case ChineseDeviceRiskLevel.MEDIUM:
        // Xiaomi MIUI, Honor, Huawei
        if (profile.brandName == 'Xiaomi') {
          _cachedConfig = AdaptiveUIConfig.forXiaomiMIUI();
        } else {
          _cachedConfig = AdaptiveUIConfig.forHonorHuawei();
        }
        break;

      case ChineseDeviceRiskLevel.LOW:
      default:
        // Samsung, Motorola, etc.
        _cachedConfig = AdaptiveUIConfig.standard();
        break;
    }

    return _cachedConfig!;
  }

  /// 📱 Obtiene perfil del dispositivo (cached)
  static Future<ChineseDeviceProfile> getDeviceProfile() async {
    if (_cachedProfile != null) {
      return _cachedProfile!;
    }

    _cachedProfile = await ChineseDeviceDetector.detectCurrentDevice();
    return _cachedProfile!;
  }

  /// 🔄 Limpia cache (usar cuando sea necesario re-detectar)
  static void clearCache() {
    _cachedConfig = null;
    _cachedProfile = null;
  }

  /// 📊 Información de debug
  static Future<Map<String, dynamic>> getDebugInfo() async {
    final config = await getOptimalConfig();
    final profile = await getDeviceProfile();

    return {
      'device_brand': profile.brandName,
      'device_os': profile.deviceOS,
      'risk_level': profile.riskLevel.toString(),
      'config_applied': {
        'font_size': config.fontSize,
        'grid_spacing': config.gridSpacing,
        'font_weight': config.fontWeight.toString(),
        'needs_workarounds': config.specificFixes['needs_workarounds'],
        'rendering_mode': config.specificFixes['rendering_mode'],
      },
      'specific_fixes_count': config.specificFixes.length,
      'known_issues_count': profile.knownIssues.length,
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
      future: AdaptiveUIManager.getOptimalConfig(),
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
      future: AdaptiveUIManager.getOptimalConfig(),
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
      future: AdaptiveUIManager.getOptimalConfig(),
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