// CONTINUACIÓN del archivo add_gallo_multistep_screen_integrated.dart

            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'No especificado' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getRegistrosACrear() {
    int count = 1; // El gallo principal
    if (_crearPadreAutomatico) count++;
    if (_crearMadreAutomatico) count++;
    return count.toString();
  }
  
  void _handleStepContinue() {
    if (_currentStep < 3) {
      // Validar paso actual
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      // Es el último paso - GUARDAR
      _guardarGallo();
    }
  }
  
  void _handleStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }
  
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Foto
        return true; // La foto es opcional
        
      case 1: // Datos básicos
        if (_nombreGalloController.text.isEmpty) {
          _showError('Por favor ingresa el nombre del gallo');
          return false;
        }
        if (_numeroRegistroController.text.isEmpty) {
          _showError('Por favor ingresa el código de identificación');
          return false;
        }
        if (_pesoController.text.isEmpty) {
          _showError('Por favor ingresa el peso');
          return false;
        }
        if (_alturaController.text.isEmpty) {
          _showError('Por favor ingresa la altura');
          return false;
        }
        return true;
        
      case 2: // Genealogía
        if (_crearPadreAutomatico && _padreNombreController.text.isEmpty) {
          _showError('Por favor ingresa el nombre del padre');
          return false;
        }
        if (_crearMadreAutomatico && _madreNombreController.text.isEmpty) {
          _showError('Por favor ingresa el nombre de la madre');
          return false;
        }
        return true;
        
      default:
        return true;
    }
  }
  
  Future<void> _guardarGallo() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Preparar datos del gallo
      final datosGallo = {
        'nombre': _nombreGalloController.text,
        'codigo_identificacion': _numeroRegistroController.text,
        'peso': double.parse(_pesoController.text),
        'altura': int.parse(_alturaController.text),
        'color': _selectedColor ?? '',
        'raza_id': _selectedRazaId,
        'criador': _criadorController.text,
        'propietario': _propietarioController.text,
        'observaciones': _observacionesController.text,
      };
      
      // Preparar datos del padre si se va a crear
      Map<String, dynamic>? datosPadre;
      if (_crearPadreAutomatico) {
        datosPadre = {
          'nombre': _padreNombreController.text,
          'codigo_identificacion': _padreNumeroRegistroController.text.isEmpty
              ? 'PAD-${DateTime.now().millisecondsSinceEpoch}'
              : _padreNumeroRegistroController.text,
        };
      }
      
      // Preparar datos de la madre si se va a crear
      Map<String, dynamic>? datosMadre;
      if (_crearMadreAutomatico) {
        datosMadre = {
          'nombre': _madreNombreController.text,
          'codigo_identificacion': _madreNumeroRegistroController.text.isEmpty
              ? 'MAD-${DateTime.now().millisecondsSinceEpoch}'
              : _madreNumeroRegistroController.text,
        };
      }
      
      // 🔥 LLAMAR A LA TÉCNICA ÉPICA
      final resultado = await GalloService.crearGalloConPedigri(
        datosGallo: datosGallo,
        crearPadre: _crearPadreAutomatico,
        crearMadre: _crearMadreAutomatico,
        datosPadre: datosPadre,
        datosMadre: datosMadre,
      );
      
      if (resultado['success']) {
        // Si hay foto, subirla
        if (_selectedImageFile != null && resultado['data'] != null) {
          final galloId = resultado['data']['gallo']['id'];
          await FotoService.subirFotoPrincipal(
            galloId: galloId,
            imagePath: _selectedImageFile!.path,
          );
        }
        
        // Mostrar mensaje de éxito
        if (mounted) {
          final isOffline = resultado['offline'] == true;
          final registrosCreados = _getRegistrosACrear();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isOffline
                  ? '✅ $registrosCreados registro(s) guardado(s) localmente. Se sincronizarán cuando haya conexión.'
                  : '✅ ¡Éxito! $registrosCreados registro(s) creado(s) en el servidor.',
              ),
              backgroundColor: isOffline ? Colors.orange : Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Regresar a la pantalla anterior con el resultado
          Navigator.pop(context, resultado['data']);
        }
      } else {
        throw Exception('Error al guardar el gallo');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        _showError('Error al guardar: ${e.toString()}');
      }
    }
  }
  
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _selectedPhotoPath = pickedFile.path;
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  void dispose() {
    _nombreGalloController.dispose();
    _numeroRegistroController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    _criadorController.dispose();
    _propietarioController.dispose();
    _observacionesController.dispose();
    _padreNombreController.dispose();
    _padreNumeroRegistroController.dispose();
    _madreNombreController.dispose();
    _madreNumeroRegistroController.dispose();
    super.dispose();
  }
}

// 🎯 EJEMPLO DE USO EN PEDIGRI_SCREEN.DART:
/*
void _navigateToAddGalloMultistep() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AddGalloMultistepScreenIntegrated(),
    ),
  );
  
  if (result != null) {
    // Recargar la lista de gallos
    await _loadData();
    
    // Mostrar mensaje opcional
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Gallo(s) agregado(s) exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
*/