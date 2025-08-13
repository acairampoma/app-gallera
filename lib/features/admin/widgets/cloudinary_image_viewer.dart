// 🖼️ Viewer ÉPICO de Imágenes Cloudinary
// Con zoom, gestos y optimización avanzada

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CloudinaryImageViewer extends StatefulWidget {
  final String imageUrl;
  final String title;
  final VoidCallback? onClose;

  const CloudinaryImageViewer({
    Key? key,
    required this.imageUrl,
    this.title = 'Comprobante de Pago',
    this.onClose,
  }) : super(key: key);

  @override
  State<CloudinaryImageViewer> createState() => _CloudinaryImageViewerState();
}

class _CloudinaryImageViewerState extends State<CloudinaryImageViewer>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  late Animation<Matrix4> _animation;
  
  bool _isLoading = true;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward(from: 0);
    _animation.addListener(() {
      _transformationController.value = _animation.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 🖼️ Imagen principal con zoom
            Center(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 5.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          // Imagen cargada
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                                _hasError = false;
                              });
                            }
                          });
                          return child;
                        }
                        
                        // Mostrando progreso de carga
                        return Container(
                          width: 300,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                                color: Colors.orange,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                loadingProgress.expectedTotalBytes != null
                                    ? '${((loadingProgress.cumulativeBytesLoaded / 
                                         (loadingProgress.expectedTotalBytes ?? 1)) * 100).toInt()}%'
                                    : 'Cargando...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                              _hasError = true;
                            });
                          }
                        });
                        
                        return Container(
                          width: 300,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.red.shade900,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade700),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Error cargando imagen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Verifica la URL de Cloudinary',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // 🔧 Barra superior con controles
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Botón cerrar
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Título
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Botón reset zoom
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        onPressed: _resetZoom,
                        icon: const Icon(Icons.zoom_out_map, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 💡 Instrucciones de uso
            if (!_isLoading && !_hasError)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Pellizca para hacer zoom • Doble tap para resetear',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 🖼️ Widget simplificado para preview de imagen
class CloudinaryImagePreview extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final String? heroTag;

  const CloudinaryImagePreview({
    Key? key,
    required this.imageUrl,
    this.width = 100,
    this.height = 80,
    this.onTap,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
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
                  strokeWidth: 2,
                  color: Colors.orange,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, 
                       color: Colors.grey, size: 24),
                  SizedBox(height: 4),
                  Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // Wrap con Hero si se proporciona tag
    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    // Wrap con GestureDetector si se proporciona onTap
    if (onTap != null) {
      imageWidget = GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
