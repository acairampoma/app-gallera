// 📁 lib/features/vacunas/widgets/registro_rapido_dialog.dart
// ⚡ Dialog para registro rápido de múltiples vacunas

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../services/vacunas_service.dart';
import '../../../services/gallo_service.dart';
import '../../../models/vacuna.dart';

class RegistroRapidoDialog extends StatefulWidget {
  const RegistroRapidoDialog({Key? key}) : super(key: key);

  @override
  State<RegistroRapidoDialog> createState() => _RegistroRapidoDialogState();
}

class _RegistroRapidoDialogState extends State<RegistroRapidoDialog> {
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _dosisController = TextEditingController();
  final _notasController = TextEditingController();

  // Estado
  List<Map<String, dynamic>> gallos = [];
  List<TipoVacuna> tiposVacuna = [];
  Set<int> gallosSeleccionados = {};
  Set<String> vacunasSeleccionadas = {};
  DateTime fechaAplicacion = DateTime.now();
  DateTime? proximaDosis;
  bool isLoading = false;
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _dosisController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Cargar gallos y tipos de vacuna en paralelo
      final results = await Future.wait([
        GalloService.getGallos(),
        VacunasService.getTiposVacunas(),
      ]);

      setState(() {
        gallos = results[0] as List<Map<String, dynamic>>;
        tiposVacuna = (results[1] as List<Map<String, dynamic>>)
            .map((t) => TipoVacuna.fromJson(t))
            .toList();
        isLoadingData = false;
      });

      print('✅ Datos cargados: ${gallos.length} gallos, ${tiposVacuna.length} tipos');

    } catch (e) {
      print('❌ Error cargando datos: $e');
      setState(() => isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white, // FONDO BLANCO FORZADO
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white, // FONDO BLANCO FORZADO
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (isLoadingData)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(child: _buildContent()),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.vaccines,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚡ Registro Rápido',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Vacunar múltiples gallos a la vez',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      color: Colors.white, // FONDO BLANCO FORZADO
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSeleccionGallos(),
              const SizedBox(height: 20),
              _buildSeleccionVacunas(),
              const SizedBox(height: 20),
              _buildFechaSection(),
              const SizedBox(height: 20),
              _buildDatosVeterinario(),
              const SizedBox(height: 16),
              _buildResumen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeleccionGallos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '🐓 Seleccionar Gallos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  if (gallosSeleccionados.length == gallos.length) {
                    gallosSeleccionados.clear();
                  } else {
                    gallosSeleccionados = gallos.map((g) => g['id'] as int).toSet();
                  }
                });
              },
              child: Text(
                gallosSeleccionados.length == gallos.length ? 'Deseleccionar todo' : 'Seleccionar todo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: gallos.length,
            itemBuilder: (context, index) {
              final gallo = gallos[index];
              final isSelected = gallosSeleccionados.contains(gallo['id']);
              
              return CheckboxListTile(
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      gallosSeleccionados.add(gallo['id']);
                    } else {
                      gallosSeleccionados.remove(gallo['id']);
                    }
                  });
                },
                title: Text(
                  gallo['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  'ID: ${gallo['id']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeleccionVacunas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '💉 Seleccionar Vacunas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  if (vacunasSeleccionadas.length == tiposVacuna.length) {
                    vacunasSeleccionadas.clear();
                  } else {
                    vacunasSeleccionadas = tiposVacuna.map((v) => v.codigo).toSet();
                  }
                });
              },
              child: Text(
                vacunasSeleccionadas.length == tiposVacuna.length ? 'Deseleccionar todo' : 'Seleccionar todo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 140,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: tiposVacuna.length,
            itemBuilder: (context, index) {
              final tipo = tiposVacuna[index];
              final isSelected = vacunasSeleccionadas.contains(tipo.codigo);
              
              return CheckboxListTile(
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      vacunasSeleccionadas.add(tipo.codigo);
                    } else {
                      vacunasSeleccionadas.remove(tipo.codigo);
                    }
                  });
                },
                title: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(int.parse(tipo.color.replaceAll('#', '0xff'))),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tipo.nombre,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  tipo.enfermedad,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFechaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📅 Fecha de Aplicación',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: fechaAplicacion,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => fechaAplicacion = date);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Fecha aplicación',
                  hintText: _dateFormatter.format(fechaAplicacion),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(text: _dateFormatter.format(fechaAplicacion)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: proximaDosis ?? fechaAplicacion.add(const Duration(days: 30)),
                    firstDate: fechaAplicacion,
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  setState(() => proximaDosis = date);
                },
                decoration: InputDecoration(
                  labelText: 'Próxima dosis (opcional)',
                  hintText: proximaDosis != null 
                      ? _dateFormatter.format(proximaDosis!) 
                      : 'Sin programar',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.event),
                  suffixIcon: proximaDosis != null
                      ? IconButton(
                          onPressed: () => setState(() => proximaDosis = null),
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
                controller: TextEditingController(
                  text: proximaDosis != null ? _dateFormatter.format(proximaDosis!) : '',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatosVeterinario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 Información Adicional',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _dosisController,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumen() {
    final totalRegistros = gallosSeleccionados.length * vacunasSeleccionadas.length;
    
    if (totalRegistros == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Resumen del registro',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('• ${gallosSeleccionados.length} gallos seleccionados'),
          Text('• ${vacunasSeleccionadas.length} tipos de vacuna'),
          Text('• $totalRegistros registros a crear'),
          const SizedBox(height: 8),
          Text(
            'Fecha: ${_dateFormatter.format(fechaAplicacion)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (proximaDosis != null)
            Text(
              'Próxima dosis: ${_dateFormatter.format(proximaDosis!)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final canSubmit = gallosSeleccionados.isNotEmpty && 
                     vacunasSeleccionadas.isNotEmpty && 
                     !isLoading;
    
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: canSubmit ? _registrarVacunas : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.vaccines),
              label: Text(
                isLoading 
                    ? 'Registrando...' 
                    : 'Registrar ${gallosSeleccionados.length * vacunasSeleccionadas.length} vacunas',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registrarVacunas() async {
    if (gallosSeleccionados.isEmpty || vacunasSeleccionadas.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final fechaAplicacionStr = fechaAplicacion.toIso8601String().split('T')[0];
      final proximaDosisStr = proximaDosis?.toIso8601String().split('T')[0];

      final result = await VacunasService.registroRapido(
        galloIds: gallosSeleccionados.toList(),
        tipoVacunas: vacunasSeleccionadas.toList(),
        fechaAplicacion: fechaAplicacionStr,
        proximaDosis: proximaDosisStr,
        dosis: _dosisController.text.trim().isEmpty 
            ? null 
            : _dosisController.text.trim(),
        notas: _notasController.text.trim().isEmpty 
            ? null 
            : _notasController.text.trim(),
      );

      if (result != null) {
        Navigator.pop(context, true); // Cerrar dialog con resultado positivo
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${result['registros_creados']} vacunas registradas exitosamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('No se pudo completar el registro rápido');
      }

    } catch (e) {
      print('❌ Error en registro rápido: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}