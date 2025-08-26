// 🛡️ Widget Interceptor de Límites - Sistema Universal
// Este widget intercepta todas las acciones que pueden requerir validación de límites

import 'package:flutter/material.dart';
import '../../services/suscripcion_service.dart';
import '../../models/suscripcion_models.dart';
import '../../models/pago_models.dart';
import 'upgrade_dialog.dart';

class LimiteInterceptor extends StatelessWidget {
  final RecursoTipo recursoTipo;
  final int? galloId;
  final VoidCallback onPermitido;
  final Widget child;
  final String? mensajePersonalizado;

  const LimiteInterceptor({
    Key? key,
    required this.recursoTipo,
    required this.onPermitido,
    required this.child,
    this.galloId,
    this.mensajePersonalizado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _validarYEjecutar(context),
      child: child,
    );
  }

  Future<void> _validarYEjecutar(BuildContext context) async {
    try {
      // 🔍 Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Validar límite con el backend
      final validacion = await SuscripcionService.validarLimite(
        recursoTipo: recursoTipo.value,
        galloId: galloId,
      );

      // Cerrar indicador de carga
      if (context.mounted) Navigator.of(context).pop();

      if (validacion.puedeCrear) {
        // ✅ Puede crear, ejecutar acción
        onPermitido();
      } else {
        // ❌ Límite alcanzado, mostrar dialog de upgrade
        if (context.mounted) {
          _mostrarDialogoUpgrade(context, validacion);
        }
      }
    } catch (e) {
      // Cerrar indicador de carga en caso de error
      if (context.mounted) Navigator.of(context).pop();
      
      print('❌ Error validando límite: $e');
      
      // Mostrar error al usuario
      if (context.mounted) {
        _mostrarErrorDialog(context, e.toString());
      }
    }
  }

  void _mostrarDialogoUpgrade(BuildContext context, ValidacionLimite validacion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpgradeDialog(
        recursoTipo: recursoTipo,
        limiteSuperado: LimiteSuperadoError(
          detail: validacion.mensajeError ?? 'Límite alcanzado',
          limiteInfo: LimiteInfo(
            recursoTipo: validacion.recursoTipo,
            limiteActual: validacion.limiteActual,
            cantidadUsada: validacion.cantidadUsada,
            planRecomendado: validacion.planRecomendado,
            upgradeDisponible: validacion.upgradeDisponible,
          ),
          accionRequerida: 'upgrade_plan',
        ),
        galloId: galloId,
      ),
    );
  }

  void _mostrarErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 Error de Conexión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'No se pudo validar los límites de tu suscripción. Verifica tu conexión a internet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _validarYEjecutar(context); // Reintentar
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

// ========================================
// WIDGETS HELPER ESPECÍFICOS
// ========================================

/// 🐓 Interceptor específico para crear gallos
class LimiteGallosInterceptor extends StatelessWidget {
  final VoidCallback onPermitido;
  final Widget child;

  const LimiteGallosInterceptor({
    Key? key,
    required this.onPermitido,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LimiteInterceptor(
      recursoTipo: RecursoTipo.gallos,
      onPermitido: onPermitido,
      child: child,
    );
  }
}

/// 🏋️ Interceptor específico para crear entrenamientos/topes
class LimiteTopesInterceptor extends StatelessWidget {
  final int galloId;
  final VoidCallback onPermitido;
  final Widget child;

  const LimiteTopesInterceptor({
    Key? key,
    required this.galloId,
    required this.onPermitido,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LimiteInterceptor(
      recursoTipo: RecursoTipo.topes,
      galloId: galloId,
      onPermitido: onPermitido,
      child: child,
    );
  }
}

/// 🥊 Interceptor específico para crear peleas
class LimitePeleasInterceptor extends StatelessWidget {
  final int galloId;
  final VoidCallback onPermitido;
  final Widget child;

  const LimitePeleasInterceptor({
    Key? key,
    required this.galloId,
    required this.onPermitido,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LimiteInterceptor(
      recursoTipo: RecursoTipo.peleas,
      galloId: galloId,
      onPermitido: onPermitido,
      child: child,
    );
  }
}

/// 💉 Interceptor específico para crear vacunas
class LimiteVacunasInterceptor extends StatelessWidget {
  final int galloId;
  final VoidCallback onPermitido;
  final Widget child;

  const LimiteVacunasInterceptor({
    Key? key,
    required this.galloId,
    required this.onPermitido,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LimiteInterceptor(
      recursoTipo: RecursoTipo.vacunas,
      galloId: galloId,
      onPermitido: onPermitido,
      child: child,
    );
  }
}

// ========================================
// FUNCIÓN HELPER PARA VALIDACIÓN MANUAL
// ========================================

/// 🔍 Validar límite manualmente antes de ejecutar acción
Future<bool> validarLimiteManual(
  BuildContext context, {
  required RecursoTipo recursoTipo,
  int? galloId,
  bool mostrarError = true,
}) async {
  try {
    print('🔍 [ValidarLimite] Tipo: ${recursoTipo.value}, GalloId: $galloId');
    
    final validacion = await SuscripcionService.validarLimite(
      recursoTipo: recursoTipo.value,
      galloId: galloId,
    );
    
    print('🔍 [ValidarLimite] Puede crear: ${validacion.puedeCrear}');
    print('🔍 [ValidarLimite] Mensaje: ${validacion.mensajeError}');

    if (!validacion.puedeCrear && mostrarError && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => UpgradeDialog(
          recursoTipo: recursoTipo,
          limiteSuperado: LimiteSuperadoError(
            detail: validacion.mensajeError ?? 'Límite alcanzado',
            limiteInfo: LimiteInfo(
              recursoTipo: validacion.recursoTipo,
              limiteActual: validacion.limiteActual,
              cantidadUsada: validacion.cantidadUsada,
              planRecomendado: validacion.planRecomendado,
              upgradeDisponible: validacion.upgradeDisponible,
            ),
            accionRequerida: 'upgrade_plan',
          ),
          galloId: galloId,
        ),
      );
    }

    return validacion.puedeCrear;
  } catch (e) {
    print('❌ Error en validación manual: $e');
    
    if (mostrarError && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: ${e.toString()}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    
    // En caso de error de conexión, permitir acceso (fail-open)
    return true;
  }
}

// ========================================
// WIDGET DE ESTADO DE LÍMITES
// ========================================

/// 📊 Widget que muestra el estado actual de los límites
class EstadoLimitesWidget extends StatelessWidget {
  final RecursoTipo recursoTipo;
  final int? galloId;
  final bool mostrarProgreso;

  const EstadoLimitesWidget({
    Key? key,
    required this.recursoTipo,
    this.galloId,
    this.mostrarProgreso = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ValidacionLimite>(
      future: SuscripcionService.validarLimite(
        recursoTipo: recursoTipo.value,
        galloId: galloId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Icon(Icons.error, color: Colors.red);
        }

        final validacion = snapshot.data!;
        final porcentaje = validacion.limiteActual > 0 
            ? validacion.cantidadUsada / validacion.limiteActual 
            : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(recursoTipo.icono),
                const SizedBox(width: 8),
                Text(
                  '${validacion.cantidadUsada}/${validacion.limiteActual}',
                  style: TextStyle(
                    color: validacion.puedeCrear ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (mostrarProgreso) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: porcentaje,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  porcentaje >= 0.9 
                      ? Colors.red 
                      : porcentaje >= 0.7 
                          ? Colors.orange 
                          : Colors.green,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}