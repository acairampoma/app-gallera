// 🚀 Dialog de Upgrade - Popup cuando se alcanza límite
// Se muestra cuando el usuario intenta crear un recurso y ha alcanzado el límite

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/suscripcion_models.dart';
import '../../models/pago_models.dart';
import '../../services/suscripcion_service.dart';
import '../../features/planes/screens/planes_screen.dart';

class UpgradeDialog extends StatefulWidget {
  final RecursoTipo recursoTipo;
  final LimiteSuperadoError limiteSuperado;
  final int? galloId;

  const UpgradeDialog({
    Key? key,
    required this.recursoTipo,
    required this.limiteSuperado,
    this.galloId,
  }) : super(key: key);

  @override
  State<UpgradeDialog> createState() => _UpgradeDialogState();
}

class _UpgradeDialogState extends State<UpgradeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playEntranceAnimation();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  void _playEntranceAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 16,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.blue.shade50,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildLimiteInfo(),
                    const SizedBox(height: 24),
                    _buildPlanRecomendado(),
                    const SizedBox(height: 24),
                    _buildBotones(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.red.shade400],
            ),
          ),
          child: Icon(
            _getIconoRecurso(),
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '¡Límite Alcanzado! 🚨',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Has alcanzado el límite de tu plan actual',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLimiteInfo() {
    final info = widget.limiteSuperado.limiteInfo;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.recursoTipo.icono,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recursoTipo.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${info.cantidadUsada}/${info.limiteActual} utilizados',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: info.cantidadUsada / info.limiteActual,
            backgroundColor: Colors.red.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade400),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            info.mensaje,
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRecomendado() {
    final planRecomendado = widget.limiteSuperado.limiteInfo.planRecomendado ?? 'premium';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Plan Recomendado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPlanCard(planRecomendado),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String planCodigo) {
    final icono = SuscripcionService.obtenerIconoPlan(planCodigo);
    final nombre = SuscripcionService.obtenerNombrePlan(planCodigo);
    
    // Límites según el plan recomendado
    final Map<String, Map<String, int>> limitesPlanes = {
      'basico': {'gallos': 15, 'topes': 5, 'peleas': 5, 'vacunas': 5},
      'premium': {'gallos': 50, 'topes': 10, 'peleas': 10, 'vacunas': 10},
      'profesional': {'gallos': -1, 'topes': -1, 'peleas': -1, 'vacunas': -1}, // Ilimitado
    };
    
    final limites = limitesPlanes[planCodigo] ?? limitesPlanes['premium']!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(icono, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildLimiteChip('🐓', limites['gallos']!),
              _buildLimiteChip('🏋️', limites['topes']!),
              _buildLimiteChip('🥊', limites['peleas']!),
              _buildLimiteChip('💉', limites['vacunas']!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLimiteChip(String icono, int limite) {
    final texto = limite == -1 ? 'Ilimitado' : limite.toString();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icono, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotones() {
    return Column(
      children: [
        // Botón principal de upgrade
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _abrirPlanesScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch),
                const SizedBox(width: 8),
                const Text(
                  'Ver Planes Premium',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Botón secundario
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Continuar con Plan Actual',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconoRecurso() {
    switch (widget.recursoTipo) {
      case RecursoTipo.gallos:
        return Icons.pets;
      case RecursoTipo.topes:
        return Icons.fitness_center;
      case RecursoTipo.peleas:
        return Icons.sports_mma;
      case RecursoTipo.vacunas:
        return Icons.medical_services;
    }
  }

  void _abrirPlanesScreen() async {
    // Vibración de feedback
    HapticFeedback.lightImpact();
    
    // Cerrar el dialog actual
    Navigator.of(context).pop();
    
    // Navegar a la pantalla de planes
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlanesScreen(
          planRecomendado: widget.limiteSuperado.limiteInfo.planRecomendado,
          origenUpgrade: widget.recursoTipo.nombre,
        ),
      ),
    );
  }
}

// ========================================
// DIALOG SIMPLE PARA CASOS ESPECÍFICOS
// ========================================

/// Dialog simplificado para casos donde no se necesita tanta información
class LimiteSimpleDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String planRecomendado;

  const LimiteSimpleDialog({
    Key? key,
    required this.titulo,
    required this.mensaje,
    this.planRecomendado = 'premium',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade600),
          const SizedBox(width: 8),
          Text(titulo),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mensaje),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                Text('Upgrade a ${SuscripcionService.obtenerNombrePlan(planRecomendado)}'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlanesScreen(
                  planRecomendado: planRecomendado,
                ),
              ),
            );
          },
          child: const Text('Ver Planes'),
        ),
      ],
    );
  }
}