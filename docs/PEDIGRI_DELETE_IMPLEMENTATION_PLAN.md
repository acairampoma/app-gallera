# Pedigrí – Plan de implementación (DELETE hard en backend + mejoras frontend)

Este plan consolida el estado actual del backend (hard delete) y las mejoras de UX/flujo en frontend para homogeneizar con Vacunas y respetar el filtro de “gallos principales”.

---

## 1) Estado actual backend (confirmado)

- Todos los módulos eliminan con **hard delete**.
- Endpoints:
  - Topes: `DELETE /topes/{tope_id}` (borra registro y video en Cloudinary si existe)
  - Peleas: `DELETE /peleas/{pelea_id}` (borra registro y video en Cloudinary si existe)
  - Vacunas: `DELETE /vacunas/{vacuna_id}` (SQL DELETE)
  - Pedigrí (Gallo): `DELETE /api/v1/gallos/{id}` en `gallos_con_pedigri.py`
    - Borra fotos en Cloudinary
    - Borra peleas/topes/vacunas del gallo
    - Si es principal, borra genealogía asociada
    - Borra el gallo (hard delete)

Conclusión: la integridad se mantiene por limpieza en cascada manual; no hay soft delete por ahora.

---

## 2) Objetivo frontend (complementar sin cambiar backend)

- **Filtro persistente “Mostrar solo gallos principales”** en `pedigri_screen.dart` (SharedPreferences).
- **Eliminar con confirmación y feedback** (estilo Vacunas):
  - Preconfirmación con conteos (peleas/topes/vacunas) antes de eliminar.
  - Loading/overlay durante la operación.
  - Snackbar de éxito.
  - Navegación/refresh respetando el estado del filtro actual.

---

## 3) Cambios concretos en frontend

- `lib/services/gallo_service.dart`
  - Añadir `Future<Map<String,int>> fetchRelationsCounts(int id)` → GET `/gallos/{id}/relations-counts`.
  - Mantener `deleteGallo(int id)` (usa DELETE actual del backend).

- `lib/features/pedigri/screens/pedigri_screen.dart`
  - Agregar check "Mostrar solo gallos principales" (key: `pedigri_filter_main_cocks_only`, default `true`).
  - Aplicar el filtro al cargar/recargar lista.
  - Diálogo de confirmación de eliminación con conteos.
  - Overlay/loading mientras se elimina.
  - Refrescar lista manteniendo el filtro; si se está en detalle, hacer pop y refrescar en la lista.

- `lib/features/pedigri/screens/edit_gallo_multistep_screen.dart`
  - Si se elimina desde detalle, al éxito: `Navigator.popUntil` a la lista; trigger de refresh.

Notas:
- La definición de “gallo principal” debe quedar clara (sin padre/madre o flag de modelo). Usar la regla vigente en tu dominio actual.

---

## 4) UX esperado

- Con el check activado (por defecto), la lista muestra solo gallos principales.
- Al eliminar un gallo:
  - Muestra conteos y pide confirmación.
  - Indica "Procesando eliminación…" mientras llama al endpoint.
  - Al finalizar, muestra "Gallo eliminado" y refresca la lista respetando el check.
- Si el check se desactiva, la lista muestra todos los gallos disponibles.

---

## 5) Roadmap opcional (futuro)

- Migrar a **soft delete** en backend (status/deleted_at/deleted_by) para auditoría/recuperación.
- Endpoints de `restore` y vistas `*_active` para performance e integridad.

---

## 6) Checklists

- Implementación
  - [ ] `fetchRelationsCounts` en `gallo_service.dart`
  - [ ] Check persistente y filtro en `pedigri_screen.dart`
  - [ ] Diálogo de confirmación con conteos
  - [ ] Overlay/loading + Snackbar
  - [ ] Navegación/refresh respetando filtro tras eliminar (lista/detalle)

- QA
  - [ ] Filtro persiste (cerrar/abrir app)
  - [ ] Conteos correctos (0/N)
  - [ ] Loading visible y bloqueo de doble toque
  - [ ] Lista respeta filtro después de eliminar
  - [ ] Consistencia con módulo Vacunas
