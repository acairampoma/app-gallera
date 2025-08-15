// 📁 lib/features/vacunas/screens/vacunas_screen_real.dart
// 💉 Pantalla principal de vacunas - DATOS REALES DEL BACKEND

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/vacunas_service.dart';
import '../../../services/gallo_service.dart';
import '../../../services/suscripcion_service.dart'; // ✅ AGREGADO
import '../../../models/vacuna.dart';
import 'historial_vacunas_screen.dart';
import 'formulario_vacuna_screen.dart';
import '../widgets/registro_rapido_dialog.dart';
import '../../../shared/widgets/limite_interceptor.dart';
import '../../../models/suscripcion_models.dart';
import '../../../shared/constants/app_icons.dart';

class VacunasScreenReal extends StatefulWidget {
  const VacunasScreenReal({Key? key}) : super(key: key);

  @override
  State<VacunasScreenReal> createState() => _VacunasScreenRealState();
}

class _VacunasScreenRealState extends State<VacunasScreenReal> {
  // Estado principal
  List<Map<String, dynamic>> gallos = [];
  List<VacunaResumenGallo> gallosConVacunas = [];
  List<VacunaResumenGallo> gallosFiltrados = [];
  VacunaStats? estadisticas;
  bool isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // 🔥 NUEVO: Control para filtrar solo gallos principales
  bool _soloPrincipales = true; // Por defecto marcado

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
    print('💉 === VACUNAS SCREEN - CARGANDO DATOS REALES ===');
    setState(() => isLoading = true);
    
