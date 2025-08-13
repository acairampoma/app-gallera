// 📄🐓 MODELOS PARA DOCUMENTOS - GALLOS PARA EXPORT PDF
import 'package:flutter/material.dart';

class GalloDocumento {
  final int id;
  final String nombre;
  final String codigo;
  final String? raza;
  final String? fotoUrl;
  final int totalPeleas;
  final int peleasGanadas;
  final double efectividad;
  final double ingresosTotales;
  final String estado;
  final DateTime? fechaNacimiento;
  final String? peso;
  final String? color;

  GalloDocumento({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.raza,
    this.fotoUrl,
    required this.totalPeleas,
    required this.peleasGanadas,
    required this.efectividad,
    required this.ingresosTotales,
    required this.estado,
    this.fechaNacimiento,
    this.peso,
    this.color,
  });

  factory GalloDocumento.fromJson(Map<String, dynamic> json) {
    // Funciones de parseo seguro
    int parseIntSafe(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    double parseDoubleSafe(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    DateTime? parseDateSafe(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }
    
    // Calcular efectividad si no viene calculada
    int totalPeleas = parseIntSafe(json['total_peleas']) + 
                     parseIntSafe(json['peleas_totales']); // Diferentes nombres posibles
    int peleasGanadas = parseIntSafe(json['peleas_ganadas']) +
                       parseIntSafe(json['ganadas']);
    
    double efectividad = 0.0;
    if (totalPeleas > 0) {
      efectividad = (peleasGanadas / totalPeleas) * 100;
    }
    
    return GalloDocumento(
      id: parseIntSafe(json['id']),
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      codigo: json['codigo_identificacion']?.toString() ?? 
              json['codigo']?.toString() ?? 
              'SIN-CODIGO',
      raza: json['raza']?.toString() ?? json['raza_nombre']?.toString(),
      fotoUrl: json['url_foto_cloudinary']?.toString() ?? 
               json['foto_principal_url']?.toString(),
      totalPeleas: totalPeleas,
      peleasGanadas: peleasGanadas,
      efectividad: parseDoubleSafe(json['efectividad']) != 0.0 
          ? parseDoubleSafe(json['efectividad']) 
          : efectividad,
      ingresosTotales: parseDoubleSafe(json['ingresos_totales']) +
                      parseDoubleSafe(json['ingresos_estimados']),
      estado: json['estado']?.toString() ?? 'activo',
      fechaNacimiento: parseDateSafe(json['fecha_nacimiento']),
      peso: json['peso']?.toString(),
      color: json['color']?.toString(),
    );
  }

  int get peleasPerdidas => totalPeleas - peleasGanadas;
  
  String get efectividadFormateada => '${efectividad.toStringAsFixed(1)}%';
  
  String get recordFormateado => '${peleasGanadas}V-${peleasPerdidas}D';
  
  String get ingresosFormateados {
    if (ingresosTotales >= 1000000) {
      return 'S/ ${(ingresosTotales / 1000000).toStringAsFixed(1)}M';
    } else if (ingresosTotales >= 1000) {
      return 'S/ ${(ingresosTotales / 1000).toStringAsFixed(1)}K';
    } else {
      return 'S/ ${ingresosTotales.toStringAsFixed(0)}';
    }
  }
  
  Color get colorEfectividad {
    if (efectividad >= 80) return const Color(0xFF4CAF50); // Verde
    if (efectividad >= 60) return const Color(0xFFFF9800); // Naranja  
    if (efectividad >= 40) return const Color(0xFFFFC107); // Amarillo
    return const Color(0xFFF44336); // Rojo
  }
  
  String get edadFormateada {
    if (fechaNacimiento == null) return 'N/A';
    
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaNacimiento!);
    final meses = (diferencia.inDays / 30).round();
    
    if (meses < 12) {
      return '$meses meses';
    } else {
      final anos = (meses / 12).floor();
      final mesesRestantes = meses % 12;
      if (mesesRestantes == 0) {
        return '$anos años';
      } else {
        return '$anos años $mesesRestantes meses';
      }
    }
  }
}

class FichaExportData {
  final GalloDocumento gallo;
  final Map<String, dynamic> genealogia;
  final Map<String, dynamic> estadisticas;
  final List<Map<String, dynamic>> historialPeleas;
  final Map<String, dynamic> metadata;

  FichaExportData({
    required this.gallo,
    required this.genealogia,
    required this.estadisticas,
    required this.historialPeleas,
    required this.metadata,
  });

  factory FichaExportData.fromJson(Map<String, dynamic> json) {
    return FichaExportData(
      gallo: GalloDocumento.fromJson(json['gallo'] ?? {}),
      genealogia: json['genealogia'] ?? {},
      estadisticas: json['estadisticas'] ?? {},
      historialPeleas: List<Map<String, dynamic>>.from(json['historial_peleas'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }
}

class DocumentoEstadisticas {
  final int totalGallos;
  final int gallosActivos;
  final double efectividadPromedio;
  final int reportesGenerados;
  final DateTime? ultimoReporte;

  DocumentoEstadisticas({
    required this.totalGallos,
    required this.gallosActivos,
    required this.efectividadPromedio,
    required this.reportesGenerados,
    this.ultimoReporte,
  });

  String get efectividadFormateada => '${efectividadPromedio.toStringAsFixed(1)}%';
  
  String get ultimoReporteFormateado {
    if (ultimoReporte == null) return 'Nunca';
    
    final ahora = DateTime.now();
    final diferencia = ahora.difference(ultimoReporte!);
    
    if (diferencia.inDays == 0) {
      return 'Hoy';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else if (diferencia.inDays < 30) {
      final semanas = (diferencia.inDays / 7).round();
      return 'Hace $semanas semanas';
    } else {
      final meses = (diferencia.inDays / 30).round();
      return 'Hace $meses meses';
    }
  }
}