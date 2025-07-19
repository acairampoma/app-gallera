import 'package:flutter/material.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'GallosPro',
      subtitle: 'Gestión Profesional de Gallos de Pelea',
      currentIndex: 0,
      showQuickNav: true,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildMenuGrid(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserName() {
    return Text(
      AuthService.instance.currentUser?.nombreCompleto ?? 'Usuario',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildUserName(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menuItems = [
      _MenuItem(
        title: 'Pedigrí',
        icon: Icons.assignment,
        color: Colors.blue,
        subtitle: 'Registro genealógico',
        onTap: () {
          Navigator.pushNamed(context, '/pedigri');
        },
      ),
      _MenuItem(
        title: 'Vacunas',
        icon: Icons.medical_services,
        color: Colors.green,
        subtitle: 'Control sanitario',
        onTap: () {
          Navigator.pushNamed(context, '/vacunas');
        },
      ),
      _MenuItem(
        title: 'Topes',
        icon: Icons.fitness_center,
        color: Colors.orange,
        subtitle: 'Entrenamientos',
        onTap: () {
          Navigator.pushNamed(context, '/topes');
        },
      ),
      _MenuItem(
        title: 'Peleas',
        icon: Icons.sports_mma,
        color: Colors.red,
        subtitle: 'Registro de combates',
        onTap: () {
          Navigator.pushNamed(context, '/peleas');
        },
      ),
      _MenuItem(
        title: 'Reportes',
        icon: Icons.bar_chart,
        color: Colors.purple,
        subtitle: 'Estadísticas y PDF',
        onTap: () {
          Navigator.pushNamed(context, '/reportes');
        },
      ),
      _MenuItem(
        title: 'Suscripción',
        icon: Icons.credit_card,
        color: Colors.grey,
        subtitle: 'Planes y pagos',
        onTap: () {
          // Navegar a pantalla de Suscripción
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItemCard(item);
      },
    );
  }

  Widget _buildMenuItemCard(_MenuItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 30,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (item.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
    required this.onTap,
  });
}