    try {
      // 1. Cargar estadísticas generales
      final statsResult = await VacunasService.getEstadisticas();
      
      // 2. Cargar gallos del usuario
      final gallosResult = await GalloService.getGallos();
      
      // 🔥 FILTRAR GALLOS SEGÚN CHECKBOX
      List<Map<String, dynamic>> gallosFiltradosPorTipo = gallosResult;
      if (_soloPrincipales) {
        // Filtrar solo gallos principales (tipo_registro == "principal")
        gallosFiltradosPorTipo = gallosResult.where((gallo) {
          final tipoRegistro = gallo['tipo_registro']?.toString();
          // PRINCIPALES = tipo_registro == "principal"
          return tipoRegistro == 'principal';
        }).toList();
        print('🎯 Filtrando solo principales: ${gallosFiltradosPorTipo.length} de ${gallosResult.length}');
      }
      
      // 3. Para cada gallo filtrado, obtener resumen de vacunas
      List<VacunaResumenGallo> resumenGallos = [];
      
      for (var gallo in gallosFiltradosPorTipo) {
        final galloId = gallo['id'];
        final galloNombre = gallo['nombre'] ?? 'Sin nombre';
        
        // Obtener historial y próximas vacunas del gallo
        final historial = await VacunasService.getHistorialGallo(galloId);
        final proximas = await VacunasService.getProximasVacunas(diasAdelante: 365);
        
        // Filtrar próximas vacunas para este gallo
        final proximasGallo = proximas
            .where((p) => p['gallo_id'] == galloId)
            .map((p) => ProximaVacuna.fromJson(p))
            .toList();
        
        // Convertir historial a objetos Vacuna
        final historialVacunas = historial
            .map((h) => Vacuna.fromJson(h))
            .toList();
        
        // Crear resumen
        final resumen = VacunaHelper.crearResumenFromHistorial(
          galloId,
          galloNombre,
          historialVacunas,
          proximasGallo,
        );
        
        resumenGallos.add(resumen);
      }
      
      setState(() {
        gallos = gallosResult;
        gallosConVacunas = resumenGallos;
        gallosFiltrados = resumenGallos;
        estadisticas = statsResult != null ? VacunaStats.fromJson(statsResult) : null;
        isLoading = false;
      });
      
      print('✅ Datos cargados: ${gallos.length} gallos, ${estadisticas?.totalVacunas ?? 0} vacunas');
      
    } catch (e) {
      print('❌ Error cargando datos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterGallos(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        gallosFiltrados = gallosConVacunas;
      } else {
        gallosFiltrados = gallosConVacunas.where((gallo) {
          return gallo.galloNombre.toLowerCase().contains(_searchQuery) ||
                 gallo.estadoTexto.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '💉 Control de Vacunas',
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
        onPressed: _validarYRegistrarVacuna,
        icon: const Icon(Icons.add),
        label: const Text('Registrar Vacunas'),
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
              '🐓', 
              estadisticas!.totalVacunas.toString(),
              'Total Vacunas',
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '📅', 
              estadisticas!.vacunasEsteMes.toString(),
              'Este Mes',
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '⚠️', 
              estadisticas!.proximasVacunas.toString(),
              'Próximas',
              Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '🔴', 
              estadisticas!.vacunasVencidas.toString(),
              'Vencidas',
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
          Text(
            emoji, 
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
      child: Column(
        children: [
          // 🔥 CHECKBOX PARA FILTRAR SOLO PRINCIPALES
          CheckboxListTile(
            title: const Text(
              'Solo gallos principales',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Ocultar padres/madres generados'),
            value: _soloPrincipales,
            activeColor: AppColors.primary,
            onChanged: (bool? value) {
              setState(() {
                _soloPrincipales = value ?? true;
              });
              _loadData(); // Recargar datos con el nuevo filtro
            },
          ),
          const SizedBox(height: 8),
          // BARRA DE BÚSQUEDA
          TextField(
            controller: _searchController,
            onChanged: _filterGallos,
            decoration: InputDecoration(
              hintText: 'Buscar gallos por nombre o estado...',
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
        ],
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
          return _buildGalloVacunaCard(resumen);
        },
      ),
    );
  }

  Widget _buildGalloVacunaCard(VacunaResumenGallo resumen) {
    final estadoColor = _getEstadoColor(resumen.estadoGeneral);
    final galloData = gallos.firstWhere(
      (g) => g['id'] == resumen.galloId, 
      orElse: () => {},
    );

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
              _buildGalloImage(galloData['foto_principal_url']),
              const SizedBox(width: 16),
              
              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y código del gallo
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            resumen.galloNombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Indicador de estado
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: estadoColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${resumen.vacunasAlDia}/${resumen.totalVacunas}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Estado de vacunas
                    Text(
                      resumen.estadoTexto,
                      style: TextStyle(
                        fontSize: 14,
                        color: estadoColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Barra de progreso
                    LinearProgressIndicator(
                      value: resumen.porcentajeCumplimiento / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(estadoColor),
                    ),
                    const SizedBox(height: 8),
                    
                    // SOLO BOTÓN HISTORIAL
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _verHistorialGallo(resumen),
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text('Ver Historial de Vacunas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[700],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
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

  Widget _buildGalloImage(String? fotoUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[300]!),
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
      child: AppIcons.galloPedigriLista(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.vaccines,
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
                : 'Registra gallos primero para poder vacunarlos',
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

  void _verHistorialGallo(VacunaResumenGallo resumen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistorialVacunasScreen(
          galloId: resumen.galloId,
          galloNombre: resumen.galloNombre,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadData(); // Recargar si hubo cambios
      }
    });
  }

  void _agregarVacuna(int galloId, String galloNombre) {
    print('🚀 Navegando al formulario de vacuna para: $galloNombre (ID: $galloId)');
    
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormularioVacunaScreen(
            galloId: galloId,
            galloNombre: galloNombre,
          ),
        ),
      ).then((result) {
        print('📝 Resultado del formulario: $result');
        if (result == true) {
          print('✅ Recargando datos después de agregar vacuna');
          _loadData(); // Recargar si se agregó una vacuna
        }
      });
    } catch (e) {
      print('❌ Error navegando al formulario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error abriendo formulario: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔒 VALIDAR LÍMITES Y REGISTRAR VACUNA
  void _validarYRegistrarVacuna() async {
    try {
      print('🔍 [Vacunas] Iniciando validación de límites LOCAL...');
      
      // VALIDACIÓN LOCAL mientras arreglan el backend
      // Plan gratuito: 2 vacunas por gallo
      const int VACUNAS_POR_GALLO_GRATUITO = 2;
      
      // Contar gallos actuales del usuario
      int cantidadGallos = gallos.length;
      print('📊 [Vacunas] Gallos del usuario: $cantidadGallos');
      
      // Contar vacunas totales registradas
      int vacunasTotales = gallosConVacunas.fold(0, (sum, gallo) => sum + gallo.totalVacunas);
      print('💉 [Vacunas] Vacunas totales registradas: $vacunasTotales');
      
      // Calcular límite: gallos × 2
      int limiteVacunas = cantidadGallos * VACUNAS_POR_GALLO_GRATUITO;
      print('📏 [Vacunas] Límite calculado: $limiteVacunas ($cantidadGallos gallos × $VACUNAS_POR_GALLO_GRATUITO)');
      
      // Verificar si puede crear más vacunas
      bool puedeCrear = vacunasTotales < limiteVacunas;
      
      print('🔍 [Vacunas] Resultado: puedeCrear=$puedeCrear ($vacunasTotales/$limiteVacunas)');
      
      if (!puedeCrear) {
        print('❌ [Vacunas] Límite alcanzado - Mostrando popup');
        
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
                'Has alcanzado el límite de vacunas ($vacunasTotales/$limiteVacunas)\n'
                'Plan gratuito: $VACUNAS_POR_GALLO_GRATUITO vacunas por gallo\n\n'
                '¿Deseas actualizar tu plan para registrar más vacunas?'
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
        print('❌ [Vacunas] Bloqueando creación - límite alcanzado');
        return; // SIEMPRE retornar, no solo cuando mounted=true
      }
      
      print('✅ [Vacunas] Límite OK - Registrando vacuna');
      _showRegistroRapido();
    } catch (e) {
      print('❌ [Vacunas] Error en validación: $e');
      
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

  void _showRegistroRapido() {
    showDialog(
      context: context,
      builder: (context) => const RegistroRapidoDialog(),
    ).then((result) {
      if (result == true) {
        _loadData(); // Recargar si se registraron vacunas
      }
    });
  }
}