// 💳 Modelos para Sistema de Pagos - QR Yape
// Compatible con API Railway: https://gallerappback-production.up.railway.app

import 'dart:convert';

// ========================================
// MODELO DE PAGO PENDIENTE
// ========================================

class PagoPendiente {
  final int id;
  final int userId;
  final String planCodigo;
  final double monto;
  final String estado;
  final String? qrData;
  final String? qrUrl;
  final String? comprobanteUrl;
  final String? referenciaYape;
  final DateTime? fechaPagoUsuario;
  final DateTime? fechaVerificacion;
  final int? adminId;
  final String? notasAdmin;
  final int intentos;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Campos adicionales para UI
  final String? nombreUsuario;
  final String? planDestino;
  final String? observaciones;

  PagoPendiente({
    required this.id,
    required this.userId,
    required this.planCodigo,
    required this.monto,
    required this.estado,
    this.qrData,
    this.qrUrl,
    this.comprobanteUrl,
    this.referenciaYape,
    this.fechaPagoUsuario,
    this.fechaVerificacion,
    this.adminId,
    this.notasAdmin,
    this.intentos = 0,
    required this.createdAt,
    required this.updatedAt,
    this.nombreUsuario,
    this.planDestino,
    this.observaciones,
  });

  factory PagoPendiente.fromJson(Map<String, dynamic> json) {
    return PagoPendiente(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      planCodigo: json['plan_codigo'] ?? '',
      monto: (json['monto'] ?? 0.0).toDouble(),
      estado: json['estado'] ?? 'pendiente',
      qrData: json['qr_data'],
      qrUrl: json['qr_url'],
      comprobanteUrl: json['comprobante_url'],
      referenciaYape: json['referencia_yape'],
      fechaPagoUsuario: json['fecha_pago_usuario'] != null
          ? DateTime.parse(json['fecha_pago_usuario'])
          : null,
      fechaVerificacion: json['fecha_verificacion'] != null
          ? DateTime.parse(json['fecha_verificacion'])
          : null,
      adminId: json['admin_id'],
      notasAdmin: json['notas_admin'],
      intentos: json['intentos'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      nombreUsuario: json['nombre_usuario'],
      planDestino: json['plan_destino'],
      observaciones: json['observaciones'] ?? json['notas_admin'],
    );
  }

  /// Estados del pago
  bool get estaAprobado => estado.toLowerCase() == 'aprobado';
  bool get estaRechazado => estado.toLowerCase() == 'rechazado';
  bool get estaPendiente => estado.toLowerCase() == 'pendiente';
  bool get estaVerificando => estado.toLowerCase() == 'verificando';

  /// Color por estado
  String get estadoColor {
    switch (estado.toLowerCase()) {
      case 'aprobado': return '#4CAF50';
      case 'rechazado': return '#F44336';
      case 'verificando': return '#2196F3';
      case 'pendiente': return '#FF9800';
      default: return '#9E9E9E';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_codigo': planCodigo,
      'monto': monto,
      'estado': estado,
      'qr_data': qrData,
      'qr_url': qrUrl,
      'comprobante_url': comprobanteUrl,
      'referencia_yape': referenciaYape,
      'fecha_pago_usuario': fechaPagoUsuario?.toIso8601String(),
      'fecha_verificacion': fechaVerificacion?.toIso8601String(),
      'admin_id': adminId,
      'notas_admin': notasAdmin,
      'intentos': intentos,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre_usuario': nombreUsuario,
      'plan_destino': planDestino,
      'observaciones': observaciones,
    };
  }
}

// ========================================
// MODELO DE QR YAPE RESPONSE
// ========================================

class QRYapeResponse {
  final int pagoId;
  final String qrData;
  final String qrUrl;
  final double monto;
  final String planNombre;
  final List<String> instrucciones;
  final String? numeroYape;
  final DateTime? tiempoExpiracion;

  QRYapeResponse({
    required this.pagoId,
    required this.qrData,
    required this.qrUrl,
    required this.monto,
    required this.planNombre,
    required this.instrucciones,
    this.numeroYape,
    this.tiempoExpiracion,
  });

