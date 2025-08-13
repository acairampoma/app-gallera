// 📁 lib/features/peleas/screens/peleas_gallos_screen.dart
// 🥊 Pantalla principal de PELEAS mostrando todos los gallos

import 'package:flutter/material.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/peleas_service.dart';
import '../../../services/gallo_service.dart';
import '../../../services/suscripcion_service.dart'; // ✅ AGREGADO
import '../../../models/pelea.dart';
import 'historial_peleas_screen.dart';
import 'formulario_pelea_screen.dart';
import '../../../shared/widgets/limite_interceptor.dart';
import '../../../models/suscripcion_models.dart';

class PeleasGallosScreen extends StatefulWidget {
  const PeleasGallosScreen({Key? key}) : super(key: key);

  @override
  State<PeleasGallosScreen> createState() => _PeleasGallosScreenState();
}

class _PeleasGallosScreenState extends State<PeleasGallosScreen> {
  // Estado principal
  List<Map<String, dynamic>> gallos = [];
  List<PeleaResumenGallo> gallosConPeleas = [];
  List<PeleaResumenGallo> gallosFiltrados = [];
  PeleaStats? estadisticas;
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
    print('🥊 === PELEAS SCREEN - CARGANDO TODOS LOS GALLOS ===');
    setState(() => isLoading = true);
    
