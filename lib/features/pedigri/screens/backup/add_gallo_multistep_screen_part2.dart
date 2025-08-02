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
