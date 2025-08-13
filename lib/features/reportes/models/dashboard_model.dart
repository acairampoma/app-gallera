// 📊🐓 MODELOS ÉPICOS PARA DASHBOARD - DATA REAL DE API
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
class DashboardModel {
  final double timestamp;
  final FiltrosAplicados filtrosAplicados;
  final ResumenPeriodo resumenPeriodo;
  final FinanzasPeriodo finanzasPeriodo;
  final List<TopGallo> topGallosPeriodo;
  final EvolucionSeisM evolucionSeisMeses;

  DashboardModel({
    required this.timestamp,
    required this.filtrosAplicados,
    required this.resumenPeriodo,
    required this.finanzasPeriodo,
    required this.topGallosPeriodo,
    required this.evolucionSeisMeses,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    try {
      print('📊 Dashboard JSON recibido: ${json.keys.toList()}');
      
      // Validar estructura básica
      if (!json.containsKey('filtros_aplicados')) {
        print('⚠️ Falta filtros_aplicados, usando objeto vacío');
      }
      if (!json.containsKey('resumen_periodo')) {
        print('⚠️ Falta resumen_periodo, usando objeto vacío');
      }
      
      return DashboardModel(
        timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
        filtrosAplicados: FiltrosAplicados.fromJson(json['filtros_aplicados'] ?? {}),
        resumenPeriodo: ResumenPeriodo.fromJson(json['resumen_periodo'] ?? {}),
        finanzasPeriodo: FinanzasPeriodo.fromJson(json['finanzas_periodo'] ?? {}),
        topGallosPeriodo: (json['top_gallos_periodo'] as List?)
            ?.where((item) => item != null)
            ?.map<TopGallo?>((item) {
              try {
                return TopGallo.fromJson(item);
              } catch (e) {
                print('❌ Error parseando TopGallo: $e, item: $item');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<TopGallo>()
            .toList() ?? [],
        evolucionSeisMeses: EvolucionSeisM.fromJson(json['evolucion_6_meses'] ?? {}),
      );
    } catch (e, stack) {
      print('❌ Error parseando DashboardModel: $e');
      print('JSON completo: $json');
      print('Stack: $stack');
      rethrow;
    }
  }
}

// 🗓️ FILTROS APLICADOS
class FiltrosAplicados {
  final int? ano;
  final int? mes;
  final int? userId;
  final String? periodoNombre;

  FiltrosAplicados({
    this.ano,
    this.mes,
    this.userId,
    this.periodoNombre,
  });

  factory FiltrosAplicados.fromJson(Map<String, dynamic> json) {
    // Parseo más seguro para evitar nulls
    int? parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }
    
    return FiltrosAplicados(
      ano: parseIntNullable(json['año']) ?? parseIntNullable(json['ano']), // Buscar primero con ñ
      mes: parseIntNullable(json['mes']),
      userId: parseIntNullable(json['user_id']),
      periodoNombre: json['periodo_nombre']?.toString(),
    );
  }

  String get periodoFormateado {
    if (periodoNombre?.isNotEmpty == true) return periodoNombre!;
    if (ano != null && mes != null) {
      const meses = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${meses[mes!]} $ano';
    }
    return 'Período actual';
  }
}

// 📊 RESUMEN DEL PERÍODO
class ResumenPeriodo {
  final int totalGallos;
  final int gallosActivos;
  final int peleasPeriodo;
  final int ganadasPeriodo;
  final int topesPeriodo;
  final double efectividadPeriodo;

  ResumenPeriodo({
    required this.totalGallos,
    required this.gallosActivos,
    required this.peleasPeriodo,
    required this.ganadasPeriodo,
    required this.topesPeriodo,
    required this.efectividadPeriodo,
  });

  factory ResumenPeriodo.fromJson(Map<String, dynamic> json) {
    // Manejar nulls de forma MÁS segura
    int parseIntSafe(dynamic value) {
      try {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          return parsed ?? 0;
        }
        print('⚠️ Valor inesperado en parseIntSafe: $value (${value.runtimeType})');
        return 0;
      } catch (e) {
        print('❌ Error en parseIntSafe: $e, valor: $value');
        return 0;
      }
    }
    
    double parseDoubleSafe(dynamic value) {
      try {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          return parsed ?? 0.0;
        }
        print('⚠️ Valor inesperado en parseDoubleSafe: $value (${value.runtimeType})');
        return 0.0;
      } catch (e) {
        print('❌ Error en parseDoubleSafe: $e, valor: $value');
        return 0.0;
      }
    }
    
    // Log para debug
    print('🔍 ResumenPeriodo JSON keys: ${json.keys.toList()}');
    
    return ResumenPeriodo(
      totalGallos: parseIntSafe(json['total_gallos']),
      gallosActivos: parseIntSafe(json['gallos_activos']),
      peleasPeriodo: parseIntSafe(json['peleas_periodo']),
      ganadasPeriodo: parseIntSafe(json['ganadas_periodo']),
      topesPeriodo: parseIntSafe(json['topes_periodo']),
      efectividadPeriodo: parseDoubleSafe(json['efectividad_periodo']),
    );
  }

  int get perdidasPeriodo => peleasPeriodo - ganadasPeriodo;
  
  String get efectividadFormateada => '${efectividadPeriodo.toStringAsFixed(1)}%';
}

// 💰 FINANZAS DEL PERÍODO
class FinanzasPeriodo {
  final double ingresos;
  final double gastosTotales;
  final double gananciaNeta;
  final DetalleGastos detalleGastos;

