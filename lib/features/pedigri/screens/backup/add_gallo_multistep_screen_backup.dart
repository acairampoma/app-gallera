import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../shared/theme/app_colors.dart';

// 🎯 COLORES DEL DISEÑO HTML ROJO
class PedigriColors {
  static const primary = Color(0xFFd32f2f);  // Rojo del header HTML
  static const primaryDark = Color(0xFFb71c1c);
  static const background = Color(0xFFffffff); // Fondo blanco
  static const cardBackground = Color(0xFFffffff);
  static const textPrimary = Color(0xFF212529);
  static const borderGray = Color(0xFFddd);
  
  // Colores genealógicos del HTML
  static const fatherCard = Color(0xFFffebee);
  static const motherCard = Color(0xFFfffde7);
  static const fatherBorder = Color(0xFFffcdd2);
  static const motherBorder = Color(0xFFfff9c4);
}

class AddGalloMultistepScreen extends StatefulWidget {
  const AddGalloMultistepScreen({Key? key}) : super(key: key);

  @override
  State<AddGalloMultistepScreen> createState() => _AddGalloMultistepScreenState();
}

class _AddGalloMultistepScreenState extends State<AddGalloMultistepScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Argumentos pasados desde la pantalla anterior
  List<dynamic> razas = [];
  List<dynamic> gallosExistentes = [];
  bool _isDataLoaded = false;
  
  // Estado del formulario
  final _formKey = GlobalKey<FormState>();
  File? _selectedPhoto;
  String? _fotoPath;
  String? _assetImagePath; // Nueva variable para imágenes de assets
  bool _isAssetImage = false; // Flag para saber si es asset o archivo
  
  // Controladores de texto (reutilizando del dialog original)
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _colorController = TextEditingController();
  final _caracteristicasController = TextEditingController();
  final _procedenciaController = TextEditingController();
  final _precioController = TextEditingController();
  final _notasController = TextEditingController();

  // Variables de estado (reutilizando del dialog original)
  DateTime? _fechaNacimiento;
  DateTime? _fechaCompra;
  int? _razaSeleccionada;
  int? _padreSeleccionado;
  int? _madreSeleccionada;
  String _temperamentoSeleccionado = 'Agresivo';
  String _estadoSeleccionado = 'activo';
  
  // Variables para genealogía con tabs
  int _genealogyTabIndex = 0; // 0 = Padre, 1 = Madre
  
  // Controladores para datos del padre
  final _padreNombreController = TextEditingController();
  final _padreRegistroController = TextEditingController();
  final _padrePlacaController = TextEditingController();
  String _padreUbicacionPlaca = '';
  int? _padreRazaSeleccionada;
  
  // Controladores para datos de la madre
  final _madreNombreController = TextEditingController();
  final _madreRegistroController = TextEditingController();
  final _madrePlacaController = TextEditingController();
  String _madreUbicacionPlaca = '';
  int? _madreRazaSeleccionada;

  // Listas predeterminadas (del dialog original)
  final List<String> _temperamentos = [
    'Agresivo',
    'Defensivo',
    'Equilibrado',
    'Cauteloso'
  ];

  final List<String> _estados = [
    'activo',
    'entrenamiento',
    'lesionado',
    'retirado'
  ];

  // Lista de imágenes predeterminadas en assets
  final List<String> _assetImages = [
    'assets/imagenes/gallos/gallo_colorado.jpg',
    'assets/imagenes/gallos/gallo_giro.jpg', 
    'assets/imagenes/gallos/gallo_negro.jpg',
    'assets/imagenes/gallos/gallo_blanco.jpg',
    'assets/imagenes/gallos/gallo_canelo.jpg',
    'assets/imagenes/gallos/gallo_pinto.jpg',
    'assets/imagenes/gallos/gallo_cenizo.jpg',
    'assets/imagenes/gallos/gallo_default.jpg',
  ];

  final List<String> _coloresPredeterminados = [
    'Colorado',
    'Giro',
    'Negro',
    'Blanco',
    'Canelo',
    'Pinto',
    'Cenizo'
  ];
  
  // Lista de ubicaciones de placa
  final List<String> _ubicacionesPlaca = [
    'Ala derecha',
    'Ala izquierda', 
    'Pata derecha',
    'Pata izquierda'
  ];

  @override
  void initState() {
    super.initState();
    // Obtener argumentos pasados desde la pantalla anterior
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          razas = args['razas'] ?? [];
          gallosExistentes = args['gallosExistentes'] ?? [];
          _isDataLoaded = true;
        });
      } else {
        setState(() {
          _isDataLoaded = true;
        });
      }
    } catch (e) {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nombreController.dispose();
    _codigoController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _colorController.dispose();
    _caracteristicasController.dispose();
    _procedenciaController.dispose();
    _precioController.dispose();
    _notasController.dispose();
    
    // Dispose genealogía controllers
    _padreNombreController.dispose();
    _padreRegistroController.dispose();
    _padrePlacaController.dispose();
    _madreNombreController.dispose();
    _madreRegistroController.dispose();
    _madrePlacaController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataLoaded) {
      return Scaffold(
        backgroundColor: PedigriColors.background,
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(PedigriColors.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PedigriColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPhotoStep(),      // PASO 1: FOTO
                  _buildBasicDataStep(),  // PASO 2: DATOS BÁSICOS  
                  _buildGenealogyStep(),  // PASO 3: GENEALOGÍA
                  _buildNotesStep(),      // PASO 4: OBSERVACIONES
                ],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // Aquí continuaría el resto del código original...
  // [Todos los demás métodos se mantienen igual]
}

// [Todas las clases auxiliares se mantienen igual]