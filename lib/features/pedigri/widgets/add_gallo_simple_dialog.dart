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
  
  // FORMULARIO SUPER SIMPLIFICADO - Solo 4 campos
  final _nombreController = TextEditingController();
  final _anilloController = TextEditingController();
  final _pesoController = TextEditingController();
  
  String? _razaSeleccionada;
  String? _fotoSeleccionada;
  
  // 3 fotos predefinidas para la demo
  final Map<String, String> _fotosDisponibles = {
    'assets/images/gallos/campeon.jpg': '🏆 El Campeón',
    'assets/images/gallos/relampago.jpg': '⚡ Relámpago', 
    'assets/images/gallos/trueno.jpg': '⛈️ Trueno',
  };

  @override
  void dispose() {
    _nombreController.dispose();
    _anilloController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildFormulario(),
              ),
            ),
            _buildButtons(),
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
              '🐓 Nuevo Gallo',
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

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. FOTO - SELECTOR SIMPLE
          const Text(
            '📷 Foto del Gallo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildFotoSelector(),
          
          const SizedBox(height: 24),
          
          // 2. DATOS BÁSICOS
          const Text(
            '📝 Datos Básicos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Nombre
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: '🐓 Nombre del Gallo',
              hintText: 'Ej: El Campeón',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Anillo
          TextFormField(
            controller: _anilloController,
            decoration: const InputDecoration(
              labelText: '🏷️ Número de Anillo',
              hintText: 'Ej: CAM004',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El anillo es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Peso
          TextFormField(
            controller: _pesoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '⚖️ Peso (kg)',
              hintText: 'Ej: 2.5',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El peso es obligatorio';
              }
              final peso = double.tryParse(value);
              if (peso == null || peso <= 0 || peso > 5) {
                return 'Peso válido: 0.1 - 5.0 kg';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Raza - Dropdown simple
          const Text('🧬 Raza:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _razaSeleccionada,
                hint: const Text('Seleccionar raza'),
                isExpanded: true,
                items: widget.razas.map<DropdownMenuItem<String>>((raza) {
                  return DropdownMenuItem<String>(
                    value: raza['nombre'],
                    child: Text(raza['nombre']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _razaSeleccionada = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          if (_fotoSeleccionada != null) ...[
            // Mostrar foto seleccionada
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(Icons.pets, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              _fotosDisponibles[_fotoSeleccionada!] ?? 'Foto seleccionada',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],
          
          ElevatedButton.icon(
            onPressed: _mostrarSelectorFotos,
            icon: const Icon(Icons.photo_library),
            label: Text(_fotoSeleccionada == null ? 'Seleccionar Foto' : 'Cambiar Foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarSelectorFotos() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '📷 Seleccionar Foto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...(_fotosDisponibles.entries.map((entry) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pets, color: AppColors.primary),
                ),
                title: Text(entry.value),
                trailing: _fotoSeleccionada == entry.key 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _fotoSeleccionada = entry.key;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList()),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _guardarGallo,
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
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

  void _guardarGallo() {
    // Validar formulario
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_razaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una raza'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_fotoSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una foto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Crear nuevo gallo - ESTRUCTURA SIMPLIFICADA
    final nuevoGallo = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'usuario_id': 2,
      'nombre': _nombreController.text.trim(),
      'codigo_identificacion': _anilloController.text.trim(),
      'fecha_nacimiento': DateTime.now().subtract(const Duration(days: 365)).toIso8601String().split('T')[0],
      'peso': double.parse(_pesoController.text),
      'color': 'Colorado', // Default
      'estado': 'activo',
      'foto_principal': _fotoSeleccionada!,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'raza': {
        'id': 1,
        'nombre': _razaSeleccionada!,
      },
      'notas': 'Gallo registrado desde la app',
    };

    // Simular guardado en \"assets\" (en realidad se guarda en memoria)
    print('💾 SIMULANDO GUARDADO DE FOTO: $_fotoSeleccionada');
    print('🐓 GALLO CREADO: ${nuevoGallo['nombre']}');

    // Llamar callback
    widget.onGalloAdded(nuevoGallo);

    // Cerrar dialog
    Navigator.pop(context);

    // Mostrar confirmación épica
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('🎉 ¡Gallo \"${_nombreController.text}\" creado exitosamente!'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}