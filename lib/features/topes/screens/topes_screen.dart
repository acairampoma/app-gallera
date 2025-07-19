import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';

class TopesScreen extends StatefulWidget {
  const TopesScreen({Key? key}) : super(key: key);

  @override
  State<TopesScreen> createState() => _TopesScreenState();
}

class _TopesScreenState extends State<TopesScreen> {
  List<dynamic> entrenamientos = [];
  Map<String, dynamic> estadisticas = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String entrenJson = await rootBundle.loadString('lib/data/mock/entrenamientos_mock.json');
      final data = json.decode(entrenJson);
      setState(() {
        entrenamientos = data['entrenamientos'] ?? [];
        estadisticas = data['estadisticas_entrenamiento'] ?? {};
        isLoading = false;
      });
    } catch (e) {
      print('Error loading entrenamientos data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Registro de Topes',
      subtitle: 'Entrenamientos y sparring',
      currentIndex: 1, // Gallos section
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTopeDialog(),
        backgroundColor: Colors.orange,
        heroTag: "add_tope",
        child: const Icon(Icons.fitness_center, color: Colors.white),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEstadisticasRapidas(),
          const SizedBox(height: 20),
          _buildHistorialSection(),
        ],
      ),
    );
  }

  Widget _buildEstadisticasRapidas() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Topes',
            '${estadisticas['total_entrenamientos'] ?? 0}',
            Icons.fitness_center,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Esta Semana',
            '${estadisticas['esta_semana'] ?? 0}',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Promedio',
            '${estadisticas['duracion_promedio'] ?? 0}min',
            Icons.timer,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Entrenamientos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (entrenamientos.isEmpty)
          _buildEmptyHistorial()
        else
          ...entrenamientos.map((entrenamiento) => _buildEntrenamientoCard(entrenamiento)),
      ],
    );
  }

  Widget _buildEmptyHistorial() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sin entrenamientos registrados',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para registrar tu primer tope',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntrenamientoCard(Map<String, dynamic> entrenamiento) {
    final gallo = entrenamiento['gallo'] ?? {};
    final intensidadColor = _getIntensidadColor(entrenamiento['intensidad']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showEntrenamientoDetails(entrenamiento),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entrenamiento['tipo_entrenamiento'] ?? 'Tope',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Gallo: ${gallo['nombre'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: intensidadColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entrenamiento['intensidad'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        color: intensidadColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildEntrenamientoInfo('Fecha', entrenamiento['fecha_entrenamiento'] ?? 'N/A'),
                  const SizedBox(width: 20),
                  _buildEntrenamientoInfo('Duración', '${entrenamiento['duracion'] ?? 0} min'),
                  const SizedBox(width: 20),
                  _buildEntrenamientoInfo('Peso', '${entrenamiento['peso_gallo'] ?? 0} kg'),
                ],
              ),
              if (entrenamiento['observaciones'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entrenamiento['observaciones'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntrenamientoInfo(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIntensidadColor(String? intensidad) {
    switch (intensidad?.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showEntrenamientoDetails(Map<String, dynamic> entrenamiento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
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
                    child: _buildEntrenamientoDetailContent(entrenamiento),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEntrenamientoDetailContent(Map<String, dynamic> entrenamiento) {
    final gallo = entrenamiento['gallo'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 30,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entrenamiento['tipo_entrenamiento'] ?? 'Entrenamiento',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gallo: ${gallo['nombre'] ?? 'N/A'}',
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
        
        _buildDetailSection('Información del Entrenamiento', [
          _buildDetailRow('Fecha', entrenamiento['fecha_entrenamiento'] ?? 'N/A'),
          _buildDetailRow('Duración', '${entrenamiento['duracion'] ?? 0} minutos'),
          _buildDetailRow('Intensidad', entrenamiento['intensidad'] ?? 'N/A'),
          _buildDetailRow('Peso del Gallo', '${entrenamiento['peso_gallo'] ?? 0} kg'),
        ]),
        
        if (entrenamiento['ejercicios'] != null)
          _buildDetailSection('Ejercicios Realizados', [
            Text(
              entrenamiento['ejercicios'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ]),
        
        if (entrenamiento['observaciones'] != null)
          _buildDetailSection('Observaciones', [
            Text(
              entrenamiento['observaciones'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ]),
          
        const SizedBox(height: 24),
        
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Función de edición próximamente')),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Editar Entrenamiento'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(double.infinity, 48),
          ),
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
            width: 100,
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

  void _showAddTopeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Tope'),
        content: const Text('Formulario completo de entrenamiento próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}