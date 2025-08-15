// 📁 lib/features/topes/screens/historial_topes_screen.dart  
// 🏋️ Historial de entrenamientos de un gallo específico

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/video_player_widget.dart';
import '../../../services/topes_service.dart';
import '../../../models/tope.dart';
import 'formulario_tope_screen.dart';
import '../../../shared/constants/app_icons.dart';

class HistorialTopesScreen extends StatefulWidget {
  final int galloId;
  final String galloNombre;

  const HistorialTopesScreen({
    Key? key,
    required this.galloId,
    required this.galloNombre,
  }) : super(key: key);

  @override
  State<HistorialTopesScreen> createState() => _HistorialTopesScreenState();
}

class _HistorialTopesScreenState extends State<HistorialTopesScreen> {
  List<Tope> topes = [];
  List<Tope> topesFiltrados = [];
  bool isLoading = true;
  String _filtroTipo = 'todos';

  // Estadísticas del gallo
  int totalTopes = 0;
  Map<String, int> tiposCount = {
    'top_espuelas': 0,
    'top_sin_espuelas': 0,
    'sparring_tecnico': 0,
    'acondicionamiento_fisico': 0,
  };
  int totalMinutos = 0;
  double promedioMinutos = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTopes();
  }

  Future<void> _loadTopes() async {
    setState(() => isLoading = true);

    try {
      final result = await TopesService.getTopesGallo(widget.galloId);
      
      // Convertir a objetos Tope y calcular estadísticas
      List<Tope> topesList = [];
      Map<String, int> tipos = {
        'top_espuelas': 0,
        'top_sin_espuelas': 0,
        'sparring_tecnico': 0,
        'acondicionamiento_fisico': 0,
      };
      int minutos = 0;
      
      for (var topeData in result) {
        final tope = Tope.fromJson(topeData);
        topesList.add(tope);
        
        final tipo = tope.tipoEntrenamiento?.toLowerCase();
        if (tipo != null && tipos.containsKey(tipo)) {
          tipos[tipo] = tipos[tipo]! + 1;
        }
        
        minutos += tope.duracionMinutos ?? 0;
      }
      
      setState(() {
        topes = topesList;
        topesFiltrados = topesList;
        totalTopes = topesList.length;
        tiposCount = tipos;
        totalMinutos = minutos;
        promedioMinutos = totalTopes > 0 ? minutos / totalTopes : 0.0;
        isLoading = false;
      });
      
      // Ordenar por fecha descendente
      topesFiltrados.sort((a, b) => b.fechaTope.compareTo(a.fechaTope));
      
    } catch (e) {
      print('Error cargando topes: $e');
      setState(() => isLoading = false);
      _showError('Error cargando historial');
    }
  }

  void _filterTopes(String filtro) {
    setState(() {
      _filtroTipo = filtro;
      if (filtro == 'todos') {
        topesFiltrados = topes;
      } else {
        topesFiltrados = topes.where((t) => t.tipoEntrenamiento == filtro).toList();
      }
      topesFiltrados.sort((a, b) => b.fechaTope.compareTo(a.fechaTope));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '🏋️ Historial de Entrenamientos',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildGalloHeader(),
                _buildStatsSection(),
                _buildFilterChips(),
                Expanded(
                  child: topesFiltrados.isEmpty
                      ? _buildEmptyState()
                      : _buildTopesList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarNuevoTope,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Tope'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildGalloHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.primary.withOpacity(0.1),
      child: Column(
        children: [
          AppIcons.gallo(
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            widget.galloNombre,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'ID: ${widget.galloId}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '🏋️',
                  totalTopes.toString(),
                  'Total',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  '⏱️',
                  '${totalMinutos}min',
                  'Total Min',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  '📊',
                  '${promedioMinutos.toStringAsFixed(0)}min',
                  'Promedio',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Solo tipos nuevos
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard('🐓', tiposCount['top_espuelas']!, 'C/Espuelas', Colors.brown),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatCard('🥅', tiposCount['top_sin_espuelas']!, 'S/Espuelas', Colors.purple),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatCard('🎯', tiposCount['sparring_tecnico']!, 'Sp. Técnico', Colors.indigo),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatCard('💪', tiposCount['acondicionamiento_fisico']!, 'Físico', Colors.teal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String emoji, int value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('todos', 'Todos', Icons.fitness_center),
            const SizedBox(width: 8),
            _buildFilterChip('top_espuelas', 'C/Espuelas', Icons.sports_kabaddi, Colors.brown),
            const SizedBox(width: 8),
            _buildFilterChip('top_sin_espuelas', 'S/Espuelas', Icons.sports, Colors.purple),
            const SizedBox(width: 8),
            _buildFilterChip('sparring_tecnico', 'Sp. Técnico', Icons.gps_fixed, Colors.indigo),
            const SizedBox(width: 8),
            _buildFilterChip('acondicionamiento_fisico', 'Físico', Icons.fitness_center, Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon, [Color? color]) {
    final isSelected = _filtroTipo == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (_) => _filterTopes(value),
      selectedColor: (color ?? AppColors.primary).withOpacity(0.2),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildTopesList() {
    return RefreshIndicator(
      onRefresh: _loadTopes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topesFiltrados.length,
        itemBuilder: (context, index) {
          final tope = topesFiltrados[index];
          return _buildTopeCard(tope);
        },
      ),
    );
  }

  Widget _buildTopeCard(Tope tope) {
    final tipoColor = _getTipoColor(tope.tipoEntrenamiento);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y tipo
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tope.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(tope.fechaTope),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tipoColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getTipoLabel(tope.tipoEntrenamiento),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            // Duración
            if (tope.duracionMinutos != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${tope.duracionMinutos} minutos',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            
            // Descripción
            if (tope.descripcion?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                tope.descripcion!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Descripción de Sparring
            if (tope.desSparring?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.sports_mma, size: 14, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tope.desSparring!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Video disponible
            if (tope.videoUrl != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _reproducirVideo(tope.videoUrl!, tope.titulo),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_filled, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Ver video',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // Notas
            if (tope.notas?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 14, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tope.notas!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[900],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Botones de acción
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editarTope(tope),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _eliminarTope(tope),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _filtroTipo == 'todos'
                ? 'No hay entrenamientos registrados'
                : 'No hay entrenamientos de $_filtroTipo',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona + para agregar un entrenamiento',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTipoColor(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'top_espuelas':
        return Colors.brown;
      case 'top_sin_espuelas':
        return Colors.purple;
      case 'sparring_tecnico':
        return Colors.indigo;
      case 'acondicionamiento_fisico':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getTipoLabel(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'top_espuelas':
        return 'C/ESPUELAS';
      case 'top_sin_espuelas':
        return 'S/ESPUELAS';
      case 'sparring_tecnico':
        return 'SP. TÉCNICO';
      case 'acondicionamiento_fisico':
        return 'FÍSICO';
      default:
        return 'N/A';
    }
  }

  void _agregarNuevoTope() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioTopeScreen(
          galloPreseleccionado: widget.galloId,
          galloIsBloqueado: true,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadTopes();
      }
    });
  }

  void _editarTope(Tope tope) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioTopeScreen(tope: tope),
      ),
    ).then((result) {
      if (result == true) {
        _loadTopes();
      }
    });
  }

  void _eliminarTope(Tope tope) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Entrenamiento'),
        content: Text('¿Estás seguro de eliminar el entrenamiento "${tope.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await TopesService.eliminarTope(tope.id);
                _showSuccess('Entrenamiento eliminado exitosamente');
                _loadTopes();
              } catch (e) {
                _showError('Error eliminando entrenamiento');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _reproducirVideo(String videoUrl, String titulo) {
    print('🎬 Reproduciendo video: $videoUrl');
    VideoPlayerModal.show(
      context,
      videoUrl: videoUrl,
      title: 'Entrenamiento: $titulo',
    );
  }
}