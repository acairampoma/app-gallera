/// 📱 DETECTOR DE DISPOSITIVOS CHINOS
/// Detecta marcas chinas problemáticas y aplica fixes específicos
/// 
/// Basado en issues reales documentados en Flutter GitHub:
/// - OPPO: Black screen issues, AndroidView problems
/// - Xiaomi: HyperOS errors, Chinese character display
/// - Vivo: Rendering issues similar a OPPO
///
/// Autor: Alan Cairampoma
/// Fecha: 19 Agosto 2025

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// 🎯 Niveles de riesgo de compatibilidad
enum ChineseDeviceRiskLevel {
  CRITICAL, // OPPO - Black screens, AndroidView failures
  HIGH,     // Xiaomi HyperOS, Vivo - Multiple rendering issues  
  MEDIUM,   // Xiaomi MIUI, Honor - DPI scaling issues
  LOW,      // Samsung, Motorola - Sin problemas
}

/// 📱 Perfil del dispositivo chino
class ChineseDeviceProfile {
  final ChineseDeviceRiskLevel riskLevel;
  final List<String> knownIssues;
  final bool needsWorkarounds;
  final List<String> problematicFlutterVersions;
  final String brandName;
  final String deviceOS;
  final Map<String, dynamic> recommendedFixes;

  const ChineseDeviceProfile({
    required this.riskLevel,
    required this.knownIssues,
    required this.needsWorkarounds,
    this.problematicFlutterVersions = const [],
    this.brandName = 'Unknown',
    this.deviceOS = 'Android',
    this.recommendedFixes = const {},
  });

  /// ✅ Perfil estándar para dispositivos sin problemas
  factory ChineseDeviceProfile.standard() {
    return const ChineseDeviceProfile(
      riskLevel: ChineseDeviceRiskLevel.LOW,
      knownIssues: [],
      needsWorkarounds: false,
      brandName: 'Standard Device',
    );
  }

  /// 🚨 Perfil crítico para OPPO devices
  factory ChineseDeviceProfile.oppo(String model) {
    return ChineseDeviceProfile(
      riskLevel: ChineseDeviceRiskLevel.CRITICAL,
      knownIssues: [
        'black_screen_impeller',
        'androidview_blackblock', 
        'coloros_rendering_issues',
        'webview_compatibility'
      ],
      needsWorkarounds: true,
      problematicFlutterVersions: ['3.27.0+'],
      brandName: 'OPPO',
      deviceOS: 'ColorOS',
      recommendedFixes: {
        'disable_impeller': true,
        'avoid_androidview': true,
        'force_software_rendering': true,
        'use_alternative_webview': true,
      },
    );
  }

  /// 🔴 Perfil alto riesgo para Xiaomi HyperOS
  factory ChineseDeviceProfile.xiaomiHyperOS(String model) {
    return ChineseDeviceProfile(
      riskLevel: ChineseDeviceRiskLevel.HIGH,
      knownIssues: [
        'surfacecontrol_errors',
        'chinese_char_display_abnormal',
        'hyperos_compatibility',
        'page_sliding_crashes'
      ],
      needsWorkarounds: true,
      brandName: 'Xiaomi',
      deviceOS: 'HyperOS',
      recommendedFixes: {
        'force_utf8_encoding': true,
        'handle_surfacecontrol_errors': true,
        'adjust_text_rendering': true,
        'hyperos_specific_workarounds': true,
      },
    );
  }

  /// 🟡 Perfil medio riesgo para Xiaomi MIUI
  factory ChineseDeviceProfile.xiaomiMIUI() {
    return const ChineseDeviceProfile(
      riskLevel: ChineseDeviceRiskLevel.MEDIUM,
      knownIssues: [
        'dpi_scaling_aggressive',
        'font_rendering_modified', 
        'miui_optimizations'
      ],
      needsWorkarounds: true,
      brandName: 'Xiaomi',
      deviceOS: 'MIUI',
      recommendedFixes: {
        'adjust_dpi_scaling': true,
        'modify_font_weights': true,
        'miui_compatible_spacing': true,
      },
    );
  }

