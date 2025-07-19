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

class _VacunasScreenState extends State<VacunasScreen> {
  List<dynamic> vacunas = [];
  List<dynamic> proximasVacunas = [];
  bool isLoading = true;
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
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
        onPressed: () => _showAddVacunaDialog(),
        backgroundColor: Colors.green,
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
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label ${selected ? 'seleccionada' : 'deseleccionada'}')),
        );
      },
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color.withOpacity(0.3),
      labelStyle: TextStyle(color: color),
      side: BorderSide(color: color.withOpacity(0.5)),
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
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vacuna registrada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddVacunaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Vacuna'),
        content: const Text('Formulario completo de vacunación próximamente.\n\nPor ahora puedes usar el registro rápido en esta pantalla.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}