  FinanzasPeriodo({
    required this.ingresos,
    required this.gastosTotales,
    required this.gananciaNeta,
    required this.detalleGastos,
  });

  factory FinanzasPeriodo.fromJson(Map<String, dynamic> json) {
    double parseDoubleSafe(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return FinanzasPeriodo(
      ingresos: parseDoubleSafe(json['ingresos']),
      gastosTotales: parseDoubleSafe(json['gastos_totales']),
      gananciaNeta: parseDoubleSafe(json['ganancia_neta']),
      detalleGastos: DetalleGastos.fromJson(json['detalle_gastos'] ?? {}),
    );
  }

  double get roiPorcentaje {
    if (gastosTotales == 0) return 0.0;
    return (gananciaNeta / gastosTotales) * 100;
  }

  String get roiFormateado => '${roiPorcentaje.toStringAsFixed(1)}%';
  
  String get ingresosFormateados => formatearMoneda(ingresos);
  String get gastosFormateados => formatearMoneda(gastosTotales);
  String get gananciaFormateada => formatearMoneda(gananciaNeta);

  static String formatearMoneda(double valor) {
    if (valor >= 1000000) {
      return 'S/ ${(valor / 1000000).toStringAsFixed(1)}M';
    } else if (valor >= 1000) {
      return 'S/ ${(valor / 1000).toStringAsFixed(1)}K';
    } else {
      return 'S/ ${valor.toStringAsFixed(0)}';
    }
  }
}

// 💳 DETALLE DE GASTOS
class DetalleGastos {
  final double alimento;
  final double medicina;
  final double entrenador;
  final double limpieza;

  DetalleGastos({
    required this.alimento,
    required this.medicina,
    required this.entrenador,
    required this.limpieza,
  });

  factory DetalleGastos.fromJson(Map<String, dynamic> json) {
    double parseDoubleSafe(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return DetalleGastos(
      alimento: parseDoubleSafe(json['alimento']),
      medicina: parseDoubleSafe(json['medicina']),
      entrenador: parseDoubleSafe(json['entrenador']),
      limpieza: parseDoubleSafe(json['limpieza']),
    );
  }

  double get total => alimento + medicina + entrenador + limpieza;

  List<GastoCategoria> get categorias => [
    GastoCategoria('Alimento', alimento, const Color(0xFF4CAF50)),
    GastoCategoria('Medicina', medicina, const Color(0xFF2196F3)),
    GastoCategoria('Entrenador', entrenador, const Color(0xFFFF9800)),
    GastoCategoria('Limpieza', limpieza, const Color(0xFF9C27B0)),
  ].where((cat) => cat.valor > 0).toList();
}

// 📊 CATEGORÍA DE GASTO PARA GRÁFICOS
class GastoCategoria {
  final String nombre;
  final double valor;
  final Color color;

  GastoCategoria(this.nombre, this.valor, this.color);

  double porcentaje(double total) {
    if (total == 0) return 0.0;
    return (valor / total) * 100;
  }

