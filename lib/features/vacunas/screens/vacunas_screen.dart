import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../shared/widgets/base_screen.dart';
import '../../../shared/theme/app_colors.dart';

class VacunasScreen extends StatefulWidget {
  const VacunasScreen({Key? key}) : super(key: key);

  @override
  State<VacunasScreen> createState() => _VacunasScreenState();
}

class _VacunasScreenState extends State<VacunasScreen> with TickerProviderStateMixin {
  // ==========================================
  // 🎯 ESTADO Y DATOS PRINCIPALES
  // ==========================================
  List<dynamic> vacunas = [];
  List<dynamic> proximasVacunas = [];
  bool isLoading = true;
  String? selectedDate;
  
  // Control de vacunas seleccionadas (funcionalidad épica)
  Set<String> selectedVaccines = {};
  
  // Controladores para modal detallado profesional
  final _galloController = TextEditingController();
  final _veterinarioController = TextEditingController();
  final _clinicaController = TextEditingController();
  final _medicamentoController = TextEditingController();
  final _dosisController = TextEditingController();
  final _loteController = TextEditingController();
  final _pesoAveController = TextEditingController();
  final _costoController = TextEditingController();
  final _certificadoController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  // Selecciones del formulario detallado
  String? _selectedGallo;
  String? _selectedTipoVacuna;
  String? _selectedMetodo;
  String? _selectedInmunidad;
  String? _selectedReaccion;
  String? _selectedDuracion;
  DateTime? _selectedFechaAplicacion;
  DateTime? _selectedProximaDosis;
  
  // Animaciones épicas
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  // ==========================================
  // 📊 DATOS DE CONFIGURACIÓN PROFESIONAL
  // ==========================================
  
  final List<Map<String, String>> _gallosOptions = [
    {'value': 'campeon', 'label': 'El Campeón'},
    {'value': 'relampago', 'label': 'Relámpago'},
    {'value': 'trueno', 'label': 'Trueno'},
    {'value': 'centella', 'label': 'Centella'},
    {'value': 'tornado', 'label': 'Tornado'},
  ];

  final List<Map<String, String>> _tiposVacuna = [
    {'value': 'newcastle', 'label': 'Newcastle'},
    {'value': 'bronquitis', 'label': 'Bronquitis'},
    {'value': 'viruela', 'label': 'Viruela Aviar'},
    {'value': 'gumboro', 'label': 'Gumboro'},
    {'value': 'coriza', 'label': 'Coriza'},
    {'value': 'salmonella', 'label': 'Salmonella'},
    {'value': 'marek', 'label': 'Enfermedad de Marek'},
  ];

  final List<Map<String, String>> _metodosAplicacion = [
    {'value': 'im', 'label': 'Intramuscular (IM)'},
    {'value': 'sc', 'label': 'Subcutánea (SC)'},
    {'value': 'oral', 'label': 'Oral'},
    {'value': 'ocular', 'label': 'Ocular'},
    {'value': 'nasal', 'label': 'Nasal'},
    {'value': 'puncion', 'label': 'Punción en ala'},
    {'value': 'agua', 'label': 'En agua de bebida'},
  ];

  final List<Map<String, String>> _estadosInmunidad = [
    {'value': 'protegido', 'label': 'Protegido'},
    {'value': 'proteccion_parcial', 'label': 'Protección Parcial'},
    {'value': 'desarrollo', 'label': 'En Desarrollo'},
    {'value': 'pendiente', 'label': 'Pendiente Evaluar'},
    {'value': 'refuerzo_necesario', 'label': 'Necesita Refuerzo'},
  ];

  final List<Map<String, String>> _reaccionesAdversas = [
    {'value': 'ninguna', 'label': 'Ninguna'},
    {'value': 'inflamacion_leve', 'label': 'Inflamación leve'},
    {'value': 'fiebre', 'label': 'Fiebre temporal'},
    {'value': 'perdida_apetito', 'label': 'Pérdida de apetito'},
    {'value': 'letargo', 'label': 'Letargo'},
    {'value': 'reaccion_local', 'label': 'Reacción local'},
  ];

