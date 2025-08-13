// 🗓️🐓 WIDGET ÉPICO DE FILTROS DINÁMICOS
import 'package:flutter/material.dart';
import '../services/reportes_service.dart';
import '../../../shared/theme/app_colors.dart';

class PeriodoDisponible {
  final int ano;
  final int mes;
  final String nombrePeriodo;
  final int totalPeleas;

  PeriodoDisponible({
    required this.ano,
    required this.mes,
    required this.nombrePeriodo,
    required this.totalPeleas,
  });

  factory PeriodoDisponible.fromJson(Map<String, dynamic> json) {
    return PeriodoDisponible(
      ano: json['ano'],
      mes: json['mes'],
      nombrePeriodo: json['nombre_periodo'],
      totalPeleas: json['total_peleas'],
    );
  }
}

class FiltrosWidget extends StatelessWidget {
  final int? anoSeleccionado;
  final int? mesSeleccionado;
  final List<int> anosDisponibles;
  final List<PeriodoDisponible> periodosDisponibles;
  final Function({int? ano, int? mes}) onFiltrosChanged;
  final bool isLoading;

  const FiltrosWidget({
    super.key,
    this.anoSeleccionado,
    this.mesSeleccionado,
    required this.anosDisponibles,
    required this.periodosDisponibles,
    required this.onFiltrosChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // 📅 DROPDOWNS DE FILTROS
          Row(
            children: [
              // Dropdown Año
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
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
                          child: Text('Todos los años'),
                        ),
                        ...anosDisponibles.map((ano) => DropdownMenuItem<int>(
                          value: ano,
                          child: Text(
                            ano.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        )),
                      ],
                      onChanged: isLoading ? null : (ano) {
                        onFiltrosChanged(ano: ano, mes: mesSeleccionado);
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isLoading ? Colors.grey : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Dropdown Mes
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
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
                      items: _getMesesDisponibles(),
                      onChanged: isLoading ? null : (mes) {
                        onFiltrosChanged(ano: anoSeleccionado, mes: mes);
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isLoading ? Colors.grey : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Botón limpiar filtros
              InkWell(
                onTap: isLoading ? null : () {
                  onFiltrosChanged(ano: null, mes: null);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.clear,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          
          // Comentamos por ahora para evitar overflow
          // const SizedBox(height: 6),
          // _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    final ahora = DateTime.now();
    final mesAnterior = DateTime(ahora.year, ahora.month - 1);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Este mes
          _buildQuickFilterChip(
            'Este mes',
            () => onFiltrosChanged(ano: ahora.year, mes: ahora.month),
            isSelected: anoSeleccionado == ahora.year && mesSeleccionado == ahora.month,
          ),
          
          // Mes anterior
          _buildQuickFilterChip(
            'Mes anterior',
            () {
              onFiltrosChanged(ano: mesAnterior.year, mes: mesAnterior.month);
            },
            isSelected: anoSeleccionado == mesAnterior.year && mesSeleccionado == mesAnterior.month,
          ),
          
          // Este año
          _buildQuickFilterChip(
            'Este año',
            () => onFiltrosChanged(ano: ahora.year, mes: null),
            isSelected: anoSeleccionado == ahora.year && mesSeleccionado == null,
          ),
          
          // Todos los períodos
          _buildQuickFilterChip(
            'Todos',
            () => onFiltrosChanged(ano: null, mes: null),
            isSelected: anoSeleccionado == null && mesSeleccionado == null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, VoidCallback onTap, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected 
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                ? AppColors.primary.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.white,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<int?>> _getMesesDisponibles() {
    List<DropdownMenuItem<int?>> items = [
      const DropdownMenuItem<int?>(
        value: null,
        child: Text('Todo el año'),
      ),
    ];

    // Si hay un año seleccionado, filtrar meses disponibles
    if (anoSeleccionado != null && periodosDisponibles.isNotEmpty) {
      final mesesDelAno = periodosDisponibles
          .where((periodo) => periodo.ano == anoSeleccionado)
          .map((periodo) => periodo.mes)
          .toSet()
          .toList();
      
      mesesDelAno.sort();
      
      for (final mes in mesesDelAno) {
        items.add(DropdownMenuItem<int>(
          value: mes,
          child: Text(ReportesService.getNombreMes(mes)),
        ));
      }
    } else {
      // Mostrar todos los meses
      for (int mes = 1; mes <= 12; mes++) {
        items.add(DropdownMenuItem<int>(
          value: mes,
          child: Text(ReportesService.getNombreMes(mes)),
        ));
      }
    }

    return items;
  }

  String _getPeriodoTexto() {
    if (anoSeleccionado != null && mesSeleccionado != null) {
      return '${ReportesService.getNombreMes(mesSeleccionado!)} $anoSeleccionado';
    } else if (anoSeleccionado != null) {
      return 'Año $anoSeleccionado';
    } else {
      return 'Todos los períodos';
    }
  }
}