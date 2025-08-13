// 💰 Pantalla de Inversiones - Gestión de Gastos Mensuales
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../services/inversion_service.dart';
import '../widgets/inversion_form_card.dart';
import '../widgets/mes_selector_widget.dart';

class InversionesScreen extends StatefulWidget {
  const InversionesScreen({Key? key}) : super(key: key);

  @override
  State<InversionesScreen> createState() => _InversionesScreenState();
}

class _InversionesScreenState extends State<InversionesScreen> {
  // 📅 Filtros de fecha
  late int _anioSeleccionado;
  late int _mesSeleccionado;
  
  // 💰 Datos de inversiones (4 tipos)
  final Map<String, TextEditingController> _controllers = {
    'alimento': TextEditingController(),
    'medicina': TextEditingController(),
    'limpieza_galpon': TextEditingController(),
    'entrenador': TextEditingController(),
  };
  
  // 🔄 Estados
  bool _isLoading = false;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _inicializarFecha();
    _cargarInversiones();
  }
  
  void _inicializarFecha() {
    final ahora = DateTime.now();
    _anioSeleccionado = ahora.year;
    _mesSeleccionado = ahora.month;
  }
  
  @override
  void dispose() {
    // Limpiar controllers
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Inversiones',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _cargarInversiones,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildFiltrosCard(),
            const SizedBox(height: 20),
            _buildInversionesForm(),
            const SizedBox(height: 20),
            _buildAccionesCard(),
            const SizedBox(height: 40), // Espacio para scroll
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade600, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Control de Inversiones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona tus gastos mensuales de crianza',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltrosCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt, color: Colors.teal.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filtrar por Período',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MesSelectorWidget(
              anioSeleccionado: _anioSeleccionado,
              mesSeleccionado: _mesSeleccionado,
              onChanged: _onFiltroChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInversionesForm() {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return InversionFormCard(
      controllers: _controllers,
      anioSeleccionado: _anioSeleccionado,
      mesSeleccionado: _mesSeleccionado,
    );
  }

  Widget _buildAccionesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total calculado
            _buildTotalCard(),
            const SizedBox(height: 16),
            // Botón Guardar
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _guardarInversiones,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _isSaving ? 0 : 4,
              ),
              icon: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving ? 'Guardando...' : 'Guardar Inversiones',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    final total = _calcularTotal();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: Colors.teal.shade600),
              const SizedBox(width: 8),
              Text(
                'Total del Mes:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
            ],
          ),
          Text(
            'S/. ${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  void _onFiltroChanged(int anio, int mes) {
    if (anio != _anioSeleccionado || mes != _mesSeleccionado) {
      setState(() {
        _anioSeleccionado = anio;
        _mesSeleccionado = mes;
      });
      _cargarInversiones();
    }
  }

  Future<void> _cargarInversiones() async {
    setState(() => _isLoading = true);
    
    try {
      // 🚀 Llamar al API para cargar inversiones del mes
      final inversiones = await InversionService.obtenerInversiones(
        _anioSeleccionado, 
        _mesSeleccionado,
      );
      
      // 📝 Llenar controllers con datos del API
      _controllers.forEach((tipo, controller) {
        final monto = inversiones[tipo] ?? 0.0;
        controller.text = monto > 0 ? monto.toString() : '';
      });
      
    } catch (e) {
      _mostrarError('Error cargando inversiones: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarInversiones() async {
    setState(() => _isSaving = true);
    
    try {
      // Vibración de feedback
      HapticFeedback.mediumImpact();
      
      // Validar datos
      if (!_validarDatos()) {
        return;
      }
      
      // 📦 Preparar datos para enviar al API
      final Map<String, double> inversiones = {};
      _controllers.forEach((tipo, controller) {
        final text = controller.text.trim();
        if (text.isNotEmpty) {
          final valor = double.tryParse(text) ?? 0.0;
          if (valor > 0) {
            inversiones[tipo] = valor;
          }
        }
      });
      
      print('🚀 [UI] Enviando inversiones para $_anioSeleccionado/$_mesSeleccionado: $inversiones');
      
      // 🚀 Enviar al API con ESTRATEGIA 1 (Requests en paralelo)
      await InversionService.guardarInversiones(
        _anioSeleccionado,
        _mesSeleccionado,
        inversiones,
      );
      
      print('✅ [UI] Inversiones guardadas exitosamente');
      
      // Feedback de éxito
      HapticFeedback.lightImpact();
      _mostrarExito('Inversiones guardadas exitosamente');
      
    } catch (e) {
      _mostrarError('Error guardando inversiones: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  bool _validarDatos() {
    for (final entry in _controllers.entries) {
      final text = entry.value.text.trim();
      if (text.isNotEmpty) {
        final valor = double.tryParse(text);
        if (valor == null || valor < 0) {
          _mostrarError('${_getTipoNombre(entry.key)}: Ingrese un valor válido');
          return false;
        }
      }
    }
    return true;
  }

  double _calcularTotal() {
    double total = 0.0;
    for (final controller in _controllers.values) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        final valor = double.tryParse(text) ?? 0.0;
        total += valor;
      }
    }
    return total;
  }

  String _getTipoNombre(String tipo) {
    switch (tipo) {
      case 'alimento': return 'Alimento';
      case 'medicina': return 'Medicina';
      case 'limpieza_galpon': return 'Limpieza Galpón';
      case 'entrenador': return 'Entrenador';
      default: return tipo;
    }
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _mostrarExito(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}