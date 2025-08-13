// 📊🐓 TAB DE DASHBOARD ÉPICO - CON GRÁFICOS REALES Y API
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../models/dashboard_model.dart';

class DashboardTab extends StatefulWidget {
  final DashboardModel dashboardData;
  final VoidCallback onRefresh;

  const DashboardTab({
    super.key,
    required this.dashboardData,
    required this.onRefresh,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab>
    with TickerProviderStateMixin {
  
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onRefresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: _cardAnimation,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📅 INFORMACIÓN DEL PERÍODO
                _buildPeriodoHeader(),
                
                const SizedBox(height: 20),
                
                // 📊 STATS GRID ÉPICO
                _buildStatsGrid(),
                
                const SizedBox(height: 24),
                
                // 💰 RESUMEN FINANCIERO
                _buildFinancialSummary(),
                
                const SizedBox(height: 24),
                
                // 📈 GRÁFICO DE EVOLUCIÓN
                _buildEvolutionChart(),
                
                const SizedBox(height: 24),
                
                // 🏆 TOP GALLOS DEL PERÍODO
                _buildTopGallos(),
                
                const SizedBox(height: 24),
                
                // 📊 GRÁFICO DE GASTOS
                _buildExpensesChart(),
                
                const SizedBox(height: 100), // Space for FAB
              ],
            );
          },
        ),
      ),
    );
  }

  // 📅 HEADER CON INFORMACIÓN DEL PERÍODO
  Widget _buildPeriodoHeader() {
    return Transform.translate(
      offset: Offset(0, -20 * (1 - _cardAnimation.value)),
      child: Opacity(
        opacity: _cardAnimation.value.clamp(0.0, 1.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Período Seleccionado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dashboardData.filtrosAplicados.periodoFormateado,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.dashboardData.resumenPeriodo.efectividadFormateada}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
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

  // 📊 GRID DE ESTADÍSTICAS
  Widget _buildStatsGrid() {
    final resumen = widget.dashboardData.resumenPeriodo;
    final finanzas = widget.dashboardData.finanzasPeriodo;
    
    return Transform.translate(
      offset: Offset(0, -15 * (1 - _cardAnimation.value)),
      child: Opacity(
        opacity: _cardAnimation.value.clamp(0.0, 1.0),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              title: 'Total Gallos',
              value: '${resumen.totalGallos}',
              subtitle: '${resumen.gallosActivos} activos',
              icon: Icons.pets,
              color: AppColors.primary,
              progress: resumen.gallosActivos / (resumen.totalGallos > 0 ? resumen.totalGallos : 1),
            ),
            _buildStatCard(
              title: 'Peleas',
              value: '${resumen.peleasPeriodo}',
              subtitle: '${resumen.ganadasPeriodo} ganadas',
              icon: Icons.sports_mma,
              color: AppColors.warning,
              progress: resumen.peleasPeriodo > 0 ? resumen.ganadasPeriodo / resumen.peleasPeriodo : 0,
            ),
            _buildStatCard(
              title: 'Efectividad',
              value: resumen.efectividadFormateada,
              subtitle: '${resumen.perdidasPeriodo} perdidas',
              icon: Icons.trending_up,
              color: _getColorByEffectiveness(resumen.efectividadPeriodo),
              progress: resumen.efectividadPeriodo / 100,
            ),
            _buildStatCard(
              title: 'Entrenamiento',
              value: '${resumen.topesPeriodo}',
              subtitle: 'topes realizados',
              icon: Icons.fitness_center,
              color: AppColors.secondary,
              progress: resumen.topesPeriodo / 20, // Máximo esperado 20
            ),
          ],
        ),
      ),
    );
  }

  // 📊 CARD DE ESTADÍSTICA
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  // 💰 RESUMEN FINANCIERO
  Widget _buildFinancialSummary() {
    final finanzas = widget.dashboardData.finanzasPeriodo;
    
    return Transform.translate(
      offset: Offset(0, -10 * (1 - _cardAnimation.value)),
      child: Opacity(
        opacity: _cardAnimation.value.clamp(0.0, 1.0),
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      '💰 Resumen Financiero',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: finanzas.gananciaNeta >= 0 
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ROI ${finanzas.roiFormateado}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: finanzas.gananciaNeta >= 0 
                          ? AppColors.success
                          : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _buildFinancialItem(
                      'Ingresos',
                      finanzas.ingresosFormateados,
                      AppColors.success,
                      Icons.trending_up,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(
                    child: _buildFinancialItem(
                      'Gastos',
                      finanzas.gastosFormateados,
                      AppColors.error,
                      Icons.trending_down,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: finanzas.gananciaNeta >= 0 
                    ? AppColors.success.withOpacity(0.05)
                    : AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: finanzas.gananciaNeta >= 0 
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ganancia Neta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      finanzas.gananciaFormateada,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: finanzas.gananciaNeta >= 0 
                          ? AppColors.success
                          : AppColors.error,
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

  Widget _buildFinancialItem(String label, String value, Color color, IconData icon) {
    return Column(
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
        ),
      ],
    );
  }

  // 📈 GRÁFICO DE EVOLUCIÓN
  Widget _buildEvolutionChart() {
    final evolucion = widget.dashboardData.evolucionSeisMeses;
    
    if (!evolucion.tienedatos) {
      return _buildNoDataCard('Evolución Temporal', 'No hay datos suficientes para el gráfico');
    }
    
    return Transform.translate(
      offset: Offset(0, -5 * (1 - _cardAnimation.value)),
      child: Opacity(
        opacity: _cardAnimation.value.clamp(0.0, 1.0),
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📈 Evolución de Peleas (6 meses)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < evolucion.labels.length) {
                              return Text(
                                evolucion.labels[index],
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Línea de peleas totales
                      LineChartBarData(
                        spots: evolucion.peleasSpots,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.primary,
                              strokeColor: Colors.white,
                              strokeWidth: 2,
                            );
                          },
                        ),
                      ),
                      // Línea de peleas ganadas
                      LineChartBarData(
                        spots: evolucion.ganadasSpots,
                        isCurved: true,
                        color: AppColors.success,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.success,
                              strokeColor: Colors.white,
                              strokeWidth: 2,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Total Peleas', AppColors.primary),
                  const SizedBox(width: 24),
                  _buildLegendItem('Peleas Ganadas', AppColors.success),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // 🏆 TOP GALLOS DEL PERÍODO
  Widget _buildTopGallos() {
    final topGallos = widget.dashboardData.topGallosPeriodo;
    
    if (topGallos.isEmpty) {
      return _buildNoDataCard('Top Gallos', 'No hay peleas registradas en este período');
    }
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Top Gallos del Período',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...topGallos.take(5).map((gallo) => _buildTopGalloItem(gallo)),
        ],
      ),
    );
  }

  Widget _buildTopGalloItem(TopGallo gallo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: gallo.colorEfectividad.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.pets,
              color: gallo.colorEfectividad,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gallo.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (gallo.raza?.isNotEmpty == true)
                  Text(
                    gallo.raza!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: gallo.colorEfectividad.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  gallo.efectividadFormateada,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: gallo.colorEfectividad,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${gallo.ganadasPeriodo}/${gallo.peleasPeriodo} peleas',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📊 GRÁFICO DE GASTOS
  Widget _buildExpensesChart() {
    final gastos = widget.dashboardData.finanzasPeriodo.detalleGastos;
    final categorias = gastos.categorias;
    
    if (categorias.isEmpty) {
      return _buildNoDataCard('Distribución de Gastos', 'No hay gastos registrados en este período');
    }
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Distribución de Gastos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Gráfico de dona
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sections: categorias.map((categoria) {
                        return PieChartSectionData(
                          value: categoria.valor,
                          title: '${categoria.porcentaje(gastos.total).toStringAsFixed(1)}%',
                          color: categoria.color,
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
              
              // Leyenda
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categorias.map((categoria) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: categoria.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              categoria.nombre,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            categoria.valorFormateado,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📝 NO DATA CARD
  Widget _buildNoDataCard(String title, String message) {
    return CustomCard(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🎨 HELPERS
  Color _getColorByEffectiveness(double effectiveness) {
    if (effectiveness >= 80) return AppColors.success;
    if (effectiveness >= 60) return AppColors.warning;
    if (effectiveness >= 40) return Colors.orange;
    return AppColors.error;
  }
}