  String get valorFormateado => FinanzasPeriodo.formatearMoneda(valor);
}

// 🏆 TOP GALLO DEL PERÍODO
class TopGallo {
  final int id;
  final String nombre;
  final String? raza;
  final String? codigo;
  final int peleasPeriodo;
  final int ganadasPeriodo;
  final double efectividadPeriodo;

  TopGallo({
    required this.id,
    required this.nombre,
    this.raza,
    this.codigo,
    required this.peleasPeriodo,
    required this.ganadasPeriodo,
    required this.efectividadPeriodo,
  });

  factory TopGallo.fromJson(Map<String, dynamic> json) {
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
    
    return TopGallo(
      id: parseIntSafe(json['id']),
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      raza: json['raza']?.toString(),
      codigo: json['codigo']?.toString(),
      peleasPeriodo: parseIntSafe(json['peleas_periodo']),
      ganadasPeriodo: parseIntSafe(json['ganadas_periodo']),
      efectividadPeriodo: parseDoubleSafe(json['efectividad_periodo']),
    );
  }

  int get perdidasPeriodo => peleasPeriodo - ganadasPeriodo;
  String get efectividadFormateada => '${efectividadPeriodo.toStringAsFixed(1)}%';
  double get ingresosEstimados => ganadasPeriodo * 3000.0;

  // Color por efectividad
  Color get colorEfectividad {
    if (efectividadPeriodo >= 80) return const Color(0xFF4CAF50); // Verde
    if (efectividadPeriodo >= 60) return const Color(0xFFFF9800); // Naranja  
    if (efectividadPeriodo >= 40) return const Color(0xFFFFC107); // Amarillo
    return const Color(0xFFF44336); // Rojo
  }
}

// 📈 EVOLUCIÓN 6 MESES
class EvolucionSeisM {
  final List<String> labels;
  final List<int> peleas;
  final List<int> ganadas;
  final List<double> gastos;

  EvolucionSeisM({
    required this.labels,
    required this.peleas,
    required this.ganadas,
    required this.gastos,
  });

  factory EvolucionSeisM.fromJson(Map<String, dynamic> json) {
    // Parseo seguro de listas
    List<String> parseStringList(dynamic value) {
      if (value == null || value is! List) return [];
      return value.map<String>((item) => item?.toString() ?? '').toList();
    }
    
    List<int> parseIntList(dynamic value) {
      if (value == null || value is! List) return [];
      return value.map<int>((item) {
        if (item == null) return 0;
        if (item is int) return item;
        if (item is double) return item.toInt();
        if (item is String) return int.tryParse(item) ?? 0;
        return 0;
      }).toList();
    }
    
    List<double> parseDoubleList(dynamic value) {
      if (value == null || value is! List) return [];
      return value.map<double>((item) {
        if (item == null) return 0.0;
        if (item is double) return item;
        if (item is int) return item.toDouble();
        if (item is String) return double.tryParse(item) ?? 0.0;
        return 0.0;
      }).toList();
    }
    
    return EvolucionSeisM(
      labels: parseStringList(json['labels']),
      peleas: parseIntList(json['peleas']),
      ganadas: parseIntList(json['ganadas']),
      gastos: parseDoubleList(json['gastos']),
    );
  }

  // Para gráficos de fl_chart
  List<FlSpot> get peleasSpots => peleas.asMap().entries
      .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
      .toList();

  List<FlSpot> get ganadasSpots => ganadas.asMap().entries
      .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
      .toList();

  List<FlSpot> get gastosSpots => gastos.asMap().entries
      .map((e) => FlSpot(e.key.toDouble(), e.value))
      .toList();

  // Efectividad por mes
  List<double> get efectividades => List.generate(labels.length, (index) {
    if (index >= peleas.length || index >= ganadas.length) return 0.0;
    final totalPeleas = peleas[index];
    final totalGanadas = ganadas[index];
    if (totalPeleas == 0) return 0.0;
    return (totalGanadas / totalPeleas) * 100;
  });

  List<FlSpot> get efectividadesSpots => efectividades.asMap().entries
      .map((e) => FlSpot(e.key.toDouble(), e.value))
      .toList();

  bool get tienedatos => labels.isNotEmpty && peleas.isNotEmpty;
}

// Ya importamos fl_chart arriba, usamos su FlSpot