  final List<Map<String, String>> _duracionProteccion = [
    {'value': '30', 'label': '30 días'},
    {'value': '60', 'label': '60 días'},
    {'value': '90', 'label': '90 días'},
    {'value': '180', 'label': '6 meses'},
    {'value': '365', 'label': '1 año'},
    {'value': '730', 'label': '2 años'},
    {'value': 'permanente', 'label': 'Permanente'},
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _galloController.dispose();
    _veterinarioController.dispose();
    _clinicaController.dispose();
    _medicamentoController.dispose();
    _dosisController.dispose();
    _loteController.dispose();
    _pesoAveController.dispose();
    _costoController.dispose();
    _certificadoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }
  
  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  Future<void> _loadData() async {
    try {
      final String vacunasJson = await rootBundle.loadString('lib/data/mock/vacunas_mock.json');
      final data = json.decode(vacunasJson);
      setState(() {
        vacunas = data['vacunas'] ?? [];
        proximasVacunas = data['proximas_vacunas'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print('Error loading vacunas data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Control de Vacunas',
      subtitle: 'Programa sanitario completo',
      currentIndex: 1, // Gallos section
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDetailedVacunaModal(),
        backgroundColor: AppColors.primary,
        heroTag: "add_vacuna",
        child: const Icon(Icons.medical_services, color: Colors.white),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (proximasVacunas.isNotEmpty) ...[
            _buildProximasVacunasCard(),
            const SizedBox(height: 20),
          ],
          _buildRegistroRapido(),
          const SizedBox(height: 20),
          _buildHistorialSection(),
        ],
      ),
    );
  }

  Widget _buildProximasVacunasCard() {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Próximas Vacunas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...proximasVacunas.map((vacuna) => _buildProximaVacunaItem(vacuna)),
          ],
        ),
      ),
    );
  }

  Widget _buildProximaVacunaItem(Map<String, dynamic> vacuna) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vacuna['gallo_nombre'] ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  vacuna['descripcion'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Fecha: ${vacuna['fecha_siguiente'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${vacuna['dias_restantes'] ?? 0} días',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistroRapido() {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Registro Rápido de Vacuna',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildVacunaChip('Newcastle', Colors.blue),
                _buildVacunaChip('Bronquitis', Colors.purple),
                _buildVacunaChip('Viruela', Colors.orange),
                _buildVacunaChip('Gumboro', Colors.red),
                _buildVacunaChip('Coriza', Colors.teal),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      hintText: selectedDate ?? 'Seleccionar fecha',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _registrarVacunaRapida(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVacunaChip(String label, Color color) {
    final isSelected = selectedVaccines.contains(label);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              selectedVaccines.add(label);
            } else {
              selectedVaccines.remove(label);
            }
          });
          
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label ${selected ? 'seleccionada' : 'deseleccionada'}'),
              duration: const Duration(milliseconds: 800),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: color.withOpacity(0.1),
        selectedColor: color,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? color : color.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
        elevation: isSelected ? 4 : 0,
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }

  Widget _buildHistorialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Vacunas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (vacunas.isEmpty)
          _buildEmptyState()
        else
          ...vacunas.map((vacuna) => _buildVacunaCard(vacuna)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay vacunas registradas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Usa el registro rápido o el botón + para agregar vacunas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVacunaCard(Map<String, dynamic> vacuna) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medical_services,
                    size: 20,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vacuna['descripcion'] ?? 'Vacuna',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gallo: ${vacuna['gallo']?['nombre'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Aplicada',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Fecha', vacuna['fecha_aplicacion'] ?? 'N/A'),
                ),
                Expanded(
                  child: _buildInfoItem('Veterinario', vacuna['veterinario'] ?? 'N/A'),
                ),
              ],
            ),
            if (vacuna['medicamento'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoItem('Medicamento', vacuna['medicamento']),
            ],
            if (vacuna['observaciones'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoItem('Observaciones', vacuna['observaciones']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  void _selectDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedDate = date.toString().split(' ')[0];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fecha seleccionada: $selectedDate')),
        );
      }
    });
  }

  void _registrarVacunaRapida() {
    if (selectedVaccines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Por favor selecciona al menos una vacuna'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Por favor selecciona una fecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Simulación exitosa como en el HTML
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('✅ Vacunas Aplicadas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Vacunas aplicadas:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...selectedVaccines.map((vaccine) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• $vaccine', style: const TextStyle(fontSize: 14)),
            )),
            const SizedBox(height: 12),
            Text('📅 Fecha: $selectedDate', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            const Text('Se ha registrado en el historial médico.', 
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Resetear selección
              setState(() {
                selectedVaccines.clear();
                selectedDate = null;
              });
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showAddVacunaDialog() {
    _showDetailedVacunaModal();
  }
  
  // ==========================================
  // 🚀 MODAL DETALLADO PROFESIONAL ÉPICO
  // ==========================================
  
  void _showDetailedVacunaModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header del modal épico
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '💉 Registro Detallado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _clearForm();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              
              // Contenido del formulario épico
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Selector de Gallo
                      _buildDropdownField(
                        'Gallo',
                        _selectedGallo,
                        _gallosOptions,
                        (value) => setState(() => _selectedGallo = value),
                        icon: Icons.pets,
                        required: true,
                      ),
                      const SizedBox(height: 12),
                      
                      // Fila: Tipo de vacuna y Fecha
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 400) {
                            // Layout vertical en pantallas pequeñas
                            return Column(
                              children: [
                                _buildDropdownField(
                                  'Tipo de Vacuna',
                                  _selectedTipoVacuna,
                                  _tiposVacuna,
                                  (value) => setState(() => _selectedTipoVacuna = value),
                                  icon: Icons.medical_services,
                                  required: true,
                                ),
                                const SizedBox(height: 12),
                                _buildDateField(
                                  'Fecha de Aplicación',
                                  _selectedFechaAplicacion,
                                  (date) => setState(() => _selectedFechaAplicacion = date),
                                  required: true,
                                ),
                              ],
                            );
                          } else {
                            // Layout horizontal en pantallas grandes
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    'Tipo de Vacuna',
                                    _selectedTipoVacuna,
                                    _tiposVacuna,
                                    (value) => setState(() => _selectedTipoVacuna = value),
                                    icon: Icons.medical_services,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDateField(
                                    'Fecha de Aplicación',
                                    _selectedFechaAplicacion,
                                    (date) => setState(() => _selectedFechaAplicacion = date),
                                    required: true,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Fila: Veterinario y Clínica
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 400) {
                            return Column(
                              children: [
                                _buildTextField(
                                  'Veterinario',
                                  _veterinarioController,
                                  icon: Icons.person,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  'Clínica/Consultorio',
                                  _clinicaController,
                                  icon: Icons.local_hospital,
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Veterinario',
                                    _veterinarioController,
                                    icon: Icons.person,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    'Clínica/Consultorio',
                                    _clinicaController,
                                    icon: Icons.local_hospital,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Medicamento
                      _buildTextField(
                        'Medicamento',
                        _medicamentoController,
                        icon: Icons.medication,
                        hint: 'Ej: Newcastle B1',
                      ),
                      const SizedBox(height: 12),
                      
                      // Fila: Dosis y Lote
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 400) {
                            return Column(
                              children: [
                                _buildTextField(
                                  'Dosis',
                                  _dosisController,
                                  icon: Icons.colorize,
                                  hint: 'Ej: 0.5ml',
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  'Lote',
                                  _loteController,
                                  icon: Icons.qr_code,
                                  hint: 'Lote',
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Dosis',
                                    _dosisController,
                                    icon: Icons.colorize,
                                    hint: 'Ej: 0.5ml',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    'Lote',
                                    _loteController,
                                    icon: Icons.qr_code,
                                    hint: 'Lote',
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Fila: Método y Peso
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 400) {
                            return Column(
                              children: [
                                _buildDropdownField(
                                  'Método',
                                  _selectedMetodo,
                                  _metodosAplicacion,
                                  (value) => setState(() => _selectedMetodo = value),
                                  icon: Icons.healing,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  'Peso (kg)',
                                  _pesoAveController,
                                  icon: Icons.scale,
                                  hint: '2.45',
                                  isNumeric: true,
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    'Método',
                                    _selectedMetodo,
                                    _metodosAplicacion,
                                    (value) => setState(() => _selectedMetodo = value),
                                    icon: Icons.healing,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    'Peso (kg)',
                                    _pesoAveController,
                                    icon: Icons.scale,
                                    hint: '2.45',
                                    isNumeric: true,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Observaciones
                      _buildTextField(
                        'Observaciones',
                        _observacionesController,
                        icon: Icons.notes,
                        hint: 'Condición del ave...',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer con botones épicos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _clearForm();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _saveDetailedVaccine(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          '💾 Guardar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ==========================================
  // 🛠️ WIDGETS AUXILIARES PROFESIONALES
  // ==========================================
  
  Widget _buildDropdownField(
    String label,
    String? value,
    List<Map<String, String>> options,
    Function(String?) onChanged, {
    IconData? icon,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (required)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(option['label']!),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    String? hint,
    bool required = false,
    bool isNumeric = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (required)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onChanged, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (required)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: selectedDate?.toString().split(' ')[0] ?? 'Seleccionar fecha',
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onChanged(date);
            }
          },
        ),
      ],
    );
  }

  // ==========================================
  // 🎯 MÉTODOS FUNCIONALES ÉPICOS
  // ==========================================
  
  void _clearForm() {
    setState(() {
      _selectedGallo = null;
      _selectedTipoVacuna = null;
      _selectedMetodo = null;
      _selectedInmunidad = null;
      _selectedReaccion = null;
      _selectedDuracion = null;
      _selectedFechaAplicacion = null;
      _selectedProximaDosis = null;
    });
    
    _galloController.clear();
    _veterinarioController.clear();
    _clinicaController.clear();
    _medicamentoController.clear();
    _dosisController.clear();
    _loteController.clear();
    _pesoAveController.clear();
    _costoController.clear();
    _certificadoController.clear();
    _observacionesController.clear();
  }

  void _saveDetailedVaccine() {
    // Validaciones profesionales
    if (_selectedGallo == null || _selectedTipoVacuna == null || _selectedFechaAplicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Completa los campos obligatorios: Gallo, Vacuna y Fecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Obtener nombres legibles
    final galloNombre = _gallosOptions.firstWhere(
      (g) => g['value'] == _selectedGallo,
      orElse: () => {'label': 'Desconocido'},
    )['label'];
    
    final vacunaNombre = _tiposVacuna.firstWhere(
      (v) => v['value'] == _selectedTipoVacuna,
      orElse: () => {'label': 'Desconocido'},
    )['label'];
    
    Navigator.pop(context);
    
    // Mostrar confirmación épica
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green.shade600, size: 28),
            const SizedBox(width: 8),
            const Text('🎉 ¡Registro Profesional Exitoso!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Registro veterinario guardado:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSummaryItem('Gallo', galloNombre),
            _buildSummaryItem('Vacuna', vacunaNombre),
            _buildSummaryItem('Fecha', _selectedFechaAplicacion?.toString().split(' ')[0] ?? 'N/A'),
            if (_veterinarioController.text.isNotEmpty)
              _buildSummaryItem('Veterinario', _veterinarioController.text),
            if (_medicamentoController.text.isNotEmpty)
              _buildSummaryItem('Medicamento', _medicamentoController.text),
            if (_dosisController.text.isNotEmpty)
              _buildSummaryItem('Dosis', _dosisController.text),
            if (_costoController.text.isNotEmpty)
              _buildSummaryItem('Costo', 'S/. ${_costoController.text}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text(
                '✅ Registro profesional añadido al historial médico con todos los detalles veterinarios.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: const Text('¡Épico! 🚀'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}