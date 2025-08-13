// 📁 lib/models/vacuna.dart
// 💉 Modelos para gestión de vacunas

class TipoVacuna {
  final String codigo;
  final String nombre;
  final String enfermedad;
  final String metodo;
  final String dosis;
  final int duracionDias;
  final String color;

  TipoVacuna({
    required this.codigo,
    required this.nombre,
    required this.enfermedad,
    required this.metodo,
    required this.dosis,
    required this.duracionDias,
    required this.color,
  });

  factory TipoVacuna.fromJson(Map<String, dynamic> json) {
    return TipoVacuna(
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      enfermedad: json['enfermedad'] ?? '',
      metodo: json['metodo'] ?? '',
      dosis: json['dosis'] ?? '',
      duracionDias: json['duracion_dias'] ?? 0,
      color: json['color'] ?? '#2196f3',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'enfermedad': enfermedad,
      'metodo': metodo,
      'dosis': dosis,
      'duracion_dias': duracionDias,
      'color': color,
    };
  }
}

class Vacuna {
  final int? id;
  final int? galloId;
  final String? galloNombre;
  final String? galloCodigo;
  final String tipoVacuna;
  final TipoVacuna? tipoInfo;
  final String? laboratorio;
  final DateTime fechaAplicacion;
  final DateTime? proximaDosis;
  final String? veterinarioNombre;
  final String? clinica;
  final String? dosis;
  final String? notas;
  final DateTime? createdAt;

  Vacuna({
    this.id,
    this.galloId,
    this.galloNombre,
    this.galloCodigo,
    required this.tipoVacuna,
    this.tipoInfo,
    this.laboratorio,
    required this.fechaAplicacion,
    this.proximaDosis,
    this.veterinarioNombre,
    this.clinica,
    this.dosis,
    this.notas,
    this.createdAt,
  });

  factory Vacuna.fromJson(Map<String, dynamic> json) {
    return Vacuna(
      id: json['id'],
      galloId: json['gallo_id'],
      galloNombre: json['gallo_nombre'],
      galloCodigo: json['gallo_codigo'],
      tipoVacuna: json['tipo_vacuna'] ?? '',
      tipoInfo: json['tipo_info'] != null 
          ? TipoVacuna.fromJson(json['tipo_info']) 
          : null,
      laboratorio: json['laboratorio'],
      fechaAplicacion: DateTime.parse(json['fecha_aplicacion']),
      proximaDosis: json['proxima_dosis'] != null 
          ? DateTime.parse(json['proxima_dosis']) 
          : null,
      veterinarioNombre: json['veterinario_nombre'],
      clinica: json['clinica'],
      dosis: json['dosis'],
      notas: json['notas'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (galloId != null) 'gallo_id': galloId,
      'tipo_vacuna': tipoVacuna,
      if (laboratorio != null) 'laboratorio': laboratorio,
      'fecha_aplicacion': fechaAplicacion.toIso8601String().split('T')[0],
      if (proximaDosis != null) 
        'proxima_dosis': proximaDosis!.toIso8601String().split('T')[0],
      if (veterinarioNombre != null) 'veterinario_nombre': veterinarioNombre,
      if (clinica != null) 'clinica': clinica,
      if (dosis != null) 'dosis': dosis,
      if (notas != null) 'notas': notas,
    };
  }

  // Getters de conveniencia
  String get nombreTipoVacuna => tipoInfo?.nombre ?? tipoVacuna;
  String get colorTipoVacuna => tipoInfo?.color ?? '#2196f3';
  String get enfermedadTipoVacuna => tipoInfo?.enfermedad ?? 'Desconocida';
  
  // Estado de la vacuna basado en próxima dosis
  EstadoVacuna get estado {
    if (proximaDosis == null) return EstadoVacuna.completa;
    
    final ahora = DateTime.now();
    final diferencia = proximaDosis!.difference(ahora).inDays;
    
    if (diferencia < 0) return EstadoVacuna.vencida;
    if (diferencia <= 2) return EstadoVacuna.urgente;
    if (diferencia <= 7) return EstadoVacuna.proxima;
    return EstadoVacuna.programada;
  }

  String get estadoTexto {
    switch (estado) {
      case EstadoVacuna.vencida:
        return 'Vencida';
      case EstadoVacuna.urgente:
        return 'Urgente';
      case EstadoVacuna.proxima:
        return 'Próxima';
      case EstadoVacuna.programada:
        return 'Programada';
      case EstadoVacuna.completa:
        return 'Completa';
    }
  }

  int? get diasRestantes {
    if (proximaDosis == null) return null;
    return proximaDosis!.difference(DateTime.now()).inDays;
  }
}

class ProximaVacuna {
  final int galloId;
  final String galloNombre;
  final String tipoVacuna;
  final TipoVacuna? tipoInfo;
  final DateTime proximaDosis;
  final int diasRestantes;
  final String estado;

