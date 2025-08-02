// 📁 lib/features/pedigri/screens/edit_gallo_multistep_screen.dart
// 🔥 Screen para EDITAR gallos con formulario multi-paso completo
// DISEÑO HORIZONTAL igual que ADD (TabView de izquierda a derecha)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/gallo_service.dart';

class EditGalloMultistepScreen extends StatefulWidget {
  final Map<String, dynamic> gallo;
  final List<dynamic> razas;

  const EditGalloMultistepScreen({
    Key? key,
    required this.gallo,
    required this.razas,
  }) : super(key: key);

  @override
  State<EditGalloMultistepScreen> createState() => _EditGalloMultistepScreenState();
}

class _EditGalloMultistepScreenState extends State<EditGalloMultistepScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Controllers para datos básicos del gallo
  final _nombreGalloController = TextEditingController();
  final _numeroRegistroController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _criadorController = TextEditingController();
  final _propietarioController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _notasController = TextEditingController();

  // Variables de estado
  File? _selectedImageFile;
  DateTime? _fechaNacimiento;
  int? _razaSeleccionada;
  String? _estadoSeleccionado;
  String _colorSeleccionado = '';

  // Listas de opciones
  final List<String> _estadosDisponibles = [
    'activo',
    'retirado',
    'vendido',
    'muerto',
  ];

  final List<String> _coloresDisponibles = [
    'Colorado',
    'Giro', 
    'Negro',
    'Dorado',
    'Pintado',
    'Canelo',
    'Cenizo',
    'Blanco',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeWithExistingData();
  }

  void _initializeWithExistingData() {
    final gallo = widget.gallo;
    
    // Llenar campos básicos
    _nombreGalloController.text = gallo['nombre'] ?? '';
    _numeroRegistroController.text = gallo['codigo_identificacion'] ?? '';
    _alturaController.text = gallo['altura']?.toString() ?? '';
    _pesoController.text = gallo['peso']?.toString() ?? '';
    _criadorController.text = gallo['criador'] ?? '';
    _propietarioController.text = gallo['propietario_actual'] ?? '';
    _observacionesController.text = gallo['observaciones'] ?? '';
    _notasController.text = gallo['notas'] ?? '';

    // Color - verificar si está en la lista disponible
    final colorActual = gallo['color'] ?? '';
    if (_coloresDisponibles.contains(colorActual)) {
      _colorSeleccionado = colorActual;
    } else if (colorActual.isNotEmpty) {
      // Si el color actual no está en la lista, agregarlo
      _coloresDisponibles.insert(0, colorActual);
      _colorSeleccionado = colorActual;
    }

    // Fecha de nacimiento
    if (gallo['fecha_nacimiento'] != null) {
      try {
        _fechaNacimiento = DateTime.parse(gallo['fecha_nacimiento']);
      } catch (e) {
        print('Error parseando fecha: $e');
      }
    }

    // Raza seleccionada - verificar si existe en la lista
    if (gallo['raza'] != null && gallo['raza']['id'] != null) {
      final razaId = gallo['raza']['id'];
      if (widget.razas.any((r) => r['id'] == razaId)) {
        _razaSeleccionada = razaId;
      }
    } else if (gallo['raza_id'] != null) {
      final razaId = gallo['raza_id'];
      if (widget.razas.any((r) => r['id'] == razaId)) {
        _razaSeleccionada = razaId;
      }
    }

    // Estado seleccionado - verificar si está en la lista disponible
    final estadoActual = gallo['estado'] ?? 'activo';
    if (_estadosDisponibles.contains(estadoActual)) {
      _estadoSeleccionado = estadoActual;
    } else if (estadoActual.isNotEmpty) {
      // Si el estado actual no está en la lista, agregarlo
      _estadosDisponibles.insert(0, estadoActual);
      _estadoSeleccionado = estadoActual;
    } else {
      _estadoSeleccionado = 'activo'; // Default
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreGalloController.dispose();
    _numeroRegistroController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    _criadorController.dispose();
    _propietarioController.dispose();
    _observacionesController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '✏️ Editar Gallo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Datos'),
            Tab(icon: Icon(Icons.pets), text: 'Características'),
            Tab(icon: Icon(Icons.person), text: 'Información'),
            Tab(icon: Icon(Icons.notes), text: 'Notas'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDatosBasicos(),
                _buildCaracteristicas(),
                _buildInformacionAdicional(),
                _buildNotasObservaciones(),
              ],
            ),
          ),
          // Botones de navegación en la parte inferior
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_tabController.index > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _tabController.animateTo(_tabController.index - 1);
                      },
                      child: const Text('Anterior'),
                    ),
                  ),
                if (_tabController.index > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      if (_tabController.index < 3) {
                        _tabController.animateTo(_tabController.index + 1);
                      } else {
                        _saveGallo();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _tabController.index < 3 ? 'Siguiente' : (_isLoading ? 'Guardando...' : 'Guardar Cambios'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatosBasicos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto actual
          if (widget.gallo['foto_principal_url'] != null) ...[
            const Text(
              'Foto Actual:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.gallo['foto_principal_url'] != null
                    ? Image.network(
                        widget.gallo['foto_principal_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.pets, size: 60, color: Colors.grey);
                        },
                      )
                    : const Icon(Icons.pets, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Nombre
          TextFormField(
            controller: _nombreGalloController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Gallo *',
              hintText: 'Ej: El Campeón',
              prefixIcon: Icon(Icons.pets),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Código de identificación
          TextFormField(
            controller: _numeroRegistroController,
            decoration: const InputDecoration(
              labelText: 'Código de Identificación',
              hintText: 'Ej: CAM001',
              prefixIcon: Icon(Icons.qr_code),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),

          // Raza
          DropdownButtonFormField<int>(
            value: _razaSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Raza',
              prefixIcon: Icon(Icons.pets),
              border: OutlineInputBorder(),
            ),
            items: widget.razas.map<DropdownMenuItem<int>>((raza) {
              return DropdownMenuItem<int>(
                value: raza['id'],
                child: Text(raza['nombre'] ?? 'Sin nombre'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _razaSeleccionada = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Fecha de nacimiento
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha de Nacimiento',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              child: Text(
                _fechaNacimiento != null
                    ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!)
                    : 'Seleccionar fecha',
                style: TextStyle(
                  color: _fechaNacimiento != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaracteristicas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Peso y Altura
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pesoController,
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    hintText: '2.50',
                    prefixIcon: Icon(Icons.monitor_weight),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _alturaController,
                  decoration: const InputDecoration(
                    labelText: 'Altura (cm)',
                    hintText: '58',
                    prefixIcon: Icon(Icons.height),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Color y Estado
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _colorSeleccionado.isNotEmpty ? _colorSeleccionado : null,
                  decoration: const InputDecoration(
                    labelText: 'Color',
                    prefixIcon: Icon(Icons.palette),
                    border: OutlineInputBorder(),
                  ),
                  items: _coloresDisponibles.map<DropdownMenuItem<String>>((color) {
                    return DropdownMenuItem<String>(
                      value: color,
                      child: Text(color),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _colorSeleccionado = value ?? '';
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _estadoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: Icon(Icons.info),
                    border: OutlineInputBorder(),
                  ),
                  items: _estadosDisponibles.map<DropdownMenuItem<String>>((estado) {
                    return DropdownMenuItem<String>(
                      value: estado,
                      child: Text(_capitalizeFirst(estado)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _estadoSeleccionado = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionAdicional() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Criador
          TextFormField(
            controller: _criadorController,
            decoration: const InputDecoration(
              labelText: 'Criador',
              hintText: 'Nombre del criador original',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Propietario actual
          TextFormField(
            controller: _propietarioController,
            decoration: const InputDecoration(
              labelText: 'Propietario Actual',
              hintText: 'Nombre del propietario actual',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Observaciones
          TextFormField(
            controller: _observacionesController,
            decoration: const InputDecoration(
              labelText: 'Observaciones',
              hintText: 'Características especiales, comportamiento...',
              prefixIcon: Icon(Icons.visibility),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildNotasObservaciones() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextFormField(
            controller: _notasController,
            decoration: const InputDecoration(
              labelText: 'Notas Adicionales',
              hintText: 'Información adicional, historial médico, entrenamientos...',
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),

          // Resumen de datos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de Cambios:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Nombre: ${_nombreGalloController.text}'),
                Text('Código: ${_numeroRegistroController.text}'),
                if (_razaSeleccionada != null) ...[
                  Text('Raza: ${widget.razas.firstWhere((r) => r['id'] == _razaSeleccionada, orElse: () => {'nombre': 'Desconocida'})['nombre']}'),
                ],
                Text('Color: $_colorSeleccionado'),
                Text('Estado: ${_estadoSeleccionado ?? 'No especificado'}'),
                if (_pesoController.text.isNotEmpty)
                  Text('Peso: ${_pesoController.text} kg'),
                if (_alturaController.text.isNotEmpty)
                  Text('Altura: ${_alturaController.text} cm'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _saveGallo() async {
    if (_nombreGalloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ El nombre del gallo es obligatorio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Preparar datos actualizados
      final datosActualizados = <String, dynamic>{
        'nombre': _nombreGalloController.text.trim(),
        'codigo_identificacion': _numeroRegistroController.text.trim(),
      };

      // Agregar campos opcionales solo si tienen valor
      if (_pesoController.text.isNotEmpty) {
        datosActualizados['peso'] = double.parse(_pesoController.text);
      }
      if (_alturaController.text.isNotEmpty) {
        datosActualizados['altura'] = int.parse(_alturaController.text);
      }
      if (_colorSeleccionado.isNotEmpty) {
        datosActualizados['color'] = _colorSeleccionado;
      }
      if (_estadoSeleccionado != null) {
        datosActualizados['estado'] = _estadoSeleccionado!;
      }
      if (_razaSeleccionada != null) {
        datosActualizados['raza_id'] = _razaSeleccionada!;
      }
      if (_fechaNacimiento != null) {
        datosActualizados['fecha_nacimiento'] = _fechaNacimiento!.toIso8601String().split('T')[0];
      }
      if (_criadorController.text.isNotEmpty) {
        datosActualizados['criador'] = _criadorController.text.trim();
      }
      if (_propietarioController.text.isNotEmpty) {
        datosActualizados['propietario_actual'] = _propietarioController.text.trim();
      }
      if (_observacionesController.text.isNotEmpty) {
        datosActualizados['observaciones'] = _observacionesController.text.trim();
      }
      if (_notasController.text.isNotEmpty) {
        datosActualizados['notas'] = _notasController.text.trim();
      }

      print('📝 Actualizando gallo ${widget.gallo['id']} con datos: $datosActualizados');

      // Llamar al servicio
      final resultado = await GalloService.updateGallo(
        widget.gallo['id'],
        datosActualizados,
      );

      if (resultado['success'] == true) {
        // Crear gallo actualizado para devolver
        final galloActualizado = Map<String, dynamic>.from(widget.gallo);
        galloActualizado.addAll(datosActualizados);

        // Si hay raza_id, buscar el objeto raza completo
        if (_razaSeleccionada != null) {
          final razaSeleccionada = widget.razas.firstWhere(
            (r) => r['id'] == _razaSeleccionada,
            orElse: () => {'id': _razaSeleccionada, 'nombre': 'Desconocida'},
          );
          galloActualizado['raza'] = razaSeleccionada;
        }

        galloActualizado['updated_at'] = DateTime.now().toIso8601String();

        if (mounted) {
          // Devolver el gallo actualizado
          Navigator.pop(context, galloActualizado);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${galloActualizado['nombre']} actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(resultado['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      print('❌ Error al actualizar gallo: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}