// 📁 lib/features/peleas/screens/peleas_screen_real.dart
// 🥊 Pantalla principal de PELEAS - DATOS REALES DEL BACKEND

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/peleas_service.dart';
import '../../../services/gallo_service.dart';
import '../../../models/pelea.dart';
import 'formulario_pelea_screen.dart';
import 'package:intl/intl.dart';

class PeleasScreenReal extends StatefulWidget {
  const PeleasScreenReal({Key? key}) : super(key: key);

  @override
  State<PeleasScreenReal> createState() => _PeleasScreenRealState();
}

class _PeleasScreenRealState extends State<PeleasScreenReal> {
  // Estado principal
  List<Map<String, dynamic>> gallos = [];
  List<Pelea> peleas = [];
  List<Pelea> peleasFiltradas = [];
  PeleaStats? estadisticas;
  bool isLoading = true;
  String _searchQuery = '';
  String _filtroResultado = 'todos'; // todos, ganada, perdida, empate
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('🥊 === PELEAS SCREEN - CARGANDO DATOS REALES ===');
    setState(() => isLoading = true);
    
    try {
      // 1. Cargar estadísticas de peleas
      final statsResult = await PeleasService.getEstadisticas();
      
      // 2. Cargar gallos del usuario
      final gallosResult = await GalloService.getGallos();
      
      // 3. Cargar todas las peleas
      final peleasResult = await PeleasService.getPeleas(limit: 1000);
      
      setState(() {
        gallos = gallosResult;
        peleas = peleasResult.map((p) => Pelea.fromJson(p)).toList();
        peleasFiltradas = peleas;
        estadisticas = statsResult != null ? PeleaStats.fromJson(statsResult) : null;
        isLoading = false;
      });
      
      print('✅ Datos cargados: ${gallos.length} gallos, ${peleas.length} peleas');
      
    } catch (e) {
      print('❌ Error cargando datos: $e');
      setState(() {
        isLoading = false;
      });
      _showError('Error cargando datos: $e');
    }
  }

  void _filterPeleas() {
    setState(() {
      peleasFiltradas = peleas.where((pelea) {
        // Filtro por búsqueda
        final searchMatch = _searchQuery.isEmpty ||
            pelea.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            _getGalloNombre(pelea.galloId).toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (pelea.oponenteNombre?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        // Filtro por resultado
        final resultadoMatch = _filtroResultado == 'todos' ||
            pelea.resultado == _filtroResultado;
        
        return searchMatch && resultadoMatch;
      }).toList();
      
      // Ordenar por fecha descendente
      peleasFiltradas.sort((a, b) => b.fechaPelea.compareTo(a.fechaPelea));
    });
  }

  String _getGalloNombre(int galloId) {
    final gallo = gallos.firstWhere(
      (g) => g['id'] == galloId, 
      orElse: () => {'nombre': 'Gallo #$galloId'},
    );
    return gallo['nombre'] ?? 'Gallo #$galloId';
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '🥊 Registro de Peleas',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsCards(),
                _buildFilters(),
                Expanded(
                  child: peleasFiltradas.isEmpty
                      ? _buildEmptyState()
                      : _buildPeleasList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearNuevaPelea,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Pelea'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildStatsCards() {
    if (estadisticas == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '🥊', 
              estadisticas!.totalPeleas.toString(),
              'Total Peleas',
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '🏆', 
              estadisticas!.ganadas.toString(),
              'Ganadas',
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '❌', 
              estadisticas!.perdidas.toString(),
              'Perdidas',
              Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '📊', 
              '${estadisticas!.efectividad.toStringAsFixed(1)}%',
              'Efectividad',
              Colors.blue,
            ),
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
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            onChanged: (value) {
              _searchQuery = value;
              _filterPeleas();
            },
            decoration: InputDecoration(
              hintText: 'Buscar por título, gallo u oponente...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery = '';
                        _filterPeleas();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 12),
          
          // Filtros por resultado
          SingleChildScrollView(
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
        ],
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
      onSelected: (selected) {
        setState(() {
          _filtroResultado = value;
          _filterPeleas();
        });
      },
      selectedColor: (color ?? AppColors.primary).withOpacity(0.2),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildPeleasList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: peleasFiltradas.length,
        itemBuilder: (context, index) {
          final pelea = peleasFiltradas[index];
          return _buildPeleaCard(pelea);
        },
      ),
    );
  }

  Widget _buildPeleaCard(Pelea pelea) {
    final galloNombre = _getGalloNombre(pelea.galloId);
    final resultadoColor = _getResultadoColor(pelea.resultado);
    final galloData = gallos.firstWhere(
      (g) => g['id'] == pelea.galloId, 
      orElse: () => {},
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con resultado
            Row(
              children: [
                // Foto del gallo
                _buildGalloImage(galloData['foto_principal_url']),
                const SizedBox(width: 12),
                
                // Info principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pelea.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        galloNombre,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                
                // Resultado
                if (pelea.resultado != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: resultadoColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pelea.resultado!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Fecha y ubicación
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(pelea.fechaPelea),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Spacer(),
                if (pelea.ubicacion?.isNotEmpty == true) ...[
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      pelea.ubicacion!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            
            // Información del oponente
            if (pelea.oponenteNombre?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vs. ${pelea.oponenteNombre}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (pelea.oponenteGallo?.isNotEmpty == true)
                            Text(
                              'Gallo: ${pelea.oponenteGallo}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Descripción
            if (pelea.descripcion?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                pelea.descripcion!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Notas del resultado
            if (pelea.notasResultado?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: resultadoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: resultadoColor.withOpacity(0.3)),
                ),
                child: Text(
                  pelea.notasResultado!,
                  style: TextStyle(
                    color: resultadoColor.withOpacity(0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            // Video
            if (pelea.videoUrl != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.videocam, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Video disponible',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editarPelea(pelea),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[600],
                      side: BorderSide(color: Colors.blue[300]!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _eliminarPelea(pelea),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      side: BorderSide(color: Colors.red[300]!),
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

  Widget _buildGalloImage(String? fotoUrl) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: fotoUrl != null && fotoUrl.isNotEmpty
            ? Image.network(
                fotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.pets,
        color: Colors.grey,
        size: 25,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.sports_mma,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty 
                ? 'No se encontraron peleas'
                : 'No hay peleas registradas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Intenta con otros términos de búsqueda'
                : 'Comienza registrando tu primera pelea',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
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

  void _crearNuevaPelea() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormularioPeleaScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _loadData(); // Recargar datos
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
        _loadData(); // Recargar datos
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
            onPressed: () => _confirmarEliminarPelea(pelea),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminarPelea(Pelea pelea) async {
    Navigator.pop(context); // Cerrar diálogo
    
    try {
      await PeleasService.eliminarPelea(pelea.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pelea eliminada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData(); // Recargar datos
    } catch (e) {
      _showError('Error eliminando pelea: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}