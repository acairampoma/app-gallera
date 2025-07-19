import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';

class PeleasScreen extends StatefulWidget {
  const PeleasScreen({Key? key}) : super(key: key);

  @override
  State<PeleasScreen> createState() => _PeleasScreenState();
}

class _PeleasScreenState extends State<PeleasScreen> {
  List<dynamic> peleas = [];
  Map<String, dynamic> estadisticas = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String peleasJson = await rootBundle.loadString('lib/data/mock/peleas_mock.json');
      final data = json.decode(peleasJson);
      setState(() {
        peleas = data['peleas'] ?? [];
        estadisticas = data['estadisticas_peleas'] ?? {};
        isLoading = false;
      });
    } catch (e) {
      print('Error loading peleas data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Registro de Peleas',
      subtitle: 'Documenta los combates',
      currentIndex: 1, // Gallos section
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPeleaDialog(),
        backgroundColor: Colors.red,
        heroTag: "add_pelea",
        child: const Icon(Icons.sports_mma, color: Colors.white),
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
          _buildEstadisticasGenerales(),
          const SizedBox(height: 20),
          _buildHistorialPeleas(),
        ],
      ),
    );
  }

  Widget _buildEstadisticasGenerales() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas Generales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Peleas',
                    '${estadisticas['total_peleas'] ?? 0}',
                    Icons.sports_mma,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Victorias',
                    '${estadisticas['victorias'] ?? 0}',
                    Icons.emoji_events,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Derrotas',
                    '${estadisticas['derrotas'] ?? 0}',
                    Icons.close,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '% Éxito',
                    '${estadisticas['porcentaje_exito'] ?? 0}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
            title,
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

  Widget _buildHistorialPeleas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Peleas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (peleas.isEmpty)
          _buildEmptyPeleas()
        else
          ...peleas.map((pelea) => _buildPeleaCard(pelea)),
      ],
    );
  }

  Widget _buildEmptyPeleas() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.sports_mma,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sin peleas registradas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para registrar tu primera pelea',
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

  Widget _buildPeleaCard(Map<String, dynamic> pelea) {
    final gallo = pelea['gallo'] ?? {};
    final resultado = pelea['resultado'] ?? '';
    final resultadoColor = _getResultadoColor(resultado);
    final resultadoIcon = _getResultadoIcon(resultado);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showPeleaDetails(pelea),
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
                      color: resultadoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      resultadoIcon,
                      color: resultadoColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${gallo['nombre'] ?? 'N/A'} vs ${pelea['gallo_rival'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          pelea['lugar'] ?? 'Lugar no especificado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: resultadoColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      resultado.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPeleaInfo('Fecha', pelea['fecha_pelea'] ?? 'N/A'),
                  _buildPeleaInfo('Premio', 'S/. ${pelea['premio'] ?? 0}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeleaInfo(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Color _getResultadoColor(String resultado) {
    switch (resultado.toLowerCase()) {
      case 'victoria':
        return Colors.green;
      case 'derrota':
        return Colors.red;
      case 'empate':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getResultadoIcon(String resultado) {
    switch (resultado.toLowerCase()) {
      case 'victoria':
        return Icons.emoji_events;
      case 'derrota':
        return Icons.close;
      case 'empate':
        return Icons.remove;
      default:
        return Icons.help;
    }
  }

  void _showPeleaDetails(Map<String, dynamic> pelea) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${pelea['gallo']['nombre']} vs ${pelea['gallo_rival']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resultado: ${pelea['resultado']}'),
            Text('Lugar: ${pelea['lugar']}'),
            Text('Fecha: ${pelea['fecha_pelea']}'),
            Text('Premio: S/. ${pelea['premio']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAddPeleaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Pelea'),
        content: const Text('Formulario completo de pelea próximamente'),
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