// 📱🔥 SERVICIO MEJORADO DE PDF CON PREVIEW INTEGRADO
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/platform_factory.dart';
import '../services/platform_implementations/platform_service_base.dart';

class PDFViewerService {
  static late PlatformServiceBase _platformService;
  
  static void _initPlatformService() {
    _platformService = PlatformFactory.createPlatformService();
  }
  
  /// 🔥 MÉTODO PRINCIPAL: Muestra PDF con opciones (ver, compartir, descargar)
  static Future<void> showPDFOptions({
    required BuildContext context,
    required String pdfBase64,
    required String fileName,
    String? title,
  }) async {
    try {
      _initPlatformService();
      print('📥 === INICIANDO VISOR DE PDF ===');
      print('📄 Archivo: $fileName');
      
      if (_platformService.isWeb) {
        // En web, usar platform service
        await _platformService.downloadPDF(pdfBase64, fileName);
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
                  _platformService.generateAndPrintPDF(pdfBase64, fileName: fileName);
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
                  _platformService.sharePDF(pdfBase64, fileName);
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
                  _platformService.downloadPDF(pdfBase64, fileName);
                },
              ),
              
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}