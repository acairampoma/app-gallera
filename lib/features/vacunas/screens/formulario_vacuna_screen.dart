// 📁 lib/features/vacunas/screens/formulario_vacuna_screen.dart
// 💉 Formulario para crear/editar vacunas - VERSIÓN SIMPLIFICADA

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/vacunas_service.dart';
import '../../../models/vacuna.dart';

class FormularioVacunaScreen extends StatefulWidget {
  final int galloId;
  final String galloNombre;
  final Vacuna? vacunaExistente;

  const FormularioVacunaScreen({
    Key? key,
    required this.galloId,
    required this.galloNombre,
    this.vacunaExistente,
  }) : super(key: key);

  @override
  State<FormularioVacunaScreen> createState() => _FormularioVacunaScreenState();
}

class _FormularioVacunaScreenState extends State<FormularioVacunaScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  
  // Controladores
  final _laboratorioController = TextEditingController();
  final _veterinarioController = TextEditingController();
  final _clinicaController = TextEditingController();
  final _dosisController = TextEditingController();
  final _notasController = TextEditingController();

  // Estado
  List<TipoVacuna> tiposVacuna = [];
  String? tipoVacunaSeleccionado;
  DateTime fechaAplicacion = DateTime.now();
  DateTime? proximaDosis;
  bool isLoading = false;
  bool isLoadingTipos = true;

  @override
  void initState() {
    super.initState();
    _loadTiposVacuna();
    _initializeFormData();
  }

  @override
  void dispose() {
    _laboratorioController.dispose();
    _veterinarioController.dispose();
    _clinicaController.dispose();
    _dosisController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _loadTiposVacuna() async {
    try {
      final tipos = await VacunasService.getTiposVacunas();
      setState(() {
        tiposVacuna = tipos.map((t) => TipoVacuna.fromJson(t)).toList();
        isLoadingTipos = false;
      });
    } catch (e) {
      setState(() => isLoadingTipos = false);
    }
  }

  void _initializeFormData() {
    if (widget.vacunaExistente != null) {
      final vacuna = widget.vacunaExistente!;
      tipoVacunaSeleccionado = vacuna.tipoVacuna;
      fechaAplicacion = vacuna.fechaAplicacion;
      proximaDosis = vacuna.proximaDosis;
      
      _laboratorioController.text = vacuna.laboratorio ?? '';
      _veterinarioController.text = vacuna.veterinarioNombre ?? '';
      _clinicaController.text = vacuna.clinica ?? '';
      _dosisController.text = vacuna.dosis ?? '';
      _notasController.text = vacuna.notas ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.vacunaExistente != null ? 'Editar Vacuna' : 'Nueva Vacuna',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoadingTipos
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGalloInfo(),
                      const SizedBox(height: 20),
                      _buildTipoVacunaField(),
                      const SizedBox(height: 20),
                      _buildFechaAplicacionField(),
                      const SizedBox(height: 20),
                      _buildProximaDosisField(),
                      const SizedBox(height: 20),
                      _buildVeterinarioField(),
                      const SizedBox(height: 20),
                      _buildClinicaField(),
                      const SizedBox(height: 20),
                      _buildLaboratorioField(),
                      const SizedBox(height: 20),
                      _buildDosisField(),
                      const SizedBox(height: 20),
                      _buildNotasField(),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildGalloInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gallo a vacunar:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            widget.galloNombre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'ID: ${widget.galloId}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoVacunaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Vacuna *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: tipoVacunaSeleccionado,
              hint: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Seleccione tipo de vacuna'),
              ),
              isExpanded: true,
              onChanged: (String? value) {
                setState(() {
                  tipoVacunaSeleccionado = value;
                  if (value != null) {
                    final tipo = tiposVacuna.firstWhere((t) => t.codigo == value);
                    proximaDosis = fechaAplicacion.add(Duration(days: tipo.duracionDias));
                  }
                });
              },
              items: tiposVacuna.map((tipo) {
                return DropdownMenuItem(
                  value: tipo.codigo,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      tipo.nombre,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFechaAplicacionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de Aplicación *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: fechaAplicacion,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                fechaAplicacion = date;
                if (tipoVacunaSeleccionado != null) {
                  final tipo = tiposVacuna.firstWhere((t) => t.codigo == tipoVacunaSeleccionado);
                  proximaDosis = fechaAplicacion.add(Duration(days: tipo.duracionDias));
                }
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _dateFormatter.format(fechaAplicacion),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProximaDosisField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Próxima Dosis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => proximaDosis = null),
              child: const Text('Limpiar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: proximaDosis ?? fechaAplicacion.add(const Duration(days: 30)),
              firstDate: fechaAplicacion,
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (date != null) {
              setState(() => proximaDosis = date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              proximaDosis != null 
                  ? _dateFormatter.format(proximaDosis!) 
                  : 'Sin próxima dosis programada',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVeterinarioField() {
    return _buildTextField(
      'Veterinario',
      _veterinarioController,
      'Dr. Juan Pérez',
    );
  }

  Widget _buildClinicaField() {
    return _buildTextField(
      'Clínica',
      _clinicaController,
      'Clínica Veterinaria',
    );
  }

  Widget _buildLaboratorioField() {
    return _buildTextField(
      'Laboratorio',
      _laboratorioController,
      'Lab. XYZ',
    );
  }

  Widget _buildDosisField() {
    return _buildTextField(
      'Dosis',
      _dosisController,
      '1 ml',
    );
  }

  Widget _buildNotasField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notasController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Observaciones, reacciones, etc...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _guardarVacuna,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.vacunaExistente != null ? 'Actualizar Vacuna' : 'Registrar Vacuna',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _guardarVacuna() async {
    if (tipoVacunaSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un tipo de vacuna'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final fechaAplicacionStr = fechaAplicacion.toIso8601String().split('T')[0];
      final proximaDosisStr = proximaDosis?.toIso8601String().split('T')[0];

      Map<String, dynamic>? result;

      if (widget.vacunaExistente != null) {
        result = await VacunasService.actualizarVacuna(
          widget.vacunaExistente!.id!,
          galloId: widget.galloId,
          tipoVacuna: tipoVacunaSeleccionado!,
          fechaAplicacion: fechaAplicacionStr,
          proximaDosis: proximaDosisStr,
          laboratorio: _laboratorioController.text.trim().isEmpty ? null : _laboratorioController.text.trim(),
          veterinarioNombre: _veterinarioController.text.trim().isEmpty ? null : _veterinarioController.text.trim(),
          clinica: _clinicaController.text.trim().isEmpty ? null : _clinicaController.text.trim(),
          dosis: _dosisController.text.trim().isEmpty ? null : _dosisController.text.trim(),
          notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
        );
      } else {
        result = await VacunasService.crearVacuna(
          galloId: widget.galloId,
          tipoVacuna: tipoVacunaSeleccionado!,
          fechaAplicacion: fechaAplicacionStr,
          proximaDosis: proximaDosisStr,
          laboratorio: _laboratorioController.text.trim().isEmpty ? null : _laboratorioController.text.trim(),
          veterinarioNombre: _veterinarioController.text.trim().isEmpty ? null : _veterinarioController.text.trim(),
          clinica: _clinicaController.text.trim().isEmpty ? null : _clinicaController.text.trim(),
          dosis: _dosisController.text.trim().isEmpty ? null : _dosisController.text.trim(),
          notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
        );
      }

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.vacunaExistente != null ? 'Vacuna actualizada' : 'Vacuna registrada',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}