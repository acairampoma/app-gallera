import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../widgets/add_gallo_simple_dialog.dart';

class PedigriScreen extends StatefulWidget {
  const PedigriScreen({Key? key}) : super(key: key);

  @override
  State<PedigriScreen> createState() => _PedigriScreenState();
}

class _PedigriScreenState extends State<PedigriScreen> {
  List<dynamic> gallos = [];
  List<dynamic> razas = [];
  List<dynamic> gallosFiltrados = [];
  bool isLoading = true;
  String _searchQuery = '';
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
    try {
      // 🔥 ÉPICO: Primero intentar cargar datos guardados
      final savedGallos = await _loadSavedGallos();
      
      if (savedGallos.isNotEmpty) {
        // Si hay datos guardados, usarlos
        setState(() {
          gallos = savedGallos;
          gallosFiltrados = List.from(gallos);
        });
        print('📱 CARGADOS ${savedGallos.length} gallos guardados');
      }
      
      // Cargar razas del JSON original
      final String gallosJson = await rootBundle.loadString('lib/data/mock/gallos_mock.json');
      final data = json.decode(gallosJson);
      
      setState(() {
        // Solo cargar gallos del JSON si no hay guardados
        if (savedGallos.isEmpty) {
          gallos = data['gallos'] ?? [];
          gallosFiltrados = List.from(gallos);
          print('📁 CARGADOS ${gallos.length} gallos del JSON original');
        }
        razas = data['razas'] ?? [];
        isLoading = false;
      });
      
    } catch (e) {
      print('❌ Error loading gallos data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 💾 CARGAR GALLOS GUARDADOS
  Future<List<dynamic>> _loadSavedGallos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gallosString = prefs.getString('gallos_guardados');
      
      if (gallosString != null) {
        final gallosJson = json.decode(gallosString);
        return List<dynamic>.from(gallosJson);
      }
      return [];
    } catch (e) {
      print('❌ Error cargando gallos guardados: $e');
      return [];
    }
  }