  ProximaVacuna({
    required this.galloId,
    required this.galloNombre,
    required this.tipoVacuna,
    this.tipoInfo,
    required this.proximaDosis,
    required this.diasRestantes,
    required this.estado,
  });

  factory ProximaVacuna.fromJson(Map<String, dynamic> json) {
    return ProximaVacuna(
      galloId: json['gallo_id'] ?? 0,
      galloNombre: json['gallo_nombre'] ?? '',
      tipoVacuna: json['tipo_vacuna'] ?? '',
      tipoInfo: json['tipo_info'] != null 
          ? TipoVacuna.fromJson(json['tipo_info']) 
          : null,
      proximaDosis: DateTime.parse(json['proxima_dosis']),
      diasRestantes: json['dias_restantes'] ?? 0,
      estado: json['estado'] ?? 'normal',
    );
  }

  // Getters de conveniencia
  String get nombreTipoVacuna => tipoInfo?.nombre ?? tipoVacuna;
  String get colorTipoVacuna => tipoInfo?.color ?? '#2196f3';

  EstadoVacuna get estadoEnum {
    switch (estado) {
      case 'urgente':
        return EstadoVacuna.urgente;
      case 'proximo':
        return EstadoVacuna.proxima;
      case 'vencida':
        return EstadoVacuna.vencida;
      default:
        return EstadoVacuna.programada;
    }
  }
}

class VacunaStats {
  final int totalVacunas;
  final int vacunasEsteMes;
  final int proximasVacunas;
  final int vacunasVencidas;

  VacunaStats({
    required this.totalVacunas,
    required this.vacunasEsteMes,
    required this.proximasVacunas,
    required this.vacunasVencidas,
  });

  factory VacunaStats.fromJson(Map<String, dynamic> json) {
    return VacunaStats(
      totalVacunas: json['total_vacunas'] ?? 0,
      vacunasEsteMes: json['vacunas_este_mes'] ?? 0,
      proximasVacunas: json['proximas_vacunas'] ?? 0,
      vacunasVencidas: json['vacunas_vencidas'] ?? 0,
    );
  }

  // Calcular porcentaje de cumplimiento
  double get porcentajeCumplimiento {
    if (totalVacunas == 0) return 0.0;
    final alDia = totalVacunas - vacunasVencidas;
    return (alDia / totalVacunas) * 100;
  }

  bool get tieneAlertas => vacunasVencidas > 0 || proximasVacunas > 0;
}

// Enum para estados de vacuna
enum EstadoVacuna {
  vencida,    // Próxima dosis pasada
  urgente,    // Próxima dosis en 1-2 días
  proxima,    // Próxima dosis en 3-7 días
  programada, // Próxima dosis en más de 7 días
  completa,   // Sin próxima dosis programada
}

// Modelo para resumen de vacunas por gallo
class VacunaResumenGallo {
  final int galloId;
  final String galloNombre;
  final int totalVacunas;
  final int vacunasAlDia;
  final int vacunasVencidas;
  final ProximaVacuna? proximaVacuna;
  final DateTime? ultimaVacuna;

  VacunaResumenGallo({
    required this.galloId,
    required this.galloNombre,
    required this.totalVacunas,
    required this.vacunasAlDia,
    required this.vacunasVencidas,
    this.proximaVacuna,
    this.ultimaVacuna,
  });

  // Estado general del gallo
  EstadoVacuna get estadoGeneral {
    if (vacunasVencidas > 0) return EstadoVacuna.vencida;
    if (proximaVacuna != null) return proximaVacuna!.estadoEnum;
    return EstadoVacuna.completa;
  }

  String get estadoTexto {
    if (vacunasVencidas > 0) {
      return 'Vacunas vencidas ($vacunasVencidas)';
    }
    if (proximaVacuna != null) {
      return 'Próxima: ${proximaVacuna!.nombreTipoVacuna} en ${proximaVacuna!.diasRestantes} días';
    }
    return 'Vacunas al día';
  }

  double get porcentajeCumplimiento {
    if (totalVacunas == 0) return 100.0;
    return (vacunasAlDia / totalVacunas) * 100;
  }
}

// Helper para crear instancias desde JSON de backend
class VacunaHelper {
  static VacunaResumenGallo crearResumenFromHistorial(
    int galloId,
    String galloNombre,
    List<Vacuna> historial,
    List<ProximaVacuna> proximas,
  ) {
    final vacunasVencidas = proximas
        .where((p) => p.estadoEnum == EstadoVacuna.vencida)
        .length;
    
    final proximaVacuna = proximas.isNotEmpty 
        ? proximas.first 
        : null;
    
    final ultimaVacuna = historial.isNotEmpty 
        ? historial.first.fechaAplicacion 
        : null;

    return VacunaResumenGallo(
      galloId: galloId,
      galloNombre: galloNombre,
      totalVacunas: historial.length,
      vacunasAlDia: historial.length - vacunasVencidas,
      vacunasVencidas: vacunasVencidas,
      proximaVacuna: proximaVacuna,
      ultimaVacuna: ultimaVacuna,
    );
  }
}