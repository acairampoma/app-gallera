import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../widgets/add_gallo_dialog.dart';
import '../widgets/edit_gallo_dialog.dart';
import 'add_gallo_multistep_screen.dart';
import 'edit_gallo_multistep_screen.dart';
import 'genealogy_tree_screen.dart';
import '../../../services/connection_service.dart';
import '../../../services/gallo_service.dart';
import '../../../services/suscripcion_service.dart'; // ✅ AGREGADO
import '../../../shared/widgets/limite_interceptor.dart';
import '../../../models/suscripcion_models.dart';

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
    print('🐓 === PEDIGRI SCREEN - CARGANDO DATOS REALES ===');
    setState(() => isLoading = true);
    
    try {
      // 🔥 SOLO BACKEND REAL - NO MÁS MOCK
      print('🌐 Intentando conectar al backend Railway...');
      final gallosBackend = await GalloService.getGallos();
      
      print('✅ Gallos recibidos del backend: ${gallosBackend.length}');
      
      setState(() {
        gallos = gallosBackend;
        gallosFiltrados = List.from(gallos);
        print('🎯 Gallos cargados en UI: ${gallos.length}');
      });
      
      // Cargar razas del JSON (mantener por ahora)
      final String gallosJson = await rootBundle.loadString('lib/data/mock/gallos_mock.json');
      final data = json.decode(gallosJson);
      
      setState(() {
        razas = data['razas'] ?? [];
        isLoading = false;
      });
      
      print('✅ === DATOS CARGADOS EXITOSAMENTE ===');
      
    } catch (e) {
      print('❌ === ERROR CARGANDO DATOS DEL BACKEND ===');
      print('💥 Error: $e');
      
      // 🔥 NO FALLBACK - MOSTRAR ERROR
      setState(() {
        gallos = [];
        gallosFiltrados = [];
        isLoading = false;
      });
      
      // Mostrar snackbar con error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error conectando al servidor: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: _loadData,
            ),
          ),
        );
      }
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
        onPressed: () => _validarYCrearGallo(), // 🚀 NUEVA PANTALLA CON VALIDACIÓN
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
        // 📊 SECCIÓN DE ESTADÍSTICAS SEPARADA
        _buildStatsSection(),
        const SizedBox(height: 16),
        // 🔍 BÚSQUEDA
        _buildSearchBar(),
        // 📱 LISTA DE GALLOS
        Expanded(
          child: gallosFiltrados.isEmpty ? _buildEmptyState() : _buildGallosList(),
        ),
      ],
    );
  }

  // 📊 ESTADÍSTICAS CENTRADAS - TODO EL ANCHO - VERSIÓN MEJORADA
  Widget _buildStatsSection() {
    final totalGallos = gallos.length;
    final gallosMostrados = gallosFiltrados.length;
    final gallosActivos = gallos.where((g) => g['estado'] == 'activo').length;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildMiniStatCard('📱', '$totalGallos', 'Total', Colors.blue)),
          const SizedBox(width: 8),
          Expanded(child: _buildMiniStatCard('👁️', '$gallosMostrados', 'Mostrando', Colors.green)),
          const SizedBox(width: 8),
          Expanded(child: _buildMiniStatCard('🏆', '$gallosActivos', 'Activos', Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String emoji, String value, String label, Color color) {
    return Container(
      width: double.infinity, // 🔥 OCUPAR TODO EL ANCHO DISPONIBLE
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // 🔥 MÁS PADDING
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // 🔥 BORDES MÁS REDONDEADOS
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column( // 🔥 CAMBIAR A COLUMN PARA CENTRAR VERTICALMENTE
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji, 
            style: const TextStyle(fontSize: 18), // 🔥 EMOJI MÁS GRANDE
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20, // 🔥 NÚMERO MÁS GRANDE
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
    // 🔥 MOSTRAR DATOS REALES DEL BACKEND - SIN VALORES POR DEFECTO
    final razaTexto = _mapRazaIdToDisplayName(gallo['raza_id']?.toString()) ?? 
                      gallo['raza']?.toString() ?? 
                      'Sin especificar';
    final colorTexto = gallo['color_placa'] ?? gallo['color_plumaje'] ?? gallo['color'] ?? 'Sin especificar';
    
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
              // 🖼️ FOTO DEL GALLO - MEJORADA PARA BACKEND URLs
              _buildGalloImage(gallo['foto_principal_url']),
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
                    // 🔥 RAZA CORREGIDA - CON VALOR POR DEFECTO REAL
                    Text(
                      'Raza: $razaTexto',
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
                        // 🔥 COLOR CORREGIDO - PRIORIZAR color_plumaje
                        _buildInfoChip(
                          colorTexto,
                          Icons.palette,
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // Reducido de 12 a 10
                    // 🌳 BOTÓN COMPACTO Y ELEGANTE
                    InkWell(
                      onTap: () => _showGenealogyTree(gallo),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Más compacto
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_tree, size: 14, color: Colors.green),
                            SizedBox(width: 6),
                            Text(
                              'Ver Árbol Genealógico',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
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
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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

    // 🔥 MANEJAR URLs DE CLOUDINARY Y ASSETS
    if (fotoPath.startsWith('http')) {
      // URLs de internet (Cloudinary)
      return Image.network(
        fotoPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error cargando imagen: $fotoPath - $error');
          return const Icon(
            Icons.pets,
            size: 40,
            color: AppColors.primary,
          );
        },
      );
    } else if (fotoPath.startsWith('assets/')) {
      // Assets locales
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
      // Fallback para rutas desconocidas
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
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
    // 🔥 MOSTRAR DATOS REALES DEL BACKEND - SIN VALORES POR DEFECTO
    final razaTexto = _mapRazaIdToDisplayName(gallo['raza_id']?.toString()) ?? 
                      gallo['raza']?.toString() ?? 
                      'Sin especificar';
    final colorTexto = gallo['color_placa'] ?? gallo['color_plumaje'] ?? gallo['color'] ?? 'Sin especificar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildGalloImage(gallo['foto_principal_url']),  // 🔥 CORREGIDO
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
          // 🔥 RAZA CORREGIDA - TEXTO DIRECTO
          _buildDetailRow('Raza', razaTexto),
          _buildDetailRow('Peso', '${gallo['peso'] ?? 0} kg'),
          // 🔥 COLOR CORREGIDO - MÚTIPLES FUENTES POSIBLES
          _buildDetailRow('Color', colorTexto),
          _buildDetailRow('Estado', gallo['estado'] ?? 'N/A'),
          // 🆕 CAMPOS ADICIONALES SI EXISTEN
          if (gallo['color_patas'] != null) 
            _buildDetailRow('Color Patas', gallo['color_patas'].toString()),
          if (gallo['color_placa'] != null) 
            _buildDetailRow('Color Placa', gallo['color_placa'].toString()),
          if (gallo['ubicacion_placa'] != null) 
            _buildDetailRow('Ubicación Placa', gallo['ubicacion_placa'].toString()),
          if (gallo['criador'] != null && gallo['criador'].toString().isNotEmpty) 
            _buildDetailRow('Criador', gallo['criador'].toString()),
          if (gallo['propietario_actual'] != null && gallo['propietario_actual'].toString().isNotEmpty) 
            _buildDetailRow('Propietario', gallo['propietario_actual'].toString()),
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

  // 🔒 VALIDAR LÍMITES Y CREAR GALLO
  void _validarYCrearGallo() async {
    try {
      print('🔍 [Pedigri] Iniciando validación de límites...');
      
      final validacion = await SuscripcionService.validarLimite(
        recursoTipo: RecursoTipo.gallos.value,
        galloId: null,
      );
      
      print('🔍 [Pedigri] Resultado: puedeCrear=${validacion.puedeCrear}');
      
      if (!validacion.puedeCrear) {
        print('❌ [Pedigri] Límite alcanzado - Mostrando popup');
        
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
                '${validacion.mensajeError ?? "Has alcanzado el límite de gallos"}\n\n'
                '¿Deseas actualizar tu plan para crear más gallos?'
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
        return;
      }
      
      print('✅ [Pedigri] Límite OK - Navegando a multistep');
      _navigateToAddGalloMultistep();
    } catch (e) {
      print('❌ [Pedigri] Error en validación: $e');
      
      // Cerrar loading si está abierto
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar error y permitir continuar sin validación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al validar límites. Continuando sin validación...'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // Continuar sin validación (temporal para no bloquear)
        _navigateToAddGalloMultistep();
      }
    }
  }

  // 🚀 NAVEGAR A PANTALLA MULTISTEP - VERSIÓN ÉPICA CON REFRESH COMPLETO
  void _navigateToAddGalloMultistep() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddGalloMultistepScreen(),
      ),
    );
    
    // 🔥 MANEJAR RESULTADO ÉPICO DEL FORMULARIO
    if (result != null && result is Map<String, dynamic>) {
      print('🎯 === RESULTADO DEL FORMULARIO ===');
      print('📊 Datos recibidos: ${result.keys}');
      
      // Verificar si tiene flag de refrescar lista
      if (result['action'] == 'REFRESH_LIST') {
        print('🔄 === REFRESCANDO LISTA COMPLETA DEL BACKEND ===');
        
        // MOSTRAR MENSAJE DE ÉXITO INMEDIATAMENTE
        final totalRegistros = result['total_registros_creados'] ?? 1;
        final nombreGallo = result['gallo_principal']?['nombre'] ?? 'Gallo';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ¡$nombreGallo creado! ($totalRegistros registros)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // REFRESCAR DATOS DESDE EL BACKEND PARA OBTENER LOS 3 GALLOS
        await _refreshFromBackendAfterCreate(result);
      } else {
        // Fallback: agregar solo el resultado (modo antiguo)
        setState(() {
          gallos.add(result);
          _filterGallos(_searchQuery);
        });
        
        _saveGallos();
        print('🎉 GALLO AGREGADO (MODO SIMPLE): ${result['nombre']}');
      }
    }
  }
  
  // 🔄 REFRESH ÉPICO DESPUÉS DE CREAR GALLO
  Future<void> _refreshFromBackendAfterCreate(Map<String, dynamic> resultData) async {
    try {
      print('🔄 Iniciando refresh épico...');
      
      // Mostrar indicador de carga sutil
      setState(() => isLoading = true);
      
      // Obtener datos frescos del backend
      final gallosFrescos = await GalloService.getGallos();
      
      print('✅ Gallos frescos obtenidos: ${gallosFrescos.length}');
      
      // Actualizar estado con datos frescos
      setState(() {
        gallos = gallosFrescos;
        gallosFiltrados = List.from(gallos);
        isLoading = false;
      });
      
      // Guardar en caché
      await _saveGallos();
      
      // Mostrar confirmación final
      final totalNuevos = resultData['total_registros_creados'] ?? 1;
      final galloPrincipal = resultData['gallo_principal']?['nombre'] ?? 'Gallo';
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎯 Lista actualizada: $galloPrincipal + familia genealógica ($totalNuevos gallos)'
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      print('🎉 === REFRESH ÉPICO COMPLETADO ===');
      print('📱 Total gallos actuales: ${gallos.length}');
      
    } catch (e) {
      print('❌ Error en refresh épico: $e');
      
      setState(() => isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Gallo creado, pero no se pudo actualizar la lista: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
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
            _filterGallos(_searchQuery);
          });
          
          _saveGallos();
          print('🎉 GALLO AGREGADO: ${nuevoGallo['nombre']}');
          print('📱 TOTAL GALLOS: ${gallos.length}');
        },
      ),
    );
  }

  void _showEditGalloDialog(Map<String, dynamic> gallo) async {
    // Navegar a la pantalla de edición multistep
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGalloMultistepScreen(
          gallo: gallo,
        ),
      ),
    );

    // 🔥 MANEJAR RESULTADO ÉPICO DEL FORMULARIO DE EDICIÓN - MEJORADO
    if (result != null && result is Map<String, dynamic>) {
      print('🎯 === RESULTADO DE LA EDICIÓN ===');
      print('📊 Datos recibidos: ${result.keys}');
      print('📝 Datos completos: $result');
      
      // 🔥 DETECTAR DIFERENTES TIPOS DE RESULTADO
      if (result.containsKey('action') && result['action'] == 'REFRESH_LIST') {
        print('🔄 === REFRESCANDO LISTA DESPUÉS DE EDITAR (MODO ÉPICO) ===');
        
        // MOSTRAR MENSAJE DE ÉXITO INMEDIATAMENTE
        final nombreGallo = result['gallo_actualizado']?['nombre'] ?? gallo['nombre'] ?? 'Gallo';
        final tieneExpansion = result['expansion_genealogica'] == true;
        final registrosNuevos = result['registros_nuevos_creados'] ?? 0;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tieneExpansion 
                  ? '🎉 $nombreGallo actualizado! (+$registrosNuevos registros)'
                  : '✅ $nombreGallo actualizado exitosamente!'
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        // 🔥 REFRESCAR DATOS DESDE EL BACKEND INMEDIATAMENTE
        await _refreshFromBackendAfterEdit(result);
        
      } else if (result.containsKey('success') && result['success'] == true) {
        print('🔄 === MODO DE COMPATIBILIDAD - REFRESCANDO ===');
        
        // Modo de compatibilidad: refrescar sin flags especiales
        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${gallo['nombre']} actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
      } else if (result == true) {
        print('🔄 === MODO LEGACY - REFRESCANDO ===');
        
        // Fallback: si solo retorna true (modo antiguo)
        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Gallo actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('⚠️ === RESULTADO DESCONOCIDO - REFRESCANDO POR SEGURIDAD ===');
        
        // Si no reconocemos el formato, refrescar por seguridad
        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cambios guardados'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } else {
      print('ℹ️ === NO SE RECIBIÓ RESULTADO DE LA EDICIÓN ===');
      // Si no hay resultado, asumir que no hubo cambios
    }
  }
  
  // 🔄 REFRESH ÉPICO DESPUÉS DE EDITAR GALLO
  Future<void> _refreshFromBackendAfterEdit(Map<String, dynamic> resultData) async {
    try {
      print('🔄 Iniciando refresh épico después de editar...');
      
      // Mostrar indicador de carga sutil
      setState(() => isLoading = true);
      
      // Obtener datos frescos del backend
      final gallosFrescos = await GalloService.getGallos();
      
      print('✅ Gallos frescos obtenidos: ${gallosFrescos.length}');
      
      // Actualizar estado con datos frescos
      setState(() {
        gallos = gallosFrescos;
        gallosFiltrados = List.from(gallos);
        isLoading = false;
      });
      
      // Guardar en caché
      await _saveGallos();
      
      // Mostrar confirmación final
      final nombreGallo = resultData['gallo_actualizado']?['nombre'] ?? 'Gallo';
      final tieneExpansion = resultData['expansion_genealogica'] == true;
      final registrosNuevos = resultData['registros_nuevos_creados'] ?? 0;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tieneExpansion
                ? '🎯 Lista actualizada: $nombreGallo + expansión genealógica ($registrosNuevos nuevos)'
                : '🎯 Lista actualizada: $nombreGallo modificado'
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      print('🎉 === REFRESH EDICIÓN ÉPICO COMPLETADO ===');
      print('📱 Total gallos actuales: ${gallos.length}');
      
    } catch (e) {
      print('❌ Error en refresh épico después de editar: $e');
      
      setState(() => isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Gallo actualizado, pero no se pudo refrescar la lista: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
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
            onPressed: () async {
              Navigator.pop(context);
              
              // Mostrar loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Intentar eliminar en el backend
                final success = await GalloService.deleteGallo(gallo['id']);
                
                if (success) {
                  setState(() {
                    gallos.removeWhere((g) => g['id'] == gallo['id']);
                    _filterGallos(_searchQuery);
                  });
                  
                  // Guardar cambios localmente también
                  await _saveGallos();
                  
                  if (mounted) {
                    Navigator.pop(context); // Cerrar loading
                    
                    final connectionService = ConnectionService();
                    final isOffline = connectionService.isOffline;
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isOffline 
                            ? '🗑️ Gallo \"${gallo['nombre']}\" eliminado localmente. Se sincronizará cuando haya conexión.'
                            : '🗑️ Gallo \"${gallo['nombre']}\" eliminado exitosamente'
                        ),
                        backgroundColor: isOffline ? Colors.orange : Colors.red,
                        duration: Duration(seconds: isOffline ? 4 : 2),
                      ),
                    );
                  }
                } else {
                  throw Exception('No se pudo eliminar el gallo');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Cerrar loading
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error al eliminar: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showGenealogyTree(Map<String, dynamic> gallo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenealogyTreeScreen(
          galloSeleccionado: gallo,
          todosLosGallos: gallos,
        ),
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

  // 🔥 HELPER: CONVERTIR RAZA_ID DEL BACKEND A NOMBRE LEGIBLE
  String? _mapRazaIdToDisplayName(String? razaId) {
    if (razaId == null || razaId.isEmpty) return null;
    
    // Mapear IDs del backend a nombres legibles
    switch (razaId.toUpperCase()) {
      case 'KELSO_AMERICANO': return 'Kelso';
      case 'HATCH_AMERICANO': return 'Hatch';
      case 'ALBANY_AMERICANO': return 'Albany';
      case 'SWEATER_AMERICANO': return 'Sweater';
      case 'RADIO_AMERICANO': return 'Radio';
      case 'CLARET_AMERICANO': return 'Claret';
      case 'LAW_AMERICANO': return 'Law';
      case 'GREY_AMERICANO': return 'Grey';
      case 'ROUNDHEAD_AMERICANO': return 'Roundhead';
      case 'BUTCHER_AMERICANO': return 'Butcher';
      case 'MCLEAN_AMERICANO': return 'McLean';
      case 'WHITEHACKLE_AMERICANO': return 'Whitehackle';
      case 'ASIL_PERUANO': return 'Asil';
      case 'SHAMO_JAPONES': return 'Shamo';
      case 'NAVAJERO': return 'Thai';
      default: 
        // Si no coincide con ningún mapeo conocido, mostrar el ID tal como viene
        return razaId.replaceAll('_', ' ').toLowerCase().split(' ').map((word) => 
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }
}