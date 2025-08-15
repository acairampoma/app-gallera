// 💰 Card de Formulario de Inversiones
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InversionFormCard extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final int anioSeleccionado;
  final int mesSeleccionado;

  const InversionFormCard({
    Key? key,
    required this.controllers,
    required this.anioSeleccionado,
    required this.mesSeleccionado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            ..._buildInversionFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.edit_note, color: Colors.teal.shade600, size: 20),
        const SizedBox(width: 8),
        Text(
          'Inversiones del Mes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInversionFields() {
    final tipos = [
      {'key': 'alimento', 'nombre': 'Alimento', 'icon': Icons.restaurant, 'color': Colors.green},
      {'key': 'medicina', 'nombre': 'Medicina', 'icon': Icons.medical_services, 'color': Colors.red},
      {'key': 'limpieza_galpon', 'nombre': 'Galponero', 'icon': Icons.cleaning_services, 'color': Colors.blue},
    ];

    return tipos.map((tipo) => Column(
      children: [
        _buildInversionField(
          key: tipo['key'] as String,
          nombre: tipo['nombre'] as String,
          icon: tipo['icon'] as IconData,
          color: tipo['color'] as Color,
        ),
        const SizedBox(height: 12),
      ],
    )).toList();
  }

  Widget _buildInversionField({
    required String key,
    required String nombre,
    required IconData icon,
    required Color color,
  }) {
    final controller = controllers[key]!;
    
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icono
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Label
            Expanded(
              flex: 2,
              child: Text(
                nombre,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Campo de texto
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: 'S/. ',
                  prefixStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: color.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: color.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
                onChanged: (_) {
                  // Trigger rebuild para actualizar total en tiempo real
                  // Este callback se puede usar para notificar cambios al padre
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}