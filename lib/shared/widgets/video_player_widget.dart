// 📁 lib/shared/widgets/video_player_widget.dart
// 🎬 Reproductor de video elegante con controles avanzar/retroceder

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final bool autoPlay;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.title,
    this.autoPlay = false,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  String _errorMessage = '';
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      print('🎬 Inicializando video: ${widget.videoUrl}');
      
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
      await _controller!.initialize();
      
      _controller!.addListener(_videoListener);
      
      setState(() {
        _isInitialized = true;
        _totalDuration = _controller!.value.duration;
      });

      if (widget.autoPlay) {
        await _controller!.play();
        setState(() => _isPlaying = true);
      }

      print('✅ Video inicializado exitosamente');
      
    } catch (e) {
      print('❌ Error inicializando video: $e');
      setState(() {
        _errorMessage = 'Error al cargar el video: $e';
        _isInitialized = false;
      });
    }
  }

  void _videoListener() {
    if (_controller != null) {
      setState(() {
        _currentPosition = _controller!.value.position;
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detectar orientación
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Altura máxima para evitar estiramiento
    final maxHeight = isLandscape 
        ? MediaQuery.of(context).size.height * 0.8
        : screenWidth * 0.6; // Máximo 60% del ancho en vertical
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _controller != null && _controller!.value.isInitialized
            ? Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: _buildVideoContent(),
                ),
              )
            : SizedBox(
                width: double.infinity,
                height: 200,
                child: _buildVideoContent(),
              ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return GestureDetector(
      onTap: _toggleControlsVisibility,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player
          VideoPlayer(_controller!),
          
          // Controls overlay
          if (_showControls) _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Cargando video...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.title != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.title!,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al reproducir video',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _initializeVideo,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header con título
          if (widget.title != null) _buildHeader(),
          
          // Controles centrales
          Expanded(child: _buildCenterControls()),
          
          // Progress bar y controles inferiores
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Retroceder 10 segundos
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: _rewind10Seconds,
          tooltip: 'Retroceder 10s',
        ),
        
        // Play/Pause
        _buildControlButton(
          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
          onPressed: _togglePlayPause,
          tooltip: _isPlaying ? 'Pausar' : 'Reproducir',
          size: 64,
        ),
        
        // Avanzar 10 segundos
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: _forward10Seconds,
          tooltip: 'Avanzar 10s',
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    double size = 48,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: size * 0.6,
        ),
        iconSize: size,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress bar
          VideoProgressIndicator(
            _controller!,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Theme.of(context).primaryColor,
              bufferedColor: Colors.white.withOpacity(0.4),
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          
          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });

    // Auto-hide controls after 3 seconds
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    if (_isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _rewind10Seconds() {
    if (_controller == null) return;
    
    final currentPosition = _controller!.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    final targetPosition = newPosition < Duration.zero ? Duration.zero : newPosition;
    
    _controller!.seekTo(targetPosition);
  }

  void _forward10Seconds() {
    if (_controller == null) return;
    
    final currentPosition = _controller!.value.position;
    final totalDuration = _controller!.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    final targetPosition = newPosition > totalDuration ? totalDuration : newPosition;
    
    _controller!.seekTo(targetPosition);
  }
}

// Widget para mostrar video en modal
class VideoPlayerModal {
  static void show(BuildContext context, {
    required String videoUrl,
    String? title,
  }) {
    // Permitir rotación automática
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        return Container(
          height: isLandscape 
              ? MediaQuery.of(context).size.height 
              : MediaQuery.of(context).size.height * 0.5, // Reducido de 0.7 a 0.5
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Video player - adaptativo según orientación
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 0 : 8,
                  vertical: isLandscape ? 0 : 4,
                ),
                child: VideoPlayerWidget(
                  videoUrl: videoUrl,
                  title: title,
                  autoPlay: true,
                ),
              ),
            ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Restaurar orientación al cerrar
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    });
  }
}