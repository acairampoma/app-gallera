import 'package:flutter/material.dart';
import '../constants/app_icons.dart'; // 🔥 IMPORTAR ÍCONOS CENTRALIZADOS

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFD32F2F),
      backgroundColor: Colors.white,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.galloNavBar(currentIndex == 1), // 🐓 Usando ícono centralizado
          label: 'Gallos',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Reportes',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Planes',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}