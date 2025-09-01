# Estrategia de Eliminación Segura (Pedigrí, Peleas, Topes, Vacunas)

Objetivo: proteger la integridad de datos y la experiencia de usuario al “eliminar” gallos y sus relaciones (peleas, topes, vacunas), evitando errores por integridad referencial y minimizando datos innecesarios visibles. La eliminación será lógica (soft delete) con opción de restauración y purga.

---

## 1) Alcance y modelos involucrados

- **Entidad principal**: `gallo`
- **Entidades dependientes**: `pelea`, `tope`, `vacuna` (y otras futuras)
- **Relaciones**:
  - Cada `pelea`, `tope`, `vacuna` referencia a un `gallo` vía `gallo_id` (FK)
  - El pedigrí enlaza gallos entre sí (padre/madre → hijo)

---

## 2) Principios de la solución

- **Soft delete** por consistencia y auditoría
  - Campos estándar: `status` (ENUM: `active`, `hidden`, `deleted`), `deleted_at TIMESTAMP NULL`, `deleted_by UUID NULL`.
  - `deleted` no se muestra en la app por defecto. `hidden` permite ocultar sin declarar borrado definitivo.
- **No cascada destructiva**
  - No se eliminan físicamente `peleas/topes/vacunas` cuando se elimina un `gallo`.
  - Se inhabilita su visibilidad usando filtros (vistas/consultas) por `status` del gallo y del registro hijo.
- **Restaurable**
  - Un gallo `deleted` puede restaurarse si procede.
- **Purga controlada**
  - Tarea administrativa para borrar físicamente registros `deleted` después de X días (opcional).

---

## 3) PostgreSQL – Diseño de base de datos

### 3.1 Campos y migraciones sugeridas

Ejemplo para `gallo`:
```sql
ALTER TABLE gallo
  ADD COLUMN status TEXT NOT NULL DEFAULT 'active',
  ADD COLUMN deleted_at TIMESTAMP NULL,
  ADD COLUMN deleted_by UUID NULL;

CREATE INDEX IF NOT EXISTS idx_gallo_status ON gallo(status);
CREATE INDEX IF NOT EXISTS idx_gallo_deleted_at ON gallo(deleted_at);
```

Para dependientes (`pelea`, `tope`, `vacuna`):
```sql
ALTER TABLE pelea
  ADD COLUMN status TEXT NOT NULL DEFAULT 'active',
  ADD COLUMN deleted_at TIMESTAMP NULL,
  ADD COLUMN deleted_by UUID NULL;

-- Repetir equivalente para tope y vacuna
```

### 3.2 Integridad referencial

- Mantener FKs con **ON DELETE RESTRICT** en relaciones críticas (evita borrado físico si hay hijos):
```sql
ALTER TABLE pelea
  ADD CONSTRAINT fk_pelea_gallo
  FOREIGN KEY (gallo_id) REFERENCES gallo(id) ON DELETE RESTRICT;
```
- Si ya existen, revisar que no estén en `ON DELETE CASCADE` para evitar pérdida de histórico.

### 3.3 Vistas filtradas (solo activos)

- Exponer vistas que la API/queries usen por defecto:
```sql
CREATE OR REPLACE VIEW v_gallo_active AS
SELECT * FROM gallo WHERE status = 'active';

CREATE OR REPLACE VIEW v_pelea_active AS
SELECT p.*
FROM pelea p
JOIN gallo g ON g.id = p.gallo_id
WHERE p.status = 'active' AND g.status = 'active';
```
- Repetir para `tope` y `vacuna`.

### 3.4 Triggers opcionales

- Evitar que un `gallo` pase a `deleted` si tiene hijos `active` y la política exige bloquear (alternativa a solo ocultar):
```sql
CREATE OR REPLACE FUNCTION prevent_delete_gallo_with_children()
RETURNS trigger AS $$
BEGIN
  IF NEW.status = 'deleted' THEN
    IF EXISTS (SELECT 1 FROM pelea WHERE gallo_id = NEW.id AND status = 'active') THEN
      RAISE EXCEPTION 'No se puede eliminar: gallo con peleas activas';
    END IF;
    -- Repetir checks para tope, vacuna si se desea bloqueo fuerte
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_delete_gallo
BEFORE UPDATE ON gallo
FOR EACH ROW
WHEN (OLD.status <> 'deleted' AND NEW.status = 'deleted')
EXECUTE FUNCTION prevent_delete_gallo_with_children();
```
- Si preferimos **no bloquear**, omitir el trigger y solo ocultar dependientes por filtros.

---

## 4) API – Contratos y endpoints

