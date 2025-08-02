import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({Key? key}) : super(key: key);

  @override
  State<PlanesScreen> createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '📋 Planes de Gallos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.sports), text: 'TOPES'),
            Tab(icon: Icon(Icons.psychology), text: 'PELEAS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTopesTab(),
          _buildPeleasTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlanDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // 🏋️ TAB DE TOPES
  Widget _buildTopesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPlanCard(
            '🏋️ Plan de Tope - El Campeón',
            'Entrenamiento intensivo para competencia',
            'Fecha: 15 Feb 2025',
            'Duración: 45 minutos',
            'Ubicación: Patio trasero',
            hasVideo: true,
            videoPath: 'videos/tope_campeon.mp4',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            '💪 Tope de Resistencia - Relámpago',
            'Mejora de condición física y resistencia',
            'Fecha: 18 Feb 2025',
            'Duración: 30 minutos',
            'Ubicación: Campo de entrenamiento',
            hasVideo: false,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            '⚡ Tope de Velocidad - Trueno',
            'Ejercicios para mejorar velocidad de ataque',
            'Fecha: 20 Feb 2025',
            'Duración: 25 minutos',
            'Ubicación: Arena de práctica',
            hasVideo: true,
            videoPath: 'videos/tope_trueno.mp4',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  // ⚔️ TAB DE PELEAS
  Widget _buildPeleasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPlanCard(
            '⚔️ Pelea Regional - El Campeón',
            'Competencia oficial regional',
            'Fecha: 25 Feb 2025',
            'Hora: 3:00 PM',
            'Ubicación: Coliseo Municipal',
            hasVideo: true,
            videoPath: 'videos/pelea_campeon.mp4',
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            '🏆 Torneo de Campeones - Relámpago',
            'Participación en torneo principal',
            'Fecha: 2 Mar 2025',
            'Hora: 4:30 PM',
            'Ubicación: Arena Central',
            hasVideo: false,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            '🥇 Final del Circuito - Trueno',
            'Pelea final del circuito anual',
            'Fecha: 8 Mar 2025',
            'Hora: 5:00 PM',
            'Ubicación: Estadio Mayor',
            hasVideo: true,
            videoPath: 'videos/final_trueno.mp4',
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }

  // 📄 CARD DE PLAN CON OPCIÓN DE VIDEO
  Widget _buildPlanCard(
    String title,
    String description,
    String fecha,
    String duracion,
    String ubicacion, {
    bool hasVideo = false,
    String? videoPath,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y estado de video
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              if (hasVideo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'VIDEO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Descripción
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Detalles
          _buildDetailRow('📅', fecha),
          _buildDetailRow('⏰', duracion),
          _buildDetailRow('📍', ubicacion),
          
          const SizedBox(height: 16),
          
          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _editPlan(title),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (hasVideo) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _playVideo(videoPath!),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Ver Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasVideo ? () => _addVideo(title) : () => _addVideo(title),
                  icon: Icon(
                    hasVideo ? Icons.video_library : Icons.add_a_photo,
                    size: 16,
                  ),
                  label: Text(hasVideo ? 'Cambiar' : 'Agregar Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // 🎬 REPRODUCIR VIDEO
  void _playVideo(String videoPath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.play_circle, color: Colors.red),
            SizedBox(width: 8),
            Text('Reproducir Video'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Video Player\n(Simulación)',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Archivo: $videoPath'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // 📹 AGREGAR/CAMBIAR VIDEO
  void _addVideo(String planTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.videocam, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Agregar Video'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('Grabar nuevo video'),
              subtitle: Text('Usar cámara del dispositivo'),
            ),
            ListTile(
              leading: Icon(Icons.folder, color: Colors.green),
              title: Text('Seleccionar archivo'),
              subtitle: Text('Elegir video de galería'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showVideoAdded(planTitle);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Seleccionar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showVideoAdded(String planTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Video agregado a: $planTitle'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ✏️ EDITAR PLAN
  void _editPlan(String planTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✏️ Editando: $planTitle'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ➕ AGREGAR NUEVO PLAN
  void _showAddPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('➕ Nuevo Plan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.sports, color: Colors.blue),
              title: Text('Plan de Tope'),
              subtitle: Text('Entrenamiento y práctica'),
            ),
            ListTile(
              leading: Icon(Icons.psychology, color: Colors.red),
              title: Text('Plan de Pelea'),
              subtitle: Text('Competencia oficial'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
