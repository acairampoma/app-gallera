import 'package:flutter/material.dart';
import '../../utils/device_utils.dart';

/// 🎯 ADAPTIVE LAYOUT BUILDER - Layouts adaptativos para móvil/tablet
/// Autor: Alan Cairampoma  
/// Propósito: Screenshots perfectos de iPad para Apple Store

class AdaptiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const AdaptiveLayoutBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si no se proporciona diseño para tablet, usar móvil
    if (DeviceUtils.isTablet(context) && tablet != null) {
      return tablet!;
    }
    
    // Si no se proporciona diseño para desktop, usar tablet o móvil
    if (DeviceUtils.isIPadPro(context) && desktop != null) {
      return desktop!;
    }
    
    // Fallback siempre a móvil
    return mobile;
  }
}

/// 🏗️ RESPONSIVE ROW/COLUMN - Se adapta automáticamente
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  
  const ResponsiveRowColumn({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (DeviceUtils.isTablet(context)) {
      // En tablet: usar Row (horizontal)
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    } else {
      // En móvil: usar Column (vertical)
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }
  }
}

/// 📐 RESPONSIVE GRID - Grid que se adapta según dispositivo
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? forceColumns;
  
  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.forceColumns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = forceColumns ?? DeviceUtils.getGridColumns(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 1.0,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// 📱 RESPONSIVE CARD - Card que se ajusta según dispositivo
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  
  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adaptivePadding = padding ?? DeviceUtils.getAdaptivePadding(context);
    final adaptiveElevation = elevation ?? (DeviceUtils.isTablet(context) ? 6.0 : 4.0);
    
    return Card(
      elevation: adaptiveElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DeviceUtils.isTablet(context) ? 20 : 15),
      ),
      child: Padding(
        padding: adaptivePadding,
        child: child,
      ),
    );
  }
}

/// 🎨 RESPONSIVE TEXT - Texto que escala según dispositivo  
class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  
  const ResponsiveText(
    this.text, {
    Key? key,
    this.baseFontSize = 16.0,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: DeviceUtils.getAdaptiveFontSize(context, baseFontSize),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}

/// 🖼️ ADAPTIVE CONTAINER - Container con dimensiones adaptativas
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Decoration? decoration;
  
  const AdaptiveContainer({
    Key? key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? width;
    
    if (DeviceUtils.isTablet(context) && tabletWidth != null) {
      width = tabletWidth;
    } else if (mobileWidth != null) {
      width = mobileWidth;
    }
    
    return Container(
      width: width,
      height: height,
      padding: padding ?? DeviceUtils.getAdaptivePadding(context),
      margin: margin,
      decoration: decoration,
      color: color,
      child: child,
    );
  }
}

/// 🚀 DEBUG WIDGET - Mostrar info del dispositivo (solo en debug)
class DeviceInfoDebug extends StatelessWidget {
  const DeviceInfoDebug({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Solo mostrar en modo debug
    assert(() {
      return true;
    }());
    
    final deviceInfo = DeviceUtils.getDeviceInfo(context);
    
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔧 Device Debug Info',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          ...deviceInfo.entries.map(
            (entry) => Text(
              '${entry.key}: ${entry.value}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}