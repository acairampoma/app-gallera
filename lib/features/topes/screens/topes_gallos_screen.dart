// 📁 lib/features/topes/screens/topes_gallos_screen.dart
// 🏋️ Pantalla principal de TOPES mostrando todos los gallos

import 'package:flutter/material.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/topes_service.dart';
import '../../../services/gallo_service.dart';
import '../../../services/suscripcion_service.dart'; // ✅ AGREGADO
import '../../../models/tope.dart';
import 'historial_topes_screen.dart';
import 'formulario_tope_screen.dart';
import '../../../shared/widgets/limite_interceptor.dart';
import '../../../models/suscripcion_models.dart';
import '../../../shared/constants/app_icons.dart';

class TopesGallosScreen extends StatefulWidget {
  const TopesGallosScreen({Key? key}) : super(key: key);

  @override
  State<TopesGallosScreen> createState() => _TopesGallosScreenState();
}

class _TopesGallosScreenState extends State<TopesGallosScreen> {
  // Estado principal
  List<Map<String, dynamic>> gallos = [];
  List<TopeResumenGallo> gallosConTopes = [];
  List<TopeResumenGallo> gallosFiltrados = [];
  TopeStats? estadisticas;
  bool isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // 🔥 NUEVO: Control para incluir padres generados en topes
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
    print('🏋️ === TOPES SCREEN - CARGANDO TODOS LOS GALLOS ===');
    setState(() => isLoading = true);
    