  factory QRYapeResponse.fromJson(Map<String, dynamic> json) {
    return QRYapeResponse(
      pagoId: json['pago_id'] ?? 0,
      qrData: json['qr_data'] ?? '',
      qrUrl: json['qr_url'] ?? '',
      monto: (json['monto'] ?? 0.0).toDouble(),
      planNombre: json['plan_nombre'] ?? '',
      instrucciones: json['instrucciones'] != null
          ? List<String>.from(json['instrucciones'])
          : [],
      numeroYape: json['numero_yape'],
      tiempoExpiracion: json['tiempo_expiracion'] != null
          ? DateTime.parse(json['tiempo_expiracion'])
          : null,
    );
  }

  /// Monto formateado
  String get montoFormateado => 'S/. ${monto.toStringAsFixed(2)}';

  Map<String, dynamic> toJson() {
    return {
      'pago_id': pagoId,
      'qr_data': qrData,
      'qr_url': qrUrl,
      'monto': monto,
      'plan_nombre': planNombre,
      'instrucciones': instrucciones,
      'numero_yape': numeroYape,
      'tiempo_expiracion': tiempoExpiracion?.toIso8601String(),
    };
  }
}

// ========================================
// MODELO PARA CONFIRMAR PAGO
// ========================================

class ConfirmarPagoRequest {
  final int pagoId;
  final String? referenciaYape;
  final String? comprobanteBase64;

  ConfirmarPagoRequest({
    required this.pagoId,
    this.referenciaYape,
    this.comprobanteBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'pago_id': pagoId,
      'referencia_yape': referenciaYape,
      'comprobante_base64': comprobanteBase64,
    };
  }
}

class ConfirmarPagoResponse {
  final bool success;
  final String mensaje;
  final String estado;
  final int pagoId;

  ConfirmarPagoResponse({
    required this.success,
    required this.mensaje,
    required this.estado,
    required this.pagoId,
  });

  factory ConfirmarPagoResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmarPagoResponse(
      success: json['success'] ?? false,
      mensaje: json['mensaje'] ?? '',
      estado: json['estado'] ?? '',
      pagoId: json['pago_id'] ?? 0,
    );
  }
}

// ========================================
// MODELO DE ERROR DE LÍMITE SUPERADO
// ========================================

class LimiteSuperadoError implements Exception {
  final String detail;
  final LimiteInfo limiteInfo;
  final String accionRequerida;

  LimiteSuperadoError({
    required this.detail,
    required this.limiteInfo,
    required this.accionRequerida,
  });

  factory LimiteSuperadoError.fromJson(Map<String, dynamic> json) {
    return LimiteSuperadoError(
      detail: json['detail'] ?? 'Límite superado',
      limiteInfo: LimiteInfo.fromJson(json['limite_info'] ?? {}),
      accionRequerida: json['accion_requerida'] ?? 'upgrade_plan',
    );
  }

  @override
  String toString() => detail;
}

class LimiteInfo {
  final String recursoTipo;
  final int limiteActual;
  final int cantidadUsada;
  final String? planRecomendado;
  final bool upgradeDisponible;

  LimiteInfo({
    required this.recursoTipo,
    required this.limiteActual,
    required this.cantidadUsada,
    this.planRecomendado,
    this.upgradeDisponible = true,
  });

  factory LimiteInfo.fromJson(Map<String, dynamic> json) {
    return LimiteInfo(
      recursoTipo: json['recurso_tipo'] ?? '',
      limiteActual: json['limite_actual'] ?? 0,
      cantidadUsada: json['cantidad_usada'] ?? 0,
      planRecomendado: json['plan_recomendado'],
      upgradeDisponible: json['upgrade_disponible'] ?? true,
    );
  }

  /// Mensaje descriptivo del límite
  String get mensaje {
    if (cantidadUsada >= limiteActual) {
      return 'Has alcanzado el límite de $limiteActual $recursoTipo';
    } else {
      final restantes = limiteActual - cantidadUsada;
      return 'Te quedan $restantes $recursoTipo de $limiteActual';
    }
  }

  /// Porcentaje de uso
  double get porcentajeUso {
    if (limiteActual == 0) return 0.0;
    return (cantidadUsada / limiteActual).clamp(0.0, 1.0);
  }
}