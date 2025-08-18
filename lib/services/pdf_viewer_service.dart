// 📱🔥 SERVICIO MEJORADO DE PDF CON PREVIEW INTEGRADO
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';  // 🔥 AGREGAMOS ESTA LÍNEA PARA PdfPageFormat
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

class PDFViewerService {
  /// 🔥 MÉTODO PRINCIPAL: Muestra PDF con opciones (ver, compartir, descargar)
  static Future<void> showPDFOptions({
    required BuildContext context,
    required String pdfBase64,
    required String fileName,
    String? title,
  }) async {
    try {
      print('📥 === INICIANDO VISOR DE PDF ===');
      print('📄 Archivo: $fileName');
      
      if (kIsWeb) {
        // En web, abrir directamente en nueva pestaña
        _openPDFInWeb(pdfBase64, fileName);
      } else {
        // En móvil, mostrar diálogo con opciones
        await _showPDFOptionsDialog(
          context: context,
          pdfBase64: pdfBase64,
          fileName: fileName,
          title: title,
        );
      }
    } catch (e) {
      print('❌ Error mostrando PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error abriendo PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 📱 DIÁLOGO DE OPCIONES PARA MÓVIL
  static Future<void> _showPDFOptionsDialog({
    required BuildContext context,
    required String pdfBase64,
    required String fileName,
    String? title,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Título
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title ?? 'Documento PDF',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            fileName,
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
              ),
              
              Divider(height: 1),
              
              // Opciones
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.visibility, color: Colors.blue),
                ),
                title: Text('Ver PDF'),
                subtitle: Text('Abrir en el visor integrado'),
                onTap: () {
                  Navigator.pop(context);
                  _viewPDF(context, pdfBase64, fileName);
                },
              ),
              
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.share, color: Colors.green),
                ),
                title: Text('Compartir'),
                subtitle: Text('Enviar por WhatsApp u otras apps'),
                onTap: () {
                  Navigator.pop(context);
                  _sharePDF(context, pdfBase64, fileName);
                },
              ),
              
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.download, color: Colors.orange),
                ),
                title: Text('Descargar'),
                subtitle: Text('Guardar en el dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadPDF(context, pdfBase64, fileName);
                },
              ),
              
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// 👀 VER PDF EN VISOR INTEGRADO
  static Future<void> _viewPDF(
    BuildContext context,
    String pdfBase64,
    String fileName,
  ) async {
    try {
      final bytes = base64Decode(pdfBase64);
      
      // Usar Printing para mostrar el PDF
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name: fileName,
        format: PdfPageFormat.a4,
      );
      
      print('✅ PDF abierto en visor integrado');
    } catch (e) {
      print('❌ Error viendo PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error abriendo PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 📤 COMPARTIR PDF
  static Future<void> _sharePDF(
    BuildContext context,
    String pdfBase64,
    String fileName,
  ) async {
    try {
      final bytes = base64Decode(pdfBase64);
      
      // Guardar temporalmente
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      // Compartir con Share Plus
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '📄 Documento: $fileName',
      );
      
      print('✅ PDF compartido exitosamente');
    } catch (e) {
      print('❌ Error compartiendo PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error compartiendo PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 💾 DESCARGAR PDF EN DISPOSITIVO
  static Future<void> _downloadPDF(
    BuildContext context,
    String pdfBase64,
    String fileName,
  ) async {
    try {
      // Solicitar permisos
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Se necesitan permisos de almacenamiento'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }
      
      final bytes = base64Decode(pdfBase64);
      
      // Determinar directorio de descarga
      Directory? directory;
      if (Platform.isAndroid) {
        // Intentar usar Downloads en Android
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        // iOS
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        throw Exception('No se pudo acceder al directorio de descarga');
      }
      
      // Crear archivo con nombre único si ya existe
      String finalPath = '${directory.path}/$fileName';
      int counter = 1;
      while (await File(finalPath).exists()) {
        final nameWithoutExt = fileName.replaceAll('.pdf', '');
        finalPath = '${directory.path}/${nameWithoutExt}_($counter).pdf';
        counter++;
      }
      
      final file = File(finalPath);
      await file.writeAsBytes(bytes);
      
      print('✅ PDF guardado en: ${file.path}');
      
      // Mostrar notificación con opción de abrir
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('PDF descargado exitosamente'),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Guardado en: Downloads',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'VER',
              textColor: Colors.white,
              onPressed: () {
                _viewPDF(context, pdfBase64, fileName);
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error descargando PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error descargando PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 🌐 ABRIR PDF EN WEB (NUEVA PESTAÑA)
  static void _openPDFInWeb(String pdfBase64, String fileName) {
    try {
      final bytes = base64Decode(pdfBase64);
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Abrir en nueva pestaña
      html.window.open(url, '_blank');
      
      // Limpiar después de 5 segundos
      Future.delayed(Duration(seconds: 5), () {
        html.Url.revokeObjectUrl(url);
      });
      
      print('✅ PDF abierto en nueva pestaña (Web)');
    } catch (e) {
      print('❌ Error abriendo PDF en web: $e');
    }
  }
}