    try {
      // 1. Cargar estadísticas generales
      final statsResult = await PeleasService.getEstadisticas();
      
      // 2. Cargar TODOS los gallos del usuario
      final gallosResult = await GalloService.getGallos();
      
      // 3. Para cada gallo, obtener resumen de peleas
      List<PeleaResumenGallo> resumenGallos = [];
      
      for (var gallo in gallosResult) {
        final galloId = gallo['id'];
        final galloNombre = gallo['nombre'] ?? 'Sin nombre';
        final galloFoto = gallo['foto_principal_url'];
        
        // Obtener peleas del gallo
        final peleas = await PeleasService.getPeleasGallo(galloId);
        print('🐓 Gallo $galloNombre (ID: $galloId) tiene ${peleas.length} peleas');
        
        // Calcular estadísticas del gallo
        int ganadas = 0;
        int perdidas = 0;
        int empates = 0;
        
        for (var pelea in peleas) {
          final resultado = pelea['resultado']?.toString().toLowerCase();
          if (resultado == 'ganada') ganadas++;
          else if (resultado == 'perdida') perdidas++;
          else if (resultado == 'empate') empates++;
        }
        
        final totalPeleas = peleas.length;
        final efectividad = totalPeleas > 0 
            ? ((ganadas / totalPeleas) * 100).toStringAsFixed(1)
            : '0.0';
        
        // Crear resumen
        resumenGallos.add(PeleaResumenGallo(
          galloId: galloId,
          galloNombre: galloNombre,
          galloFoto: galloFoto,
          totalPeleas: totalPeleas,
          ganadas: ganadas,
          perdidas: perdidas,
          empates: empates,
          efectividad: efectividad,
          ultimaPelea: peleas.isNotEmpty ? peleas.first['fecha_pelea'] : null,
        ));
      }
      
      setState(() {
        gallos = gallosResult;
        gallosConPeleas = resumenGallos;
        gallosFiltrados = resumenGallos;
        estadisticas = statsResult != null ? PeleaStats.fromJson(statsResult) : null;
        isLoading = false;
      });
      
      print('✅ Datos cargados: ${gallos.length} gallos');
      for (var resumen in resumenGallos) {
        if (resumen.totalPeleas > 0) {
          print('   - ${resumen.galloNombre}: ${resumen.totalPeleas} peleas (G:${resumen.ganadas} P:${resumen.perdidas} E:${resumen.empates})');
        }
      }
      
    } catch (e) {
      print('❌ Error cargando datos: $e');
      setState(() {
        isLoading = false;
      });
      _showError('Error cargando datos: $e');
    }
  }

  void _filterGallos(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        gallosFiltrados = gallosConPeleas;
      } else {
        gallosFiltrados = gallosConPeleas.where((gallo) {
          return gallo.galloNombre.toLowerCase().contains(_searchQuery) ||
                 gallo.efectividad.contains(_searchQuery);
        }).toList();
      }
    });
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
                _buildSearchBar(),
                Expanded(
                  child: gallosFiltrados.isEmpty
                      ? _buildEmptyState()
                      : _buildGallosList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _validarYCrearPelea,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterGallos,
        decoration: InputDecoration(
          hintText: 'Buscar gallos por nombre...',
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
          final resumen = gallosFiltrados[index];
          return _buildGalloPeleaCard(resumen);
        },
      ),
    );
  }

  Widget _buildGalloPeleaCard(PeleaResumenGallo resumen) {
    final Color estadoColor;
    if (resumen.totalPeleas == 0) {
      estadoColor = Colors.grey;
    } else if (double.parse(resumen.efectividad) >= 60) {
      estadoColor = Colors.green;
    } else if (double.parse(resumen.efectividad) >= 40) {
      estadoColor = Colors.orange;
    } else {
      estadoColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _verHistorialGallo(resumen),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 🖼️ FOTO DEL GALLO
              _buildGalloImage(resumen.galloFoto),
              const SizedBox(width: 16),
              
              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resumen.galloNombre,
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
                        _buildMiniStat('🥊', resumen.totalPeleas.toString(), 'Total'),
                        const SizedBox(width: 12),
                        _buildMiniStat('🏆', resumen.ganadas.toString(), 'G', Colors.green),
                        const SizedBox(width: 8),
                        _buildMiniStat('❌', resumen.perdidas.toString(), 'P', Colors.red),
                        const SizedBox(width: 8),
                        _buildMiniStat('🤝', resumen.empates.toString(), 'E', Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: estadoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: estadoColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Efectividad: ${resumen.efectividad}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: estadoColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Botón de historial
              Column(
                children: [
                  IconButton(
                    onPressed: () => _verHistorialGallo(resumen),
                    icon: const Icon(Icons.history),
                    color: AppColors.primary,
                    iconSize: 28,
                  ),
                  Text(
                    'Historial',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String emoji, String value, String label, [Color? color]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildGalloImage(String? fotoUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
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
        size: 30,
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
            'No hay gallos registrados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registra tus gallos primero',
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

  void _verHistorialGallo(PeleaResumenGallo resumen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistorialPeleasScreen(
          galloId: resumen.galloId,
          galloNombre: resumen.galloNombre,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  // 🔒 VALIDAR LÍMITES Y CREAR PELEA
  void _validarYCrearPelea() async {
    try {
      print('🔍 [Peleas] Iniciando validación de límites LOCAL...');
      
      // VALIDACIÓN LOCAL mientras arreglan el backend
      // Plan gratuito: 2 peleas por gallo
      const int PELEAS_POR_GALLO_GRATUITO = 2;
      
      // Contar gallos actuales del usuario
      int cantidadGallos = gallosConPeleas.length;
      print('📊 [Peleas] Gallos del usuario: $cantidadGallos');
      
      // Contar peleas totales registradas
      int peleasTotales = gallosConPeleas.fold(0, (sum, gallo) => sum + gallo.totalPeleas);
      print('⚔️ [Peleas] Peleas totales registradas: $peleasTotales');
      
      // Calcular límite: gallos × 2
      int limitePeleas = cantidadGallos * PELEAS_POR_GALLO_GRATUITO;
      print('📏 [Peleas] Límite calculado: $limitePeleas ($cantidadGallos gallos × $PELEAS_POR_GALLO_GRATUITO)');
      
      // Verificar si puede crear más peleas
      bool puedeCrear = peleasTotales < limitePeleas;
      
      print('🔍 [Peleas] Resultado: puedeCrear=$puedeCrear ($peleasTotales/$limitePeleas)');
      
      if (!puedeCrear) {
        print('❌ [Peleas] Límite alcanzado - Mostrando popup');
        
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text('Límite Alcanzado', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              content: Text(
                'Has alcanzado el límite de peleas ($peleasTotales/$limitePeleas)\n'
                'Plan gratuito: $PELEAS_POR_GALLO_GRATUITO peleas por gallo\n\n'
                '¿Deseas actualizar tu plan para registrar más peleas?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/planes');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Actualizar Plan', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
        print('❌ [Peleas] Bloqueando creación - límite alcanzado');
        return; // SIEMPRE retornar, no solo cuando mounted=true
      }
      
      print('✅ [Peleas] Límite OK - Creando pelea');
      _crearNuevaPelea();
    } catch (e) {
      print('❌ [Peleas] Error en validación: $e');
      
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al validar límites. Intente nuevamente.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
        _loadData();
      }
    });
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

// Modelo para resumen de peleas por gallo
class PeleaResumenGallo {
  final int galloId;
  final String galloNombre;
  final String? galloFoto;
  final int totalPeleas;
  final int ganadas;
  final int perdidas;
  final int empates;
  final String efectividad;
  final String? ultimaPelea;

  PeleaResumenGallo({
    required this.galloId,
    required this.galloNombre,
    this.galloFoto,
    required this.totalPeleas,
    required this.ganadas,
    required this.perdidas,
    required this.empates,
    required this.efectividad,
    this.ultimaPelea,
  });
}