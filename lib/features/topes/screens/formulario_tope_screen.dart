// 📁 lib/features/topes/screens/formulario_tope_screen.dart
// 🏋️ Formulario para crear/editar topes con video

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../shared/theme/app_colors.dart';
import '../../../services/topes_service.dart';
import '../../../services/gallo_service.dart';
import '../../../models/tope.dart';

class FormularioTopeScreen extends StatefulWidget {
  final Tope? tope;
  final int? galloPreseleccionado;
  final bool galloIsBloqueado;

  const FormularioTopeScreen({
    Key? key,
    this.tope,
    this.galloPreseleccionado,
    this.galloIsBloqueado = false,
  }) : super(key: key);

  @override
  State<FormularioTopeScreen> createState() => _FormularioTopeScreenState();
}

class _FormularioTopeScreenState extends State<FormularioTopeScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat _timeFormatter = DateFormat('HH:mm');
  
  // Controladores
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _duracionController = TextEditingController();
  final _desSparringController = TextEditingController();
  final _pesoPostTopeController = TextEditingController();
  final _notasController = TextEditingController();

  // Estado
  List<Map<String, dynamic>> gallos = [];
  int? galloSeleccionado;
  String? tipoEntrenamientoSeleccionado;
  String? tipoResultadoSeleccionado;
  String? tipoCondicionFisicaSeleccionado;
  DateTime fechaTope = DateTime.now();
  TimeOfDay horaTope = TimeOfDay.now();
  DateTime? fechaProximo;
  bool isLoading = false;
  bool isLoadingGallos = true;
  File? videoSeleccionado;
  String? videoUrlExistente;

  final List<Map<String, String>> tiposEntrenamiento = [
    {'codigo': 'top_espuelas', 'nombre': 'Tope con espuelas forradas'},
    {'codigo': 'top_sin_espuelas', 'nombre': 'Tope sin espuelas'},
    {'codigo': 'sparring_tecnico', 'nombre': 'Sparring técnico'},
    {'codigo': 'acondicionamiento_fisico', 'nombre': 'Acondicionamiento físico'},
  ];

  final List<Map<String, String>> opcionesDesempeno = [
    {'codigo': 'excelente_desempeno', 'nombre': 'Excelente desempeño'},
    {'codigo': 'buen_desempeno', 'nombre': 'Buen desempeño'},
    {'codigo': 'regular', 'nombre': 'Regular'},
    {'codigo': 'necesita_mejorar', 'nombre': 'Necesita mejorar'},
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
    _duracionController.dispose();
    _desSparringController.dispose();
    _pesoPostTopeController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _loadGallos() async {
    try {
      final result = await GalloService.getGallos();
      setState(() {
        gallos = result;
        isLoadingGallos = false;
      });
    } catch (e) {
      print('Error cargando gallos: $e');
      setState(() => isLoadingGallos = false);
    }
  }

  void _initializeFormData() {
    if (widget.tope != null) {
      final tope = widget.tope!;
      galloSeleccionado = tope.galloId;
      
      // 🗺️ Mapear valor del backend a valor UI
      tipoEntrenamientoSeleccionado = _mapearTipoEntrenamientoReverso(tope.tipoEntrenamiento);
      fechaTope = tope.fechaTope;
      horaTope = TimeOfDay.fromDateTime(tope.fechaTope);
      videoUrlExistente = tope.videoUrl;
      
      _tituloController.text = tope.titulo;
      _descripcionController.text = tope.descripcion ?? '';
      _duracionController.text = tope.duracionMinutos?.toString() ?? '';
      _desSparringController.text = tope.desSparring ?? '';
      _pesoPostTopeController.text = tope.pesoPostTope ?? '';
      _notasController.text = tope.notas ?? '';
      
      // Nuevos campos de evaluación
      tipoResultadoSeleccionado = tope.tipoResultado;
      tipoCondicionFisicaSeleccionado = tope.tipoCondicionFisica;
      fechaProximo = tope.fechaProximo;
    } else if (widget.galloPreseleccionado != null) {
      galloSeleccionado = widget.galloPreseleccionado;
    }
  }

  // 🗺️ NO MAPEAR - Mantener valores únicos para estadísticas
  String _mapearTipoEntrenamiento(String valorUI) {
    // Devolver el valor tal cual para mantener la información completa
    return valorUI;
  }

  // 🗺️ NO MAPEAR para edición - Mantener valores originales
  String _mapearTipoEntrenamientoReverso(String? valorBackend) {
    // Si el valor existe en nuestra lista, está bien
    if (['top_espuelas', 'top_sin_espuelas', 'sparring_tecnico', 'acondicionamiento_fisico'].contains(valorBackend)) {
      return valorBackend!;
    }
    
    // Para valores legacy del backend, asignar uno por defecto
    switch (valorBackend?.toLowerCase()) {
      case 'sparring':
        return 'top_espuelas';
      case 'tecnica':
        return 'sparring_tecnico';
      case 'resistencia':
      case 'velocidad':
        return 'acondicionamiento_fisico';
      default:
        return 'sparring_tecnico';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.tope != null ? 'Editar Tope' : 'Nuevo Tope',
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
                      _buildDesSparringField(),
                      const SizedBox(height: 20),
                      _buildFechaHoraFields(),
                      const SizedBox(height: 20),
                      _buildDuracionField(),
                      const SizedBox(height: 20),
                      _buildTipoEntrenamientoField(),
                      const SizedBox(height: 20),
                      _buildTipoResultadoField(),
                      const SizedBox(height: 20),
                      _buildVideoSection(),
                      const SizedBox(height: 20),
                      _buildNotasField(),
                      const SizedBox(height: 20),
                      _buildTipoCondicionFisicaField(),
                      const SizedBox(height: 20),
                      _buildPesoPostTopeField(),
                      const SizedBox(height: 20),
                      _buildFechaProximoField(),
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
          'Gallo *',
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
                  widget.galloIsBloqueado ? 'Gallo preseleccionado' : 'Seleccione un gallo',
                  style: TextStyle(
                    color: widget.galloIsBloqueado ? Colors.grey[600] : null,
                  ),
                ),
              ),
              isExpanded: true,
              onChanged: widget.galloIsBloqueado ? null : (int? value) {
                setState(() {
                  galloSeleccionado = value;
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

  Widget _buildDesSparringField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gallo Sparring',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _desSparringController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Describe detalles específicos del sparring...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipoEntrenamientoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Entrenamiento *',
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
            child: DropdownButton<String>(
              value: tipoEntrenamientoSeleccionado,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Seleccione tipo de entrenamiento'),
              ),
              isExpanded: true,
              onChanged: (String? value) {
                setState(() {
                  tipoEntrenamientoSeleccionado = value;
                });
              },
              items: tiposEntrenamiento.map((tipo) {
                return DropdownMenuItem(
                  value: tipo['codigo'],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      tipo['nombre']!,
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

  Widget _buildFechaHoraFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fecha *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: fechaTope,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => fechaTope = date);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _dateFormatter.format(fechaTope),
                    style: const TextStyle(fontSize: 16),
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
                'Hora *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: horaTope,
                  );
                  if (time != null) {
                    setState(() => horaTope = time);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _timeFormatter.format(DateTime(2021, 1, 1, horaTope.hour, horaTope.minute)),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDuracionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duración (minutos)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _duracionController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ej: 30',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final duracion = int.tryParse(value);
              if (duracion == null || duracion <= 0) {
                return 'Debe ser un número válido mayor a 0';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTipoResultadoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Resultado',
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
            child: DropdownButton<String>(
              value: tipoResultadoSeleccionado,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Seleccione evaluación del resultado'),
              ),
              isExpanded: true,
              onChanged: (String? value) {
                setState(() {
                  tipoResultadoSeleccionado = value;
                });
              },
              items: opcionesDesempeno.map((opcion) {
                return DropdownMenuItem(
                  value: opcion['codigo'],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      opcion['nombre']!,
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

  Widget _buildTipoCondicionFisicaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Condición Física',
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
            child: DropdownButton<String>(
              value: tipoCondicionFisicaSeleccionado,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Seleccione evaluación física'),
              ),
              isExpanded: true,
              onChanged: (String? value) {
                setState(() {
                  tipoCondicionFisicaSeleccionado = value;
                });
              },
              items: opcionesDesempeno.map((opcion) {
                return DropdownMenuItem(
                  value: opcion['codigo'],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      opcion['nombre']!,
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

  Widget _buildPesoPostTopeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Peso Post-Tope',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pesoPostTopeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Ej: 2.5 kg',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final peso = double.tryParse(value.replaceAll(' kg', ''));
              if (peso == null || peso <= 0) {
                return 'Debe ser un peso válido mayor a 0';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFechaProximoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha Próximo Entrenamiento',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: fechaProximo ?? DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => fechaProximo = date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              fechaProximo != null 
                  ? _dateFormatter.format(fechaProximo!)
                  : 'Seleccionar fecha próximo entrenamiento',
              style: TextStyle(
                fontSize: 16,
                color: fechaProximo != null ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video del Entrenamiento',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Formatos: MP4, MOV, AVI (máx. 500MB)\nRecomendado: Grabar en horizontal',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[800],
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
                    'Video actual guardado',
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
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNotasField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observaciones',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notasController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Observaciones, resultados, mejoras...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _guardarTope,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.tope != null ? 'Actualizar Tope' : 'Registrar Tope',
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
        maxDuration: const Duration(minutes: 10), // Límite de 10 minutos
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

  Future<void> _guardarTope() async {
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

    if (tipoEntrenamientoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un tipo de entrenamiento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Combinar fecha y hora
      final fechaTopeCompleta = DateTime(
        fechaTope.year,
        fechaTope.month,
        fechaTope.day,
        horaTope.hour,
        horaTope.minute,
      );

      // Preparar datos
      final duracionMinutos = _duracionController.text.trim().isEmpty 
          ? null 
          : int.tryParse(_duracionController.text.trim());
      
      // 🗺️ Mapear valores UI a valores que acepta el backend
      String tipoEntrenamientoBackend = _mapearTipoEntrenamiento(tipoEntrenamientoSeleccionado!);

      Map<String, dynamic>? result;

      if (widget.tope != null) {
        // Actualizar tope existente
        result = await TopesService.actualizarTope(
          widget.tope!.id,
          galloId: galloSeleccionado!,
          titulo: 'Tope ${tipoEntrenamientoSeleccionado ?? "entrenamiento"}',
          tipoEntrenamiento: tipoEntrenamientoBackend,
          fechaTope: fechaTopeCompleta,
          duracionMinutos: duracionMinutos,
          descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
          desSparring: _desSparringController.text.trim().isEmpty ? null : _desSparringController.text.trim(),
          tipoResultado: tipoResultadoSeleccionado,
          tipoCondicionFisica: tipoCondicionFisicaSeleccionado,
          pesoPostTope: _pesoPostTopeController.text.trim().isEmpty ? null : _pesoPostTopeController.text.trim(),
          fechaProximo: fechaProximo,
          notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
          video: videoSeleccionado,
        );
      } else {
        // Crear nuevo tope
        print('🎬 FormTope - Video seleccionado: ${videoSeleccionado?.path ?? "NULL"}');
        result = await TopesService.crearTope(
          galloId: galloSeleccionado!,
          titulo: 'Tope ${tipoEntrenamientoSeleccionado ?? "entrenamiento"}',
          tipoEntrenamiento: tipoEntrenamientoBackend,
          fechaTope: fechaTopeCompleta,
          duracionMinutos: duracionMinutos,
          descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
          desSparring: _desSparringController.text.trim().isEmpty ? null : _desSparringController.text.trim(),
          tipoResultado: tipoResultadoSeleccionado,
          tipoCondicionFisica: tipoCondicionFisicaSeleccionado,
          pesoPostTope: _pesoPostTopeController.text.trim().isEmpty ? null : _pesoPostTopeController.text.trim(),
          fechaProximo: fechaProximo,
          notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
          video: videoSeleccionado,
        );
      }

      if (result != null) {
        final isWorkaround = result['workaround'] == true;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.tope != null ? 'Tope actualizado exitosamente' : 'Tope registrado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        if (isWorkaround) {
          print('🛠️ UI: Éxito mostrado con workaround - datos guardados a pesar del 500');
        }
        
        Navigator.pop(context, true);
      } else {
        throw Exception('No se recibió respuesta del servidor');
      }
    } catch (e) {
      print('Error guardando tope: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error guardando tope: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}