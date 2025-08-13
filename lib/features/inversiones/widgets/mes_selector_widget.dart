// 📅 Widget Selector de Mes y Año
import 'package:flutter/material.dart';

class MesSelectorWidget extends StatelessWidget {
  final int anioSeleccionado;
  final int mesSeleccionado;
  final Function(int anio, int mes) onChanged;

  const MesSelectorWidget({
    Key? key,
    required this.anioSeleccionado,
    required this.mesSeleccionado,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Selector de Año
        Expanded(
          flex: 2,
          child: _buildAnioSelector(context),
        ),
        const SizedBox(width: 12),
        // Selector de Mes
        Expanded(
          flex: 3,
          child: _buildMesSelector(context),
        ),
      ],
    );
  }

  Widget _buildAnioSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Año',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: anioSeleccionado,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade600),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: _getAniosDisponibles().map((anio) {
                return DropdownMenuItem<int>(
                  value: anio,
                  child: Text('$anio'),
                );
              }).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  onChanged(valor, mesSeleccionado);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMesSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: mesSeleccionado,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade600),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: _getMesesDisponibles().map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  onChanged(anioSeleccionado, valor);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  List<int> _getAniosDisponibles() {
    final anioActual = DateTime.now().year;
    return List.generate(5, (index) => anioActual - 2 + index);
  }

  List<MapEntry<int, String>> _getMesesDisponibles() {
    return const [
      MapEntry(1, 'Enero'),
      MapEntry(2, 'Febrero'),
      MapEntry(3, 'Marzo'),
      MapEntry(4, 'Abril'),
      MapEntry(5, 'Mayo'),
      MapEntry(6, 'Junio'),
      MapEntry(7, 'Julio'),
      MapEntry(8, 'Agosto'),
      MapEntry(9, 'Septiembre'),
      MapEntry(10, 'Octubre'),
      MapEntry(11, 'Noviembre'),
      MapEntry(12, 'Diciembre'),
    ];
  }
}