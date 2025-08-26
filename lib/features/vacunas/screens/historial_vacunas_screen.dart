// 📁 lib/features/vacunas/screens/historial_vacunas_screen.dart
// 📊 Pantalla de historial detallado de vacunas por gallo

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/vacunas_service.dart';
import '../../../models/vacuna.dart';
import 'formulario_vacuna_screen.dart';
import '../../../shared/widgets/limite_interceptor.dart'; // 🛡️ VALIDACIÓN DE LÍMITES
import '../../../models/suscripcion_models.dart'; // 🔄 ENUM RecursoTipo

class HistorialVacunasScreen extends StatefulWidget {
  final int galloId;
  final String galloNombre;
  
  const HistorialVacunasScreen({
    Key? key,
    required this.galloId,
    required this.galloNombre,
  }) : super(key: key);

  @override
  State<HistorialVacunasScreen> createState() => _HistorialVacunasScreenState();
}

class _HistorialVacunasScreenState extends State<HistorialVacunasScreen> {
  List<Vacuna> historialVacunas = [];
  List<ProximaVacuna> proximasVacunas = [];
  bool isLoading = true;
  bool _hasChanges = false; // Flag para indicar si hubo cambios
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  Future<void> _loadHistorial() async {
    print('📊 Cargando historial del gallo ${widget.galloId}...');
    
    // Solo mostrar loading si no hay datos previos
    if (historialVacunas.isEmpty) {
      setState(() => isLoading = true);
    }
    
    try {
      // Cargar historial y próximas vacunas
      final historialData = await VacunasService.getHistorialGallo(widget.galloId);
      final proximasData = await VacunasService.getProximasVacunas(diasAdelante: 365);
      
      // Filtrar próximas vacunas para este gallo
      final proximasGallo = proximasData
          .where((p) => p['gallo_id'] == widget.galloId)
          .map((p) => ProximaVacuna.fromJson(p))
          .toList();
      
      // Convertir historial
      final historial = historialData.map((h) => Vacuna.fromJson(h)).toList();
      
      // Forzar actualización completa del widget
      if (mounted) {
        setState(() {
          historialVacunas = historial;
          proximasVacunas = proximasGallo;
          isLoading = false;
        });
      }
      
      print('✅ Historial actualizado: ${historial.length} registros, ${proximasGallo.length} próximas');
      
    } catch (e) {
      print('❌ Error cargando historial: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Si hubo cambios, retornar true para que la pantalla anterior recargue
        if (_hasChanges) {
          Navigator.pop(context, true);
          return false; // Prevenir el pop por defecto
        }
        return true; // Permitir el pop normal
      },
      child: BaseScreen(
        title: '📊 ${widget.galloNombre}',
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildSummaryCards(),
                  _buildProximasVacunas(),
                  Expanded(child: _buildHistorialList()),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _agregarNuevaVacuna,
          icon: const Icon(Icons.add),
          label: const Text('Nueva Vacuna'),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final vacunasVencidas = proximasVacunas
        .where((p) => p.estadoEnum == EstadoVacuna.vencida)
        .length;
    
    final vacunasUrgentes = proximasVacunas
        .where((p) => p.estadoEnum == EstadoVacuna.urgente)
        .length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              '📊', 
              historialVacunas.length.toString(),
              'Total Aplicadas',
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              '📅', 
              proximasVacunas.length.toString(),
              'Programadas',
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              '⚠️', 
              vacunasUrgentes.toString(),
              'Urgentes',
              Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              '🔴', 
              vacunasVencidas.toString(),
              'Vencidas',
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProximasVacunas() {
    if (proximasVacunas.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔜 Próximas Vacunas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...proximasVacunas.map((proxima) => _buildProximaVacunaItem(proxima)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProximaVacunaItem(ProximaVacuna proxima) {
    final estadoColor = _getEstadoColor(proxima.estadoEnum);
    final diasTexto = proxima.diasRestantes < 0 
        ? '${proxima.diasRestantes.abs()} días vencida'
        : '${proxima.diasRestantes} días restantes';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: estadoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: estadoColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Color(int.parse(proxima.colorTipoVacuna.replaceAll('#', '0xff'))),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.vaccines, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proxima.nombreTipoVacuna,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_dateFormatter.format(proxima.proximaDosis)} • $diasTexto',
                  style: TextStyle(
                    color: estadoColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildHistorialList() {
    if (historialVacunas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vaccines, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sin vacunas registradas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega la primera vacuna con el botón +',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistorial,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: historialVacunas.length,
        itemBuilder: (context, index) {
          final vacuna = historialVacunas[index];
          return _buildVacunaCard(vacuna);
        },
      ),
    );
  }

  Widget _buildVacunaCard(Vacuna vacuna) {
    final tipoColor = Color(int.parse(vacuna.colorTipoVacuna.replaceAll('#', '0xff')));
    final fechaTexto = _dateFormatter.format(vacuna.fechaAplicacion);
    final proximaTexto = vacuna.proximaDosis != null 
        ? _dateFormatter.format(vacuna.proximaDosis!)
        : 'Sin programar';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _editarVacuna(vacuna),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Indicador de tipo de vacuna
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tipoColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.vaccines, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              
              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vacuna.nombreTipoVacuna,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aplicada: $fechaTexto',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if (vacuna.proximaDosis != null)
                      Text(
                        'Próxima: $proximaTexto',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    if (vacuna.veterinarioNombre != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Dr. ${vacuna.veterinarioNombre}',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Acciones con tamaño garantizado
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _editarVacuna(vacuna),
                        icon: const Icon(Icons.edit, size: 18),
                        color: Colors.blue[700],
                        tooltip: 'Editar vacuna',
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _eliminarVacuna(vacuna),
                        icon: const Icon(Icons.delete, size: 18),
                        color: Colors.red[700],
                        tooltip: 'Eliminar vacuna',
                        padding: EdgeInsets.zero,
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

  Color _getEstadoColor(EstadoVacuna estado) {
    switch (estado) {
      case EstadoVacuna.vencida:
        return Colors.red;
      case EstadoVacuna.urgente:
        return Colors.orange;
      case EstadoVacuna.proxima:
        return Colors.amber;
      case EstadoVacuna.programada:
        return Colors.blue;
      case EstadoVacuna.completa:
        return Colors.green;
    }
  }

  void _agregarNuevaVacuna() async {
    // 🛡️ VALIDAR LÍMITES ANTES DE ABRIR FORMULARIO
    final puedeCrear = await validarLimiteManual(
      context,
      recursoTipo: RecursoTipo.vacunas,
      galloId: widget.galloId,
    );

    if (puedeCrear) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormularioVacunaScreen(
            galloId: widget.galloId,
            galloNombre: widget.galloNombre,
          ),
        ),
      ).then((result) {
        if (result == true) {
          _hasChanges = true; // Marcar que hubo cambios
          _loadHistorial(); // Recargar si se agregó una vacuna
        }
      });
    }
  }

  void _editarVacuna(Vacuna vacuna) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioVacunaScreen(
          galloId: widget.galloId,
          galloNombre: widget.galloNombre,
          vacunaExistente: vacuna,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadHistorial();
      }
    });
  }

  void _eliminarVacuna(Vacuna vacuna) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Vacuna'),
          content: Text('¿Eliminar vacuna ${vacuna.nombreTipoVacuna}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _confirmarEliminacion(vacuna);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarEliminacion(Vacuna vacuna) async {
    try {
      final success = await VacunasService.eliminarVacuna(vacuna.id!);
      if (success) {
        // Marcar que hubo cambios
        _hasChanges = true;
        
        // Actualizar la lista localmente primero para respuesta inmediata
        setState(() {
          historialVacunas.removeWhere((v) => v.id == vacuna.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vacuna eliminada'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Luego recargar desde el servidor para sincronizar
        await _loadHistorial();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}