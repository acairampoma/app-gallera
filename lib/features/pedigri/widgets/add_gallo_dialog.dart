import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class AddGalloDialog extends StatefulWidget {
  final List<dynamic> razas;
  final List<dynamic> gallosExistentes;
  final Function(Map<String, dynamic>) onGalloAdded;

  const AddGalloDialog({
    Key? key,
    required this.razas,
    required this.gallosExistentes,
    required this.onGalloAdded,
  }) : super(key: key);

  @override
  State<AddGalloDialog> createState() => _AddGalloDialogState();
}

class _AddGalloDialogState extends State<AddGalloDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controladores de texto
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _colorController = TextEditingController();
  final _caracteristicasController = TextEditingController();
  final _procedenciaController = TextEditingController();
  final _precioController = TextEditingController();
  final _notasController = TextEditingController();

  // Variables de estado
  DateTime? _fechaNacimiento;
  DateTime? _fechaCompra;
  int? _razaSeleccionada;
  int? _padreSeleccionado;
  int? _madreSeleccionada;
  String _temperamentoSeleccionado = 'Agresivo';
  String _estadoSeleccionado = 'activo';
  String? _fotoPath;

  final List<String> _temperamentos = [
    'Agresivo',
    'Defensivo',
    'Equilibrado',
    'Cauteloso'
  ];

  final List<String> _estados = [
    'activo',
    'entrenamiento',
    'lesionado',
    'retirado'
  ];

  final List<String> _coloresPredeterminados = [
    'Colorado',
    'Giro',
    'Negro',
    'Blanco',
    'Canelo',
    'Pinto',
    'Cenizo'
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _colorController.dispose();
    _caracteristicasController.dispose();
    _procedenciaController.dispose();
    _precioController.dispose();
    _notasController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildBasicInfoPage(),
                  _buildPhysicalInfoPage(),
                  _buildGenealogyPage(),
                  _buildAdditionalInfoPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Registrar Nuevo Gallo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentPage ? AppColors.primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Básica',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Foto del gallo
            _buildPhotoSection(),
            const SizedBox(height: 24),

            // Nombre
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Gallo *',
                prefixIcon: Icon(Icons.pets),
                hintText: 'Ej: El Campeón',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (value.trim().length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Código de identificación
            TextFormField(
              controller: _codigoController,
              decoration: const InputDecoration(
                labelText: 'Código de Identificación *',
                prefixIcon: Icon(Icons.qr_code),
                hintText: 'Ej: CAM001',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El código es obligatorio';
                }
                if (value.trim().length < 3) {
                  return 'El código debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Raza
            DropdownButtonFormField<int>(
              value: _razaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Raza *',
                prefixIcon: Icon(Icons.category),
              ),
              items: widget.razas.map<DropdownMenuItem<int>>((raza) {
                return DropdownMenuItem<int>(
                  value: raza['id'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        raza['nombre'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        raza['descripcion'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _razaSeleccionada = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecciona una raza';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fecha de nacimiento
            InkWell(
              onTap: () => _selectFechaNacimiento(),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento *',
                  prefixIcon: Icon(Icons.calendar_today),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: _fotoPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const Icon(Icons.pets, size: 60, color: AppColors.primary),
                )
              : const Icon(Icons.pets, size: 60, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _selectPhoto,
          icon: const Icon(Icons.camera_alt),
          label: Text(_fotoPath != null ? 'Cambiar Foto' : 'Agregar Foto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[100],
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Características Físicas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Peso
          TextFormField(
            controller: _pesoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Peso (kg) *',
              prefixIcon: Icon(Icons.monitor_weight),
              hintText: 'Ej: 2.45',
              suffixText: 'kg',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El peso es obligatorio';
              }
              final peso = double.tryParse(value);
              if (peso == null || peso <= 0 || peso > 5) {
                return 'Ingresa un peso válido (0-5 kg)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Altura
          TextFormField(
            controller: _alturaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Altura (cm)',
              prefixIcon: Icon(Icons.height),
              hintText: 'Ej: 58',
              suffixText: 'cm',
            ),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final altura = double.tryParse(value);
                if (altura == null || altura <= 0 || altura > 100) {
                  return 'Ingresa una altura válida (0-100 cm)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Color
          _buildColorSelector(),
          const SizedBox(height: 16),

          // Temperamento
          DropdownButtonFormField<String>(
            value: _temperamentoSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Temperamento',
              prefixIcon: Icon(Icons.psychology),
            ),
            items: _temperamentos.map((temperamento) {
              return DropdownMenuItem(
                value: temperamento,
                child: Text(temperamento),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _temperamentoSeleccionado = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Características físicas
          TextFormField(
            controller: _caracteristicasController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Características Físicas',
              prefixIcon: Icon(Icons.description),
              hintText: 'Ej: Excelente estructura, patas fuertes...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _colorController,
          decoration: const InputDecoration(
            labelText: 'Color *',
            prefixIcon: Icon(Icons.palette),
            hintText: 'Selecciona o escribe el color',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El color es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        const Text(
          'Colores comunes:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _coloresPredeterminados.map((color) {
            return FilterChip(
              label: Text(color),
              selected: _colorController.text == color,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _colorController.text = color;
                  });
                }
              },
              backgroundColor: Colors.grey[100],
              selectedColor: AppColors.primary.withOpacity(0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenealogyPage() {
    final gallosPosibles = widget.gallosExistentes.where((gallo) => gallo['id'] != null).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Genealogía',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Padre
          DropdownButtonFormField<int>(
            value: _padreSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Padre (Padrillo)',
              prefixIcon: Icon(Icons.male),
              hintText: 'Seleccionar padrillo',
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('Sin padre registrado'),
              ),
              ...gallosPosibles.map<DropdownMenuItem<int>>((gallo) {
                return DropdownMenuItem<int>(
                  value: gallo['id'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        gallo['nombre'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Código: ${gallo['codigo_identificacion']} - ${gallo['raza']?['nombre'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _padreSeleccionado = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Madre
          DropdownButtonFormField<int>(
            value: _madreSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Madre',
              prefixIcon: Icon(Icons.female),
              hintText: 'Seleccionar madre',
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('Sin madre registrada'),
              ),
              ...gallosPosibles.map<DropdownMenuItem<int>>((gallo) {
                return DropdownMenuItem<int>(
                  value: gallo['id'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        gallo['nombre'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Código: ${gallo['codigo_identificacion']} - ${gallo['raza']?['nombre'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _madreSeleccionada = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Información genealógica
          if (_padreSeleccionado != null || _madreSeleccionada != null) ...[
            Container(
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
                  if (_padreSeleccionado != null) ...[
                    _buildParentInfo('Padre', _padreSeleccionado!, gallosPosibles),
                    const SizedBox(height: 8),
                  ],
                  if (_madreSeleccionada != null) ...[
                    _buildParentInfo('Madre', _madreSeleccionada!, gallosPosibles),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParentInfo(String parentType, int parentId, List<dynamic> gallosPosibles) {
    final parent = gallosPosibles.where((gallo) => gallo['id'] == parentId).firstOrNull;

    if (parent == null) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$parentType: ${parent['nombre']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Raza: ${parent['raza']?['nombre'] ?? 'N/A'}'),
        Text('Nacimiento: ${parent['fecha_nacimiento'] ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildAdditionalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Adicional',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Procedencia
          TextFormField(
            controller: _procedenciaController,
            decoration: const InputDecoration(
              labelText: 'Procedencia',
              prefixIcon: Icon(Icons.location_on),
              hintText: 'Ej: Criadero Los Campeones - Lima',
            ),
          ),
          const SizedBox(height: 16),

          // Precio de compra
          TextFormField(
            controller: _precioController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Precio de Compra',
              prefixIcon: Icon(Icons.monetization_on),
              hintText: 'Ej: 1500',
              prefixText: 'S/. ',
            ),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final precio = double.tryParse(value);
                if (precio == null || precio < 0) {
                  return 'Ingresa un precio válido';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Fecha de compra
          InkWell(
            onTap: () => _selectFechaCompra(),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha de Compra',
                prefixIcon: Icon(Icons.shopping_cart),
              ),
              child: Text(
                _fechaCompra != null
                    ? '${_fechaCompra!.day}/${_fechaCompra!.month}/${_fechaCompra!.year}'
                    : 'Seleccionar fecha',
                style: TextStyle(
                  color: _fechaCompra != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Estado
          DropdownButtonFormField<String>(
            value: _estadoSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Estado',
              prefixIcon: Icon(Icons.flag),
            ),
            items: _estados.map((estado) {
              return DropdownMenuItem(
                value: estado,
                child: Text(estado.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _estadoSeleccionado = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Notas
          TextFormField(
            controller: _notasController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notas y Observaciones',
              prefixIcon: Icon(Icons.note),
              hintText: 'Información adicional sobre el gallo...',
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
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _currentPage < 3 ? _nextPage : _saveGallo,
              icon: Icon(_currentPage < 3 ? Icons.arrow_forward : Icons.save),
              label: Text(_currentPage < 3 ? 'Siguiente' : 'Guardar Gallo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage == 0) {
      // Validar página básica
      if (_formKey.currentState?.validate() ?? false) {
        if (_fechaNacimiento == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selecciona la fecha de nacimiento')),
          );
          return;
        }
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectFechaNacimiento() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _fechaNacimiento = date;
      });
    }
  }

  void _selectFechaCompra() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaCompra ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _fechaCompra = date;
      });
    }
  }

  void _selectPhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Seleccionar Foto del Gallo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPhotoOption(
                            icon: Icons.camera_alt,
                            title: 'Cámara',
                            subtitle: 'Tomar foto',
                            color: Colors.blue,
                            onTap: () => _takePhoto('camera'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPhotoOption(
                            icon: Icons.photo_library,
                            title: 'Galería',
                            subtitle: 'Elegir foto',
                            color: Colors.green,
                            onTap: () => _takePhoto('gallery'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_fotoPath != null)
                      SizedBox(
                        width: double.infinity,
                        child: _buildPhotoOption(
                          icon: Icons.delete,
                          title: 'Quitar Foto',
                          subtitle: 'Eliminar actual',
                          color: Colors.red,
                          onTap: () => _removePhoto(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _takePhoto(String source) async {
    Navigator.pop(context); // Cerrar bottom sheet
    
    // Simular delay de cámara/galería
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _fotoPath = 'gallo_${source}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Foto capturada desde ${source == 'camera' ? 'cámara' : 'galería'}'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _removePhoto() {
    Navigator.pop(context);
    setState(() {
      _fotoPath = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text('Foto eliminada'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _saveGallo() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_fechaNacimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona la fecha de nacimiento')),
        );
        return;
      }

      // Crear el nuevo gallo
      final nuevoGallo = {
        'id': DateTime.now().millisecondsSinceEpoch, // ID temporal
        'usuario_id': 2, // Usuario actual (mock)
        'criadero_id': 1, // Criadero default
        'raza_id': _razaSeleccionada,
        'nombre': _nombreController.text.trim(),
        'codigo_identificacion': _codigoController.text.trim(),
        'fecha_nacimiento': _fechaNacimiento!.toIso8601String().split('T')[0],
        'peso': double.tryParse(_pesoController.text) ?? 0.0,
        'altura': double.tryParse(_alturaController.text) ?? 0.0,
        'color': _colorController.text.trim(),
        'caracteristicas_fisicas': _caracteristicasController.text.trim(),
        'temperamento': _temperamentoSeleccionado,
        'precio_compra': double.tryParse(_precioController.text) ?? 0.0,
        'fecha_compra': _fechaCompra?.toIso8601String().split('T')[0],
        'procedencia': _procedenciaController.text.trim(),
        'padre_id': _padreSeleccionado,
        'madre_id': _madreSeleccionada,
        'estado': _estadoSeleccionado,
        'notas': _notasController.text.trim(),
        'foto_principal': _fotoPath ?? '/uploads/gallos/default.jpg',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'raza': widget.razas.firstWhere(
          (raza) => raza['id'] == _razaSeleccionada,
          orElse: () => {'nombre': 'N/A'},
        ),
      };

      // Llamar callback
      widget.onGalloAdded(nuevoGallo);

      // Cerrar dialog
      Navigator.pop(context);

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gallo "${_nombreController.text}" registrado exitosamente'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Navegar al detalle del gallo
            },
          ),
        ),
      );
    }
  }
}
