// Screen para agregar/editar gallos con formulario multi-paso
// Incluye manejo de fotos, datos básicos, genealogía y notas
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class AddGalloMultistepScreen extends StatefulWidget {
  const AddGalloMultistepScreen({Key? key}) : super(key: key);

  @override
  State<AddGalloMultistepScreen> createState() => _AddGalloMultistepScreenState();
}

class _AddGalloMultistepScreenState extends State<AddGalloMultistepScreen> {
  int _currentStep = 0;
  int _genealogyTabIndex = 0;

  // Controllers para datos básicos del gallo
  final _nombreGalloController = TextEditingController();
  final _numeroRegistroController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _criadorController = TextEditingController();
  final _propietarioController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _notasController = TextEditingController();

  // Genealogía - Padre
  final _padreNombreController = TextEditingController();
  final _padreNumeroRegistroController = TextEditingController();
  final _padreAlturaController = TextEditingController();
  final _padrePesoController = TextEditingController();
  final _padreObservacionesController = TextEditingController();

  // Genealogía - Madre
  final _madreNombreController = TextEditingController();
  final _madreNumeroRegistroController = TextEditingController();
  final _madreAlturaController = TextEditingController();
  final _madrePesoController = TextEditingController();
  final _madreObservacionesController = TextEditingController();

  // Variables de estado
  String? _selectedPhotoPath;
  File? _selectedImageFile;
  DateTime? _fechaNacimiento;
  DateTime? _padreFechaNacimiento;
  DateTime? _madreFechaNacimiento;

  // Dropdowns del gallo principal
  String _colorPlacaSeleccionado = '';
  String _ubicacionPlacaSeleccionado = '';
  int _razaSeleccionada = 0;
  String _colorPatasSeleccionado = '';
  String _colorPlumajeSeleccionado = '';

  // Genealogía - Padre
  String _padreColorPlacaSeleccionado = '';
  String _padreUbicacionPlacaSeleccionado = '';
  int _padreRazaSeleccionada = 0;
  String _padreColorPatasSeleccionado = '';
  String _padreColorPlumajeSeleccionado = '';

  // Genealogía - Madre
  String _madreColorPlacaSeleccionado = '';
  String _madreUbicacionPlacaSeleccionado = '';
  int _madreRazaSeleccionada = 0;
  String _madreColorPatasSeleccionado = '';
  String _madreColorPlumajeSeleccionado = '';

  // Datos estáticos
  final List<String> _razas = ['Kelso', 'Hatch', 'Asil', 'Shamo', 'Sweater'];
  final List<String> _coloresPlaca = ['Rojo', 'Azul', 'Verde', 'Amarillo', 'Blanco', 'Negro'];
  final List<String> _ubicacionesPlaca = ['Pata Derecha', 'Pata Izquierda', 'Ambas Patas'];
  final List<String> _coloresPatas = ['Amarillo', 'Verde', 'Blanco', 'Negro', 'Moteado'];
  final List<String> _coloresPlumaje = ['Colorado', 'Giro', 'Blanco', 'Negro', 'Canelo', 'Indio'];

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _razaSeleccionada = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void dispose() {
    _nombreGalloController.dispose();
    _numeroRegistroController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    _criadorController.dispose();
    _propietarioController.dispose();
    _observacionesController.dispose();
    _notasController.dispose();
    _padreNombreController.dispose();
    _padreNumeroRegistroController.dispose();
    _padreAlturaController.dispose();
    _padrePesoController.dispose();
    _padreObservacionesController.dispose();
    _madreNombreController.dispose();
    _madreNumeroRegistroController.dispose();
    _madreAlturaController.dispose();
    _madrePesoController.dispose();
    _madreObservacionesController.dispose();
    super.dispose();
  }

