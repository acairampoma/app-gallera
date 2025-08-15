// 📁 lib/features/peleas/screens/historial_peleas_screen.dart
// 🥊 Historial de peleas de un gallo específico

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/video_player_widget.dart';
import '../../../services/peleas_service.dart';
import '../../../models/pelea.dart';
import 'formulario_pelea_screen.dart';
import '../../../shared/constants/app_icons.dart';

class HistorialPeleasScreen extends StatefulWidget {
  final int galloId;
  final String galloNombre;

  const HistorialPeleasScreen({
    Key? key,
    required this.galloId,
    required this.galloNombre,
  }) : super(key: key);

  @override
  State<HistorialPeleasScreen> createState() => _HistorialPeleasScreenState();
}

class _HistorialPeleasScreenState extends State<HistorialPeleasScreen> {
  List<Pelea> peleas = [];
  List<Pelea> peleasFiltradas = [];
  bool isLoading = true;
  String _filtroResultado = 'todos';

  // Estadísticas del gallo
  int totalPeleas = 0;
  int ganadas = 0;
  int perdidas = 0;
  int empates = 0;
  double efectividad = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPeleas();
  }

  Future<void> _loadPeleas() async {
    setState(() => isLoading = true);

    try {
      final result = await PeleasService.getPeleasGallo(widget.galloId);
      
      // Convertir a objetos Pelea y calcular estadísticas
      List<Pelea> peleasList = [];
      int g = 0, p = 0, e = 0;
      
      for (var peleaData in result) {
        final pelea = Pelea.fromJson(peleaData);
        peleasList.add(pelea);
        
        if (pelea.resultado == 'ganada') g++;
        else if (pelea.resultado == 'perdida') p++;
        else if (pelea.resultado == 'empate') e++;
      }
      
      setState(() {
        peleas = peleasList;
        peleasFiltradas = peleasList;
        totalPeleas = peleasList.length;
        ganadas = g;
        perdidas = p;
        empates = e;
        efectividad = totalPeleas > 0 ? (g / totalPeleas) * 100 : 0.0;
        isLoading = false;
      });
      
      // Ordenar por fecha descendente
      peleasFiltradas.sort((a, b) => b.fechaPelea.compareTo(a.fechaPelea));
      
    } catch (e) {
      print('Error cargando peleas: $e');
      setState(() => isLoading = false);
      _showError('Error cargando historial');
    }
  }

  void _filterPeleas(String filtro) {
    setState(() {
      _filtroResultado = filtro;
      if (filtro == 'todos') {
        peleasFiltradas = peleas;
      } else {
        peleasFiltradas = peleas.where((p) => p.resultado == filtro).toList();
      }
      peleasFiltradas.sort((a, b) => b.fechaPelea.compareTo(a.fechaPelea));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '🥊 Historial de Peleas',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildGalloHeader(),
                _buildStatsSection(),
                _buildFilterChips(),
                Expanded(
                  child: peleasFiltradas.isEmpty
                      ? _buildEmptyState()
                      : _buildPeleasList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarNuevaPelea,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Pelea'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  '📊 ESTADÍSTICAS - ${widget.galloNombre}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Dashboard 2x2 compacto - diseño HTML
          Row(
            children: [
              Expanded(
                child: _buildStatCardCompact(
                  totalPeleas.toString(),
                  'Total Peleas',
                  Colors.red,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildStatCardCompact(
                  ganadas.toString(),
                  'Victorias',
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildStatCardCompact(
                  '${efectividad.toStringAsFixed(1)}%',
                  'Efectividad',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildStatCardCompact(
                  _getUltimoResultado(),
                  'Último Resultado',
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 📊 ESTADÍSTICAS COMPACTAS - DISEÑO HTML
  Widget _buildStatCardCompact(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  String _getUltimoResultado() {
    if (peleas.isEmpty) return 'N/A';
    final ultimaPelea = peleas.first;
    switch (ultimaPelea.resultado?.toLowerCase()) {
      case 'ganada':
        return '🏆';
      case 'perdida':
        return '❌';
      case 'empate':
        return '🤝';
      default:
        return '❓';
    }
  }
  
  Color _getUltimoResultadoColor() {
    if (peleas.isEmpty) return Colors.grey;
    final ultimaPelea = peleas.first;
    return _getResultadoColor(ultimaPelea.resultado);
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('todos', 'Todas', Icons.list),
            const SizedBox(width: 8),
            _buildFilterChip('ganada', 'Ganadas', Icons.emoji_events, Colors.green),
            const SizedBox(width: 8),
            _buildFilterChip('perdida', 'Perdidas', Icons.cancel, Colors.red),
            const SizedBox(width: 8),
            _buildFilterChip('empate', 'Empates', Icons.remove, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon, [Color? color]) {
    final isSelected = _filtroResultado == value;
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
      onSelected: (_) => _filterPeleas(value),
      selectedColor: (color ?? AppColors.primary).withOpacity(0.2),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildPeleasList() {
    return RefreshIndicator(
      onRefresh: _loadPeleas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: peleasFiltradas.length,
        itemBuilder: (context, index) {
          final pelea = peleasFiltradas[index];
          return _buildPeleaCard(pelea);
        },
      ),
    );
  }

  Widget _buildPeleaCard(Pelea pelea) {
    final resultadoColor = _getResultadoColor(pelea.resultado);

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
            // 🏁 HEADER CON TÍTULO Y RESULTADO - DISEÑO HTML ÉPICO
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: resultadoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: resultadoColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Combate ${pelea.id}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(pelea.fechaPelea),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (pelea.tieneUbicacionCompleta) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pelea.ubicacionCompleta,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (pelea.resultado != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: resultadoColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pelea.resultadoDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            
            // 🐓 GALLOS LADO A LADO - DISEÑO HTML ÉPICO
            const SizedBox(height: 12),
            Row(
              children: [
                // MI GALLO (verde)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.home, size: 16, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(
                              'GALLO LOCAL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pelea.miGalloNombre ?? widget.galloNombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (pelea.miGalloPropietario?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            pelea.miGalloPropietario!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (pelea.miGalloPeso != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            pelea.pesoMiGalloDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // VS
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                
                // GALLO OPONENTE (rojo)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.red[700]),
                            const SizedBox(width: 4),
                            Text(
                              'GALLO VISITANTE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pelea.oponenteGallo ?? 'Gallo rival',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (pelea.oponenteNombre?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            pelea.oponenteNombre!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (pelea.oponenteGalloPeso != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            pelea.pesoOponenteDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // 💰 INFO BADGES - PREMIO, VIDEO, DURACIÓN
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (pelea.tienePremio)
                  _buildInfoBadge(
                    '💰 ${pelea.premioDisplay}',
                    Colors.orange,
                  ),
                if (pelea.videoUrl != null)
                  GestureDetector(
                    onTap: () => _reproducirVideo(pelea.videoUrl!, pelea.titulo),
                    child: _buildInfoBadge(
                      '🎥 Video',
                      Colors.purple,
                    ),
                  ),
                if (pelea.tieneDuracion)
                  _buildInfoBadge(
                    '⏱️ ${pelea.duracionDisplay}',
                    Colors.blue,
                  ),
              ],
            ),
            
            
            // 🔧 BOTONES DE ACCIÓN
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editarPelea(pelea),
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
                    onPressed: () => _eliminarPelea(pelea),
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
  
  Widget _buildInfoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
            Icons.sports_mma,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _filtroResultado == 'todos'
                ? 'No hay peleas registradas'
                : 'No hay peleas ${_filtroResultado}s',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona + para agregar una pelea',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getResultadoColor(String? resultado) {
    switch (resultado?.toLowerCase()) {
      case 'ganada':
        return Colors.green;
      case 'perdida':
        return Colors.red;
      case 'empate':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _agregarNuevaPelea() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioPeleaScreen(
          // Pre-seleccionar el gallo actual
          galloPreseleccionado: widget.galloId,
          galloIsBloqueado: true,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadPeleas();
      }
    });
  }

  void _editarPelea(Pelea pelea) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioPeleaScreen(pelea: pelea),
      ),
    ).then((result) {
      if (result == true) {
        _loadPeleas();
      }
    });
  }

  void _eliminarPelea(Pelea pelea) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Pelea'),
        content: Text('¿Estás seguro de eliminar la pelea "${pelea.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await PeleasService.eliminarPelea(pelea.id);
                _showSuccess('Pelea eliminada exitosamente');
                _loadPeleas();
              } catch (e) {
                _showError('Error eliminando pelea');
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
      title: 'Pelea: $titulo',
    );
  }
}