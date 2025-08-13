// 📄🐓 TAB DE DOCUMENTOS ÉPICO - LISTA DE GALLOS CON EXPORT PDF
import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart' as custom_error;
import '../../../services/gallo_service.dart';
import '../services/reportes_service.dart';
import '../models/documentos_model.dart';
import '../../../services/pdf_download_service.dart';

class DocumentosTab extends StatefulWidget {
  const DocumentosTab({super.key});

  @override
  State<DocumentosTab> createState() => _DocumentosTabState();
}

class _DocumentosTabState extends State<DocumentosTab>
    with TickerProviderStateMixin {
  
  final ReportesService _reportesService = ReportesService();
  
  // 📊 DATOS
  List<GalloDocumento> _gallos = [];
  List<GalloDocumento> _gallosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  
  // 🔍 BÚSQUEDA
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // 📊 ESTADÍSTICAS
  int _totalGallos = 0;
  double _efectividadPromedio = 0.0;
  
  // 🎨 ANIMACIONES
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _loadGallos();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  // 🚀 CARGAR GALLOS
  Future<void> _loadGallos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      print('📄 Cargando gallos para documentos...');
      
      // Usar el servicio existente de gallos (método estático)
      final gallosData = await GalloService.getGallos();
      
      print('📄 Gallos recibidos: ${gallosData.length}');
      
      setState(() {
        _gallos = gallosData.map((gallo) {
          try {
            return GalloDocumento.fromJson(gallo);
          } catch (e) {
            print('⚠️ Error parseando gallo: $e');
            print('⚠️ Datos del gallo: $gallo');
            // Crear un gallo básico si falla el parseo
            return GalloDocumento(
              id: gallo['id'] ?? 0,
              nombre: gallo['nombre'] ?? 'Sin nombre',
              codigo: gallo['codigo_identificacion'] ?? gallo['codigo'] ?? 'SIN-CODIGO',
              totalPeleas: 0,
              peleasGanadas: 0,
              efectividad: 0.0,
              ingresosTotales: 0.0,
              estado: gallo['estado'] ?? 'activo',
            );
          }
        }).toList();
        _gallosFiltrados = List.from(_gallos);
        _totalGallos = _gallos.length;
        _efectividadPromedio = _calcularEfectividadPromedio();
        _isLoading = false;
      });
      
      _fadeController.forward();
      
    } catch (e) {
      print('❌ Error cargando gallos: $e');
      setState(() {
        _error = 'Error cargando gallos: $e';
        _isLoading = false;
      });
    }
  }
  
  // 📊 CALCULAR EFECTIVIDAD PROMEDIO
  double _calcularEfectividadPromedio() {
    if (_gallos.isEmpty) return 0.0;
    
    double suma = 0.0;
    int contador = 0;
    
    for (var gallo in _gallos) {
      if (gallo.totalPeleas > 0) {
        suma += gallo.efectividad;
        contador++;
      }
    }
    
    return contador > 0 ? suma / contador : 0.0;
  }
  
  // 🔍 FILTRAR GALLOS
  void _filterGallos(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _gallosFiltrados = List.from(_gallos);
      } else {
        _gallosFiltrados = _gallos.where((gallo) {
          return gallo.nombre.toLowerCase().contains(_searchQuery) ||
                 gallo.codigo.toLowerCase().contains(_searchQuery) ||
                 (gallo.raza?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();
      }
    });
  }
  
  // 📥 EXPORTAR FICHA PDF
  Future<void> _exportarFicha(GalloDocumento gallo) async {
    try {
      print('🔥 ===== INICIANDO EXPORTACIÓN PDF =====');
      print('📥 Gallo: ${gallo.nombre} (ID: ${gallo.id})');
      print('📊 Efectividad: ${gallo.efectividad}%');
      print('💰 Ingresos: ${gallo.ingresosFormateados}');
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Generando ficha de ${gallo.nombre}...'),
              const SizedBox(height: 8),
              Text(
                'ID: ${gallo.id}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
      
      print('📡 Llamando API de exportar ficha...');
      
      // Llamar API real de exportar
      final response = await _reportesService.exportarFichaGallo(gallo.id);
      
      print('✅ Respuesta de API recibida');
      print('📄 Datos para PDF: ${response.keys.toList()}');
      
      Navigator.of(context).pop(); // Cerrar loading
      
      // 🔥 VERIFICAR SI TENEMOS PDF GENERADO
      if (response['pdf_available'] == true && response['pdf_base64'] != null) {
        print('🔥 ¡PDF GENERADO EXITOSAMENTE!');
        print('📄 PDF Base64 disponible: ${response['pdf_base64'].toString().length} chars');
        
        // Mostrar diálogo con opción de descarga
        _mostrarDialogoPDFListo(response, gallo.nombre);
        
      } else if (response['pdf_url'] != null) {
        print('🔗 URL del PDF: ${response['pdf_url']}');
        _abrirPDF(response['pdf_url'], gallo.nombre);
        
      } else {
        print('📊 PDF no disponible, mostrando datos:');
        print('   - Gallo: ${response['data']['gallo']['nombre']}');
        print('   - Estadísticas: ${response['data']['estadisticas']}');
        
        // Fallback: mostrar datos en diálogo
        _mostrarDatosFicha(response['data'], gallo.nombre);
      }
      
      // Mostrar éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('📥 Ficha de "${gallo.nombre}" generada'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Ver PDF',
              textColor: Colors.white,
              onPressed: () {
                print('👆 Usuario presionó VER PDF');
                print('📄 Mostrando ficha de ${gallo.nombre}');
                
                if (response['pdf_url'] != null) {
                  _abrirPDF(response['pdf_url'], gallo.nombre);
                } else {
                  _mostrarDatosFicha(response['data'], gallo.nombre);
                }
              },
            ),
          ),
        );
      }
      
    } catch (e) {
      print('❌ ERROR EXPORTANDO FICHA: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      
      Navigator.of(context).pop(); // Cerrar loading si hay error
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Error exportando ficha', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${e.toString()}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
  
  // 🔗 ABRIR PDF EN NAVEGADOR O VISOR
  void _abrirPDF(String pdfUrl, String nombreGallo) {
    print('🌐 Abriendo PDF en navegador/visor...');
    print('🔗 URL: $pdfUrl');
    
    // Aquí se puede usar url_launcher o pdf_viewer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📄 Abriendo PDF de $nombreGallo...'),
        backgroundColor: Colors.blue[600],
      ),
    );
  }
  
  // 📊 MOSTRAR DATOS DE LA FICHA (TEMPORAL)
  void _mostrarDatosFicha(Map<String, dynamic> data, String nombreGallo) {
    print('📋 Mostrando datos de la ficha en diálogo...');
    
    final gallo = data['gallo'] ?? {};
    final estadisticas = data['estadisticas'] ?? {};
    final genealogia = data['genealogia'] ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ficha de $nombreGallo',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSeccion('📊 INFORMACIÓN PRINCIPAL'),
              _buildDato('Código', gallo['codigo'] ?? 'N/A'),
              _buildDato('Raza', gallo['raza'] ?? 'N/A'),
              _buildDato('Estado', gallo['estado'] ?? 'N/A'),
              _buildDato('Peso', gallo['peso'] ?? 'N/A'),
              
              const SizedBox(height: 16),
              _buildSeccion('🏆 ESTADÍSTICAS'),
              _buildDato('Total Peleas', '${estadisticas['total_peleas'] ?? 0}'),
              _buildDato('Ganadas', '${estadisticas['peleas_ganadas'] ?? 0}'),
              _buildDato('Efectividad', '${estadisticas['efectividad'] ?? 0}%'),
              _buildDato('Ingresos', 'S/ ${estadisticas['ingresos_totales'] ?? 0}'),
              
              if (genealogia['padre'] != null) ...[
                const SizedBox(height: 16),
                _buildSeccion('👨 PADRE'),
                _buildDato('Nombre', genealogia['padre']['nombre'] ?? 'N/A'),
                _buildDato('Código', genealogia['padre']['codigo'] ?? 'N/A'),
              ],
              
              if (genealogia['madre'] != null) ...[
                const SizedBox(height: 16),
                _buildSeccion('👩 MADRE'),
                _buildDato('Nombre', genealogia['madre']['nombre'] ?? 'N/A'),
                _buildDato('Código', genealogia['madre']['codigo'] ?? 'N/A'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('📥 Usuario quiere descargar PDF');
              Navigator.of(context).pop();
              // Aquí se implementaría la descarga real
            },
            child: const Text('📥 Descargar PDF'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
  
  Widget _buildDato(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
  
  // 🔥 MOSTRAR DIÁLOGO DE PDF LISTO PARA DESCARGA
  void _mostrarDialogoPDFListo(Map<String, dynamic> response, String nombreGallo) {
    print('🔥 Mostrando diálogo de PDF listo...');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🔥 PDF Generado',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La ficha de "$nombreGallo" se ha generado exitosamente.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'PDF Profesional Generado',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Foto del gallo\n• Estadísticas completas\n• Genealogía familiar\n• Historial de peleas\n• Diseño profesional',
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Mostrar datos como fallback
              _mostrarDatosFicha(response['data'], nombreGallo);
            },
            child: const Text('Ver Datos'),
          ),
          // 🔥 DESCARGA DIRECTA DESDE BASE64
          ElevatedButton.icon(
            onPressed: () {
              print('🔥 Descargando PDF desde Base64...');
              Navigator.of(context).pop();
              
              // Descargar usando el base64 que ya tenemos
              final pdfBase64 = response['pdf_base64'] as String;
              final fileName = 'ficha_${nombreGallo}_${DateTime.now().millisecondsSinceEpoch}.pdf';
              
              try {
                PDFDownloadService.downloadPDFFromBase64(pdfBase64, fileName);
                
                // Mostrar éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('🔥 Descargando PDF de "$nombreGallo"...'),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 3),
                  ),
                );
                
              } catch (e) {
                print('❌ Error descargando: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error descargando PDF: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('📥 Descargar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
          // Botón alternativo API directa
          TextButton.icon(
            onPressed: () async {
              print('📥 Descarga alternativa vía API...');
              Navigator.of(context).pop();
              
              // Intentar descarga PDF directa
              await _descargarPDFDirecto(response['data']['gallo']['id'], nombreGallo);
            },
            icon: const Icon(Icons.cloud_download, size: 16),
            label: const Text('API'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  // 📥 DESCARGAR PDF DIRECTO
  Future<void> _descargarPDFDirecto(int galloId, String nombreGallo) async {
    try {
      print('📥 Iniciando descarga PDF directa...');
      print('🐓 Gallo ID: $galloId');
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Descargando PDF de $nombreGallo...'),
              const SizedBox(height: 8),
              Text(
                'Generando archivo PDF profesional',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
      
      // Llamar servicio de descarga
      final pdfBytes = await _reportesService.descargarPDFDirecto(galloId);
      
      Navigator.of(context).pop(); // Cerrar loading
      
      if (pdfBytes != null && pdfBytes.isNotEmpty) {
        print('✅ PDF descargado: ${pdfBytes.length} bytes');
        
        // En Flutter web: crear descarga automática
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('📥 PDF de "$nombreGallo" descargado exitosamente'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        
      } else {
        print('❌ Error: PDF vacío o nulo');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error descargando PDF'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
      
    } catch (e) {
      print('❌ Error en descarga PDF: $e');
      
      Navigator.of(context).pop(); // Cerrar loading si hay error
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error descargando PDF: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadGallos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 HEADER CON ESTADÍSTICAS
            _buildStatsHeader(),
            
            const SizedBox(height: 20),
            
            // 🔍 BÚSQUEDA
            _buildSearchBar(),
            
            const SizedBox(height: 20),
            
            // 📄 CONTENIDO PRINCIPAL
            _buildContent(),
          ],
        ),
      ),
    );
  }
  
  // 📊 HEADER CON ESTADÍSTICAS
  Widget _buildStatsHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📄 Documentos y Fichas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Exporta fichas PDF de tus gallos',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Gallos',
                        '$_totalGallos',
                        AppColors.primary,
                        Icons.pets,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Efectividad Prom.',
                        '${_efectividadPromedio.toStringAsFixed(1)}%',
                        AppColors.success,
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
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
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // 🔍 BARRA DE BÚSQUEDA
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterGallos,
        decoration: InputDecoration(
          hintText: 'Buscar gallos...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
  
  // 📄 CONTENIDO SEGÚN ESTADO
  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Cargando gallos...');
    }
    
    if (_error != null) {
      return custom_error.ErrorWidget(
        message: _error!,
        onRetry: _loadGallos,
      );
    }
    
    if (_gallosFiltrados.isEmpty) {
      return _buildEmptyState();
    }
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🐓 Gallos (${_gallosFiltrados.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...(_gallosFiltrados.map((gallo) => _buildGalloCard(gallo))),
            ],
          ),
        );
      },
    );
  }
  
  // 🐓 CARD DE GALLO
  Widget _buildGalloCard(GalloDocumento gallo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 📸 FOTO DEL GALLO
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                image: gallo.fotoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(gallo.fotoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: gallo.fotoUrl == null
                  ? const Icon(Icons.pets, color: Colors.grey, size: 30)
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // 📊 INFORMACIÓN DEL GALLO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gallo.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        gallo.codigo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (gallo.raza != null) ...[
                        Text(
                          ' • ${gallo.raza}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getEfectividadColor(gallo.efectividad).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${gallo.efectividad.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getEfectividadColor(gallo.efectividad),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${gallo.peleasGanadas}/${gallo.totalPeleas}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 📥 BOTÓN EXPORTAR
            ElevatedButton.icon(
              onPressed: () => _exportarFicha(gallo),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('Ficha'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 📝 ESTADO VACÍO
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty 
                ? 'No hay gallos registrados'
                : 'No se encontraron gallos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Agrega gallos desde el módulo de Pedigrí'
                : 'Intenta con otros términos de búsqueda',
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
  
  // 🎨 HELPERS
  Color _getEfectividadColor(double efectividad) {
    if (efectividad >= 80) return AppColors.success;
    if (efectividad >= 60) return AppColors.warning;
    if (efectividad >= 40) return Colors.orange;
    return AppColors.error;
  }
}