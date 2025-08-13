// 📁 lib/models/pelea.dart
// 🥊 Modelos para gestión de peleas

class Pelea {
  final int id;
  final int userId;
  final int galloId;
  final String? galloNombre;
  final String titulo;
  final String? descripcion;
  final DateTime fechaPelea;
  final String? ubicacion;
  final String? oponenteNombre;
  final String? oponenteGallo;
  final String? resultado;
  final String? notasResultado;
  final String? videoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // 🆕 NUEVOS CAMPOS OPCIONALES (8 campos)
  final String? gallera;
  final String? ciudad;
  final String? miGalloNombre;
  final String? miGalloPropietario;
  final int? miGalloPeso; // en gramos
  final int? oponenteGalloPeso; // en gramos
  final String? premio;
  final int? duracionMinutos;

  Pelea({
    required this.id,
    required this.userId,
    required this.galloId,
    this.galloNombre,
    required this.titulo,
    this.descripcion,
    required this.fechaPelea,
    this.ubicacion,
    this.oponenteNombre,
    this.oponenteGallo,
    this.resultado,
    this.notasResultado,
    this.videoUrl,
    this.createdAt,
    this.updatedAt,
    // 🆕 Nuevos campos opcionales
    this.gallera,
    this.ciudad,
    this.miGalloNombre,
    this.miGalloPropietario,
    this.miGalloPeso,
    this.oponenteGalloPeso,
    this.premio,
    this.duracionMinutos,
  });

