// 📁 lib/features/peleas/screens/formulario_pelea_screen.dart
// 🥊 Formulario para crear/editar peleas con video

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../shared/theme/app_colors.dart';
import '../../../services/peleas_service.dart';
import '../../../services/gallo_service.dart';
import '../../../models/pelea.dart';

class FormularioPeleaScreen extends StatefulWidget {
  final Pelea? pelea;
  final int? galloPreseleccionado;
  final bool galloIsBloqueado;

  const FormularioPeleaScreen({
    Key? key,
    this.pelea,
    this.galloPreseleccionado,
    this.galloIsBloqueado = false,
  }) : super(key: key);

  @override
  State<FormularioPeleaScreen> createState() => _FormularioPeleaScreenState();
}

class _FormularioPeleaScreenState extends State<FormularioPeleaScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat _timeFormatter = DateFormat('HH:mm');
  
  // Controladores
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _oponenteNombreController = TextEditingController();
  final _oponenteGalloController = TextEditingController();
  final _notasResultadoController = TextEditingController();
  
  // 🆕 NUEVOS CONTROLADORES (8 campos) - MODO MANIÁTICO
  final _galleraController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _miGalloNombreController = TextEditingController();
  final _miGalloPropietarioController = TextEditingController();
  final _miGalloPesoController = TextEditingController();
  final _oponentePesoController = TextEditingController();
  final _premioController = TextEditingController();
  final _duracionController = TextEditingController();

  // Estado
  List<Map<String, dynamic>> gallos = [];
  int? galloSeleccionado;
  String? resultadoSeleccionado;
  DateTime fechaPelea = DateTime.now();
  TimeOfDay horaPelea = TimeOfDay.now();
  bool isLoading = false;
  bool isLoadingGallos = true;
  File? videoSeleccionado;
  String? videoUrlExistente;

  final List<Map<String, String>> resultadosPelea = [
    {'codigo': 'ganada', 'nombre': '🏆 Ganada'},
    {'codigo': 'perdida', 'nombre': '❌ Perdida'},
    {'codigo': 'empate', 'nombre': '🤝 Empate'},
  ];

  @override
  void initState() {
    super.initState();
    _loadGallos();
    _initializeFormData();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _oponenteNombreController.dispose();
    _oponenteGalloController.dispose();
    _notasResultadoController.dispose();
    
    // 🆕 DISPOSE NUEVOS CONTROLLERS - MODO MANIÁTICO
    _galleraController.dispose();
    _ciudadController.dispose();
    _miGalloNombreController.dispose();
    _miGalloPropietarioController.dispose();
    _miGalloPesoController.dispose();
    _oponentePesoController.dispose();
    _premioController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _loadGallos() async {
    try {
      final result = await GalloService.getGallos();
      setState(() {
        gallos = result;
        isLoadingGallos = false;
        
        // 🆕 Llenar valores por defecto DESPUÉS de cargar gallos
        _setDefaultMiGalloValues();
      });
    } catch (e) {
      print('Error cargando gallos: $e');
      setState(() => isLoadingGallos = false);
    }
  }

  void _initializeFormData() {
    if (widget.pelea != null) {
      final pelea = widget.pelea!;
      galloSeleccionado = pelea.galloId;
      resultadoSeleccionado = pelea.resultado;
      fechaPelea = pelea.fechaPelea;
      horaPelea = TimeOfDay.fromDateTime(pelea.fechaPelea);
      videoUrlExistente = pelea.videoUrl;
      
      _tituloController.text = pelea.titulo;
      _descripcionController.text = pelea.descripcion ?? '';
      _ubicacionController.text = pelea.ubicacion ?? '';
      _oponenteNombreController.text = pelea.oponenteNombre ?? '';
      _oponenteGalloController.text = pelea.oponenteGallo ?? '';
      _notasResultadoController.text = pelea.notasResultado ?? '';
      
      // 🆕 INICIALIZAR NUEVOS CAMPOS - MODO MANIÁTICO
      _galleraController.text = pelea.gallera ?? '';
      _ciudadController.text = pelea.ciudad ?? '';
      _miGalloNombreController.text = pelea.miGalloNombre ?? '';
      _miGalloPropietarioController.text = pelea.miGalloPropietario ?? '';
      _miGalloPesoController.text = pelea.miGalloPeso?.toString() ?? '';
      _oponentePesoController.text = pelea.oponenteGalloPeso?.toString() ?? '';
      _premioController.text = pelea.premio ?? '';
      _duracionController.text = pelea.duracionMinutos?.toString() ?? '';
    } else if (widget.galloPreseleccionado != null) {
      galloSeleccionado = widget.galloPreseleccionado;
    }
    
    // 🆕 Los valores por defecto se llenan después de cargar gallos
  }
  
  void _setDefaultMiGalloValues() {
    // Llenar valores por defecto si los campos están vacíos
    if (galloSeleccionado != null && gallos.isNotEmpty) {
      // Buscar el gallo seleccionado en la lista
      final galloActual = gallos.firstWhere(
        (gallo) => gallo['id'] == galloSeleccionado,
        orElse: () => {},
      );
      
      if (galloActual.isNotEmpty) {
        // Nombre del gallo por defecto (solo si está vacío)
        if (_miGalloNombreController.text.isEmpty) {
          _miGalloNombreController.text = galloActual['nombre'] ?? '';
        }
        
        // Propietario por defecto (solo si está vacío)
        if (_miGalloPropietarioController.text.isEmpty) {
          _miGalloPropietarioController.text = 'Alan Cairampoma'; // TODO: Obtener usuario actual
        }
        
        print('🐓 Valores por defecto llenados: ${galloActual['nombre']} - Alan Cairampoma');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.pelea != null ? 'Editar Pelea' : 'Nueva Pelea',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoadingGallos
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGalloField(),
                      const SizedBox(height: 20),
                      _buildInformacionEventoSection(),
                      const SizedBox(height: 20),
                      _buildDatosGallosSection(),
                      const SizedBox(height: 20),
                      _buildResultadoCombateSection(),
                      const SizedBox(height: 20),
                      _buildVideoObservacionesSection(),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }


  Widget _buildGalloField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gallo Participante *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: galloSeleccionado,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  widget.galloIsBloqueado ? 'Gallo preseleccionado' : 'Seleccione el gallo que peleó',
                  style: TextStyle(
                    color: widget.galloIsBloqueado ? Colors.grey[600] : null,
                  ),
                ),
              ),
              isExpanded: true,
              onChanged: widget.galloIsBloqueado ? null : (int? value) {
                setState(() {
                  galloSeleccionado = value;
                  // 🆕 Actualizar valores por defecto cuando cambia el gallo
                  _setDefaultMiGalloValues();
                });
              },
              items: gallos.map<DropdownMenuItem<int>>((gallo) {
                return DropdownMenuItem<int>(
                  value: gallo['id'],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      gallo['nombre'] ?? 'Gallo #${gallo['id']}',
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // MÉTODOS VIEJOS ELIMINADOS - USANDO 4 SECCIONES HTML ÉPICAS

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _guardarPelea,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.pelea != null ? 'Actualizar Pelea' : 'Registrar Pelea',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _seleccionarVideo(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 15), // Límite de 15 minutos para peleas
      );
      
      if (video != null) {
        setState(() {
          videoSeleccionado = File(video.path);
          videoUrlExistente = null; // Limpiar video existente si se selecciona uno nuevo
        });
      }
    } catch (e) {
      print('Error seleccionando video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar video'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _guardarPelea() async {
    if (!_formKey.currentState!.validate()) return;

    if (galloSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un gallo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔍 DEBUG: Verificar valores de los 8 campos nuevos
      print('🔍 DEBUG CAMPOS NUEVOS:');
      print('   Gallera: "${_galleraController.text}"');
      print('   Ciudad: "${_ciudadController.text}"');
      print('   Mi Gallo Nombre: "${_miGalloNombreController.text}"');
      print('   Mi Gallo Propietario: "${_miGalloPropietarioController.text}"');
      print('   Mi Gallo Peso: "${_miGalloPesoController.text}"');
      print('   Oponente Peso: "${_oponentePesoController.text}"');
      print('   Premio: "${_premioController.text}"');
      print('   Duración: "${_duracionController.text}"');
      
      // Combinar fecha y hora
      final fechaPeleaCompleta = DateTime(
        fechaPelea.year,
        fechaPelea.month,
        fechaPelea.day,
        horaPelea.hour,
        horaPelea.minute,
      );

      Map<String, dynamic>? result;

      if (widget.pelea != null) {
        // Actualizar pelea existente
        result = await PeleasService.actualizarPelea(
          widget.pelea!.id,
          titulo: _oponenteNombreController.text.trim().isEmpty 
              ? 'Pelea ${DateFormat('dd/MM/yyyy').format(fechaPeleaCompleta)}'
              : 'Pelea vs. ${_oponenteNombreController.text.trim()}',
          fechaPelea: fechaPeleaCompleta,
          descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
          ubicacion: _ubicacionController.text.trim().isEmpty ? null : _ubicacionController.text.trim(),
          oponenteNombre: _oponenteNombreController.text.trim().isEmpty ? null : _oponenteNombreController.text.trim(),
          oponenteGallo: _oponenteGalloController.text.trim().isEmpty ? null : _oponenteGalloController.text.trim(),
          resultado: resultadoSeleccionado,
          notasResultado: _notasResultadoController.text.trim().isEmpty ? null : _notasResultadoController.text.trim(),
          video: videoSeleccionado,
          // 🆕 NUEVOS CAMPOS - MODO MANIÁTICO
          gallera: _galleraController.text.trim().isEmpty ? null : _galleraController.text.trim(),
          ciudad: _ciudadController.text.trim().isEmpty ? null : _ciudadController.text.trim(),
          miGalloNombre: _miGalloNombreController.text.trim().isEmpty ? null : _miGalloNombreController.text.trim(),
          miGalloPropietario: _miGalloPropietarioController.text.trim().isEmpty ? null : _miGalloPropietarioController.text.trim(),
          miGalloPeso: _miGalloPesoController.text.trim().isEmpty ? null : int.tryParse(_miGalloPesoController.text.trim()),
          oponenteGalloPeso: _oponentePesoController.text.trim().isEmpty ? null : int.tryParse(_oponentePesoController.text.trim()),
          premio: _premioController.text.trim().isEmpty ? null : _premioController.text.trim(),
          duracionMinutos: _duracionController.text.trim().isEmpty ? null : int.tryParse(_duracionController.text.trim()),
        );
      } else {
        // Crear nueva pelea
        result = await PeleasService.crearPelea(
          galloId: galloSeleccionado!,
          titulo: _oponenteNombreController.text.trim().isEmpty 
              ? 'Pelea ${DateFormat('dd/MM/yyyy').format(fechaPeleaCompleta)}'
              : 'Pelea vs. ${_oponenteNombreController.text.trim()}',
          fechaPelea: fechaPeleaCompleta,
          descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
          ubicacion: _ubicacionController.text.trim().isEmpty ? null : _ubicacionController.text.trim(),
          oponenteNombre: _oponenteNombreController.text.trim().isEmpty ? null : _oponenteNombreController.text.trim(),
          oponenteGallo: _oponenteGalloController.text.trim().isEmpty ? null : _oponenteGalloController.text.trim(),
          resultado: resultadoSeleccionado,
          notasResultado: _notasResultadoController.text.trim().isEmpty ? null : _notasResultadoController.text.trim(),
          video: videoSeleccionado,
          // 🆕 NUEVOS CAMPOS - MODO MANIÁTICO
          gallera: _galleraController.text.trim().isEmpty ? null : _galleraController.text.trim(),
          ciudad: _ciudadController.text.trim().isEmpty ? null : _ciudadController.text.trim(),
          miGalloNombre: _miGalloNombreController.text.trim().isEmpty ? null : _miGalloNombreController.text.trim(),
          miGalloPropietario: _miGalloPropietarioController.text.trim().isEmpty ? null : _miGalloPropietarioController.text.trim(),
          miGalloPeso: _miGalloPesoController.text.trim().isEmpty ? null : int.tryParse(_miGalloPesoController.text.trim()),
          oponenteGalloPeso: _oponentePesoController.text.trim().isEmpty ? null : int.tryParse(_oponentePesoController.text.trim()),
          premio: _premioController.text.trim().isEmpty ? null : _premioController.text.trim(),
          duracionMinutos: _duracionController.text.trim().isEmpty ? null : int.tryParse(_duracionController.text.trim()),
        );
      }

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.pelea != null ? 'Pelea actualizada exitosamente' : 'Pelea registrada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('No se recibió respuesta del servidor');
      }
    } catch (e) {
      print('Error guardando pelea: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error guardando pelea: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 📅 SECCIÓN 1: INFORMACIÓN DEL EVENTO - DISEÑO HTML ÉPICO
  Widget _buildInformacionEventoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📅 INFORMACIÓN DEL EVENTO',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          // Fecha y Hora
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha de la Pelea *',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: fechaPelea,
                          firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => fechaPelea = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              _dateFormatter.format(fechaPelea),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hora',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: horaPelea,
                        );
                        if (time != null) {
                          setState(() => horaPelea = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              _timeFormatter.format(DateTime(2021, 1, 1, horaPelea.hour, horaPelea.minute)),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Gallera y Ciudad
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _galleraController,
                  decoration: InputDecoration(
                    labelText: 'Coliseo',
                    hintText: 'Ej: Coliseo Real',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _ciudadController,
                  decoration: InputDecoration(
                    labelText: 'Ciudad',
                    hintText: 'Ej: Medellín',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Ubicación general
          TextFormField(
            controller: _ubicacionController,
            decoration: InputDecoration(
              labelText: 'Ubicación adicional',
              hintText: 'Dirección o referencia del lugar',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🐓 SECCIÓN 2: DATOS DE LOS GALLOS - DISEÑO HTML ÉPICO
  Widget _buildDatosGallosSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🐓 DATOS DE LOS GALLOS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // MI GALLO
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MI GALLO',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _miGalloNombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Auto',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _miGalloPropietarioController,
                        decoration: InputDecoration(
                          labelText: 'Dueño',
                          hintText: 'Auto',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _miGalloPesoController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Peso (g)',
                          hintText: '2500',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'VS',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              // GALLO OPONENTE
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GALLO OPONENTE',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _oponenteGalloController,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ej: Tormenta',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _oponenteNombreController,
                        decoration: InputDecoration(
                          labelText: 'Dueño',
                          hintText: 'Ej: Juan Pérez',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _oponentePesoController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Peso (g)',
                          hintText: '2450',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🏆 SECCIÓN 3: RESULTADO DEL COMBATE - DISEÑO HTML ÉPICO
  Widget _buildResultadoCombateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 RESULTADO DEL COMBATE',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 16),
          // Resultado
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: resultadoSeleccionado,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text('¿Cómo terminó la pelea?'),
                ),
                isExpanded: true,
                onChanged: (String? value) {
                  setState(() {
                    resultadoSeleccionado = value;
                  });
                },
                items: resultadosPelea.map((resultado) {
                  return DropdownMenuItem(
                    value: resultado['codigo'],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        resultado['nombre']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Premio y Duración
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _premioController,
                  decoration: InputDecoration(
                    labelText: 'Premio',
                    hintText: 'Ej: S/ 2,500',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _duracionController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duración',
                    hintText: '8',
                    suffixText: 'minutos',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (resultadoSeleccionado != null) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _notasResultadoController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notas del resultado',
                hintText: 'Describe cómo fue la pelea y el resultado...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 📹 SECCIÓN 4: VIDEO Y OBSERVACIONES - DISEÑO HTML ÉPICO (SIN TOCAR)
  Widget _buildVideoObservacionesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📹 VIDEO Y OBSERVACIONES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
          const SizedBox(height: 16),
          // Video section (MANTENER IGUAL - NO JODER)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.purple[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Formatos: MP4, MOV, AVI (máx. 500MB)\nRecomendado: Grabar en horizontal',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.purple[800],
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              if (videoSeleccionado != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.video_file, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Video seleccionado: ${videoSeleccionado!.path.split('/').last}',
                          style: const TextStyle(color: Colors.green),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => videoSeleccionado = null),
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ] else if (videoUrlExistente != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Video de la pelea guardado',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => videoUrlExistente = null),
                        child: const Text('Quitar'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _seleccionarVideo(ImageSource.camera),
                        icon: const Icon(Icons.videocam),
                        label: const Text('Grabar Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[100],
                          foregroundColor: Colors.red[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _seleccionarVideo(ImageSource.gallery),
                        icon: const Icon(Icons.video_library),
                        label: const Text('Elegir Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[100],
                          foregroundColor: Colors.purple[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Observaciones
          TextFormField(
            controller: _descripcionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Observaciones',
              hintText: 'Describe los detalles de la pelea...',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}