// 📁 lib/features/pedigri/widgets/edit_gallo_dialog.dart
// 📝 Dialog para editar gallos existentes con integración completa

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/gallo_service.dart';
import '../../../services/connection_service.dart';
import '../../../shared/constants/app_icons.dart';

class EditGalloDialog extends StatefulWidget {
  final Map<String, dynamic> gallo;
  final List<dynamic> razas;
  final Function(Map<String, dynamic>) onGalloUpdated;

  const EditGalloDialog({
    Key? key,
    required this.gallo,
    required this.razas,
    required this.onGalloUpdated,
  }) : super(key: key);

  @override
  State<EditGalloDialog> createState() => _EditGalloDialogState();
}

class _EditGalloDialogState extends State<EditGalloDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _colorController = TextEditingController();
  final _notasController = TextEditingController();
  
  int? _selectedRazaId;
  String? _selectedEstado;
  bool _isLoading = false;

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
    _initializeFields();
  }

  void _initializeFields() {
    _nombreController.text = widget.gallo['nombre'] ?? '';
    _codigoController.text = widget.gallo['codigo_identificacion'] ?? '';
    _pesoController.text = widget.gallo['peso']?.toString() ?? '';
    _alturaController.text = widget.gallo['altura']?.toString() ?? '';
    _colorController.text = widget.gallo['color'] ?? '';
    _notasController.text = widget.gallo['notas'] ?? '';
    
    // Raza seleccionada
    final raza = widget.gallo['raza'];
    if (raza != null && raza['id'] != null) {
      _selectedRazaId = raza['id'];
    }
    
    // Estado seleccionado
    _selectedEstado = widget.gallo['estado'] ?? 'activo';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _colorController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Editar Gallo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${widget.gallo['id']}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del Gallo *',
                          hintText: 'Ej: El Campeón',
                          prefixIcon: Icon(AppIcons.galloIconData),
                        ),
                        textCapitalization: TextCapitalization.words,
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
                      
                      // Código
                      TextFormField(
                        controller: _codigoController,
                        decoration: const InputDecoration(
                          labelText: 'Código de Identificación',
                          hintText: 'Ej: CAM001',
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),
                      
                      // Peso y Altura en fila
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pesoController,
                              decoration: const InputDecoration(
                                labelText: 'Peso (kg)',
                                hintText: '2.50',
                                prefixIcon: Icon(Icons.monitor_weight),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final peso = double.tryParse(value);
                                  if (peso == null || peso <= 0 || peso > 10) {
                                    return 'Peso inválido (0.1-10 kg)';
                                  }
                                }
                                return null;
                              },
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
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final altura = int.tryParse(value);
                                  if (altura == null || altura < 30 || altura > 80) {
                                    return 'Altura inválida (30-80 cm)';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Raza y Estado en fila
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedRazaId,
                              decoration: InputDecoration(
                                labelText: 'Raza',
                                prefixIcon: Icon(AppIcons.galloIconData),
                              ),
                              items: widget.razas.map<DropdownMenuItem<int>>((raza) {
                                return DropdownMenuItem<int>(
                                  value: raza['id'],
                                  child: Text(raza['nombre'] ?? 'Sin nombre'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRazaId = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedEstado,
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                                prefixIcon: Icon(Icons.info),
                              ),
                              items: _estadosDisponibles.map<DropdownMenuItem<String>>((estado) {
                                return DropdownMenuItem<String>(
                                  value: estado,
                                  child: Text(_capitalizeFirst(estado)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedEstado = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Color
                      DropdownButtonFormField<String>(
                        value: _coloresDisponibles.contains(_colorController.text) 
                            ? _colorController.text 
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Color',
                          prefixIcon: Icon(Icons.palette),
                        ),
                        items: _coloresDisponibles.map<DropdownMenuItem<String>>((color) {
                          return DropdownMenuItem<String>(
                            value: color,
                            child: Text(color),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _colorController.text = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Notas
                      TextFormField(
                        controller: _notasController,
                        decoration: const InputDecoration(
                          labelText: 'Notas',
                          hintText: 'Observaciones adicionales...',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer con botones
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      child: _isLoading 
                          ? const SizedBox(
                              height: 16,
                              width: 16,
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
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Preparar datos actualizados
      final datosActualizados = {
        'nombre': _nombreController.text.trim(),
        'codigo_identificacion': _codigoController.text.trim(),
        'peso': _pesoController.text.isNotEmpty 
            ? double.parse(_pesoController.text)
            : null,
        'altura': _alturaController.text.isNotEmpty 
            ? int.parse(_alturaController.text)
            : null,
        'color': _colorController.text.trim(),
        'estado': _selectedEstado,
        'raza_id': _selectedRazaId,
        'notas': _notasController.text.trim(),
      };

      // Remover campos null para no enviarlos
      datosActualizados.removeWhere((key, value) => 
          value == null || (value is String && value.isEmpty));

      print('🔄 Actualizando gallo ${widget.gallo['id']} con datos: $datosActualizados');

      // Llamar al servicio
      final resultado = await GalloService.updateGallo(
        widget.gallo['id'], 
        datosActualizados,
      );

      if (resultado['success'] == true) {
        // Crear gallo actualizado para la UI
        final galloActualizado = Map<String, dynamic>.from(widget.gallo);
        galloActualizado.addAll(datosActualizados);
        
        // Si hay raza_id, buscar el objeto raza completo
        if (_selectedRazaId != null) {
          final razaSeleccionada = widget.razas.firstWhere(
            (r) => r['id'] == _selectedRazaId,
            orElse: () => {'id': _selectedRazaId, 'nombre': 'Desconocida'},
          );
          galloActualizado['raza'] = razaSeleccionada;
        }

        // Marcar como actualizado recientemente
        galloActualizado['updated_at'] = DateTime.now().toIso8601String();

        if (mounted) {
          Navigator.pop(context);
          
          // Callback para actualizar la lista
          widget.onGalloUpdated(galloActualizado);
          
          // Mostrar mensaje de éxito
          final connectionService = ConnectionService();
          final isOffline = connectionService.isOffline;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isOffline 
                  ? '📝 Gallo "${galloActualizado['nombre']}" actualizado localmente. Se sincronizará cuando haya conexión.'
                  : '✅ Gallo "${galloActualizado['nombre']}" actualizado exitosamente'
              ),
              backgroundColor: isOffline ? Colors.orange : Colors.green,
              duration: Duration(seconds: isOffline ? 4 : 2),
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
