import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuickNavFAB extends StatelessWidget {
  const QuickNavFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showQuickNavMenu(context),
      backgroundColor: AppColors.primary,
      heroTag: "quick_nav",
      child: const Icon(Icons.apps, color: Colors.white),
    );
  }

  void _showQuickNavMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Navegación Rápida',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: [
                _buildNavButton(context, 'Inicio', Icons.home, '/home'),
                _buildNavButton(context, 'Pedigrí', Icons.assignment, '/pedigri'),
                _buildNavButton(context, 'Vacunas', Icons.medical_services, '/vacunas'),
                _buildNavButton(context, 'Topes', Icons.fitness_center, '/topes'),
                _buildNavButton(context, 'Peleas', Icons.sports_mma, '/peleas'),
                _buildNavButton(context, 'Reportes', Icons.bar_chart, '/reportes'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, IconData icon, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == route;
    
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.primary : Colors.grey[100],
        foregroundColor: isActive ? Colors.white : Colors.grey[700],
        elevation: isActive ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}