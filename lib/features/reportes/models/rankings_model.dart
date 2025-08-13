// 🏆🐓 MODELOS PARA RANKINGS - TOP GALLOS, PADRILLOS Y MADRES
import 'package:flutter/material.dart';

class RankingsData {
  final String tipo;
  final List<RankingItem> items;
  final EstadisticasRanking? estadisticas;
  final double timestamp;

  RankingsData({
    required this.tipo,
    required this.items,
    this.estadisticas,
    required this.timestamp,
  });

  factory RankingsData.fromJson(Map<String, dynamic> json) {
    try {
      print('📊 Rankings JSON recibido: ${json.keys.toList()}');
      
      return RankingsData(
        tipo: json['tipo']?.toString() ?? 'gallos',
        items: (json['items'] as List?)
            ?.where((item) => item != null)
            ?.map<RankingItem?>((item) {
              try {
                return RankingItem.fromJson(item);
              } catch (e) {
                print('❌ Error parseando RankingItem: $e, item: $item');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<RankingItem>()
            .toList() ?? [],
        estadisticas: json['estadisticas'] != null 
            ? EstadisticasRanking.fromJson(json['estadisticas'])
            : null,
        timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e, stack) {
      print('❌ Error parseando RankingsData: $e');
      print('JSON completo: $json');
      print('Stack: $stack');
      rethrow;
    }
  }
}

class RankingItem {
  final int id;
  final String nombre;
  final String? raza;
  final String? codigo;
  final int peleasPeriodo;
  final int ganadasPeriodo;
  final int topesPeriodo;
  final double efectividadPeriodo;
  final int posicion;

  RankingItem({
    required this.id,
    required this.nombre,
    this.raza,
    this.codigo,
    required this.peleasPeriodo,
    required this.ganadasPeriodo,
    required this.topesPeriodo,
    required this.efectividadPeriodo,
    required this.posicion,
  });

  factory RankingItem.fromJson(Map<String, dynamic> json) {
    // Usar las mismas funciones de parseo seguro
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
    
    return RankingItem(
      id: parseIntSafe(json['id']),
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      raza: json['raza']?.toString(),
      codigo: json['codigo']?.toString(),
      peleasPeriodo: parseIntSafe(json['peleas_periodo']),
      ganadasPeriodo: parseIntSafe(json['ganadas_periodo']),
      topesPeriodo: parseIntSafe(json['topes_periodo']),
      efectividadPeriodo: parseDoubleSafe(json['efectividad_periodo']),
      posicion: parseIntSafe(json['posicion']),
    );
  }

  int get perdidasPeriodo => peleasPeriodo - ganadasPeriodo;
  String get efectividadFormateada => '${efectividadPeriodo.toStringAsFixed(1)}%';

  // Color por efectividad
  Color get colorEfectividad {
    if (efectividadPeriodo >= 80) return const Color(0xFF4CAF50); // Verde
    if (efectividadPeriodo >= 60) return const Color(0xFFFF9800); // Naranja  
    if (efectividadPeriodo >= 40) return const Color(0xFFFFC107); // Amarillo
    return const Color(0xFFF44336); // Rojo
  }

  // Color por posición
  Color get colorPosicion {
    switch (posicion) {
      case 1: return const Color(0xFFFFD700); // Oro
      case 2: return const Color(0xFFC0C0C0); // Plata
      case 3: return const Color(0xFFCD7F32); // Bronce
      default: return const Color(0xFF2196F3); // Azul
    }
  }

  // Icono según posición
  IconData get iconoPosicion {
    switch (posicion) {
      case 1: return Icons.emoji_events;
      case 2: return Icons.workspace_premium;
      case 3: return Icons.military_tech;
      default: return Icons.star_outline;
    }
  }
}

class EstadisticasRanking {
  final int totalItems;
  final int totalPeleas;
  final int totalGanadas;
  final double efectividadPromedio;
  final int totalTopes;

  EstadisticasRanking({
    required this.totalItems,
    required this.totalPeleas,
    required this.totalGanadas,
    required this.efectividadPromedio,
    required this.totalTopes,
  });

  factory EstadisticasRanking.fromJson(Map<String, dynamic> json) {
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
    
    return EstadisticasRanking(
      totalItems: parseIntSafe(json['total_items']),
      totalPeleas: parseIntSafe(json['total_peleas']),
      totalGanadas: parseIntSafe(json['total_ganadas']),
      efectividadPromedio: parseDoubleSafe(json['efectividad_promedio']),
      totalTopes: parseIntSafe(json['total_topes']),
    );
  }

  int get totalPerdidas => totalPeleas - totalGanadas;
  String get efectividadFormateada => '${efectividadPromedio.toStringAsFixed(1)}%';
}