- **DELETE /gallos/{id}** → Soft delete
  - Cambia `status='deleted'`, `deleted_at=now()`, `deleted_by=user_id`.
  - Respuesta incluye conteos: `{ peleas: 3, topes: 2, vacunas: 5 }` para mostrar en la UI de confirmación.
- **POST /gallos/{id}/restore** → Restaurar
  - `status='active'`, `deleted_at=NULL`, cascada opcional a dependientes si estaban `hidden`.
- **GET /gallos** (por defecto activos)
  - Filtro `status=active` por defecto. Soporta `?status=all` para administración.
- **DELETE /peleas/{id}**, **/topes/{id}**, **/vacunas/{id}**
  - También soft delete con los mismos campos.
- **GET /gallos/{id}/relations-counts**
  - Devuelve conteos activos de peleas/topes/vacunas para confirmaciones de UI.

Ejemplo de SQL para soft delete de gallo:
```sql
UPDATE gallo
SET status='deleted', deleted_at=NOW(), deleted_by=$1
WHERE id=$2 AND status <> 'deleted';
```

---

## 5) UI/UX – Flujos en Flutter

- **Confirmación previa a eliminar gallo** (`pedigri_screen.dart` / `edit_gallo_multistep_screen.dart`):
  - Llamar `GET /gallos/{id}/relations-counts` y mostrar:
    - "Este gallo tiene: 3 peleas, 2 topes, 5 vacunas. Al eliminar, no se mostrarán más en la app."
  - Requiere confirmación explícita (doble confirmación opcional).
- **Listado por defecto**: mostrar solo `status='active'`.
- **Filtros avanzados** (modo admin): permitir mostrar `deleted`/`hidden` con badges.
- **Restaurar**: acción en detalle de gallo eliminado.
- **Accesibilidad e i18n**: mensajes claros y consistentes.

---

## 6) Plan de migración y despliegue

1. **Migraciones DB**: agregar campos `status/deleted_*`, índices y vistas `v_*_active`.
2. **API**: adaptar endpoints a soft delete; agregar `relations-counts` y `restore`.
3. **App Flutter**: actualizar llamadas y UI de confirmación/badges.
4. **Backfill**: setear `status='active'` a registros existentes (default ya lo cubre).
5. **Feature flag** (opcional): activar soft delete por fases.
6. **Purge job** (opcional): tarea semanal/mensual que borre definitivamente `deleted` con antigüedad > N días.

---

## 7) Pruebas (QA)

- **Unidad (DB)**: triggers, vistas, consultas filtradas.
- **API**: DELETE=soft delete, RESTORE, LIST con filtros.
- **UI**: flujos de confirmación, conteos correctos, ocultamiento en listados.
- **Regresión**: pedigrí, genealogía, búsquedas, filtros.
- **Carga**: índices efectivos en `status`, `deleted_at`.

---

## 8) Consideraciones adicionales

- **Genealogía**: si se elimina un gallo ancestro, el árbol debe omitirlo en vistas por defecto; permitir modo histórico.
- **Reportes**: usar vistas activas por defecto, o permitir incluir `deleted` con un flag.
- **Auditoría**: registrar `deleted_by` y opcionalmente tabla de auditoría.
- **Seguridad**: solo roles autorizados pueden eliminar/restaurar/purgar.

---

## 9) Ejemplos de consultas

- Conteos para confirmación:
```sql
SELECT
  (SELECT COUNT(1) FROM pelea  WHERE gallo_id=$1 AND status='active') AS peleas,
  (SELECT COUNT(1) FROM tope   WHERE gallo_id=$1 AND status='active') AS topes,
  (SELECT COUNT(1) FROM vacuna WHERE gallo_id=$1 AND status='active') AS vacunas;
```

- Listado activo de gallos con últimos eventos:
```sql
SELECT g.*,
       (SELECT MAX(fecha) FROM pelea WHERE gallo_id=g.id AND status='active') AS ultima_pelea
FROM v_gallo_active g
ORDER BY g.created_at DESC;
```

---

## 10) Resumen

- Implementar **soft delete** con `status/deleted_at/deleted_by` en `gallo`, `pelea`, `tope`, `vacuna`.
- Mantener **integridad** con FKs `ON DELETE RESTRICT` y vistas filtradas por `active`.
- Cambiar **API/UI** para confirmar con conteos, ocultar por defecto y permitir **restaurar**.
- Opcional: **purga** programada y auditoría.

Con esta estrategia evitas errores por integridad, proteges la data de clientes y ofreces control total sobre visibilidad, restauración y limpieza.