  factory Pelea.fromJson(Map<String, dynamic> json) {
    return Pelea(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      galloId: json['gallo_id'] ?? 0,
      galloNombre: json['gallo_nombre'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'],
      fechaPelea: DateTime.parse(json['fecha_pelea']),
      ubicacion: json['ubicacion'],
      oponenteNombre: json['oponente_nombre'],
      oponenteGallo: json['oponente_gallo'],
      resultado: json['resultado'],
      notasResultado: json['notas_resultado'],
      videoUrl: json['video_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      // 🆕 Nuevos campos opcionales
      gallera: json['gallera'],
      ciudad: json['ciudad'],
      miGalloNombre: json['mi_gallo_nombre'],
      miGalloPropietario: json['mi_gallo_propietario'],
      miGalloPeso: json['mi_gallo_peso'],
      oponenteGalloPeso: json['oponente_gallo_peso'],
      premio: json['premio'],
      duracionMinutos: json['duracion_minutos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gallo_id': galloId,
      'titulo': titulo,
      if (descripcion != null) 'descripcion': descripcion,
      'fecha_pelea': fechaPelea.toIso8601String(),
      if (ubicacion != null) 'ubicacion': ubicacion,
      if (oponenteNombre != null) 'oponente_nombre': oponenteNombre,
      if (oponenteGallo != null) 'oponente_gallo': oponenteGallo,
      if (resultado != null) 'resultado': resultado,
      if (notasResultado != null) 'notas_resultado': notasResultado,
      if (videoUrl != null) 'video_url': videoUrl,
      // 🆕 Nuevos campos opcionales
      if (gallera != null) 'gallera': gallera,
      if (ciudad != null) 'ciudad': ciudad,
      if (miGalloNombre != null) 'mi_gallo_nombre': miGalloNombre,
      if (miGalloPropietario != null) 'mi_gallo_propietario': miGalloPropietario,
      if (miGalloPeso != null) 'mi_gallo_peso': miGalloPeso,
      if (oponenteGalloPeso != null) 'oponente_gallo_peso': oponenteGalloPeso,
      if (premio != null) 'premio': premio,
      if (duracionMinutos != null) 'duracion_minutos': duracionMinutos,
    };
  }

  // Getters de conveniencia
  String get resultadoDisplay {
    switch (resultado?.toLowerCase()) {
      case 'ganada':
        return '🏆 Ganada';
      case 'perdida':
        return '❌ Perdida';
      case 'empate':
        return '🤝 Empate';
      default:
        return 'Sin resultado';
    }
  }

  ResultadoPelea? get resultadoEnum {
    switch (resultado?.toLowerCase()) {
      case 'ganada':
        return ResultadoPelea.ganada;
      case 'perdida':
        return ResultadoPelea.perdida;
      case 'empate':
        return ResultadoPelea.empate;
      default:
        return null;
    }
  }

  bool get tieneVideo => videoUrl != null && videoUrl!.isNotEmpty;

  bool get tieneOponente => 
      (oponenteNombre != null && oponenteNombre!.isNotEmpty) ||
      (oponenteGallo != null && oponenteGallo!.isNotEmpty);

  String get oponenteCompleto {
    if (!tieneOponente) return 'Oponente no especificado';
    
    final partes = <String>[];
    if (oponenteNombre != null && oponenteNombre!.isNotEmpty) {
      partes.add(oponenteNombre!);
    }
    if (oponenteGallo != null && oponenteGallo!.isNotEmpty) {
      partes.add('(${oponenteGallo!})');
    }
    return partes.join(' ');
  }

  // Calcular tiempo transcurrido desde la pelea
  String get tiempoTranscurrido {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaPelea);

    if (diferencia.inDays > 365) {
      final anos = (diferencia.inDays / 365).floor();
      return 'Hace $anos año${anos > 1 ? 's' : ''}';
    } else if (diferencia.inDays > 30) {
      final meses = (diferencia.inDays / 30).floor();
      return 'Hace $meses mes${meses > 1 ? 'es' : ''}';
    } else if (diferencia.inDays > 0) {
      return 'Hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'Hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else {
      return 'Reciente';
    }
  }

  bool get esVictoria => resultado?.toLowerCase() == 'ganada';
  bool get esDerrota => resultado?.toLowerCase() == 'perdida';
  bool get esEmpate => resultado?.toLowerCase() == 'empate';

  // 🆕 Getters de conveniencia para campos nuevos
  String get ubicacionCompleta {
    final partes = <String>[];
    if (gallera != null && gallera!.isNotEmpty) partes.add(gallera!);
    if (ciudad != null && ciudad!.isNotEmpty) partes.add(ciudad!);
    return partes.join(' • ');
  }

  bool get tieneUbicacionCompleta => ubicacionCompleta.isNotEmpty;

  String get pesoMiGalloDisplay {
    if (miGalloPeso == null) return 'N/A';
    final kg = miGalloPeso! / 1000;
    return '${kg.toStringAsFixed(2)} kg';
  }

  String get pesoOponenteDisplay {
    if (oponenteGalloPeso == null) return 'N/A';
    final kg = oponenteGalloPeso! / 1000;
    return '${kg.toStringAsFixed(2)} kg';
  }

  String get duracionDisplay {
    if (duracionMinutos == null) return 'N/A';
    if (duracionMinutos! < 60) return '${duracionMinutos}min';
    final horas = duracionMinutos! ~/ 60;
    final mins = duracionMinutos! % 60;
    return '${horas}h ${mins}min';
  }

  String get premioDisplay => premio ?? 'No especificado';

  bool get tieneDatosPeso => miGalloPeso != null || oponenteGalloPeso != null;
  bool get tieneDuracion => duracionMinutos != null;
  bool get tienePremio => premio != null && premio!.isNotEmpty;
}

class PeleaStats {
  final int totalPeleas;
  final int ganadas;
  final int perdidas;
  final int empates;
  final double efectividad;
  final int peleasEsteMes;
  final DateTime? ultimaPelea;

  PeleaStats({
    required this.totalPeleas,
    required this.ganadas,
    required this.perdidas,
    required this.empates,
    required this.efectividad,
    required this.peleasEsteMes,
    this.ultimaPelea,
  });

  factory PeleaStats.fromJson(Map<String, dynamic> json) {
    return PeleaStats(
      totalPeleas: json['total_peleas'] ?? 0,
      ganadas: json['ganadas'] ?? 0,
      perdidas: json['perdidas'] ?? 0,
      empates: json['empates'] ?? 0,
      efectividad: (json['efectividad'] ?? 0.0).toDouble(),
      peleasEsteMes: json['peleas_este_mes'] ?? 0,
      ultimaPelea: json['ultima_pelea'] != null 
          ? DateTime.parse(json['ultima_pelea']) 
          : null,
    );
  }

  // Getters de conveniencia
  int get peleasConResultado => ganadas + perdidas + empates;
  
  double get porcentajeGanadas {
    if (totalPeleas == 0) return 0.0;
    return (ganadas / totalPeleas) * 100;
  }

  double get porcentajePerdidas {
    if (totalPeleas == 0) return 0.0;
    return (perdidas / totalPeleas) * 100;
  }

  double get porcentajeEmpates {
    if (totalPeleas == 0) return 0.0;
    return (empates / totalPeleas) * 100;
  }

  String get resumenRendimiento {
    if (totalPeleas == 0) return 'Sin peleas registradas';
    
    return '$ganadas ganadas, $perdidas perdidas, $empates empates (${efectividad.toStringAsFixed(1)}% efectividad)';
  }

  String get estadoGeneral {
    if (totalPeleas == 0) return 'Sin historial';
    
    if (efectividad >= 80.0) return 'Excelente';
    if (efectividad >= 60.0) return 'Bueno';
    if (efectividad >= 40.0) return 'Regular';
    return 'Necesita mejora';
  }

  bool get tieneRachaGanadora => ganadas > perdidas && efectividad > 50.0;
}

// Enum para resultados de peleas
enum ResultadoPelea {
  ganada,
  perdida,
  empate,
}

extension ResultadoPeleaExtension on ResultadoPelea {
  String get displayName {
    switch (this) {
      case ResultadoPelea.ganada:
        return 'Ganada';
      case ResultadoPelea.perdida:
        return 'Perdida';
      case ResultadoPelea.empate:
        return 'Empate';
    }
  }

  String get emoji {
    switch (this) {
      case ResultadoPelea.ganada:
        return '🏆';
      case ResultadoPelea.perdida:
        return '❌';
      case ResultadoPelea.empate:
        return '🤝';
    }
  }

  String get codigo {
    switch (this) {
      case ResultadoPelea.ganada:
        return 'ganada';
      case ResultadoPelea.perdida:
        return 'perdida';
      case ResultadoPelea.empate:
        return 'empate';
    }
  }

  static ResultadoPelea? fromString(String? resultado) {
    if (resultado == null) return null;
    switch (resultado.toLowerCase()) {
      case 'ganada':
        return ResultadoPelea.ganada;
      case 'perdida':
        return ResultadoPelea.perdida;
      case 'empate':
        return ResultadoPelea.empate;
      default:
        return null;
    }
  }
}

// Modelo para resumen de peleas por gallo
class PeleaResumenGallo {
  final int galloId;
  final String galloNombre;
  final int totalPeleas;
  final int victorias;
  final int derrotas;
  final int empates;
  final double efectividad;
  final DateTime? ultimaPelea;

  PeleaResumenGallo({
    required this.galloId,
    required this.galloNombre,
    required this.totalPeleas,
    required this.victorias,
    required this.derrotas,
    required this.empates,
    required this.efectividad,
    this.ultimaPelea,
  });

  factory PeleaResumenGallo.fromPeleas(
    int galloId,
    String galloNombre,
    List<Pelea> peleas,
  ) {
    if (peleas.isEmpty) {
      return PeleaResumenGallo(
        galloId: galloId,
        galloNombre: galloNombre,
        totalPeleas: 0,
        victorias: 0,
        derrotas: 0,
        empates: 0,
        efectividad: 0.0,
        ultimaPelea: null,
      );
    }

    final victorias = peleas.where((p) => p.esVictoria).length;
    final derrotas = peleas.where((p) => p.esDerrota).length;
    final empates = peleas.where((p) => p.esEmpate).length;

    final efectividad = peleas.isNotEmpty ? (victorias / peleas.length) * 100 : 0.0;
    final ultimaPelea = peleas.isNotEmpty ? peleas.first.fechaPelea : null;

    return PeleaResumenGallo(
      galloId: galloId,
      galloNombre: galloNombre,
      totalPeleas: peleas.length,
      victorias: victorias,
      derrotas: derrotas,
      empates: empates,
      efectividad: efectividad,
      ultimaPelea: ultimaPelea,
    );
  }

  String get resumenTexto {
    if (totalPeleas == 0) return 'Sin peleas registradas';
    
    final ultimoTexto = ultimaPelea != null 
        ? 'Última: ${_formatFecha(ultimaPelea!)}'
        : '';
    
    return '$totalPeleas peleas • ${efectividad.toStringAsFixed(1)}% efectividad • $ultimoTexto';
  }

  String get recordTexto => '$victorias-$derrotas-$empates';

  String get estadoRendimiento {
    if (totalPeleas == 0) return 'Sin historial';
    
    if (efectividad >= 75.0) return 'Campeón';
    if (efectividad >= 50.0) return 'Competitivo';
    if (efectividad >= 25.0) return 'En desarrollo';
    return 'Necesita entrenamiento';
  }

  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    
    if (diferencia.inDays == 0) return 'Hoy';
    if (diferencia.inDays == 1) return 'Ayer';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays} días';
    if (diferencia.inDays < 30) return 'Hace ${(diferencia.inDays / 7).floor()} semanas';
    return 'Hace ${(diferencia.inDays / 30).floor()} meses';
  }
}