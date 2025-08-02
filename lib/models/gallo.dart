// 📁 gallo.dart
// 🐓 MODELO DE GALLO

class Raza {
  final int? id;
  final String? nombre;
  final String? descripcion;

  Raza({
    this.id,
    this.nombre,
    this.descripcion,
  });

  factory Raza.fromJson(Map<String, dynamic> json) {
    return Raza(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}

class Gallo {
  final int? id;
  final String? nombre;
  final String? codigoIdentificacion;
  final DateTime? fechaNacimiento;
  final double? peso;
  final int? altura;
  final String? color;
  final String? colorPatas;
  final String? colorPlumaje;
  final String? colorPlaca;
  final String? ubicacionPlaca;
  final String? procedencia;
  final String? criador;
  final String? propietarioActual;
  final String? estado;
  final String? observaciones;
  final String? notas;
  final String? fotoPrincipalUrl;
  final int? padreId;
  final int? madreId;
  final int? razaId;
  final Raza? raza;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Gallo({
    this.id,
    this.nombre,
    this.codigoIdentificacion,
    this.fechaNacimiento,
    this.peso,
    this.altura,
    this.color,
    this.colorPatas,
    this.colorPlumaje,
    this.colorPlaca,
    this.ubicacionPlaca,
    this.procedencia,
    this.criador,
    this.propietarioActual,
    this.estado,
    this.observaciones,
    this.notas,
    this.fotoPrincipalUrl,
    this.padreId,
    this.madreId,
    this.razaId,
    this.raza,
    this.createdAt,
    this.updatedAt,
  });

  factory Gallo.fromJson(Map<String, dynamic> json) {
    return Gallo(
      id: json['id'],
      nombre: json['nombre'],
      codigoIdentificacion: json['codigo_identificacion'],
      fechaNacimiento: json['fecha_nacimiento'] != null 
          ? DateTime.parse(json['fecha_nacimiento']) 
          : null,
      peso: json['peso']?.toDouble(),
      altura: json['altura'],
      color: json['color'],
      colorPatas: json['color_patas'],
      colorPlumaje: json['color_plumaje'],
      colorPlaca: json['color_placa'],
      ubicacionPlaca: json['ubicacion_placa'],
      procedencia: json['procedencia'],
      criador: json['criador'],
      propietarioActual: json['propietario_actual'],
      estado: json['estado'],
      observaciones: json['observaciones'],
      notas: json['notas'],
      fotoPrincipalUrl: json['foto_principal_url'],
      padreId: json['padre_id'],
      madreId: json['madre_id'],
      razaId: json['raza_id'],
      raza: json['raza'] != null ? Raza.fromJson(json['raza']) : null,
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
      'nombre': nombre,
      'codigo_identificacion': codigoIdentificacion,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String().split('T')[0],
      'peso': peso,
      'altura': altura,
      'color': color,
      'color_patas': colorPatas,
      'color_plumaje': colorPlumaje,
      'color_placa': colorPlaca,
      'ubicacion_placa': ubicacionPlaca,
      'procedencia': procedencia,
      'criador': criador,
      'propietario_actual': propietarioActual,
      'estado': estado,
      'observaciones': observaciones,
      'notas': notas,
      'foto_principal_url': fotoPrincipalUrl,
      'padre_id': padreId,
      'madre_id': madreId,
      'raza_id': razaId,
      'raza': raza?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Método para crear una copia con modificaciones
  Gallo copyWith({
    int? id,
    String? nombre,
    String? codigoIdentificacion,
    DateTime? fechaNacimiento,
    double? peso,
    int? altura,
    String? color,
    String? colorPatas,
    String? colorPlumaje,
    String? colorPlaca,
    String? ubicacionPlaca,
    String? procedencia,
    String? criador,
    String? propietarioActual,
    String? estado,
    String? observaciones,
    String? notas,
    String? fotoPrincipalUrl,
    int? padreId,
    int? madreId,
    int? razaId,
    Raza? raza,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Gallo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigoIdentificacion: codigoIdentificacion ?? this.codigoIdentificacion,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      peso: peso ?? this.peso,
      altura: altura ?? this.altura,
      color: color ?? this.color,
      colorPatas: colorPatas ?? this.colorPatas,
      colorPlumaje: colorPlumaje ?? this.colorPlumaje,
      colorPlaca: colorPlaca ?? this.colorPlaca,
      ubicacionPlaca: ubicacionPlaca ?? this.ubicacionPlaca,
      procedencia: procedencia ?? this.procedencia,
      criador: criador ?? this.criador,
      propietarioActual: propietarioActual ?? this.propietarioActual,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      notas: notas ?? this.notas,
      fotoPrincipalUrl: fotoPrincipalUrl ?? this.fotoPrincipalUrl,
      padreId: padreId ?? this.padreId,
      madreId: madreId ?? this.madreId,
      razaId: razaId ?? this.razaId,
      raza: raza ?? this.raza,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
