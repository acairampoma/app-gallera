// 📁 add_gallo_screen.dart
// 🔥 FORMULARIO ADD GALLO - TU DISEÑO BONITO + FUNCIONALIDAD REAL
// Mantiene tu PageView hermoso pero ahora SÍ graba en BD y sube fotos

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../shared/theme/app_colors.dart';
import '../../../services/gallo_service.dart';
import '../../../config/constants.dart';

// Enum para el modo de genealogía
enum GenealogyMode { existing, create }

class AddGalloScreen extends StatefulWidget {
  final List<dynamic> razas;
  final List<dynamic> gallosExistentes;
  final Function(Map<String, dynamic>) onGalloAdded;

  const AddGalloScreen({
    super.key,
    required this.razas,
    required this.gallosExistentes,
    required this.onGalloAdded,
  });

  @override
  State<AddGalloScreen> createState() => _AddGalloScreenState();
}

class _AddGalloScreenState extends State<AddGalloScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false; // Para mostrar loading al guardar

  // Controladores
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _colorController = TextEditingController();
  final _procedenciaController = TextEditingController();
  final _notasController = TextEditingController();

  // Variables de estado - MEJORADAS
  File? _selectedImageFile; // Archivo real seleccionado
  String? _fotoSeleccionadaAsset; // Para demo si no selecciona archivo real
  int? _razaSeleccionada;
  DateTime? _fechaNacimiento;
  int? _padreSeleccionado;
  int? _madreSeleccionada;
  String _estadoSeleccionado = 'activo';
  
  // GENEALOGÍA ÉPICA
  GenealogyMode _genealogyMode = GenealogyMode.existing;
  
  // Variables para crear padres
  bool _crearPadre = false;
  bool _crearMadre = false;
  
  // Controladores para nuevo padre
  final _padreNombreController = TextEditingController();
  final _padreCodigoController = TextEditingController();
  final _padreColorController = TextEditingController();
  final _padrePesoController = TextEditingController();
  final _padreProcedenciaController = TextEditingController();
  int? _padreRazaSeleccionada;
  DateTime? _padreFechaNacimiento;
  
  // Controladores para nueva madre
  final _madreNombreController = TextEditingController();
  final _madreCodigoController = TextEditingController();
  final _madreColorController = TextEditingController();
  final _madrePesoController = TextEditingController();
  final _madreProcedenciaController = TextEditingController();
  int? _madreRazaSeleccionada;
  DateTime? _madreFechaNacimiento;

  @override
  void dispose() {
    _pageController.dispose();
    _nombreController.dispose();
    _codigoController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _colorController.dispose();
    _procedenciaController.dispose();
    _notasController.dispose();
    
    // Dispose nuevos controladores
    _padreNombreController.dispose();
    _padreCodigoController.dispose();
    _padreColorController.dispose();
    _padrePesoController.dispose();
    _padreProcedenciaController.dispose();
    _madreNombreController.dispose();
    _madreCodigoController.dispose();
    _madreColorController.dispose();
    _madrePesoController.dispose();
    _madreProcedenciaController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildStep1Foto(),
                _buildStep2Basico(),
                _buildStep3Genealogia(),
                _buildStep4Adicional(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '🐓 Nuevo Gallo',
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _handleBackButton(),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < _currentStep;
          final isActive = index == _currentStep;
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 6,
              decoration: BoxDecoration(
                color: isCompleted || isActive 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1Foto() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStepTitle('📷', 'Paso 1: Foto del Gallo'),
          const SizedBox(height: 32),
          
          // Selector de foto MEJORADO
          GestureDetector(
            onTap: _showPhotoOptions,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 200),
                decoration: BoxDecoration(
                  color: (_selectedImageFile != null || _fotoSeleccionadaAsset != null)
                      ? Colors.white
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (_selectedImageFile != null || _fotoSeleccionadaAsset != null)
                        ? AppColors.primary
                        : Colors.grey[300]!,
                    width: 3,
                  ),
                  boxShadow: [
                    if (_selectedImageFile != null || _fotoSeleccionadaAsset != null)
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: _buildPhotoPreview(),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botones de selección
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _selectImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text('Cámara', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _selectImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library, color: Colors.white),
                  label: Text('Galería', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botón para fotos demo
          OutlinedButton.icon(
            onPressed: _selectAssetPhoto,
            icon: Icon(Icons.photo_library_outlined),
            label: Text('Usar foto demo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
          ),
          
          const SizedBox(height: 24),
          
          if (_selectedImageFile != null || _fotoSeleccionadaAsset != null)
            _buildInfoCard(
              '✅ Foto agregada correctamente',
              _selectedImageFile != null 
                  ? 'Foto real seleccionada (se subirá a Cloudinary)'
                  : 'Foto demo seleccionada',
              Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    if (_selectedImageFile != null) {
      // Mostrar archivo real seleccionado
      return ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
        ),
      );
    } else if (_fotoSeleccionadaAsset != null) {
      // Mostrar asset demo
      return ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Image.asset(
          _fotoSeleccionadaAsset!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pets,
                  size: 60,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Foto Demo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      );
    } else {
      // Sin foto
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tocar para agregar foto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }

  Widget _buildStep2Basico() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle('📝', 'Paso 2: Información Básica'),
            const SizedBox(height: 24),
            
            _buildTextFormField(
              controller: _nombreController,
              label: 'Nombre del Gallo',
              hint: 'Ej: El Campeón',
              icon: Icons.pets,
              isRequired: true,
            ),
            
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _codigoController,
              label: 'Número de Anillo',
              hint: 'Ej: CAM001',
              icon: Icons.qr_code,
              isRequired: true,
            ),
            
            const SizedBox(height: 16),
            
            _buildRazaDropdown(),
            
            const SizedBox(height: 16),
            
            _buildDateSelector(),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _pesoController,
                    label: 'Peso (kg)',
                    hint: '2.5',
                    icon: Icons.monitor_weight,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextFormField(
                    controller: _alturaController,
                    label: 'Altura (cm)',
                    hint: '58',
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _colorController,
              label: 'Color',
              hint: 'Colorado, Giro, Negro...',
              icon: Icons.palette,
              isRequired: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Genealogia() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('👨‍👩‍👦', 'Paso 3: Genealogía'),
          const SizedBox(height: 24),
          
          // Toggle para modo de genealogía
          _buildGenealogyModeSelector(),
          const SizedBox(height: 24),
          
          if (_genealogyMode == GenealogyMode.existing)
            _buildExistingParentsSection()
          else
            _buildCreateParentsSection(),
          
          const SizedBox(height: 24),
          
          if (_genealogyMode == GenealogyMode.create && (_crearPadre || _crearMadre))
            _buildPedigreePreview(),
        ],
      ),
    );
  }

  Widget _buildStep4Adicional() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('📋', 'Paso 4: Información Adicional'),
          const SizedBox(height: 24),
          
          _buildTextFormField(
            controller: _procedenciaController,
            label: 'Procedencia',
            hint: 'Criadero Los Campeones - Lima',
            icon: Icons.location_on,
          ),
          
          const SizedBox(height: 16),
          
          _buildEstadoDropdown(),
          
          const SizedBox(height: 16),
          
          _buildTextFormField(
            controller: _notasController,
            label: 'Notas y Observaciones',
            hint: 'Información adicional...',
            icon: Icons.note,
            maxLines: 4,
          ),
          
          const SizedBox(height: 24),
          
          _buildInfoCard(
            '🎉 ¡Último paso!',
            'Revisa toda la información y presiona "Guardar" para completar el registro.',
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🔥 SECCIÓN GENEALOGÍA CREAR PADRES
  // ==========================================
  Widget _buildCreateParentsSection() {
    return Column(
      children: [
        // Opción crear padre
        CheckboxListTile(
          title: Text('🔥 Crear nuevo padre'),
          subtitle: Text('Registrar el padre junto con este gallo'),
          value: _crearPadre,
          onChanged: (value) => setState(() => _crearPadre = value!),
          activeColor: AppColors.primary,
        ),
        
        if (_crearPadre) ...[
          SizedBox(height: 16),
          _buildCreateParentForm('padre'),
        ],
        
        SizedBox(height: 16),
        
        // Opción crear madre
        CheckboxListTile(
          title: Text('🔥 Crear nueva madre'),
          subtitle: Text('Registrar la madre junto con este gallo'),
          value: _crearMadre,
          onChanged: (value) => setState(() => _crearMadre = value!),
          activeColor: AppColors.primary,
        ),
        
        if (_crearMadre) ...[
          SizedBox(height: 16),
          _buildCreateParentForm('madre'),
        ],
      ],
    );
  }

  Widget _buildCreateParentForm(String tipo) {
    final esPadre = tipo == 'padre';
    final nombreController = esPadre ? _padreNombreController : _madreNombreController;
    final codigoController = esPadre ? _padreCodigoController : _madreCodigoController;
    final colorController = esPadre ? _padreColorController : _madreColorController;
    final pesoController = esPadre ? _padrePesoController : _madrePesoController;
    final procedenciaController = esPadre ? _padreProcedenciaController : _madreProcedenciaController;
    final razaSeleccionada = esPadre ? _padreRazaSeleccionada : _madreRazaSeleccionada;
    final fechaNacimiento = esPadre ? _padreFechaNacimiento : _madreFechaNacimiento;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esPadre ? Colors.blue[50] : Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esPadre ? Colors.blue[200]! : Colors.pink[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${esPadre ? '👨' : '👩'} Datos del ${tipo}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: esPadre ? Colors.blue[800] : Colors.pink[800],
            ),
          ),
          SizedBox(height: 16),
          
          _buildTextFormField(
            controller: nombreController,
            label: 'Nombre del ${tipo}',
            hint: 'Ej: ${esPadre ? 'Tornado' : 'Reina'}',
            icon: Icons.pets,
            isRequired: true,
          ),
          SizedBox(height: 12),
          
          _buildTextFormField(
            controller: codigoController,
            label: 'Código del ${tipo}',
            hint: 'Ej: ${esPadre ? 'TOR001' : 'REI001'}',
            icon: Icons.qr_code,
          ),
          SizedBox(height: 12),
          
          // Dropdown de raza para padre/madre
          DropdownButtonFormField<int>(
            value: razaSeleccionada,
            decoration: InputDecoration(
              labelText: 'Raza del ${tipo}',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            isExpanded: true,
            items: widget.razas.map<DropdownMenuItem<int>>((raza) {
              return DropdownMenuItem<int>(
                value: raza['id'],
                child: Text(
                  raza['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                if (esPadre) {
                  _padreRazaSeleccionada = value;
                } else {
                  _madreRazaSeleccionada = value;
                }
              });
            },
          ),
          SizedBox(height: 12),
          
          // Selector de fecha para padre/madre
          InkWell(
            onTap: () => _selectParentDate(esPadre),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Fecha de nacimiento del ${tipo}',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                fechaNacimiento != null
                    ? '${fechaNacimiento.day}/${fechaNacimiento.month}/${fechaNacimiento.year}'
                    : 'Seleccionar fecha',
                style: TextStyle(
                  color: fechaNacimiento != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: pesoController,
                  label: 'Peso (kg)',
                  hint: '3.0',
                  icon: Icons.monitor_weight,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: colorController,
                  label: 'Color',
                  hint: 'Colorado',
                  icon: Icons.palette,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          _buildTextFormField(
            controller: procedenciaController,
            label: 'Procedencia',
            hint: 'Criadero origen...',
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildExistingParentsSection() {
    final gallosPosibles = widget.gallosExistentes
        .where((g) => g['id'] != null)
        .toList();
    
    return Column(
      children: [
        _buildParentDropdown(
          'Padre (Padrillo)',
          Icons.male,
          _padreSeleccionado,
          gallosPosibles,
          (value) => setState(() => _padreSeleccionado = value),
        ),
        
        const SizedBox(height: 20),
        
        _buildParentDropdown(
          'Madre',
          Icons.female,
          _madreSeleccionada,
          gallosPosibles,
          (value) => setState(() => _madreSeleccionada = value),
        ),
        
        if (_padreSeleccionado != null || _madreSeleccionada != null) ...[
          const SizedBox(height: 20),
          _buildGenealogyInfo(gallosPosibles),
        ],
      ],
    );
  }

  Widget _buildPedigreePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.family_restroom, color: Colors.green.shade700),
              SizedBox(width: 8),
              Text(
                '🧬 Vista previa genealógica',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text('Se crearán automáticamente:'),
          if (_crearPadre) Text('• 1 registro de padre: ${_padreNombreController.text.isNotEmpty ? _padreNombreController.text : 'Sin nombre'}'),
          if (_crearMadre) Text('• 1 registro de madre: ${_madreNombreController.text.isNotEmpty ? _madreNombreController.text : 'Sin nombre'}'),
          Text('• 1 registro del gallo principal: ${_nombreController.text.isNotEmpty ? _nombreController.text : 'Sin nombre'}'),
          SizedBox(height: 8),
          Text(
            'Total: ${1 + (_crearPadre ? 1 : 0) + (_crearMadre ? 1 : 0)} registros genealógicos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🔥 MÉTODOS DE SELECCIÓN Y GUARDADO
  // ==========================================
  
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '📷 Seleccionar foto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('Cámara'),
              subtitle: Text('Tomar foto nueva'),
              onTap: () {
                Navigator.pop(context);
                _selectImage(ImageSource.camera);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('Galería'),
              subtitle: Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _selectImage(ImageSource.gallery);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: Text('Foto demo'),
              subtitle: Text('Usar imagen de ejemplo'),
              onTap: () {
                Navigator.pop(context);
                _selectAssetPhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _fotoSeleccionadaAsset = null; // Limpiar asset si hay archivo real
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📸 Foto real seleccionada (se subirá a Cloudinary)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectAssetPhoto() {
    final imageOptions = [
      {'path': 'assets/images/gallos/campeon.jpg', 'name': '🏆 El Campeón'},
      {'path': 'assets/images/gallos/relampago.jpg', 'name': '⚡ Relámpago'},
      {'path': 'assets/images/gallos/trueno.jpg', 'name': '⛈️ Trueno'},
      {'path': 'assets/images/gallos/gallo1.webp', 'name': '🔥 Gallo Dorado'},
      {'path': 'assets/images/gallos/gallo2.webp', 'name': '🎨 Gallo Pintado'},
      {'path': 'assets/images/gallos/gallo3.webp', 'name': '💪 Gallo Fuerte'},
      {'path': 'assets/images/gallos/gallo4.webp', 'name': '⭐ Gallo Estrella'},
      {'path': 'assets/images/gallos/gallo5.webp', 'name': '🌅 Gallo Aurora'},
      {'path': 'assets/images/gallos/gallo6.webp', 'name': '🌊 Gallo Tsunami'},
      {'path': 'assets/images/gallos/gallo7.webp', 'name': '🎯 Gallo Certero'},
      {'path': 'assets/images/gallos/gallo8.webp', 'name': '🚀 Gallo Cohete'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.photo_library, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '📷 Seleccionar Foto Demo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Grid de fotos
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: imageOptions.length,
                  itemBuilder: (context, index) {
                    final option = imageOptions[index];
                    final isSelected = _fotoSeleccionadaAsset == option['path'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _fotoSeleccionadaAsset = option['path'] as String;
                          _selectedImageFile = null; // Limpiar archivo real
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🎉 Foto demo "${option['name']}" seleccionada'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey[300]!,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Imagen
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.asset(
                                  option['path'] as String,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.pets,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            
                            // Nombre
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(15),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    option['name'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isSelected 
                                          ? AppColors.primary
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(height: 4),
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 📸 SUBIDA A CLOUDINARY
  // ==========================================
  Future<String?> _uploadPhotoToCloudinary() async {
    if (_selectedImageFile == null) return null;
    
    try {
      print('📸 Iniciando subida a Cloudinary...');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/${Constants.cloudinaryCloudName}/image/upload'),
      );
      
      // Datos de subida
      request.fields['upload_preset'] = Constants.cloudinaryUploadPreset;
      request.fields['folder'] = 'galloapp/gallos';
      
      final galloCode = _codigoController.text.isNotEmpty 
          ? _codigoController.text 
          : 'AUTO_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      
      request.fields['public_id'] = '${galloCode}_${DateTime.now().millisecondsSinceEpoch}';
      request.fields['transformation'] = 'c_fill,w_800,h_600,q_auto:best';
      
      // Archivo
      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedImageFile!.path),
      );
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        final imageUrl = jsonResponse['secure_url'];
        print('✅ Foto subida exitosamente: $imageUrl');
        return imageUrl;
      } else {
        print('❌ Error Cloudinary ${response.statusCode}: $responseData');
        return null;
      }
      
    } catch (e) {
      print('❌ Excepción en Cloudinary: $e');
      return null;
    }
  }

  // ==========================================
  // 💾 GUARDADO ÉPICO CON TÉCNICA RECURSIVA
  // ==========================================
  Future<void> _saveGallo() async {
    // Validaciones básicas
    if ((_selectedImageFile == null && _fotoSeleccionadaAsset == null) || 
        !(_formKey.currentState?.validate() ?? false) || 
        _fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Completa todos los campos obligatorios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. SUBIR FOTO A CLOUDINARY (si hay archivo real)
      String? fotoCloudinaryUrl;
      if (_selectedImageFile != null) {
        fotoCloudinaryUrl = await _uploadPhotoToCloudinary();
        if (fotoCloudinaryUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Error al subir foto, pero continuando...'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // 2. PREPARAR DATOS DEL GALLO PRINCIPAL
      final galloData = {
        'nombre': _nombreController.text.trim(),
        'codigo_identificacion': _codigoController.text.trim(),
        'fecha_nacimiento': _fechaNacimiento!.toIso8601String().split('T')[0],
        'peso': double.tryParse(_pesoController.text) ?? 0.0,
        'altura': double.tryParse(_alturaController.text) ?? 0.0,
        'color': _colorController.text.trim(),
        'procedencia': _procedenciaController.text.trim(),
        'estado': _estadoSeleccionado,
        'notas': _notasController.text.trim(),
        'raza_id': _razaSeleccionada,
        
        // Foto: Cloudinary URL o asset path
        'foto_principal_url': fotoCloudinaryUrl ?? _fotoSeleccionadaAsset,
      };

      // 3. TÉCNICA GENEALÓGICA RECURSIVA
      if (_genealogyMode == GenealogyMode.existing) {
        // Modo existente: asignar padres
        if (_padreSeleccionado != null) {
          galloData['padre_id'] = _padreSeleccionado;
        }
        if (_madreSeleccionada != null) {
          galloData['madre_id'] = _madreSeleccionada;
        }
        
        // Llamar API normal
        final response = await GalloService.createGallo(galloData);
        _handleSaveResponse(response, false);
        
      } else {
        // Modo crear: técnica recursiva épica
        bool tieneGenealogiaRecursiva = false;
        
        // Agregar datos del padre si se va a crear
        if (_crearPadre && _padreNombreController.text.trim().isNotEmpty) {
          galloData['crear_padre'] = true;
          galloData['padre_nombre'] = _padreNombreController.text.trim();
          galloData['padre_codigo_identificacion'] = _padreCodigoController.text.trim().isNotEmpty 
              ? _padreCodigoController.text.trim() 
              : 'AUTO_P_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
          galloData['padre_fecha_nacimiento'] = _padreFechaNacimiento?.toIso8601String().split('T')[0];
          galloData['padre_peso'] = double.tryParse(_padrePesoController.text) ?? 0.0;
          galloData['padre_color'] = _padreColorController.text.trim();
          galloData['padre_procedencia'] = _padreProcedenciaController.text.trim();
          galloData['padre_raza_id'] = _padreRazaSeleccionada;
          tieneGenealogiaRecursiva = true;
        }
        
        // Agregar datos de la madre si se va a crear
        if (_crearMadre && _madreNombreController.text.trim().isNotEmpty) {
          galloData['crear_madre'] = true;
          galloData['madre_nombre'] = _madreNombreController.text.trim();
          galloData['madre_codigo_identificacion'] = _madreCodigoController.text.trim().isNotEmpty 
              ? _madreCodigoController.text.trim() 
              : 'AUTO_M_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
          galloData['madre_fecha_nacimiento'] = _madreFechaNacimiento?.toIso8601String().split('T')[0];
          galloData['madre_peso'] = double.tryParse(_madrePesoController.text) ?? 0.0;
          galloData['madre_color'] = _madreColorController.text.trim();
          galloData['madre_procedencia'] = _madreProcedenciaController.text.trim();
          galloData['madre_raza_id'] = _madreRazaSeleccionada;
          tieneGenealogiaRecursiva = true;
        }

        print('🔥 Datos a enviar: $galloData');

        // Llamar API con genealogía recursiva
        final response = await GalloService.createWithGenealogy(galloData);
        _handleSaveResponse(response, tieneGenealogiaRecursiva);
      }

    } catch (e) {
      print('❌ Error en _saveGallo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleSaveResponse(Map<String, dynamic> response, bool tieneGenealogiaRecursiva) {
    if (response['success'] == true) {
      final data = response['data'];
      
      if (tieneGenealogiaRecursiva) {
        final totalRegistros = data['total_registros_creados'] ?? 1;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ¡Gallo creado! Se registraron $totalRegistros gallos genealógicos'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Gallo "${_nombreController.text}" registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Notificar al padre y cerrar
      widget.onGalloAdded(data);
      Navigator.pop(context);
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar: ${response['message'] ?? 'Error desconocido'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================
  // 🎨 MÉTODOS UI EXISTENTES (Mantenidos)
  // ==========================================
  Widget _buildStepTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildRazaDropdown() {
    return DropdownButtonFormField<int>(
      value: _razaSeleccionada,
      decoration: InputDecoration(
        labelText: 'Raza *',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
      items: widget.razas.map<DropdownMenuItem<int>>((raza) {
        return DropdownMenuItem<int>(
          value: raza['id'],
          child: Text(
            raza['nombre'] ?? 'Sin nombre',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _razaSeleccionada = value),
      validator: (value) => value == null ? 'Selecciona una raza' : null,
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de Nacimiento *',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _fechaNacimiento != null
              ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
              : 'Seleccionar fecha',
          style: TextStyle(
            color: _fechaNacimiento != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildParentDropdown(
    String label,
    IconData icon,
    int? selectedValue,
    List<dynamic> options,
    Function(int?) onChanged,
  ) {
    return DropdownButtonFormField<int>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text(
            'Sin ${label.toLowerCase()} registrado',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...options.map<DropdownMenuItem<int>>((gallo) {
          return DropdownMenuItem<int>(
            value: gallo['id'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gallo['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'Código: ${gallo['codigo_identificacion'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildEstadoDropdown() {
    final estados = ['activo', 'entrenamiento', 'lesionado', 'retirado'];
    
    return DropdownButtonFormField<String>(
      value: _estadoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Estado',
        prefixIcon: const Icon(Icons.flag),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
      items: estados.map<DropdownMenuItem<String>>((estado) {
        return DropdownMenuItem<String>(
          value: estado,
          child: Text(
            estado.toUpperCase(),
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _estadoSeleccionado = value!),
    );
  }

  Widget _buildGenealogyInfo(List<dynamic> gallosPosibles) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Información Genealógica',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_padreSeleccionado != null)
            _buildParentInfo('Padre', _padreSeleccionado!, gallosPosibles),
          if (_madreSeleccionada != null)
            _buildParentInfo('Madre', _madreSeleccionada!, gallosPosibles),
        ],
      ),
    );
  }

  Widget _buildParentInfo(String type, int parentId, List<dynamic> options) {
    final parent = options.where((g) => g['id'] == parentId).firstOrNull;
    if (parent == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$type: ${parent['nombre']} (${parent['codigo_identificacion']})',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : (_currentStep < 3 ? _nextStep : _saveGallo),
              icon: _isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(_currentStep < 3 ? Icons.arrow_forward : Icons.save),
              label: Text(_isLoading 
                  ? 'Guardando...' 
                  : _currentStep < 3 ? 'Siguiente' : 'Guardar Gallo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenealogyModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(Icons.family_restroom, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '🧬 Opciones de Genealogía',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Opción A: Padres existentes
                RadioListTile<GenealogyMode>(
                  title: const Text(
                    '📋 Seleccionar de gallos existentes',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Elige padres que ya tienes registrados'),
                  value: GenealogyMode.existing,
                  groupValue: _genealogyMode,
                  onChanged: (value) {
                    setState(() {
                      _genealogyMode = value!;
                      _resetGenealogyFields();
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                
                const Divider(),
                
                // Opción B: Crear nuevos padres
                RadioListTile<GenealogyMode>(
                  title: const Text(
                    '🆕 Crear nuevos padres',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Registra padre y/o madre nuevos junto con este gallo'),
                  value: GenealogyMode.create,
                  groupValue: _genealogyMode,
                  onChanged: (value) {
                    setState(() {
                      _genealogyMode = value!;
                      _resetGenealogyFields();
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🔄 MÉTODOS DE NAVEGACIÓN Y UTILIDAD
  // ==========================================
  void _handleBackButton() {
    if (_currentStep > 0) {
      _previousStep();
    } else {
      _showExitDialog();
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir del registro?'),
        content: const Text('Se perderá toda la información ingresada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar dialog
              Navigator.pop(context); // Volver a lista
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _fechaNacimiento = date);
    }
  }

  void _selectParentDate(bool isPadre) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 8)),
      lastDate: DateTime.now().subtract(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        if (isPadre) {
          _padreFechaNacimiento = date;
        } else {
          _madreFechaNacimiento = date;
        }
      });
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && (_selectedImageFile == null && _fotoSeleccionadaAsset == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una foto para continuar')),
      );
      return;
    }

    if (_currentStep == 1) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      if (_fechaNacimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona la fecha de nacimiento')),
        );
        return;
      }
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // MÉTODOS PARA GENEALOGÍA ÉPICA
  void _resetGenealogyFields() {
    setState(() {
      _padreSeleccionado = null;
      _madreSeleccionada = null;
      _crearPadre = false;
      _crearMadre = false;
      _padreRazaSeleccionada = null;
      _madreRazaSeleccionada = null;
      _padreFechaNacimiento = null;
      _madreFechaNacimiento = null;
    });
    
    _padreNombreController.clear();
    _padreCodigoController.clear();
    _padreColorController.clear();
    _padrePesoController.clear();
    _padreProcedenciaController.clear();
    _madreNombreController.clear();
    _madreCodigoController.clear();
    _madreColorController.clear();
    _madrePesoController.clear();
    _madreProcedenciaController.clear();
  }
}