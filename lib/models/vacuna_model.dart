class Vacuna {
  final int? id;
  final int? galloId;
  final String tipoVacuna;
  final String? laboratorio;
  final DateTime fechaAplicacion;
  final DateTime? proximaDosis;
  final String? veterinarioNombre;
  final String? clinica;
  final String? dosis;
  final String? notas;
  final DateTime? createdAt;
  final String? galloNombre;
  final String? galloCodigo;

  Vacuna({
    this.id,
    this.galloId,
    required this.tipoVacuna,
    this.laboratorio,
    required this.fechaAplicacion,
    this.proximaDosis,
    this.veterinarioNombre,
    this.clinica,
    this.dosis,
    this.notas,
    this.createdAt,
    this.galloNombre,
    this.galloCodigo,
  });

  factory Vacuna.fromJson(Map<String, dynamic> json) {
    return Vacuna(
      id: json['id'],
      galloId: json['gallo_id'],
      tipoVacuna: json['tipo_vacuna'],
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
      galloNombre: json['gallo_nombre'],
      galloCodigo: json['gallo_codigo'],
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

  Vacuna copyWith({
    int? id,
    int? galloId,
    String? tipoVacuna,
    String? laboratorio,
    DateTime? fechaAplicacion,
    DateTime? proximaDosis,
    String? veterinarioNombre,
    String? clinica,
    String? dosis,
    String? notas,
    DateTime? createdAt,
    String? galloNombre,
    String? galloCodigo,
  }) {
    return Vacuna(
      id: id ?? this.id,
      galloId: galloId ?? this.galloId,
      tipoVacuna: tipoVacuna ?? this.tipoVacuna,
      laboratorio: laboratorio ?? this.laboratorio,
      fechaAplicacion: fechaAplicacion ?? this.fechaAplicacion,
      proximaDosis: proximaDosis ?? this.proximaDosis,
      veterinarioNombre: veterinarioNombre ?? this.veterinarioNombre,
      clinica: clinica ?? this.clinica,
      dosis: dosis ?? this.dosis,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      galloNombre: galloNombre ?? this.galloNombre,
      galloCodigo: galloCodigo ?? this.galloCodigo,
    );
  }
}

class ProximaVacuna {
  final int galloId;
  final String galloNombre;
  final String tipoVacuna;
  final DateTime proximaDosis;
  final int diasRestantes;
  final String estado; // urgente, proximo, normal

  ProximaVacuna({
    required this.galloId,
    required this.galloNombre,
    required this.tipoVacuna,
    required this.proximaDosis,
    required this.diasRestantes,
    required this.estado,
  });

  factory ProximaVacuna.fromJson(Map<String, dynamic> json) {
    return ProximaVacuna(
      galloId: json['gallo_id'],
      galloNombre: json['gallo_nombre'],
      tipoVacuna: json['tipo_vacuna'],
      proximaDosis: DateTime.parse(json['proxima_dosis']),
      diasRestantes: json['dias_restantes'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gallo_id': galloId,
      'gallo_nombre': galloNombre,
      'tipo_vacuna': tipoVacuna,
      'proxima_dosis': proximaDosis.toIso8601String(),
      'dias_restantes': diasRestantes,
      'estado': estado,
    };
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
      totalVacunas: json['total_vacunas'],
      vacunasEsteMes: json['vacunas_este_mes'],
      proximasVacunas: json['proximas_vacunas'],
      vacunasVencidas: json['vacunas_vencidas'],
    );
  }
}