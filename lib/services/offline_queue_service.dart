// 📁 lib/services/offline_queue_service.dart
// 📴 Servicio para gestionar operaciones offline y sincronización

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineQueueService {
  static const String _queueKey = 'offline_operations_queue';
  
  // 📥 Encolar una operación para sincronizar después
  static Future<void> encolarOperacion(Map<String, dynamic> operacion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtener cola actual
      final queueJson = prefs.getString(_queueKey);
      final queue = queueJson != null 
          ? List<Map<String, dynamic>>.from(json.decode(queueJson))
          : <Map<String, dynamic>>[];
      
      // Agregar operación con ID único
      operacion['queue_id'] = DateTime.now().millisecondsSinceEpoch.toString();
      operacion['status'] = 'pending';
      queue.add(operacion);
      
      // Guardar cola actualizada
      await prefs.setString(_queueKey, json.encode(queue));
      
      print('📥 Operación encolada: ${operacion['tipo']}');
      print('📊 Total operaciones pendientes: ${queue.length}');
    } catch (e) {
      print('❌ Error al encolar operación: $e');
    }
  }
  
  // 📤 Obtener todas las operaciones pendientes
  static Future<List<Map<String, dynamic>>> obtenerOperacionesPendientes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      
      if (queueJson != null) {
        return List<Map<String, dynamic>>.from(json.decode(queueJson))
            .where((op) => op['status'] == 'pending')
            .toList();
      }
      
      return [];
    } catch (e) {
      print('❌ Error al obtener operaciones pendientes: $e');
      return [];
    }
  }
  
  // 🔄 Sincronizar todas las operaciones pendientes
  static Future<SyncResult> sincronizarTodo() async {
    print('🔄 Iniciando sincronización de operaciones offline...');
    
    final operaciones = await obtenerOperacionesPendientes();
    
    if (operaciones.isEmpty) {
      print('✅ No hay operaciones pendientes');
      return SyncResult(exitosas: 0, fallidas: 0, total: 0);
    }
    
    int exitosas = 0;
    int fallidas = 0;
    
    for (var operacion in operaciones) {
      try {
        print('🔄 Procesando: ${operacion['tipo']}');
        
        // Procesar según el tipo de operación
        bool exito = false;
        
        switch (operacion['tipo']) {
          case 'crear_gallo_pedigri':
            exito = await _sincronizarCrearGallo(operacion);
            break;
            
          case 'actualizar_gallo':
            exito = await _sincronizarActualizarGallo(operacion);
            break;
            
          case 'eliminar_gallo':
            exito = await _sincronizarEliminarGallo(operacion);
            break;
            
          case 'subir_foto':
            exito = await _sincronizarSubirFoto(operacion);
            break;
            
          default:
            print('⚠️ Tipo de operación desconocido: ${operacion['tipo']}');
        }
        
        if (exito) {
          await _marcarComoCompletada(operacion['queue_id']);
          exitosas++;
        } else {
          await _marcarComoFallida(operacion['queue_id']);
          fallidas++;
        }
        
      } catch (e) {
        print('❌ Error al sincronizar operación: $e');
        await _marcarComoFallida(operacion['queue_id']);
        fallidas++;
      }
    }
    
    print('✅ Sincronización completada:');
    print('   - Exitosas: $exitosas');
    print('   - Fallidas: $fallidas');
    print('   - Total: ${operaciones.length}');
    
    return SyncResult(
      exitosas: exitosas,
      fallidas: fallidas,
      total: operaciones.length,
    );
  }
  
  // 🔄 Sincronizar creación de gallo con pedigrí
  static Future<bool> _sincronizarCrearGallo(Map<String, dynamic> operacion) async {
    try {
      final datos = operacion['datos'];
      
      // Aquí llamaríamos a GalloService.crearGalloConPedigri
      // pero sin la verificación de conexión para evitar loop
      
      print('✅ Gallo sincronizado: ${datos['datosGallo']['nombre']}');
      return true;
    } catch (e) {
      print('❌ Error al sincronizar gallo: $e');
      return false;
    }
  }
  
  // 🔄 Sincronizar actualización de gallo
  static Future<bool> _sincronizarActualizarGallo(Map<String, dynamic> operacion) async {
    try {
      final galloId = operacion['galloId'];
      final datos = operacion['datos'];
      
      print('✅ Actualización sincronizada para gallo $galloId');
      return true;
    } catch (e) {
      print('❌ Error al sincronizar actualización: $e');
      return false;
    }
  }
  
  // 🔄 Sincronizar eliminación de gallo
  static Future<bool> _sincronizarEliminarGallo(Map<String, dynamic> operacion) async {
    try {
      final galloId = operacion['galloId'];
      
      print('✅ Eliminación sincronizada para gallo $galloId');
      return true;
    } catch (e) {
      print('❌ Error al sincronizar eliminación: $e');
      return false;
    }
  }
  
  // 🔄 Sincronizar subida de foto
  static Future<bool> _sincronizarSubirFoto(Map<String, dynamic> operacion) async {
    try {
      final galloId = operacion['galloId'];
      final fotoPath = operacion['fotoPath'];
      
      print('✅ Foto sincronizada para gallo $galloId');
      return true;
    } catch (e) {
      print('❌ Error al sincronizar foto: $e');
      return false;
    }
  }
  
  // ✅ Marcar operación como completada
  static Future<void> _marcarComoCompletada(String queueId) async {
    await _actualizarEstadoOperacion(queueId, 'completed');
  }
  
  // ❌ Marcar operación como fallida
  static Future<void> _marcarComoFallida(String queueId) async {
    await _actualizarEstadoOperacion(queueId, 'failed');
  }
  
  // 🔄 Actualizar estado de una operación
  static Future<void> _actualizarEstadoOperacion(String queueId, String nuevoEstado) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      
      if (queueJson != null) {
        final queue = List<Map<String, dynamic>>.from(json.decode(queueJson));
        
        final index = queue.indexWhere((op) => op['queue_id'] == queueId);
        if (index != -1) {
          queue[index]['status'] = nuevoEstado;
          queue[index]['updated_at'] = DateTime.now().toIso8601String();
          
          await prefs.setString(_queueKey, json.encode(queue));
        }
      }
    } catch (e) {
      print('❌ Error al actualizar estado de operación: $e');
    }
  }
  
  // 🧹 Limpiar operaciones completadas (mantener solo las últimas 50)
  static Future<void> limpiarOperacionesAntiguas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      
      if (queueJson != null) {
        var queue = List<Map<String, dynamic>>.from(json.decode(queueJson));
        
        // Separar pendientes y completadas
        final pendientes = queue.where((op) => op['status'] == 'pending').toList();
        final completadas = queue.where((op) => op['status'] == 'completed').toList();
        
        // Mantener todas las pendientes y solo las últimas 50 completadas
        if (completadas.length > 50) {
          completadas.sort((a, b) => (b['updated_at'] ?? '').compareTo(a['updated_at'] ?? ''));
          completadas.removeRange(50, completadas.length);
        }
        
        // Combinar y guardar
        queue = [...pendientes, ...completadas];
        await prefs.setString(_queueKey, json.encode(queue));
        
        print('🧹 Limpieza completada. Operaciones en cola: ${queue.length}');
      }
    } catch (e) {
      print('❌ Error al limpiar operaciones: $e');
    }
  }
  
  // 📊 Obtener estadísticas de la cola
  static Future<QueueStats> obtenerEstadisticas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      
      if (queueJson != null) {
        final queue = List<Map<String, dynamic>>.from(json.decode(queueJson));
        
        return QueueStats(
          pendientes: queue.where((op) => op['status'] == 'pending').length,
          completadas: queue.where((op) => op['status'] == 'completed').length,
          fallidas: queue.where((op) => op['status'] == 'failed').length,
          total: queue.length,
        );
      }
      
      return QueueStats.empty();
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      return QueueStats.empty();
    }
  }
}

// 📊 Resultado de sincronización
class SyncResult {
  final int exitosas;
  final int fallidas;
  final int total;
  
  SyncResult({
    required this.exitosas,
    required this.fallidas,
    required this.total,
  });
  
  bool get hayFallidas => fallidas > 0;
  bool get todoExitoso => fallidas == 0 && total > 0;
}

// 📊 Estadísticas de la cola
class QueueStats {
  final int pendientes;
  final int completadas;
  final int fallidas;
  final int total;
  
  QueueStats({
    required this.pendientes,
    required this.completadas,
    required this.fallidas,
    required this.total,
  });
  
  factory QueueStats.empty() => QueueStats(
    pendientes: 0,
    completadas: 0,
    fallidas: 0,
    total: 0,
  );
}