// 📊 Widget de Progreso de Límites - UI Responsive
// Muestra el uso actual vs límite máximo con animaciones

import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class LimiteProgressWidget extends StatefulWidget {
  final String titulo;
  final String icono;
  final int usado;
  final int limite;
  final bool mostrarPorcentaje;
  final bool esCompacto;

  const LimiteProgressWidget({
    Key? key,
    required this.titulo,
    required this.icono,
    required this.usado,
    required this.limite,
    this.mostrarPorcentaje = true,
    this.esCompacto = false,
  }) : super(key: key);

  @override
  State<LimiteProgressWidget> createState() => _LimiteProgressWidgetState();
}

class _LimiteProgressWidgetState extends State<LimiteProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _getProgreso(),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _progressController.forward();
        
        // Si está cerca del límite, hacer pulse
        if (_getProgreso() >= 0.8) {
          _pulseController.repeat(reverse: true);
        }
      }
    });
  }

  @override
  void didUpdateWidget(LimiteProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.usado != widget.usado || oldWidget.limite != widget.limite) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _getProgreso(),
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ));
      
      _progressController.reset();
      _progressController.forward();
      
      // Controlar pulse
      if (_getProgreso() >= 0.8) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double _getProgreso() {
    if (widget.limite == -1) return 0.0; // Ilimitado
    if (widget.limite == 0) return 0.0;
    return (widget.usado / widget.limite).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return widget.esCompacto ? _buildCompactWidget() : _buildFullWidget();
  }

  Widget _buildFullWidget() {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _getProgreso() >= 0.8 ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildProgressBar(),
                const SizedBox(height: 8),
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactWidget() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getBorderColor()),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.icono, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getProgressColor(),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.usado}/${_getLimiteText()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _getProgressColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.icono,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getStatusText(),
                style: TextStyle(
                  fontSize: 12,
                  color: _getProgressColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (widget.mostrarPorcentaje) _buildPorcentajeBadge(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressAnimation.value,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getProgressGradient(),
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    if (_getProgreso() >= 0.8)
                      BoxShadow(
                        color: _getProgressColor().withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${widget.usado} utilizados',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          widget.limite == -1 ? 'Sin límite' : 'de ${widget.limite}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPorcentajeBadge() {
    final porcentaje = widget.limite == -1 ? 0 : ((_getProgreso() * 100).round());
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getProgressColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.limite == -1 ? '∞' : '$porcentaje%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getProgressColor() {
    if (widget.limite == -1) return Colors.green; // Ilimitado
    
    final progreso = _getProgreso();
    if (progreso >= 1.0) return Colors.red.shade600;
    if (progreso >= 0.9) return Colors.red.shade500;
    if (progreso >= 0.8) return Colors.orange.shade600;
    if (progreso >= 0.6) return Colors.amber.shade600;
    return Colors.green.shade600;
  }

  List<Color> _getProgressGradient() {
    final color = _getProgressColor();
    return [
      color,
      color.withOpacity(0.8),
    ];
  }

  Color _getBackgroundColor() {
    final progreso = _getProgreso();
    if (progreso >= 0.9) return Colors.red.shade50;
    if (progreso >= 0.8) return Colors.orange.shade50;
    return Colors.green.shade50;
  }

  Color _getBorderColor() {
    final progreso = _getProgreso();
    if (progreso >= 0.9) return Colors.red.shade200;
    if (progreso >= 0.8) return Colors.orange.shade200;
    return Colors.green.shade200;
  }

  String _getStatusText() {
    if (widget.limite == -1) return 'Ilimitado';
    
    final progreso = _getProgreso();
    if (progreso >= 1.0) return 'Límite alcanzado';
    if (progreso >= 0.9) return 'Cerca del límite';
    if (progreso >= 0.8) return 'Uso elevado';
    return 'Disponible';
  }

  String _getLimiteText() {
    return widget.limite == -1 ? '∞' : widget.limite.toString();
  }
}

// ========================================
// VARIANTE CIRCULAR
// ========================================

class LimiteCircularWidget extends StatefulWidget {
  final String titulo;
  final String icono;
  final int usado;
  final int limite;
  final double size;

  const LimiteCircularWidget({
    Key? key,
    required this.titulo,
    required this.icono,
    required this.usado,
    required this.limite,
    this.size = 100,
  }) : super(key: key);

  @override
  State<LimiteCircularWidget> createState() => _LimiteCircularWidgetState();
}

class _LimiteCircularWidgetState extends State<LimiteCircularWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: _getProgreso(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getProgreso() {
    if (widget.limite == -1) return 0.0; // Ilimitado
    if (widget.limite == 0) return 0.0;
    return (widget.usado / widget.limite).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                children: [
                  // Círculo de fondo
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  // Círculo de progreso
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                    ),
                  ),
                  // Contenido central
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.icono,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.usado}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(),
                          ),
                        ),
                        Text(
                          widget.limite == -1 ? '∞' : '/ ${widget.limite}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Color _getProgressColor() {
    if (widget.limite == -1) return Colors.green;
    
    final progreso = _getProgreso();
    if (progreso >= 1.0) return Colors.red;
    if (progreso >= 0.8) return Colors.orange;
    return Colors.green;
  }
}