  void _loadData() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _isEditMode = args['isEdit'] ?? false;
      _nombreGalloController.text = args['nombre'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildPhotoStep(),
                _buildBasicDataStep(),
                _buildGenealogyStep(),
                _buildNotesStep(),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final List<String> stepTitles = ['📷 Foto', '📝 Datos Básicos', '👨‍👩‍👦 Genealogía', '📋 Notas'];
    
    return AppBar(
      backgroundColor: const Color(0xFF8B4513),
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _handleBackPressed(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditMode ? 'Editar Gallo' : 'Nuevo Gallo',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Paso ${_currentStep + 1}/4: ${stepTitles[_currentStep]}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      actions: [
        if (_currentStep == 3)
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveGallo,
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent 
                            ? const Color(0xFF8B4513) 
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < 3)
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? const Color(0xFF8B4513) 
                            : isCurrent 
                                ? const Color(0xFF8B4513)
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted 
                          ? const Icon(Icons.check, size: 8, color: Colors.white)
                          : null,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📷 Foto y Datos Principales',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega la foto e información básica del gallo',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          
          // 🔥 FOTO MÁS PEQUEÑA Y CENTRADA
          Center(
            child: Column(
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _selectedImageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _selectedImageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _selectedPhotoPath != null && _selectedPhotoPath!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _selectedPhotoPath!.startsWith('assets/')
                                  ? Image.asset(
                                      _selectedPhotoPath!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_selectedPhotoPath!),
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : InkWell(
                              onTap: _selectPhoto,
                              borderRadius: BorderRadius.circular(14),
                              child: _buildPhotoPlaceholder(),
                            ),
                ),
                const SizedBox(height: 16),
                
                // Botón para cambiar foto más compacto
                ElevatedButton.icon(
                  onPressed: _showPhotoOptions,
                  icon: const Icon(Icons.add_a_photo, size: 18, color: Colors.white),
                  label: const Text('Seleccionar Foto', style: TextStyle(color: Colors.white, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 🔥 CAMPOS PRINCIPALES DEL PASO 1
          const Text(
            '📝 Información Principal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 16),

          // 1. Nombre del gallo
          _HtmlTextField(
            controller: _nombreGalloController,
            label: 'Nombre del Gallo',
            hint: 'Ej: El Campeón, Relámpago, etc.',
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // 2. Número de registro
          _HtmlTextField(
            controller: _numeroRegistroController,
            label: 'Número de Registro',
            hint: 'Ej: REG-001, ABC-123, etc.',
            isRequired: false,
          ),
          const SizedBox(height: 20),

          // 3. Color de placa
          _HtmlDropdown(
            label: 'Color de Placa',
            value: _colorPlacaSeleccionado.isEmpty ? null : _colorPlacaSeleccionado,
            items: _coloresPlaca,
            onChanged: (value) => setState(() => _colorPlacaSeleccionado = value ?? ''),
          ),
          const SizedBox(height: 20),

          // 4. Ubicación de placa
          _HtmlDropdown(
            label: 'Ubicación de Placa',
            value: _ubicacionPlacaSeleccionado.isEmpty ? null : _ubicacionPlacaSeleccionado,
            items: _ubicacionesPlaca,
            onChanged: (value) => setState(() => _ubicacionPlacaSeleccionado = value ?? ''),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 40,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            'Agregar\nFoto',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDataStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📝 Datos Básicos',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Características físicas y información del gallo',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 32),

          // 🔥 LAYOUT EN GRID PARA LOS CAMPOS COMO EN LA IMAGEN
          
          // Fila 1: Raza y Color de Patas
          Row(
            children: [
              Expanded(
                child: _HtmlDropdown(
                  label: 'Raza',
                  value: _razas.isNotEmpty ? _razas[_razaSeleccionada] : null,
                  items: _razas,
                  onChanged: (value) {
                    final index = _razas.indexOf(value ?? '');
                    if (index != -1) {
                      setState(() => _razaSeleccionada = index);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _HtmlDropdown(
                  label: 'Color de Patas',
                  value: _colorPatasSeleccionado.isEmpty ? null : _colorPatasSeleccionado,
                  items: _coloresPatas,
                  onChanged: (value) => setState(() => _colorPatasSeleccionado = value ?? ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fila 2: Color de Plumaje y Peso
          Row(
            children: [
              Expanded(
                child: _HtmlDropdown(
                  label: 'Color de Plumaje',
                  value: _colorPlumajeSeleccionado.isEmpty ? null : _colorPlumajeSeleccionado,
                  items: _coloresPlumaje,
                  onChanged: (value) => setState(() => _colorPlumajeSeleccionado = value ?? ''),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _HtmlTextField(
                  controller: _pesoController,
                  label: 'Peso (kg)',
                  hint: '2.5',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fila 3: Altura y Criador
          Row(
            children: [
              Expanded(
                child: _HtmlTextField(
                  controller: _alturaController,
                  label: 'Altura (cm)',
                  hint: '45',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _HtmlTextField(
                  controller: _criadorController,
                  label: 'Criador',
                  hint: 'Nombre del criador',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fila 4: Propietario Actual (completo)
          _HtmlTextField(
            controller: _propietarioController,
            label: 'Propietario Actual',
            hint: 'Nombre del propietario',
          ),
          const SizedBox(height: 32),

          // Información adicional
          const Text(
            '🎂 Información Adicional',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 16),

          // Fecha de nacimiento
          _HtmlDateField(
            label: 'Fecha de Nacimiento',
            selectedDate: _fechaNacimiento,
            onTap: _selectFechaNacimiento,
          ),
          const SizedBox(height: 20),

          // Observaciones
          _HtmlTextField(
            controller: _observacionesController,
            label: 'Observaciones',
            hint: 'Características especiales del gallo...',
            maxLines: 3,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGenealogyStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👨‍👩‍👦 Genealogía',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Información del padre y madre (opcional)',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta información es opcional. Puedes completarla más tarde.',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tabs para Padre y Madre
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _genealogyTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _genealogyTabIndex == 0 
                            ? const Color(0xFF8B4513) 
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        '👨 Padre',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _genealogyTabIndex == 0 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _genealogyTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _genealogyTabIndex == 1 
                            ? const Color(0xFF8B4513) 
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        '👩 Madre',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _genealogyTabIndex == 1 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Contenido de las tabs
          Expanded(
            child: SingleChildScrollView(
              child: _genealogyTabIndex == 0 ? _buildPadreTab() : _buildMadreTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPadreTab() {
    return Column(
      children: [
        // 1. Nombre del padre
        _HtmlTextField(
          controller: _padreNombreController,
          label: 'Nombre del Padre',
          hint: 'Nombre del gallo padre (opcional)',
        ),
        const SizedBox(height: 20),
        
        // 2. Fecha de nacimiento del padre
        _HtmlDateField(
          label: 'Fecha de Nacimiento del Padre',
          selectedDate: _padreFechaNacimiento,
          onTap: () => _selectPadreFechaNacimiento(),
        ),
        const SizedBox(height: 20),

        // 3. Número de registro del padre
        _HtmlTextField(
          controller: _padreNumeroRegistroController,
          label: 'Número de Registro del Padre',
          hint: 'Ej: REG-P001, PAD-123, etc.',
        ),
        const SizedBox(height: 20),

        // 4. Color de placa del padre
        _HtmlDropdown(
          label: 'Color de Placa del Padre',
          value: _padreColorPlacaSeleccionado.isEmpty ? null : _padreColorPlacaSeleccionado,
          items: _coloresPlaca,
          onChanged: (value) => setState(() => _padreColorPlacaSeleccionado = value ?? ''),
        ),
        const SizedBox(height: 20),

        // 5. Lugar de placa del padre
        _HtmlDropdown(
          label: 'Lugar de Placa del Padre',
          value: _padreUbicacionPlacaSeleccionado.isEmpty ? null : _padreUbicacionPlacaSeleccionado,
          items: _ubicacionesPlaca,
          onChanged: (value) => setState(() => _padreUbicacionPlacaSeleccionado = value ?? ''),
        ),
        const SizedBox(height: 20),

        // Campos adicionales del padre
        const Divider(),
        const Text(
          '📋 Información Adicional del Padre',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
          ),
        ),
        const SizedBox(height: 16),

        _HtmlDropdown(
          label: 'Raza del Padre',
          value: _razas.isNotEmpty ? _razas[_padreRazaSeleccionada] : null,
          items: _razas,
          onChanged: (value) {
            final index = _razas.indexOf(value ?? '');
            if (index != -1) {
              setState(() => _padreRazaSeleccionada = index);
            }
          },
        ),
        const SizedBox(height: 20),

        _HtmlDropdown(
          label: 'Color de Patas del Padre',
          value: _padreColorPatasSeleccionado.isEmpty ? null : _padreColorPatasSeleccionado,
          items: _coloresPatas,
          onChanged: (value) => setState(() => _padreColorPatasSeleccionado = value ?? ''),
        ),
        const SizedBox(height: 20),

        _HtmlDropdown(
          label: 'Color de Plumaje del Padre',
          value: _padreColorPlumajeSeleccionado.isEmpty ? null : _padreColorPlumajeSeleccionado,
          items: _coloresPlumaje,
          onChanged: (value) => setState(() => _padreColorPlumajeSeleccionado = value ?? ''),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMadreTab() {
    return Column(
      children: [
        // 1. Nombre de la madre
        _HtmlTextField(
          controller: _madreNombreController,
          label: 'Nombre de la Madre',
          hint: 'Nombre de la gallina madre (opcional)',
        ),
        const SizedBox(height: 20),
        
        // 2. Fecha de nacimiento de la madre
        _HtmlDateField(
          label: 'Fecha de Nacimiento de la Madre',
          selectedDate: _madreFechaNacimiento,
          onTap: () => _selectMadreFechaNacimiento(),
        ),
        const SizedBox(height: 20),

        // 3. Número de registro de la madre
        _HtmlTextField(
          controller: _madreNumeroRegistroController,
          label: 'Número de Registro de la Madre',
          hint: 'Ej: REG-M001, MAD-123, etc.',
        ),
        const SizedBox(height: 20),

        // 4. Color de placa de la madre
        _HtmlDropdown(
          label: 'Color de Placa de la Madre',
          value: _madreColorPlacaSeleccionado.isEmpty ? null : _madreColorPlacaSeleccionado,
          items: _coloresPlaca,
          onChanged: (value) => setState(() => _madreColorPlacaSeleccionado = value ?? ''),
        ),
        const SizedBox(height: 20),

        // 5. Lugar de placa de la madre
        _HtmlDropdown(
          label: 'Lugar de Placa de la Madre',
          value: _madreUbicacionPlacaSeleccionado.isEmpty ? null : _madreUbicacionPlacaSeleccionado,
          items: _ubicacionesPlaca,
          onChanged: (value) => setState(() => _madreUbicacionPlacaSeleccionado = value ?? ''),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNotesStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Notas Finales',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Información adicional y observaciones',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _notasController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Escribe aquí cualquier información adicional sobre el gallo...\n\n• Características especiales\n• Historia del gallo\n• Premios o logros\n• Notas del criador',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botón de guardar grande
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _saveGallo,
              icon: const Icon(Icons.save, color: Colors.white, size: 24),
              label: Text(
                _isEditMode ? 'Actualizar Gallo' : 'Guardar Gallo',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          // Botón Anterior
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
              label: const Text('Anterior', style: TextStyle(color: Color(0xFF8B4513))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8B4513)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Botón Siguiente
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _currentStep < 3 ? _nextStep : null,
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: Text(
                _currentStep < 3 ? 'Siguiente' : 'Terminado',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nombreGalloController.text.isEmpty) {
        _showSnackbar('📝 Ingresa el nombre del gallo', Colors.orange);
        return;
      }
    }
    
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _handleBackPressed() {
    if (_currentStep > 0) {
      _previousStep();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Salir sin guardar?'),
          content: const Text('Se perderán todos los cambios realizados.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Salir'),
            ),
          ],
        ),
      );
    }
  }

  void _selectPhoto() {
    _showPhotoOptions();
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Foto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PhotoOptionButton(
                  icon: Icons.camera_alt,
                  label: 'Cámara',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _PhotoOptionButton(
                  icon: Icons.photo_library,
                  label: 'Galería',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _PhotoOptionButton(
                  icon: Icons.folder,
                  label: 'Demo',
                  onTap: () {
                    Navigator.pop(context);
                    _showAssetImageSelector();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
          _selectedPhotoPath = image.path;
        });
        _showSnackbar('📷 Foto agregada exitosamente', Colors.green);
      }
    } catch (e) {
      _showSnackbar('⚠️ Error al seleccionar la imagen', Colors.red);
    }
  }

  void _showAssetImageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Seleccionar Foto Demo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: _assetImages.length,
                  itemBuilder: (context, index) {
                    final assetPath = _assetImages[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _selectAssetImage(assetPath);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            assetPath,
                            fit: BoxFit.cover,
                          ),
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

  final List<String> _assetImages = [
    'assets/images/gallos/gallo1.jpg',
    'assets/images/gallos/gallo2.jpg',
    'assets/images/gallos/gallo3.jpg',
    'assets/images/gallos/gallo4.jpg',
    'assets/images/gallos/gallo5.jpg',
    'assets/images/gallos/gallo6.jpg',
    'assets/images/gallos/gallo7.jpg',
    'assets/images/gallos/gallo8.jpg',
    'assets/images/gallos/gallo9.jpg',
  ];

  void _selectAssetImage(String assetPath) {
    setState(() {
      _selectedPhotoPath = assetPath;
      _selectedImageFile = null; // Limpiar archivo seleccionado
    });
    
    _showSnackbar('📁 Asset seleccionado: ${assetPath.split('/').last}', Colors.green);
  }

  Future<void> _selectFechaNacimiento() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _fechaNacimiento = date);
    }
  }

  Future<void> _selectPadreFechaNacimiento() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _padreFechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _padreFechaNacimiento = date);
    }
  }

  Future<void> _selectMadreFechaNacimiento() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _madreFechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _madreFechaNacimiento = date);
    }
  }

  void _saveGallo() {
    if (_nombreGalloController.text.isEmpty) {
      _showSnackbar('❌ El nombre del gallo es obligatorio', Colors.red);
      return;
    }

    try {
      // Crear el objeto del gallo con toda la información
      final nuevoGallo = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'nombre': _nombreGalloController.text,
        'codigo_identificacion': _numeroRegistroController.text.isNotEmpty 
            ? _numeroRegistroController.text 
            : 'REG-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        'fechaNacimiento': _fechaNacimiento?.toIso8601String(),
        'altura': _alturaController.text,
        'peso': double.tryParse(_pesoController.text) ?? 0.0,
        'color': _colorPlumajeSeleccionado.isNotEmpty ? _colorPlumajeSeleccionado : 'No especificado',
        'colorPlaca': _colorPlacaSeleccionado,
        'ubicacionPlaca': _ubicacionPlacaSeleccionado,
        'colorPatas': _colorPatasSeleccionado,
        'colorPlumaje': _colorPlumajeSeleccionado,
        'criador': _criadorController.text,
        'propietario': _propietarioController.text,
        'observaciones': _observacionesController.text,
        'notas': _notasController.text,
        'foto_principal': _selectedPhotoPath,
        'estado': 'activo',
        'raza': {
          'id': _razaSeleccionada,
          'nombre': _razas[_razaSeleccionada],
        },
        'padre': {
          'nombre': _padreNombreController.text,
          'fechaNacimiento': _padreFechaNacimiento?.toIso8601String(),
          'numeroRegistro': _padreNumeroRegistroController.text,
          'colorPlaca': _padreColorPlacaSeleccionado,
          'ubicacionPlaca': _padreUbicacionPlacaSeleccionado,
        },
        'madre': {
          'nombre': _madreNombreController.text,
          'fechaNacimiento': _madreFechaNacimiento?.toIso8601String(),
          'numeroRegistro': _madreNumeroRegistroController.text,
          'colorPlaca': _madreColorPlacaSeleccionado,
          'ubicacionPlaca': _madreUbicacionPlacaSeleccionado,
        },
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      Navigator.pop(context, nuevoGallo);
      _showSnackbar('🎉 Gallo "${_nombreGalloController.text}" registrado exitosamente', Colors.green);
    } catch (e) {
      _showSnackbar('❌ Error al guardar el gallo', Colors.red);
    }
  }

  void _showSnackbar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}

// 🔥 CLASES HELPER MEJORADAS

class _HtmlTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool isRequired;
  final int? maxLines;

  const _HtmlTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.isRequired = false,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRequired ? '$label *' : label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HtmlDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const _HtmlDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              hint: Text(
                'Seleccionar...',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              items: [
                ...items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ],
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HtmlDateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _HtmlDateField({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
                        : 'Seleccionar fecha',
                    style: TextStyle(
                      color: selectedDate != null ? Colors.black87 : Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoOptionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF8B4513),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B4513),
              ),
            ),
          ],
        ),
      ),
    );
  }
}