  // 💾 GUARDAR GALLOS EN SHAREPREFERENCES
  Future<void> _saveGallos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gallosString = json.encode(gallos);
      await prefs.setString('gallos_guardados', gallosString);
      print('✅ GUARDADOS ${gallos.length} gallos en SharedPreferences');
    } catch (e) {
      print('❌ Error guardando gallos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Pedigrí',
      subtitle: 'Registro genealógico',
      currentIndex: 1,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGalloDialog(),
        backgroundColor: AppColors.primary,
        heroTag: "add_gallo",
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildStatsBar(), // 🆕 NUEVO: Mostrar estadísticas
        Expanded(
          child: gallosFiltrados.isEmpty ? _buildEmptyState() : _buildGallosList(),
        ),
      ],
    );
  }

  // 🆕 BARRA DE ESTADÍSTICAS ÉPICA
  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('📱 Total', '${gallos.length}'),
          _buildStatItem('👁️ Mostrando', '${gallosFiltrados.length}'),
          _buildStatItem('🏆 Activos', '${gallos.where((g) => g['estado'] == 'activo').length}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterGallos,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, código o raza...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterGallos('');
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
    );
  }

  Widget _buildGallosList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: gallosFiltrados.length,
        itemBuilder: (context, index) {
          final gallo = gallosFiltrados[index];
          return _buildGalloCard(gallo);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.pets,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty 
                ? 'No se encontraron gallos'
                : 'No hay gallos registrados',
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
                : 'Toca el botón + para agregar tu primer gallo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _filterGallos('');
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpiar búsqueda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGalloCard(Map<String, dynamic> gallo) {
    final raza = gallo['raza'] ?? {};
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _showGalloDetails(gallo),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 🖼️ FOTO DEL GALLO - MEJORADA PARA ASSETS
              _buildGalloImage(gallo['foto_principal']),
              const SizedBox(width: 16),
              // Información del gallo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gallo['nombre'] ?? 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // 🆕 Indicador si es nuevo gallo
                        if (_isGalloNuevo(gallo))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'NUEVO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${gallo['codigo_identificacion'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Raza: ${raza['nombre'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          '${gallo['peso'] ?? 0}kg',
                          Icons.monitor_weight,
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          gallo['color'] ?? 'N/A',
                          Icons.palette,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🖼️ WIDGET PARA MOSTRAR IMAGEN DEL GALLO
  Widget _buildGalloImage(String? fotoPath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _buildImageWidget(fotoPath),
      ),
    );
  }

  Widget _buildImageWidget(String? fotoPath) {
    if (fotoPath == null || fotoPath.isEmpty) {
      return const Icon(
        Icons.pets,
        size: 40,
        color: AppColors.primary,
      );
    }

    // 🔥 ÉPICO: Manejar tanto assets como fotos "simuladas"
    if (fotoPath.startsWith('assets/')) {
      try {
        return Image.asset(
          fotoPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.pets,
              size: 40,
              color: AppColors.primary,
            );
          },
        );
      } catch (e) {
        return const Icon(
          Icons.pets,
          size: 40,
          color: AppColors.primary,
        );
      }
    } else {
      // Para fotos que no sean assets, mostrar ícono
      return const Icon(
        Icons.pets,
        size: 40,
        color: AppColors.primary,
      );
    }
  }

  // 🆕 VERIFICAR SI ES GALLO NUEVO (creado hace menos de 24 horas)
  bool _isGalloNuevo(Map<String, dynamic> gallo) {
    try {
      final createdAt = DateTime.parse(gallo['created_at'] ?? '');
      final now = DateTime.now();
      final difference = now.difference(createdAt);
      return difference.inHours < 24;
    } catch (e) {
      return false;
    }
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showGalloDetails(Map<String, dynamic> gallo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: _buildGalloDetailContent(gallo),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGalloDetailContent(Map<String, dynamic> gallo) {
    final raza = gallo['raza'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildGalloImage(gallo['foto_principal']),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gallo['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Código: ${gallo['codigo_identificacion'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildDetailSection('Información Básica', [
          _buildDetailRow('Raza', raza['nombre'] ?? 'N/A'),
          _buildDetailRow('Peso', '${gallo['peso'] ?? 0} kg'),
          _buildDetailRow('Color', gallo['color'] ?? 'N/A'),
          _buildDetailRow('Estado', gallo['estado'] ?? 'N/A'),
        ]),
        
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditGalloDialog(gallo);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteGallo(gallo);
                },
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGalloDialog() {
    showDialog(
      context: context,
      builder: (context) => AddGalloDialog(
        razas: razas,
        gallosExistentes: gallos,
        onGalloAdded: (nuevoGallo) {
          setState(() {
            gallos.add(nuevoGallo);
            _filterGallos(_searchQuery); // Refresh filtered list
          });
          
          // 🔥 ÉPICO: GUARDAR AUTOMÁTICAMENTE
          _saveGallos();
          
          print('🎉 GALLO AGREGADO: ${nuevoGallo['nombre']}');
          print('📱 TOTAL GALLOS: ${gallos.length}');
        },
      ),
    );
  }

  void _showEditGalloDialog(Map<String, dynamic> gallo) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔧 Función de edición próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteGallo(Map<String, dynamic> gallo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ Eliminar Gallo'),
        content: Text('¿Estás seguro de eliminar a \"${gallo['nombre']}\"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                gallos.removeWhere((g) => g['id'] == gallo['id']);
                _filterGallos(_searchQuery);
              });
              
              // Guardar cambios
              _saveGallos();
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ Gallo \"${gallo['nombre']}\" eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _filterGallos(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        gallosFiltrados = List.from(gallos);
      } else {
        gallosFiltrados = gallos.where((gallo) {
          final nombre = gallo['nombre']?.toString().toLowerCase() ?? '';
          final codigo = gallo['codigo_identificacion']?.toString().toLowerCase() ?? '';
          final raza = gallo['raza']?['nombre']?.toString().toLowerCase() ?? '';
          final color = gallo['color']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          
          return nombre.contains(searchLower) ||
                 codigo.contains(searchLower) ||
                 raza.contains(searchLower) ||
                 color.contains(searchLower);
        }).toList();
      }
    });
  }
}