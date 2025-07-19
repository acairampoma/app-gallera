class Usuario {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final String? direccion;
  final DateTime? fechaRegistro;
  final bool activo;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Usuario({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.direccion,
    this.fechaRegistro,
    this.activo = true,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
      email: map['email'] as String,
      telefono: map['telefono'] as String?,
      direccion: map['direccion'] as String?,
      fechaRegistro: map['fecha_registro'] != null 
          ? DateTime.parse(map['fecha_registro'].toString())
          : null,
      activo: map['activo'] as bool? ?? true,
      avatar: map['avatar'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'].toString())
          : null,
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}