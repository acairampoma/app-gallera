// 📁 lib/features/topes/screens/topes_screen_real.dart
// 🏋️ Pantalla principal de TOPES - DATOS REALES DEL BACKEND

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/topes_service.dart';
import '../../../services/gallo_service.dart';
import '../../../models/tope.dart';
import 'formulario_tope_screen.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/limite_interceptor.dart'; // 🛡️ VALIDACIÓN DE LÍMITES

class TopesScreenReal extends StatefulWidget {
  const TopesScreenReal({Key? key}) : super(key: key);

  @override
  State<TopesScreenReal> createState() => _TopesScreenRealState();
}

class _TopesScreenRealState extends State<TopesScreenReal> {
  // Estado principal
  List<Map<String, dynamic>> gallos = [];
  List<Tope> topes = [];
  List<Tope> topesFiltrados = [];
  TopeStats? estadisticas;
  bool isLoading = true;
  String _searchQuery = '';
  String _filtroTipo = 'todos'; // todos, sparring, tecnica, resistencia, velocidad
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
    print('🏋️ === TOPES SCREEN - CARGANDO DATOS REALES ===');
    setState(() => isLoading = true);
    
    try {
      // 1. Cargar estadísticas de topes
      final statsResult = await TopesService.getEstadisticas();
      
      // 2. Cargar gallos del usuario
      final gallosResult = await GalloService.getGallos();
      
      // 3. Cargar todos los topes
      final topesResult = await TopesService.getTopes(limit: 1000);
      
      setState(() {
        gallos = gallosResult;
        topes = topesResult.map((t) => Tope.fromJson(t)).toList();
        topesFiltrados = topes;
        estadisticas = statsResult != null ? TopeStats.fromJson(statsResult) : null;
        isLoading = false;
      });
      
      print('✅ Datos cargados: ${gallos.length} gallos, ${topes.length} topes');
      
    } catch (e) {
      print('❌ Error cargando datos: $e');
      setState(() {
        isLoading = false;
      });
      _showError('Error cargando datos: $e');
    }
  }

  void _filterTopes() {
    setState(() {
      topesFiltrados = topes.where((tope) {
        // Filtro por búsqueda
        final searchMatch = _searchQuery.isEmpty ||
            tope.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            _getGalloNombre(tope.galloId).toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Filtro por tipo
        final tipoMatch = _filtroTipo == 'todos' ||
            tope.tipoEntrenamiento == _filtroTipo;
        
        return searchMatch && tipoMatch;
      }).toList();
      
      // Ordenar por fecha descendente
      topesFiltrados.sort((a, b) => b.fechaTope.compareTo(a.fechaTope));
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
      title: '🏋️ Entrenamientos (Topes)',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsCards(),
                _buildFilters(),
                Expanded(
                  child: topesFiltrados.isEmpty
                      ? _buildEmptyState()
                      : _buildTopesList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearNuevoTope,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Tope'),
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
              '🏋️', 
              estadisticas!.totalTopes.toString(),
              'Total Topes',
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '📅', 
              estadisticas!.topesEsteMes.toString(),
              'Este Mes',
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '⏱️', 
              '${estadisticas!.promedioDuracion.toStringAsFixed(0)}min',
              'Promedio',
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '🥊', 
              estadisticas!.tiposEntrenamiento['sparring']?.toString() ?? '0',
              'Sparring',
              Colors.red,
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
              _filterTopes();
            },
            decoration: InputDecoration(
              hintText: 'Buscar por título o gallo...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery = '';
                        _filterTopes();
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
          
          // Filtros por tipo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('todos', 'Todos', Icons.fitness_center),
                const SizedBox(width: 8),
                _buildFilterChip('sparring', 'Sparring', Icons.sports_mma),
                const SizedBox(width: 8),
                _buildFilterChip('tecnica', 'Técnica', Icons.psychology),
                const SizedBox(width: 8),
                _buildFilterChip('resistencia', 'Resistencia', Icons.directions_run),
                const SizedBox(width: 8),
                _buildFilterChip('velocidad', 'Velocidad', Icons.speed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _filtroTipo == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _filtroTipo = value;
          _filterTopes();
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildTopesList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: topesFiltrados.length,
        itemBuilder: (context, index) {
          final tope = topesFiltrados[index];
          return _buildTopeCard(tope);
        },
      ),
    );
  }

  Widget _buildTopeCard(Tope tope) {
    final galloNombre = _getGalloNombre(tope.galloId);
    final tipoColor = _getTipoColor(tope.tipoEntrenamiento);
    final galloData = gallos.firstWhere(
      (g) => g['id'] == tope.galloId, 
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
            // Header con gallo y fecha
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
                
                // Tipo de entrenamiento
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tipoColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tope.tipoEntrenamiento?.toUpperCase() ?? 'N/A',
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
            
            // Detalles del tope
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(tope.fechaTope),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Spacer(),
                if (tope.duracionMinutos != null) ...[
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${tope.duracionMinutos}min',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ],
            ),
            
            if (tope.descripcion?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                tope.descripcion!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            if (tope.videoUrl != null) ...[
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
                    onPressed: () => _editarTope(tope),
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
                    onPressed: () => _eliminarTope(tope),
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
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.fitness_center,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty 
                ? 'No se encontraron topes'
                : 'No hay entrenamientos registrados',
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
                : 'Comienza registrando tu primer entrenamiento',
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

  Color _getTipoColor(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'sparring':
        return Colors.red;
      case 'tecnica':
        return Colors.blue;
      case 'resistencia':
        return Colors.green;
      case 'velocidad':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _crearNuevoTope() async {
    // 🛡️ VALIDAR LÍMITES ANTES DE ABRIR FORMULARIO
    if (gallos.isEmpty) {
      _showError('Necesitas tener al menos un gallo registrado para crear topes');
      return;
    }

    // Usar el primer gallo como referencia para validación
    final galloReferencia = gallos.first['id'] as int;
    
    // Validar límite de topes por gallo
    final puedeCrear = await validarLimiteManual(
      context,
      recursoTipo: RecursoTipo.topes,
      galloId: galloReferencia,
    );

    if (puedeCrear) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FormularioTopeScreen(),
        ),
      ).then((result) {
        if (result == true) {
          _loadData(); // Recargar datos
        }
      });
    }
  }

  void _editarTope(Tope tope) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioTopeScreen(tope: tope),
      ),
    ).then((result) {
      if (result == true) {
        _loadData(); // Recargar datos
      }
    });
  }

  void _eliminarTope(Tope tope) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tope'),
        content: Text('¿Estás seguro de eliminar el entrenamiento "${tope.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _confirmarEliminarTope(tope),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminarTope(Tope tope) async {
    Navigator.pop(context); // Cerrar diálogo
    
    try {
      await TopesService.eliminarTope(tope.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrenamiento eliminado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData(); // Recargar datos
    } catch (e) {
      _showError('Error eliminando tope: $e');
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