    try {
      // 1. Cargar estadísticas generales
      final statsResult = await TopesService.getEstadisticas();
      
      // 2. Cargar TODOS los gallos del usuario
      final gallosResult = await GalloService.getGallos();
      
      // 🔥 FILTRAR GALLOS SEGÚN CHECKBOX PARA TOPES
      List<Map<String, dynamic>> gallosFiltradosPorTipo = gallosResult.where((gallo) {
        final tipoRegistro = gallo['tipo_registro']?.toString();
        if (_soloPrincipales) {
          // Solo principales
          return tipoRegistro == 'principal';
        } else {
          // Principales + padres generados (NO madres)
          return tipoRegistro == 'principal' || tipoRegistro == 'padre_generado';
        }
      }).toList();
      print('🎯 Filtrando gallos: ${gallosFiltradosPorTipo.length} de ${gallosResult.length} (solo principales: $_soloPrincipales)');
      
      // 3. Para cada gallo filtrado, obtener resumen de topes
      List<TopeResumenGallo> resumenGallos = [];
      
      for (var gallo in gallosFiltradosPorTipo) {
        final galloId = gallo['id'];
        final galloNombre = gallo['nombre'] ?? 'Sin nombre';
        final galloFoto = gallo['foto_principal_url'];
        
        // Obtener topes del gallo
        final topes = await TopesService.getTopesGallo(galloId);
        print('🐓 Gallo $galloNombre (ID: $galloId) tiene ${topes.length} topes');
        
        // Calcular estadísticas del gallo
        Map<String, int> tiposCont = {
          'sparring': 0,
          'tecnica': 0,
          'resistencia': 0,
          'velocidad': 0,
        };
        
        int totalMinutos = 0;
        DateTime? ultimoTope;
        
        for (var tope in topes) {
          final tipo = tope['tipo_entrenamiento']?.toString().toLowerCase();
          if (tipo != null && tiposCont.containsKey(tipo)) {
            tiposCont[tipo] = tiposCont[tipo]! + 1;
          }
          
          final duracion = tope['duracion_minutos'] ?? 0;
          totalMinutos += duracion as int;
          
          if (ultimoTope == null && tope['fecha_tope'] != null) {
            ultimoTope = DateTime.tryParse(tope['fecha_tope']);
          }
        }
        
        final totalTopes = topes.length;
        final promedioMinutos = totalTopes > 0 
            ? (totalMinutos / totalTopes).toStringAsFixed(0)
            : '0';
        
        // Tipo más frecuente
        String tipoMasFrecuente = 'N/A';
        int maxCount = 0;
        tiposCont.forEach((tipo, count) {
          if (count > maxCount) {
            maxCount = count;
            tipoMasFrecuente = tipo;
          }
        });
        
        // Crear resumen
        resumenGallos.add(TopeResumenGallo(
          galloId: galloId,
          galloNombre: galloNombre,
          galloFoto: galloFoto,
          totalTopes: totalTopes,
          totalMinutos: totalMinutos,
          promedioMinutos: promedioMinutos,
          tipoMasFrecuente: tipoMasFrecuente,
          sparringCount: tiposCont['sparring']!,
          tecnicaCount: tiposCont['tecnica']!,
          resistenciaCount: tiposCont['resistencia']!,
          velocidadCount: tiposCont['velocidad']!,
          ultimoTope: ultimoTope,
        ));
      }
      
      setState(() {
        gallos = gallosResult;
        gallosConTopes = resumenGallos;
        gallosFiltrados = resumenGallos;
        estadisticas = statsResult != null ? TopeStats.fromJson(statsResult) : null;
        isLoading = false;
      });
      
      print('✅ Datos cargados: ${gallos.length} gallos');
      for (var resumen in resumenGallos) {
        if (resumen.totalTopes > 0) {
          print('   - ${resumen.galloNombre}: ${resumen.totalTopes} topes');
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
        gallosFiltrados = gallosConTopes;
      } else {
        gallosFiltrados = gallosConTopes.where((gallo) {
          return gallo.galloNombre.toLowerCase().contains(_searchQuery) ||
                 gallo.tipoMasFrecuente.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
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
                _buildSearchBar(),
                Expanded(
                  child: gallosFiltrados.isEmpty
                      ? _buildEmptyState()
                      : _buildGallosList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _validarYCrearTope,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 🔥 CHECKBOX PARA INCLUIR PADRES GENERADOS EN TOPES
          CheckboxListTile(
            title: const Text(
              'Solo gallos principales',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Desmarca para incluir padres generados'),
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
          return _buildGalloTopeCard(resumen);
        },
      ),
    );
  }

  Widget _buildGalloTopeCard(TopeResumenGallo resumen) {
    final Color estadoColor;
    if (resumen.totalTopes == 0) {
      estadoColor = Colors.grey;
    } else if (resumen.totalTopes >= 10) {
      estadoColor = Colors.green;
    } else if (resumen.totalTopes >= 5) {
      estadoColor = Colors.orange;
    } else {
      estadoColor = Colors.blue;
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
                        _buildMiniStat('🏋️', resumen.totalTopes.toString(), 'Total'),
                        const SizedBox(width: 12),
                        _buildMiniStat('⏱️', '${resumen.promedioMinutos}min', 'Prom'),
                        const SizedBox(width: 12),
                        if (resumen.sparringCount > 0)
                          _buildMiniStat('🥊', resumen.sparringCount.toString(), 'S', Colors.red),
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
                        resumen.totalTopes == 0 
                            ? 'Sin entrenamientos'
                            : 'Tipo principal: ${_capitalize(resumen.tipoMasFrecuente)}',
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
      child: AppIcons.galloPedigriLista(),
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _verHistorialGallo(TopeResumenGallo resumen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistorialTopesScreen(
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

  // 🔒 VALIDAR LÍMITES Y CREAR TOPE
  void _validarYCrearTope() async {
    try {
      print('🔍 [Topes] Iniciando validación de límites LOCAL...');
      
      // VALIDACIÓN LOCAL mientras arreglan el backend
      // Plan gratuito: 2 topes por gallo
      const int TOPES_POR_GALLO_GRATUITO = 2;
      
      // Contar gallos actuales del usuario
      int cantidadGallos = gallosConTopes.length;
      print('📊 [Topes] Gallos del usuario: $cantidadGallos');
      
      // Contar topes totales registrados
      int topesTotales = gallosConTopes.fold(0, (sum, gallo) => sum + gallo.totalTopes);
      print('💪 [Topes] Topes totales registrados: $topesTotales');
      
      // Calcular límite: gallos × 2
      int limiteTopes = cantidadGallos * TOPES_POR_GALLO_GRATUITO;
      print('📏 [Topes] Límite calculado: $limiteTopes ($cantidadGallos gallos × $TOPES_POR_GALLO_GRATUITO)');
      
      // Verificar si puede crear más topes
      bool puedeCrear = topesTotales < limiteTopes;
      
      print('🔍 [Topes] Resultado: puedeCrear=$puedeCrear ($topesTotales/$limiteTopes)');
      
      if (!puedeCrear) {
        print('❌ [Topes] Límite alcanzado - Mostrando popup');
        
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
                'Has alcanzado el límite de entrenamientos ($topesTotales/$limiteTopes)\n'
                'Plan gratuito: $TOPES_POR_GALLO_GRATUITO entrenamientos por gallo\n\n'
                '¿Deseas actualizar tu plan para registrar más entrenamientos?'
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
        print('❌ [Topes] Bloqueando creación - límite alcanzado');
        return; // SIEMPRE retornar, no solo cuando mounted=true
      }
      
      print('✅ [Topes] Límite OK - Creando tope');
      _crearNuevoTope();
    } catch (e) {
      print('❌ [Topes] Error en validación: $e');
      
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

  void _crearNuevoTope() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormularioTopeScreen(),
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

// Modelo para resumen de topes por gallo
class TopeResumenGallo {
  final int galloId;
  final String galloNombre;
  final String? galloFoto;
  final int totalTopes;
  final int totalMinutos;
  final String promedioMinutos;
  final String tipoMasFrecuente;
  final int sparringCount;
  final int tecnicaCount;
  final int resistenciaCount;
  final int velocidadCount;
  final DateTime? ultimoTope;

  TopeResumenGallo({
    required this.galloId,
    required this.galloNombre,
    this.galloFoto,
    required this.totalTopes,
    required this.totalMinutos,
    required this.promedioMinutos,
    required this.tipoMasFrecuente,
    required this.sparringCount,
    required this.tecnicaCount,
    required this.resistenciaCount,
    required this.velocidadCount,
    this.ultimoTope,
  });
}