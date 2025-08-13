// 📁 lib/models/tope.dart
// 🏋️ Modelos para gestión de topes (entrenamientos)

class Tope {
  final int id;
  final int userId;
  final int galloId;
  final String? galloNombre;
  final String titulo;
  final String? descripcion;
  final DateTime fechaTope;
  final String? tipoEntrenamiento;
  final int? duracionMinutos;
  final String? desSparring;
  final String? tipoResultado;
  final String? tipoCondicionFisica;
  final String? pesoPostTope;
  final DateTime? fechaProximo;
  final String? notas;
  final String? videoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Tope({
    required this.id,
    required this.userId,
    required this.galloId,
    this.galloNombre,
    required this.titulo,
    this.descripcion,
    required this.fechaTope,
    this.tipoEntrenamiento,
    this.duracionMinutos,
    this.desSparring,
    this.tipoResultado,
    this.tipoCondicionFisica,
    this.pesoPostTope,
    this.fechaProximo,
    this.notas,
    this.videoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Tope.fromJson(Map<String, dynamic> json) {
    return Tope(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      galloId: json['gallo_id'] ?? 0,
      galloNombre: json['gallo_nombre'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'],
      fechaTope: DateTime.parse(json['fecha_tope']),
      tipoEntrenamiento: json['tipo_entrenamiento'],
      duracionMinutos: json['duracion_minutos'],
      desSparring: json['des_sparring'],
      tipoResultado: json['tipo_resultado'],
      tipoCondicionFisica: json['tipo_condicion_fisica'],
      pesoPostTope: json['peso_post_tope'],
      fechaProximo: json['fecha_proximo'] != null 
          ? DateTime.parse(json['fecha_proximo']) 
          : null,
      notas: json['observaciones'],
      videoUrl: json['video_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gallo_id': galloId,
      'titulo': titulo,
      if (descripcion != null) 'descripcion': descripcion,
      'fecha_tope': fechaTope.toIso8601String(),
      if (tipoEntrenamiento != null) 'tipo_entrenamiento': tipoEntrenamiento,
      if (duracionMinutos != null) 'duracion_minutos': duracionMinutos,
      if (desSparring != null) 'des_sparring': desSparring,
      if (tipoResultado != null) 'tipo_resultado': tipoResultado,
      if (tipoCondicionFisica != null) 'tipo_condicion_fisica': tipoCondicionFisica,
      if (pesoPostTope != null) 'peso_post_tope': pesoPostTope,
      if (fechaProximo != null) 'fecha_proximo': fechaProximo!.toIso8601String(),
      if (notas != null) 'observaciones': notas,
      if (videoUrl != null) 'video_url': videoUrl,
    };
  }

  // Getters de conveniencia
  String get tipoEntrenamientoDisplay {
    switch (tipoEntrenamiento?.toLowerCase()) {
      case 'sparring':
        return 'Sparring';
      case 'tecnica':
        return 'Técnica';
      case 'resistencia':
        return 'Resistencia';
      case 'velocidad':
        return 'Velocidad';
      default:
        return tipoEntrenamiento ?? 'N/A';
    }
  }

  String get duracionDisplay {
    if (duracionMinutos == null) return 'No especificada';
    if (duracionMinutos! < 60) {
      return '${duracionMinutos}min';
    } else {
      final horas = duracionMinutos! ~/ 60;
      final minutos = duracionMinutos! % 60;
      if (minutos == 0) {
        return '${horas}h';
      } else {
        return '${horas}h ${minutos}min';
      }
    }
  }

  bool get tieneVideo => videoUrl != null && videoUrl!.isNotEmpty;

  // Getters para nuevos campos de evaluación
  String get tipoResultadoDisplay {
    switch (tipoResultado?.toLowerCase()) {
      case 'excelente_desempeno':
        return 'Excelente desempeño';
      case 'buen_desempeno':
        return 'Buen desempeño';
      case 'regular':
        return 'Regular';
      case 'necesita_mejorar':
        return 'Necesita mejorar';
      default:
        return tipoResultado ?? 'No evaluado';
    }
  }

  String get tipoCondicionFisicaDisplay {
    switch (tipoCondicionFisica?.toLowerCase()) {
      case 'excelente_desempeno':
        return 'Excelente desempeño';
      case 'buen_desempeno':
        return 'Buen desempeño';
      case 'regular':
        return 'Regular';
      case 'necesita_mejorar':
        return 'Necesita mejorar';
      default:
        return tipoCondicionFisica ?? 'No evaluado';
    }
  }

  String get pesoPostTopeDisplay {
    if (pesoPostTope == null || pesoPostTope!.isEmpty) return 'No registrado';
    return pesoPostTope!.contains('kg') ? pesoPostTope! : '$pesoPostTope kg';
  }

  String get fechaProximoDisplay {
    if (fechaProximo == null) return 'No programado';
    final ahora = DateTime.now();
    final diferencia = fechaProximo!.difference(ahora);
    
    if (diferencia.inDays > 0) {
      return 'En ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inDays == 0) {
      return 'Hoy';
    } else {
      return 'Vencido (${(-diferencia.inDays)} días)';
    }
  }

  // Calcular tiempo transcurrido desde el entrenamiento
  String get tiempoTranscurrido {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaTope);

    if (diferencia.inDays > 0) {
      return 'Hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'Hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else if (diferencia.inMinutes > 0) {
      return 'Hace ${diferencia.inMinutes} minuto${diferencia.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora mismo';
    }
  }
}

class TopeStats {
  final int totalTopes;
  final int topesEsteMes;
  final double promedioDuracion;
  final Map<String, int> tiposEntrenamiento;
  final DateTime? ultimoTope;

  TopeStats({
    required this.totalTopes,
    required this.topesEsteMes,
    required this.promedioDuracion,
    required this.tiposEntrenamiento,
    this.ultimoTope,
  });

  factory TopeStats.fromJson(Map<String, dynamic> json) {
    return TopeStats(
      totalTopes: json['total_topes'] ?? 0,
      topesEsteMes: json['topes_este_mes'] ?? 0,
      promedioDuracion: (json['promedio_duracion'] ?? 0.0).toDouble(),
      tiposEntrenamiento: Map<String, int>.from(json['tipos_entrenamiento'] ?? {}),
      ultimoTope: json['ultimo_tope'] != null 
          ? DateTime.parse(json['ultimo_tope']) 
          : null,
    );
  }

  // Getters de conveniencia
  int get topesEstaSemana => tiposEntrenamiento.values.fold(0, (sum, count) => sum + count);
  
  String get tipoMasFrecuente {
    if (tiposEntrenamiento.isEmpty) return 'N/A';
    
    String tipoMax = tiposEntrenamiento.keys.first;
    int maxCount = 0;
    
    tiposEntrenamiento.forEach((tipo, count) {
      if (count > maxCount) {
        maxCount = count;
        tipoMax = tipo;
      }
    });
    
    return _formatTipoEntrenamiento(tipoMax);
  }

  String _formatTipoEntrenamiento(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'sparring':
        return 'Sparring';
      case 'tecnica':
        return 'Técnica';
      case 'resistencia':
        return 'Resistencia';
      case 'velocidad':
        return 'Velocidad';
      default:
        return tipo;
    }
  }

  double get promedioTopesPorSemana {
    if (totalTopes == 0) return 0.0;
    // Estimación básica: total de topes dividido entre semanas del mes
    return (topesEsteMes / 4.0);
  }
}

// Enum para tipos de entrenamiento
enum TipoEntrenamiento {
  sparring,
  tecnica,
  resistencia,
  velocidad,
}

extension TipoEntrenamientoExtension on TipoEntrenamiento {
  String get displayName {
    switch (this) {
      case TipoEntrenamiento.sparring:
        return 'Sparring';
      case TipoEntrenamiento.tecnica:
        return 'Técnica';
      case TipoEntrenamiento.resistencia:
        return 'Resistencia';
      case TipoEntrenamiento.velocidad:
        return 'Velocidad';
    }
  }

  String get codigo {
    switch (this) {
      case TipoEntrenamiento.sparring:
        return 'sparring';
      case TipoEntrenamiento.tecnica:
        return 'tecnica';
      case TipoEntrenamiento.resistencia:
        return 'resistencia';
      case TipoEntrenamiento.velocidad:
        return 'velocidad';
    }
  }

  static TipoEntrenamiento? fromString(String? tipo) {
    if (tipo == null) return null;
    switch (tipo.toLowerCase()) {
      case 'sparring':
        return TipoEntrenamiento.sparring;
      case 'tecnica':
        return TipoEntrenamiento.tecnica;
      case 'resistencia':
        return TipoEntrenamiento.resistencia;
      case 'velocidad':
        return TipoEntrenamiento.velocidad;
      default:
        return null;
    }
  }
}

// Modelo para resumen de entrenamientos por gallo
class TopeResumenGallo {
  final int galloId;
  final String galloNombre;
  final int totalTopes;
  final int topesEsteMes;
  final String tipoMasFrecuente;
  final double promedioDuracion;
  final DateTime? ultimoTope;

  TopeResumenGallo({
    required this.galloId,
    required this.galloNombre,
    required this.totalTopes,
    required this.topesEsteMes,
    required this.tipoMasFrecuente,
    required this.promedioDuracion,
    this.ultimoTope,
  });

  factory TopeResumenGallo.fromTopes(
    int galloId,
    String galloNombre,
    List<Tope> topes,
  ) {
    if (topes.isEmpty) {
      return TopeResumenGallo(
        galloId: galloId,
        galloNombre: galloNombre,
        totalTopes: 0,
        topesEsteMes: 0,
        tipoMasFrecuente: 'N/A',
        promedioDuracion: 0.0,
        ultimoTope: null,
      );
    }

    // Calcular estadísticas
    final fechaInicioMes = DateTime.now().subtract(const Duration(days: 30));
    final topesEsteMes = topes.where((t) => t.fechaTope.isAfter(fechaInicioMes)).length;

    // Tipo más frecuente
    final tiposCounts = <String, int>{};
    for (final tope in topes) {
      if (tope.tipoEntrenamiento != null) {
        tiposCounts[tope.tipoEntrenamiento!] = 
            (tiposCounts[tope.tipoEntrenamiento!] ?? 0) + 1;
      }
    }

    String tipoMasFrecuente = 'N/A';
    if (tiposCounts.isNotEmpty) {
      tipoMasFrecuente = tiposCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    // Promedio de duración
    final topesConDuracion = topes.where((t) => t.duracionMinutos != null).toList();
    double promedioDuracion = 0.0;
    if (topesConDuracion.isNotEmpty) {
      final totalMinutos = topesConDuracion
          .map((t) => t.duracionMinutos!)
          .reduce((a, b) => a + b);
      promedioDuracion = totalMinutos / topesConDuracion.length;
    }

    // Último tope
    final ultimoTope = topes.isNotEmpty ? topes.first.fechaTope : null;

    return TopeResumenGallo(
      galloId: galloId,
      galloNombre: galloNombre,
      totalTopes: topes.length,
      topesEsteMes: topesEsteMes,
      tipoMasFrecuente: tipoMasFrecuente,
      promedioDuracion: promedioDuracion,
      ultimoTope: ultimoTope,
    );
  }

  String get resumenTexto {
    if (totalTopes == 0) return 'Sin entrenamientos registrados';
    
    final ultimoTexto = ultimoTope != null 
        ? 'Último: ${_formatFecha(ultimoTope!)}'
        : '';
    
    return '$totalTopes entrenamientos • $ultimoTexto';
  }

  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    
    if (diferencia.inDays == 0) return 'Hoy';
    if (diferencia.inDays == 1) return 'Ayer';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays} días';
    return 'Hace ${(diferencia.inDays / 7).floor()} semanas';
  }
}