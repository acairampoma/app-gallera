# Pedigrí – UX especificación de Eliminación y Filtro “Gallos principales”

Objetivo: Homogeneizar la experiencia del módulo Pedigrí con Vacunas para (1) filtrar por “gallos principales” con un check, (2) eliminar gallos con feedback claro, respetando el filtro y mostrando advertencias si existen peleas/topes/vacunas.

---

## 1) Alcance

- Pantallas afectadas:
  - `lib/features/pedigri/screens/pedigri_screen.dart` (listado)
  - `lib/features/pedigri/screens/edit_gallo_multistep_screen.dart` (detalle/edición)
- Servicios:
  - `lib/services/gallo_service.dart` (eliminación y nuevos métodos de conteo)
- Comportamientos a alinear con Vacunas:
  - Toggle/Check de filtro persistente
  - Flujo de eliminación con loading, confirmación y retorno a la lista

---

## 2) Filtro “Mostrar solo gallos principales”

- Componente: Check/Switch en `pedigri_screen.dart` (header o AppBar actions).
- Estado persistente (SharedPreferences):
  - Key sugerida: `pedigri_filter_main_cocks_only`
  - Default: `true` (mostrar solo principales)
- Consulta/Renderizado:
  - Cuando `true`: consultar/filtrar solo “gallos principales”.
    - Definición “principal”: sin padre/madre o flag específico del modelo (ajustar a tu dominio actual).
  - Cuando `false`: mostrar todos los gallos (activos).
- Interacción:
  - Cambiar el check → guardar preferencia → recargar lista respetando el filtro.

Pseudo-código (simplificado):
```dart
bool showMainOnly = await prefs.getBool('pedigri_filter_main_cocks_only') ?? true;

Widget buildFilter() => Row(
  children: [
    Checkbox(
      value: showMainOnly,
      onChanged: (v) async {
        setState(() => showMainOnly = v ?? true);
        await prefs.setBool('pedigri_filter_main_cocks_only', showMainOnly);
        _reloadList();
      },
    ),
    const Text('Mostrar solo gallos principales'),
  ],
);
```

---

## 3) Eliminación de gallo – Flujo UX

- Botón eliminar desde tarjeta/item (en la lista) o desde detalle.
- Paso 1: Pre-confirmación con conteos
  - Llamar `GET /gallos/{id}/relations-counts`.
  - Mostrar diálogo:
    - “Este gallo tiene: X peleas, Y topes, Z vacunas. Al eliminar, dejarán de mostrarse en la app. ¿Deseas continuar?”
    - Botones: Cancelar / Eliminar
- Paso 2: Progreso (mismo estilo que Vacunas)
  - Al confirmar, mostrar overlay/loading: “Procesando eliminación…”
  - Deshabilitar interacciones.
- Paso 3: Eliminar
  - Invocar `GalloService.deleteGallo(id)` (soft delete en backend).
- Paso 4: Post-acción
  - Snackbar: “Gallo eliminado correctamente”.
  - Refrescar la lista manteniendo el filtro actual (si `showMainOnly` estaba activo, seguir activo).
  - Navegación: si venías de detalle, pop a la lista; si desde lista, permanecer y refrescar.

Mensajes/Errores:
- Si hay error (e.g., integridad/permiso): mostrar alerta con detalle y dejar al usuario en la pantalla actual.

---

## 4) Contratos de API

- `GET /gallos/{id}/relations-counts` → `{ peleas: number, topes: number, vacunas: number }`
- `DELETE /api/v1/gallos/{id}`
  - Soft delete: `status='deleted'` en backend.
  - Respuesta: `{ success: true }` (y opcionalmente conteos usados en UI)

Cambios en `lib/services/gallo_service.dart`:
- `Future<Map<String,int>> fetchRelationsCounts(int id)`
  - GET al endpoint de conteos.
- `Future<bool> deleteGallo(int id)`
  - Ya existe; mantener contrato. Alinear a soft delete si backend lo hace.

---

## 5) Comportamiento de lista tras eliminar

- Debe respetar el filtro actual:
  - Si `showMainOnly == true`: recargar y mostrar solo principales.
  - Si `showMainOnly == false`: recargar y mostrar todos.
- UX igual a Vacunas:
  - Mostrar estado de “procesando” mientras se elimina.
  - Al terminar, feedback (Snackbar) y refresco inmediato.

---

## 6) Estados y vacíos

- Vacío con filtro activo:
  - Si no hay gallos principales pero sí existen no-principales, sugerir desactivar el check.
  - CTA: “Ver todos los gallos”.
- Accesibilidad/i18n:
  - Textos claros y localizables.

---

## 7) Tareas técnicas

- `pedigri_screen.dart`
  - Agregar check de filtro + persistencia.
  - Aplicar filtro al provider/stream/consulta que alimenta la lista.
  - Implementar diálogo de confirmación con conteos (llamando al nuevo método en servicio).
  - Overlay/loading estilo Vacunas al confirmar eliminación.
  - Refresco de lista y mantenimiento del estado del filtro.

- `gallo_service.dart`
  - Añadir `fetchRelationsCounts(id)`.
  - Mantener `deleteGallo(id)`.

- `edit_gallo_multistep_screen.dart`
  - Si se elimina desde detalle, al éxito: pop hasta lista y refrescar.

---

## 8) Puntos de validación (QA)

- Check de filtro persiste al cerrar/abrir la app.
- Conteos correctos antes de eliminar (verificados con casos de 0/N registros).
- Loading visible durante la eliminación.
- Snackbar de éxito/error.
- Lista se recarga respetando el estado del check.
- Comportamiento análogo a Vacunas.

---

## 9) Riesgos y mitigaciones

- Inconsistencia de definición “gallo principal”: documentar regla exacta (flag o derivado del árbol).
- Latencia de conteos: cache/CQRS o contar en DB con índices.
- Backend DELETE no es soft: coordinar para que la API aplique soft delete.

---

## 10) Resumen

- Agregar filtro “Mostrar solo gallos principales” persistente.
- Eliminar con confirmación previa y conteos, mostrando loading y feedback.
- Tras eliminar, recargar manteniendo el filtro (UX como Vacunas).
- Añadir método de conteos en `GalloService` y endpoint en backend.
