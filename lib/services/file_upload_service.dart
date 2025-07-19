import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class FileUploadService {
  static FileUploadService? _instance;
  static FileUploadService get instance => _instance ??= FileUploadService._();
  FileUploadService._();

  // 🔥 SIMULACIÓN DE SUBIDA DE ARCHIVOS PARA DEMO WEB
  
  Future<FileUploadResult> uploadImage({
    required Uint8List fileBytes,
    required String filename,
    required String tipo, // 'gallo_foto', 'avatar', 'thumbnail'
    int? galloId,
  }) async {
    try {
      print('📁 [MOCK] Subiendo imagen: $filename');
      print('📁 [MOCK] Tipo: $tipo, Tamaño: ${fileBytes.length} bytes');
      
      // Simular delay de subida
      await Future.delayed(Duration(milliseconds: 1500));
      
      // Validar formato (mock)
      if (!_isValidImageFormat(filename)) {
        return FileUploadResult.failure('Formato no soportado. Use JPG, PNG o WEBP');
      }
      
      // Validar tamaño (mock)
      if (fileBytes.length > 10 * 1024 * 1024) { // 10MB
        return FileUploadResult.failure('Archivo muy grande. Máximo 10MB');
      }
      
      // Generar URLs mock
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final baseName = filename.split('.').first;
      final extension = filename.split('.').last;
      
      final mockUrl = '/uploads/$tipo/${baseName}_$timestamp.$extension';
      final thumbnailUrl = '/uploads/thumbs/${baseName}_$timestamp\_thumb.$extension';
      
      print('✅ [MOCK] Imagen subida exitosamente: $mockUrl');
      
      return FileUploadResult.success(
        url: mockUrl,
        thumbnailUrl: thumbnailUrl,
        filename: '${baseName}_$timestamp.$extension',
        fileSize: fileBytes.length,
      );
      
    } catch (e) {
      print('❌ [MOCK] Error subiendo imagen: $e');
      return FileUploadResult.failure('Error interno del servidor');
    }
  }
  
  Future<FileUploadResult> uploadVideo({
    required Uint8List fileBytes,
    required String filename,
    required String tipo, // 'pelea_video', 'entrenamiento_video'
    int? relacionId,
  }) async {
    try {
      print('🎥 [MOCK] Subiendo video: $filename');
      print('🎥 [MOCK] Tipo: $tipo, Tamaño: ${fileBytes.length} bytes');
      
      // Simular delay de subida (videos tardan más)
      await Future.delayed(Duration(milliseconds: 3000));
      
      // Validar formato (mock)
      if (!_isValidVideoFormat(filename)) {
        return FileUploadResult.failure('Formato no soportado. Use MP4, MOV o AVI');
      }
      
      // Validar tamaño (mock)
      if (fileBytes.length > 500 * 1024 * 1024) { // 500MB
        return FileUploadResult.failure('Video muy grande. Máximo 500MB');
      }
      
      // Generar URLs mock
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final baseName = filename.split('.').first;
      final extension = filename.split('.').last;
      
      final mockUrl = '/uploads/videos/${baseName}_$timestamp.$extension';
      final thumbnailUrl = '/uploads/thumbs/${baseName}_$timestamp\_thumb.jpg';
      
      // Simular duración del video (mock)
      final mockDurationSeconds = (fileBytes.length / (1024 * 1024) * 60).round();
      
      print('✅ [MOCK] Video subido exitosamente: $mockUrl');
      
      return FileUploadResult.success(
        url: mockUrl,
        thumbnailUrl: thumbnailUrl,
        filename: '${baseName}_$timestamp.$extension',
        fileSize: fileBytes.length,
        durationSeconds: mockDurationSeconds,
      );
      
    } catch (e) {
      print('❌ [MOCK] Error subiendo video: $e');
      return FileUploadResult.failure('Error interno del servidor');
    }
  }
  
  // Método para convertir archivo a base64 (referencia para FastAPI)
  String fileToBase64(Uint8List fileBytes) {
    return base64Encode(fileBytes);
  }
  
  // Validaciones mock
  bool _isValidImageFormat(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }
  
  bool _isValidVideoFormat(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv'].contains(extension);
  }
  
  // Simular progreso de subida (para UI)
  Stream<double> simulateUploadProgress() async* {
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(Duration(milliseconds: 100));
      yield i / 100.0;
    }
  }
}

class FileUploadResult {
  final bool success;
  final String? message;
  final String? url;
  final String? thumbnailUrl;
  final String? filename;
  final int? fileSize;
  final int? durationSeconds;

  FileUploadResult._({
    required this.success,
    this.message,
    this.url,
    this.thumbnailUrl,
    this.filename,
    this.fileSize,
    this.durationSeconds,
  });

  factory FileUploadResult.success({
    required String url,
    String? thumbnailUrl,
    String? filename,
    int? fileSize,
    int? durationSeconds,
  }) {
    return FileUploadResult._(
      success: true,
      message: 'Archivo subido exitosamente',
      url: url,
      thumbnailUrl: thumbnailUrl,
      filename: filename,
      fileSize: fileSize,
      durationSeconds: durationSeconds,
    );
  }

  factory FileUploadResult.failure(String message) {
    return FileUploadResult._(
      success: false,
      message: message,
    );
  }

  // Convertir a JSON para FastAPI
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'filename': filename,
      'file_size_bytes': fileSize,
      'duration_seconds': durationSeconds,
    };
  }
}