import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

// 🔥 WIDGET SIMPLE PARA AGREGAR GALLO RÁPIDO
class AddGalloSimpleDialog extends StatefulWidget {
  final List<dynamic> razas;
  final Function(Map<String, dynamic>) onGalloAdded;

  const AddGalloSimpleDialog({
    Key? key,
    required this.razas,
    required this.onGalloAdded,
  }) : super(key: key);

  @override
  State<AddGalloSimpleDialog> createState() => _AddGalloSimpleDialogState();
}

class _AddGalloSimpleDialogState extends State<AddGalloSimpleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _pesoController = TextEditingController();
  final _colorController = TextEditingController();
  
  int? _razaSeleccionada;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _pesoController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Agregar Gallo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Form
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nombreController,
                        label: 'Nombre del Gallo',
                        icon: Icons.pets,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _codigoController,
                        label: 'Código/Anillo',
                        icon: Icons.confirmation_number,
                        hintText: 'Ej: CAM001',
                      ),
                      const SizedBox(height: 16),
                      
                      _buildDropdown(),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _pesoController,
                              label: 'Peso (kg)',
                              icon: Icons.monitor_weight,
                              keyboardType: TextInputType.number,
                              hintText: '2.5',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _colorController,
                              label: 'Color',
                              icon: Icons.palette,
                              hintText: 'Colorado',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveGallo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<int>(
      value: _razaSeleccionada,
      decoration: InputDecoration(
        labelText: 'Raza',
        prefixIcon: const Icon(Icons.category, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
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
    );
  }

  void _saveGallo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular delay
    await Future.delayed(const Duration(seconds: 1));

    final razaSeleccionada = widget.razas.firstWhere(
      (raza) => raza['id'] == _razaSeleccionada,
      orElse: () => {'id': 1, 'nombre': 'Sin raza'},
    );

    final nuevoGallo = {
      'id': DateTime.now().millisecondsSinceEpoch, // ID temporal único
      'nombre': _nombreController.text,
      'codigo_identificacion': _codigoController.text.isNotEmpty 
          ? _codigoController.text 
          : 'AUTO${DateTime.now().millisecondsSinceEpoch % 10000}',
      'peso': double.tryParse(_pesoController.text) ?? 0.0,
      'color': _colorController.text.isNotEmpty ? _colorController.text : 'Sin especificar',
      'raza': razaSeleccionada,
      'estado': 'activo',
      'fecha_nacimiento': DateTime.now().toIso8601String().split('T')[0],
      'created_at': DateTime.now().toIso8601String(),
      'foto_principal': null,
    };

    widget.onGalloAdded(nuevoGallo);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Gallo "${nuevoGallo['nombre']}" agregado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