  /// 🔴 Perfil alto riesgo para Vivo
  factory ChineseDeviceProfile.vivo() {
    return const ChineseDeviceProfile(
      riskLevel: ChineseDeviceRiskLevel.HIGH,
      knownIssues: [
        'androidview_rendering_issues',
        'funtouch_compatibility',
        'webview_blackblocks'
      ],
      needsWorkarounds: true,
      brandName: 'Vivo',
      deviceOS: 'Funtouch OS',
      recommendedFixes: {
        'avoid_androidview': true,
        'funtouch_specific_fixes': true,
        'alternative_webview_handling': true,
      },
    );
  }
}

/// 🔍 Detector principal de dispositivos chinos
class ChineseDeviceDetector {
  
  /// 🎯 Detecta el perfil del dispositivo actual
  static Future<ChineseDeviceProfile> detectCurrentDevice() async {
    if (kIsWeb) {
      return ChineseDeviceProfile.standard();
    }

    if (!Platform.isAndroid) {
      return ChineseDeviceProfile.standard();
    }

    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      
      return _analyzeAndroidDevice(androidInfo);
    } catch (e) {
      debugPrint('❌ Error detectando dispositivo: $e');
      return ChineseDeviceProfile.standard();
    }
  }

  /// 📱 Analiza dispositivo Android específico
  static ChineseDeviceProfile _analyzeAndroidDevice(AndroidDeviceInfo info) {
    final String brand = info.brand.toLowerCase().trim();
    final String manufacturer = info.manufacturer.toLowerCase().trim();  
    final String model = info.model.toLowerCase().trim();
    final int sdkInt = info.version.sdkInt;
    
    debugPrint('🔍 Analizando dispositivo: $brand $manufacturer $model (SDK: $sdkInt)');

    // 🚨 OPPO - Riesgo crítico (documentado en Flutter GitHub)
    if (_isOPPODevice(brand, manufacturer, model)) {
      return ChineseDeviceProfile.oppo(model);
    }

    // 🚨 Realme - Hereda problemas de OPPO (mismo ColorOS core)
    if (_isRealmeDevice(brand, manufacturer, model)) {
      return ChineseDeviceProfile.oppo('Realme ($model)');
    }

    // 🚨 OnePlus - Usa ColorOS core desde 2024
    if (_isOnePlusDevice(brand, manufacturer, model)) {
      return ChineseDeviceProfile.oppo('OnePlus ($model)');
    }

    // 🔴 Vivo - Alto riesgo
    if (_isVivoDevice(brand, manufacturer, model)) {
      return ChineseDeviceProfile.vivo();
    }

    // 🔴 Xiaomi HyperOS - Alto riesgo (transición de MIUI)
    if (_isXiaomiDevice(brand, manufacturer, model)) {
      if (_isHyperOSDevice(model, sdkInt)) {
        return ChineseDeviceProfile.xiaomiHyperOS(model);
      } else {
        return ChineseDeviceProfile.xiaomiMIUI();
      }
    }

    // 🟡 Honor - Medio riesgo (hereda de EMUI)
    if (_isHonorDevice(brand, manufacturer, model)) {
      return const ChineseDeviceProfile(
        riskLevel: ChineseDeviceRiskLevel.MEDIUM,
        knownIssues: ['emui_inheritance', 'magic_ui_issues'],
        needsWorkarounds: true,
        brandName: 'Honor',
        deviceOS: 'Magic UI',
      );
    }

    // 🟡 Huawei - Medio riesgo 
    if (_isHuaweiDevice(brand, manufacturer, model)) {
      return const ChineseDeviceProfile(
        riskLevel: ChineseDeviceRiskLevel.MEDIUM,
        knownIssues: ['emui_compatibility', 'harmonyos_transition'],
        needsWorkarounds: true,
        brandName: 'Huawei',
        deviceOS: 'EMUI/HarmonyOS',
      );
    }

    // ✅ Dispositivos estándar (Samsung, Motorola, etc.)
    return ChineseDeviceProfile.standard();
  }

  /// 🔍 Métodos de detección específicos por marca

  static bool _isOPPODevice(String brand, String manufacturer, String model) {
    return brand.contains('oppo') || 
           manufacturer.contains('oppo') ||
           model.startsWith('cph') || // OPPO model prefix
           model.contains('find') ||
           model.contains('reno');
  }

  static bool _isRealmeDevice(String brand, String manufacturer, String model) {
    return brand.contains('realme') || 
           manufacturer.contains('realme') ||
           model.startsWith('rmx'); // Realme model prefix
  }

  static bool _isOnePlusDevice(String brand, String manufacturer, String model) {
    return brand.contains('oneplus') || 
           manufacturer.contains('oneplus') ||
           model.contains('one plus') ||
           model.startsWith('ac') || // OnePlus model prefix
           model.startsWith('hd');
  }

  static bool _isVivoDevice(String brand, String manufacturer, String model) {
    return brand.contains('vivo') || 
           manufacturer.contains('vivo') ||
           model.startsWith('v') && model.length < 10; // Vivo simple models
  }

  static bool _isXiaomiDevice(String brand, String manufacturer, String model) {
    return brand.contains('xiaomi') || 
           manufacturer.contains('xiaomi') ||
           brand.contains('redmi') ||
           brand.contains('poco') ||
           model.contains('mi ') ||
           model.contains('redmi');
  }

  static bool _isHyperOSDevice(String model, int sdkInt) {
    // HyperOS detectado en modelos nuevos (2024+) y Android 14+
    return (model.contains('14') || model.contains('15') || model.contains('16')) &&
           sdkInt >= 34; // Android 14+
  }

  static bool _isHonorDevice(String brand, String manufacturer, String model) {
    return brand.contains('honor') || 
           manufacturer.contains('honor');
  }

  static bool _isHuaweiDevice(String brand, String manufacturer, String model) {
    return brand.contains('huawei') || 
           manufacturer.contains('huawei');
  }

  /// 🎯 Métodos de utilidad

  /// ✅ Verifica si el dispositivo necesita workarounds
  static Future<bool> needsChineseDeviceWorkarounds() async {
    final profile = await detectCurrentDevice();
    return profile.needsWorkarounds;
  }

  /// 📊 Obtiene estadísticas del dispositivo
  static Future<Map<String, dynamic>> getDeviceStats() async {
    final profile = await detectCurrentDevice();
    
    return {
      'brand': profile.brandName,
      'os': profile.deviceOS,
      'risk_level': profile.riskLevel.toString(),
      'needs_workarounds': profile.needsWorkarounds,
      'known_issues_count': profile.knownIssues.length,
      'has_flutter_version_issues': profile.problematicFlutterVersions.isNotEmpty,
      'recommended_fixes_count': profile.recommendedFixes.length,
    };
  }

  /// 🔧 Obtiene configuración recomendada
  static Future<Map<String, dynamic>> getRecommendedConfiguration() async {
    final profile = await detectCurrentDevice();
    return profile.recommendedFixes;
  }

  /// 📱 Información detallada para debugging
  static Future<String> getDetailedDeviceInfo() async {
    final profile = await detectCurrentDevice();
    
    return '''
🔍 === ANÁLISIS DISPOSITIVO CHINO ===
📱 Marca: ${profile.brandName}
🎨 OS: ${profile.deviceOS}
⚠️ Nivel de Riesgo: ${profile.riskLevel}
🔧 Necesita Workarounds: ${profile.needsWorkarounds}

📋 Issues Conocidos (${profile.knownIssues.length}):
${profile.knownIssues.map((issue) => '  - $issue').join('\n')}

🛠️ Fixes Recomendados (${profile.recommendedFixes.length}):
${profile.recommendedFixes.entries.map((e) => '  - ${e.key}: ${e.value}').join('\n')}

🚨 Versiones Flutter Problemáticas:
${profile.problematicFlutterVersions.isNotEmpty ? profile.problematicFlutterVersions.join(', ') : 'Ninguna conocida'}
    ''';
  }
}

/// 📊 Extensiones útiles para el detector
extension ChineseDeviceDetectorUtils on ChineseDeviceDetector {
  
  /// 🚨 Detecta si es dispositivo OPPO crítico
  static Future<bool> isCriticalOPPODevice() async {
    final profile = await ChineseDeviceDetector.detectCurrentDevice();
    return profile.riskLevel == ChineseDeviceRiskLevel.CRITICAL;
  }

  /// 🔴 Detecta si es dispositivo Xiaomi HyperOS
  static Future<bool> isXiaomiHyperOS() async {
    final profile = await ChineseDeviceDetector.detectCurrentDevice();
    return profile.deviceOS == 'HyperOS';
  }
}