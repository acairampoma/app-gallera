import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 📱 UTILIDADES DE DISPOSITIVO - Detección iPad/Tablet
/// Autor: Alan Cairampoma
/// Propósito: Resolver screenshots de iPad para Apple Store

class DeviceUtils {
  /// 📐 BREAKPOINTS DE DISEÑO
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 768.0;
  static const double ipadProBreakpoint = 1024.0;
  
  /// 📱 DETECTAR SI ES MÓVIL NATIVO (No Web)
  static bool isMobile(BuildContext context) {
    // En app nativa, siempre es móvil sin importar el tamaño
    if (!kIsWeb) return true;
    
    // En web, usar breakpoint
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < mobileBreakpoint;
  }
  
  /// 📟 DETECTAR SI ES TABLET/IPAD (Solo aplicar responsive en WEB)
  static bool isTablet(BuildContext context) {
    // Solo aplicar diseño tablet en WEB
    if (!kIsWeb) return false;
    
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= tabletBreakpoint;
  }
  
  /// 🍎 DETECTAR SI ES ESPECÍFICAMENTE IPAD (Solo en Web iOS)
  static bool isIPad(BuildContext context) {
    if (!kIsWeb) return false;
    return isTablet(context);
  }
  
  /// 📱 DETECTAR SI ES IPAD PRO (Solo en Web con pantallas grandes)
  static bool isIPadPro(BuildContext context) {
    if (!kIsWeb) return false;
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= ipadProBreakpoint;
  }
  
  /// 📏 OBTENER TIPO DE DISPOSITIVO COMO STRING
  static String getDeviceType(BuildContext context) {
    if (!kIsWeb) return 'Mobile App';
    if (isIPadPro(context)) return 'Web iPad Pro';
    if (isIPad(context)) return 'Web iPad';
    if (isTablet(context)) return 'Web Tablet';
    return 'Web Mobile';
  }
  
  /// 🎯 OBTENER COLUMNAS RECOMENDADAS PARA GRID
  static int getGridColumns(BuildContext context) {
    // En app nativa, siempre 1 columna para mantener diseño original
    if (!kIsWeb) return 1;
    
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 4; // Web iPad Pro landscape
    if (screenWidth >= 900) return 3;  // Web iPad landscape
    if (screenWidth >= 600) return 2;  // Web iPad portrait, tablet
    return 1; // Web Mobile
  }
  
  /// 📊 OBTENER PADDING ADAPTATIVO
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    // En app nativa, siempre padding normal
    if (!kIsWeb) return const EdgeInsets.all(16.0);
    
    if (isTablet(context)) {
      return const EdgeInsets.all(24.0); // Más padding en web tablet
    }
    return const EdgeInsets.all(16.0); // Padding normal
  }
  
  /// 📝 OBTENER TAMAÑO DE FUENTE ADAPTATIVO
  static double getAdaptiveFontSize(BuildContext context, double baseFontSize) {
    // En app nativa, siempre tamaño base
    if (!kIsWeb) return baseFontSize;
    
    if (isTablet(context)) {
      return baseFontSize * 1.2; // 20% más grande solo en web tablet
    }
    return baseFontSize;
  }
  
  /// 🔧 DEBUG: Información completa del dispositivo
  static Map<String, dynamic> getDeviceInfo(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    
    return {
      'isWeb': kIsWeb,
      'platform': kIsWeb ? 'Web' : (Platform.isAndroid ? 'Android' : 'iOS'),
      'screenWidth': screenSize.width,
      'screenHeight': screenSize.height,
      'devicePixelRatio': mediaQuery.devicePixelRatio,
      'deviceType': getDeviceType(context),
      'isMobile': isMobile(context),
      'isTablet': isTablet(context),
      'isIPad': isIPad(context),
      'isIPadPro': isIPadPro(context),
      'recommendedColumns': getGridColumns(context),
    };
  }
}