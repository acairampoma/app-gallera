import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({Key? key}) : super(key: key);

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic> reportesData = {};
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final String reportesJson = await rootBundle.loadString('lib/data/mock/reportes_mock.json');
      final data = json.decode(reportesJson);
      setState(() {
        reportesData = data['reportes'] ?? {};
        isLoading = false;
      });
    } catch (e) {
      print('Error loading reportes data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Reportes',
      subtitle: 'Estadísticas y documentos PDF',
      currentIndex: 2,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Rankings'),
              Tab(text: 'Documentos'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(),
              _buildRankingsTab(),
              _buildDocumentosTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardTab() {
    final resumen = reportesData['estadisticas_generales']?['resumen'] ?? {};
    final gastosPorCategoria = reportesData['estadisticas_generales']?['gastos_por_categoria'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(resumen),
          const SizedBox(height: 24),
          _buildFinancialSummary(resumen),
          const SizedBox(height: 24),
          _buildExpenseBreakdown(gastosPorCategoria),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> resumen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen General',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Gallos',
                '${resumen['total_gallos'] ?? 0}',
                Icons.pets,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Activos',
                '${resumen['gallos_activos'] ?? 0}',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Peleas',
                '${resumen['total_peleas'] ?? 0}',
                Icons.sports_mma,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Victorias',
                '${resumen['victorias'] ?? 0}',
                Icons.emoji_events,
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Porcentaje de Éxito',
          '${resumen['porcentaje_exito'] ?? 0}%',
          Icons.trending_up,
          Colors.purple,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isWide = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isWide ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(Map<String, dynamic> resumen) {
    final totalIngresos = resumen['total_ingresos'] ?? 0.0;
    final totalGastos = resumen['total_gastos'] ?? 0.0;
    final gananciaNeta = resumen['ganancia_neta'] ?? 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen Financiero',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFinancialRow('Ingresos', totalIngresos, Colors.green),
            const SizedBox(height: 8),
            _buildFinancialRow('Gastos', totalGastos, Colors.red),
            const Divider(),
            _buildFinancialRow('Ganancia Neta', gananciaNeta, 
                gananciaNeta >= 0 ? Colors.green : Colors.red, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, Color color, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          'S/. ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdown(List<dynamic> gastosPorCategoria) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gastos por Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...gastosPorCategoria.map((gasto) {
              final categoria = gasto['categoria'] ?? '';
              final total = gasto['total'] ?? 0.0;
              final porcentaje = gasto['porcentaje'] ?? 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(categoria),
                        Text(
                          'S/. ${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: porcentaje / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(categoria),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${porcentaje.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'alimentación':
        return Colors.green;
      case 'salud':
        return Colors.blue;
      case 'entrenamiento':
        return Colors.orange;
      case 'transporte':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRankingsTab() {
    final topGallos = reportesData['estadisticas_generales']?['top_gallos'] ?? [];
    final rankingPadrillos = reportesData['ranking_padrillos'] ?? [];
    final rankingMadres = reportesData['ranking_madres'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRankingSection('Top Gallos', topGallos, Icons.emoji_events),
          const SizedBox(height: 24),
          _buildRankingSection('Ranking Padrillos', rankingPadrillos, Icons.male),
          const SizedBox(height: 24),
          _buildRankingSection('Ranking Madres', rankingMadres, Icons.female),
        ],
      ),
    );
  }

  Widget _buildRankingSection(String title, List<dynamic> ranking, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (ranking.isEmpty)
              const Text('No hay datos disponibles')
            else
              ...ranking.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildRankingItem(item, index + 1);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> item, int position) {
    final nombre = item['nombre'] ?? item['padre_nombre'] ?? item['madre_nombre'] ?? 'N/A';
    final porcentaje = item['porcentaje'] ?? item['porcentaje_exito'] ?? 0.0;
    final premios = item['ganancia'] ?? item['total_premios_hijos'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: position <= 3 ? _getPositionColor(position).withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: position <= 3 ? _getPositionColor(position) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getPositionColor(position),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${porcentaje.toStringAsFixed(1)}% éxito',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'S/. ${premios.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber; // Oro
      case 2:
        return Colors.grey; // Plata
      case 3:
        return Colors.brown; // Bronce
      default:
        return Colors.grey[600]!;
    }
  }

  Widget _buildDocumentosTab() {
    final reportesDisponibles = reportesData['reportes_disponibles'] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: reportesDisponibles.length,
      itemBuilder: (context, index) {
        final reporte = reportesDisponibles[index];
        return _buildDocumentCard(reporte);
      },
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> reporte) {
    final nombre = reporte['nombre'] ?? 'Reporte';
    final descripcion = reporte['descripcion'] ?? '';
    final tipo = reporte['tipo'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.picture_as_pdf,
            color: AppColors.primary,
            size: 30,
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          descripcion,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: ElevatedButton(
          onPressed: () => _generateReport(tipo, nombre),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('PDF'),
        ),
      ),
    );
  }

  void _generateReport(String tipo, String nombre) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generando $nombre...'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Abrir PDF generado
          },
        ),
      ),
    );
  }
}