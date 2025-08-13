// 🏆🐓 TAB DE RANKINGS ÉPICO - TOP GALLOS, PADRILLOS Y MADRES
import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart' as custom_error;
import '../services/reportes_service.dart';
import '../models/rankings_model.dart';

class RankingsTab extends StatefulWidget {
  final int? anoSeleccionado;
  final int? mesSeleccionado;

  const RankingsTab({
    super.key,
    this.anoSeleccionado,
    this.mesSeleccionado,
  });

  @override
  State<RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<RankingsTab>
    with TickerProviderStateMixin {
  
  final ReportesService _reportesService = ReportesService();
  
  // 📊 DATOS
  Map<String, RankingsData>? _rankingsData;
  bool _isLoading = true;
  String? _error;
  
  // 🏆 TIPO SELECCIONADO
  String _tipoSeleccionado = 'gallos'; // gallos, padrillos, madres
  
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
    
    _loadRankings();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(RankingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.anoSeleccionado != widget.anoSeleccionado ||
        oldWidget.mesSeleccionado != widget.mesSeleccionado) {
      _loadRankings();
    }
  }
  
  // 🚀 CARGAR RANKINGS
  Future<void> _loadRankings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      print('🏆 Cargando rankings tipo: $_tipoSeleccionado');
      
      final data = await _reportesService.getRankings(
        tipo: _tipoSeleccionado,
        ano: widget.anoSeleccionado,
        mes: widget.mesSeleccionado,
        limite: 15,
      );
      
      setState(() {
        _rankingsData = {
          _tipoSeleccionado: RankingsData.fromJson(data),
        };
        _isLoading = false;
      });
      
      _fadeController.forward();
      
    } catch (e) {
      print('❌ Error cargando rankings: $e');
      setState(() {
        _error = 'Error cargando rankings: $e';
        _isLoading = false;
      });
    }
  }
  
  // 🔄 CAMBIAR TIPO DE RANKING
  void _onTipoChanged(String tipo) {
    if (tipo != _tipoSeleccionado) {
      setState(() {
        _tipoSeleccionado = tipo;
      });
      _fadeController.reset();
      _loadRankings();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadRankings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏆 SELECTOR DE TIPO
            _buildTipoSelector(),
            
            const SizedBox(height: 20),
            
            // 📊 CONTENIDO PRINCIPAL
            _buildContent(),
          ],
        ),
      ),
    );
  }
  
  // 🏆 SELECTOR DE TIPO DE RANKING
  Widget _buildTipoSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTipoButton('gallos', 'Gallos', Icons.pets),
          _buildTipoButton('padrillos', 'Padrillos', Icons.male),
          _buildTipoButton('madres', 'Madres', Icons.female),
        ],
      ),
    );
  }
  
  Widget _buildTipoButton(String tipo, String label, IconData icon) {
    final isSelected = _tipoSeleccionado == tipo;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTipoChanged(tipo),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 📊 CONTENIDO SEGÚN ESTADO
  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Cargando rankings...');
    }
    
    if (_error != null) {
      return custom_error.ErrorWidget(
        message: _error!,
        onRetry: _loadRankings,
      );
    }
    
    final rankingData = _rankingsData?[_tipoSeleccionado];
    if (rankingData == null || rankingData.items.isEmpty) {
      return _buildNoDataCard();
    }
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📊 ESTADÍSTICAS GENERALES
              _buildStatsHeader(rankingData),
              
              const SizedBox(height: 20),
              
              // 🏆 PODIO TOP 3
              _buildPodium(rankingData),
              
              const SizedBox(height: 24),
              
              // 📋 LISTA COMPLETA
              _buildRankingList(rankingData),
            ],
          ),
        );
      },
    );
  }
  
  // 📊 ESTADÍSTICAS DEL HEADER
  Widget _buildStatsHeader(RankingsData data) {
    return CustomCard(
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
                child: Icon(
                  _getTipoIcon(_tipoSeleccionado),
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
                      'Top ${_getTipoLabel(_tipoSeleccionado)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${data.items.length} elementos en ranking',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (data.estadisticas != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Peleas',
                    '${data.estadisticas!.totalPeleas}',
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Efectividad Prom.',
                    '${data.estadisticas!.efectividadPromedio.toStringAsFixed(1)}%',
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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
  
  // 🏆 PODIO TOP 3
  Widget _buildPodium(RankingsData data) {
    final top3 = data.items.take(3).toList();
    if (top3.isEmpty) return const SizedBox();
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Podio de Campeones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 🥈 Segundo lugar
              if (top3.length > 1)
                Expanded(
                  child: _buildPodiumItem(top3[1], 2, Colors.grey[400]!),
                ),
              
              // 🥇 Primer lugar  
              if (top3.isNotEmpty)
                Expanded(
                  child: _buildPodiumItem(top3[0], 1, const Color(0xFFFFD700)),
                ),
              
              // 🥉 Tercer lugar
              if (top3.length > 2)
                Expanded(
                  child: _buildPodiumItem(top3[2], 3, const Color(0xFFCD7F32)),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPodiumItem(RankingItem item, int posicion, Color medalColor) {
    final heights = [0.0, 80.0, 60.0, 50.0]; // Índice 0 no usado
    
    return Column(
      children: [
        // 🏅 Medalla
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: medalColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$posicion',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // 📊 Podio
        Container(
          height: heights[posicion],
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: medalColor.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${item.efectividadPeriodo.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: medalColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 📋 LISTA COMPLETA DE RANKINGS
  Widget _buildRankingList(RankingsData data) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Ranking Completo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...data.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildRankingItem(item, index + 1);
          }),
        ],
      ),
    );
  }
  
  Widget _buildRankingItem(RankingItem item, int posicion) {
    Color rankColor = _getRankColor(posicion);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: posicion <= 3 ? rankColor.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: posicion <= 3 ? rankColor.withOpacity(0.3) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          // 🏆 POSICIÓN
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$posicion',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 📊 INFORMACIÓN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.raza?.isNotEmpty == true)
                  Text(
                    item.raza!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${item.ganadasPeriodo}/${item.peleasPeriodo} peleas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // 📊 MÉTRICAS
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getColorByEffectiveness(item.efectividadPeriodo).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.efectividadPeriodo.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getColorByEffectiveness(item.efectividadPeriodo),
                  ),
                ),
              ),
              if (item.topesPeriodo > 0)
                Text(
                  '${item.topesPeriodo} topes',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 📝 NO DATA CARD
  Widget _buildNoDataCard() {
    return CustomCard(
      child: Column(
        children: [
          Icon(
            Icons.leaderboard,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay rankings disponibles',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron ${_getTipoLabel(_tipoSeleccionado).toLowerCase()} con peleas en este período.',
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
  Color _getRankColor(int posicion) {
    switch (posicion) {
      case 1: return const Color(0xFFFFD700); // Oro
      case 2: return Colors.grey[400]!; // Plata
      case 3: return const Color(0xFFCD7F32); // Bronce
      default: return AppColors.primary;
    }
  }
  
  Color _getColorByEffectiveness(double effectiveness) {
    if (effectiveness >= 80) return AppColors.success;
    if (effectiveness >= 60) return AppColors.warning;
    if (effectiveness >= 40) return Colors.orange;
    return AppColors.error;
  }
  
  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'gallos': return Icons.pets;
      case 'padrillos': return Icons.male;
      case 'madres': return Icons.female;
      default: return Icons.leaderboard;
    }
  }
  
  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'gallos': return 'Gallos';
      case 'padrillos': return 'Padrillos';
      case 'madres': return 'Madres';
      default: return 'Rankings';
    }
  }
}