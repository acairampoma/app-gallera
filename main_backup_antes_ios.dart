import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const CastaDeGallosApp());
}

class CastaDeGallosApp extends StatelessWidget {
  const CastaDeGallosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casta de Gallos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casta de Gallos'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 100,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'Casta de Gallos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'iOS Build v1.1.4+804',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '✅ Configuración minimalista activa',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}