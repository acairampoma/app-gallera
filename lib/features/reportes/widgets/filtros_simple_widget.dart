// 🗓️🐓 WIDGET SIMPLE DE FILTROS SIN OVERFLOW
import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class FiltrosSimpleWidget extends StatelessWidget {
  final int? anoSeleccionado;
  final int? mesSeleccionado;
  final List<int> anosDisponibles;
  final Function({int? ano, int? mes}) onFiltrosChanged;
  final bool isLoading;

  const FiltrosSimpleWidget({
    super.key,
    this.anoSeleccionado,
    this.mesSeleccionado,
    required this.anosDisponibles,
    required this.onFiltrosChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // 📅 Dropdown Año
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  isExpanded: true,
                  hint: const Text('Año', style: TextStyle(fontSize: 12)),
                  value: anoSeleccionado,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    ...anosDisponibles.map((ano) => DropdownMenuItem<int>(
                      value: ano,
                      child: Text(ano.toString()),
                    )),
                  ],
                  onChanged: isLoading ? null : (ano) {
                    onFiltrosChanged(ano: ano, mes: mesSeleccionado);
                  },
                  isDense: true,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 📅 Dropdown Mes
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  isExpanded: true,
                  hint: const Text('Mes', style: TextStyle(fontSize: 12)),
                  value: mesSeleccionado,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  items: _getMesesItems(),
                  onChanged: isLoading ? null : (mes) {
                    onFiltrosChanged(ano: anoSeleccionado, mes: mes);
                  },
                  isDense: true,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 🔄 Botón limpiar
          InkWell(
            onTap: isLoading ? null : () {
              onFiltrosChanged(ano: null, mes: null);
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.clear,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<int?>> _getMesesItems() {
    const meses = [
      'Todos', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return List.generate(meses.length, (index) {
      return DropdownMenuItem<int?>(
        value: index == 0 ? null : index,
        child: Text(meses[index], style: const TextStyle(fontSize: 12)),
      );
    });
  }
}