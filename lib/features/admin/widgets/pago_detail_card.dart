// 💳 Widget ÉPICO para Detalles de Pago
// Con animaciones, estado visual y acciones rápidas

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/pago_models.dart';
import '../../../services/admin_service.dart';
import 'cloudinary_image_viewer.dart';

class PagoDetailCard extends StatefulWidget {
  final PagoPendiente pago;
  final VoidCallback? onApproved;
  final VoidCallback? onRejected;

  const PagoDetailCard({
    Key? key,
    required this.pago,
    this.onApproved,
    this.onRejected,
  }) : super(key: key);

  @override
  State<PagoDetailCard> createState() => _PagoDetailCardState();
}

class _PagoDetailCardState extends State<PagoDetailCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Iniciar animaciones
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
            border: Border.all(
              color: _getEstadoColor(widget.pago.estado).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildUserInfo(),
              _buildPaymentDetails(),
              if (widget.pago.comprobanteUrl != null) _buildImageSection(),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getEstadoColor(widget.pago.estado),
            _getEstadoColor(widget.pago.estado).withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          // Icono de estado animado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getEstadoIcon(widget.pago.estado),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Estado y monto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pago.estado.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'ID: ${widget.pago.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Monto destacado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'S/. ${widget.pago.monto.toStringAsFixed(2)}',
              style: TextStyle(
                color: _getEstadoColor(widget.pago.estado),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar del usuario
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.orange.shade100,
            child: Text(
              (widget.pago.nombreUsuario ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pago.nombreUsuario ?? 'Usuario desconocido',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Plan ${widget.pago.planDestino}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatearFecha(widget.pago.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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

  Widget _buildPaymentDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildDetailRow('💳 Método', 'Yape'),
          _buildDetailRow('🆔 Referencia', widget.pago.referenciaYape ?? 'N/A'),
          _buildDetailRow('📅 Fecha', _formatearFecha(widget.pago.createdAt)),
          _buildDetailRow('⚡ Estado', widget.pago.estado),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    if (widget.pago.comprobanteUrl == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Comprobante de Pago',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Preview de imagen con efecto hover
          GestureDetector(
            onTap: () => _mostrarImagenCompleta(),
            child: Hero(
              tag: 'pago_${widget.pago.id}',
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        widget.pago.comprobanteUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                                color: Colors.orange,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, size: 32, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text(
                                    'Error cargando imagen',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Overlay con icono de zoom
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.pago.estado.toLowerCase() != 'verificando') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Botón rechazar
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : () => _rechazarPago(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.close, size: 18),
              label: const Text(
                'Rechazar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Botón aprobar
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : () => _aprobarPago(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, size: 18),
              label: const Text(
                'Aprobar Pago',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // MÉTODOS DE ACCIÓN
  // ========================================

  void _mostrarImagenCompleta() {
    if (widget.pago.comprobanteUrl == null) return;
    
    HapticFeedback.lightImpact();
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            CloudinaryImageViewer(
              imageUrl: widget.pago.comprobanteUrl!,
              title: 'Comprobante - ${widget.pago.nombreUsuario}',
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _aprobarPago() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Confirmar Aprobación'),
          ],
        ),
        content: Text(
          '¿Estás seguro de aprobar el pago de S/. ${widget.pago.monto.toStringAsFixed(2)} '
          'para ${widget.pago.nombreUsuario}?\n\n'
          'Esta acción activará automáticamente su suscripción.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Aprobar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _isProcessing = true);
      
      try {
        await AdminService.aprobarPago(widget.pago.id);
        
        HapticFeedback.heavyImpact();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Pago aprobado exitosamente - Usuario será notificado'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Ver detalles',
                textColor: Colors.white,
                onPressed: () {
                  // Mostrar info adicional
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('🎉 Pago Aprobado'),
                      content: Text(
                        'El usuario ${widget.pago.nombreUsuario} recibirá una notificación automática.\n\n'
                        '• Su suscripción se activará inmediatamente\n'
                        '• Los límites se actualizarán automáticamente\n'
                        '• Recibirá un popup de confirmación\n\n'
                        '🔄 El sistema se sincronizará en unos segundos.'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Entendido'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
          
          widget.onApproved?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error aprobando pago: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Future<void> _rechazarPago() async {
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => _buildRechazarDialog(),
    );

    if (motivo != null && motivo.isNotEmpty) {
      setState(() => _isProcessing = true);
      
      try {
        await AdminService.rechazarPago(widget.pago.id, motivo);
        
        HapticFeedback.lightImpact();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Pago rechazado'),
              backgroundColor: Colors.red,
            ),
          );
          
          widget.onRejected?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error rechazando pago: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Widget _buildRechazarDialog() {
    final TextEditingController motivoController = TextEditingController();
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.cancel, color: Colors.red, size: 28),
          SizedBox(width: 12),
          Text('Rechazar Pago'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('¿Por qué rechazas este pago?'),
          const SizedBox(height: 16),
          TextField(
            controller: motivoController,
            decoration: const InputDecoration(
              hintText: 'Motivo del rechazo...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(motivoController.text.trim()),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Rechazar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // ========================================
  // UTILIDADES
  // ========================================

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'verificando':
        return Colors.blue;
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.hourglass_empty;
      case 'verificando':
        return Icons.search;
      case 'aprobado':
        return Icons.check_circle;
      case 'rechazado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
