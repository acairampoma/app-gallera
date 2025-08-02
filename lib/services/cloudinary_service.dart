// 📁 lib/services/cloudinary_service.dart
// 📸 SERVICIO CLOUDINARY ÉPICO - Subida de fotos de gallos

import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // 🔧 CONFIGURACIÓN CLOUDINARY
  static const String _cloudName = 'tu-cloud-name'; // ⚠️ CAMBIAR POR TU CLOUD NAME
  static const String _uploadPreset = 'gallos_preset'; // ⚠️ CAMBIAR POR TU UPLOAD PRESET
  
  /// 📸 Subir foto de gallo a Cloudinary
  /// Retorna la URL segura de la imagen subida
  static Future<String?> uploadGalloPhoto(File imageFile, String galloCode) async {
    try {
      print('📸 CloudinaryService: Subiendo foto del gallo $galloCode...');
      
      // 🚀 Crear