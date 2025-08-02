# 🔥 INTEGRACIÓN BACKEND-FLUTTER ÉPICA - GALLOS APP

> **Documento maestro de integración con diagramas de secuencia**  
> Sistema con modo ONLINE/OFFLINE inteligente

---

## 📊 ARQUITECTURA GENERAL DEL SISTEMA

```mermaid
graph TB
    subgraph "Flutter App"
        UI[UI Screens]
        CONN[ConnectionService<br/>🌐 Monitor]
        SERV[Services Layer]
        CACHE[Local Storage<br/>📱 SharedPrefs]
        MOCK[Mock Data<br/>📁 JSON]
    end
    
    subgraph "Backend Railway"
        API[FastAPI<br/>🚀 Production]
        JWT[JWT Auth]
        CLD[Cloudinary<br/>📸 Fotos]
        DB[(PostgreSQL)]
    end
    
    UI --> CONN
    CONN --> |Online| SERV
    CONN --> |Offline| MOCK
    SERV --> API
    SERV --> CACHE
    API --> JWT
    API --> CLD
    API --> DB
    
    style CONN fill:#ff6b6b
    style MOCK fill:#ffd43b
    style API fill:#51cf66
```

---

## 🎯 MAPA DE SERVICIOS Y FORMULARIOS

### 1️⃣ **PedigriScreen (Lista Principal)**

```mermaid
sequenceDiagram
    participant U as Usuario
    participant PS as PedigriScreen
    participant CS as ConnectionService
    participant GS as GalloService
    participant API as Backend API
    participant MOCK as Mock JSON
    participant CACHE as SharedPrefs
    
    Note over U,CACHE: 🔄 FLUJO DE CARGA INICIAL
    
    U->>PS: Abrir pantalla
    PS->>CS: checkConnectionStatus()
    
    alt 🌐 MODO ONLINE
        CS-->>PS: ConnectionStatus.online
        PS->>PS: Mostrar banner "🌐 Modo Online"
        PS->>GS: getGallos()
        GS->>API: GET /api/v1/gallos
        API-->>GS: Lista de gallos
        GS->>CACHE: Guardar en caché
        GS-->>PS: Retornar gallos
        PS->>PS: Mostrar gallos del backend
    else 📴 MODO OFFLINE
        CS-->>PS: ConnectionStatus.offline
        PS->>PS: Mostrar banner "📴 Modo Sin Cobertura"
        PS->>MOCK: Cargar gallos_mock.json
        MOCK-->>PS: Datos de prueba
        PS->>PS: Mostrar gallos mock
    end
    
    Note over PS: Usuario puede trabajar<br/>en cualquier modo
```

### 2️⃣ **AddGalloMultistepScreen (Formulario Multi-Paso)**

```mermaid
sequenceDiagram
    participant U as Usuario
    participant FORM as AddGalloMultistep
    participant CS as ConnectionService
    participant GS as GalloService
    participant API as Backend API
    participant QUEUE as OfflineQueue
    
    Note over U,QUEUE: 🔥 TÉCNICA ÉPICA PEDIGRÍ
    
    U->>FORM: Llenar formulario
    U->>FORM: Activar "Crear Padre"
    U->>FORM: Activar "Crear Madre"
    
    FORM->>CS: checkConnectionStatus()
    
    alt 🌐 MODO ONLINE - Técnica Épica
        CS-->>FORM: ConnectionStatus.online
        FORM->>GS: crearGalloConPedigri(datos)
        
        Note over GS,API: 🔥 1 REQUEST → 3 REGISTROS
        GS->>API: POST /api/v1/gallos/con-pedigri
        Note right of API: Backend crea:<br/>1. Gallo principal<br/>2. Padre generado<br/>3. Madre generada<br/>Todos con mismo<br/>id_gallo_genealogico
        
        API-->>GS: {gallo, padre, madre}
        GS-->>FORM: Familia completa creada
        FORM->>U: ✅ Éxito: 3 gallos creados
        
    else 📴 MODO OFFLINE - Guardar en Cola
        CS-->>FORM: ConnectionStatus.offline
        FORM->>QUEUE: Encolar operación
        QUEUE->>QUEUE: Generar ID temporal
        QUEUE-->>FORM: Guardado localmente
        FORM->>U: ⏳ Guardado (se sincronizará)
        
        Note over QUEUE: Cuando vuelva internet<br/>se ejecutará la técnica épica
    end
```

### 3️⃣ **Gestión de Fotos con Cloudinary**

```mermaid
sequenceDiagram
    participant U as Usuario
    participant IMG as ImagePicker
    participant FS as FotoService
    participant CS as ConnectionService
    participant API as Backend
    participant CLD as Cloudinary
    participant CACHE as Local Cache
    
    Note over U,CACHE: 📸 FLUJO DE FOTOS
    
    U->>IMG: Seleccionar foto
    IMG-->>U: Foto seleccionada
    
    U->>FS: subirFoto(galloId, foto)
    FS->>CS: checkConnectionStatus()
    
    alt 🌐 ONLINE - Subir a Cloudinary
        CS-->>FS: ConnectionStatus.online
        FS->>API: POST /api/v1/gallos/{id}/foto
        API->>CLD: Upload imagen
        CLD-->>API: URL optimizada
        API-->>FS: {url, publicId}
        FS->>CACHE: Guardar URL
        FS-->>U: ✅ Foto subida
        
    else 📴 OFFLINE - Guardar Local
        CS-->>FS: ConnectionStatus.offline
        FS->>CACHE: Guardar path local
        FS->>CACHE: Marcar para sync
        FS-->>U: 📱 Foto guardada localmente
        
        Note over CACHE: Se subirá cuando<br/>vuelva la conexión
    end
```

### 4️⃣ **GenealogyTreeScreen (Árbol Genealógico)**

```mermaid
sequenceDiagram
    participant U as Usuario
    participant TREE as GenealogyTree
    participant CS as ConnectionService
    participant GS as GalloService
    participant API as Backend
    participant MOCK as Mock Data
    
    Note over U,MOCK: 🌳 ÁRBOL GENEALÓGICO
    
    U->>TREE: Ver árbol de "El Campeón"
    TREE->>CS: checkConnectionStatus()
    
    alt 🌐 ONLINE - Consulta Recursiva
        CS-->>TREE: ConnectionStatus.online
        TREE->>GS: getGenealogiaCompleta(galloId)
        GS->>API: GET /api/v1/gallos/{id}/genealogia
        
        Note right of API: Backend ejecuta<br/>consulta recursiva<br/>WHERE id_gallo_genealogico = X
        
        API-->>GS: JSON anidado completo
        GS-->>TREE: Árbol genealógico
        TREE->>TREE: Renderizar árbol interactivo
        
    else 📴 OFFLINE - Búsqueda Local
        CS-->>TREE: ConnectionStatus.offline
        TREE->>MOCK: Buscar relaciones
        MOCK->>MOCK: Filtrar por padre_id/madre_id
        MOCK-->>TREE: Árbol desde mock
        TREE->>TREE: Mostrar con badge "📴"
    end
```

---

## 📁 ESTRUCTURA DE ARCHIVOS MOCK

### gallos_mock.json
```json
{
  "gallos": [
    {
      "id": 1,
      "nombre": "El Campeón",
      "codigo_identificacion": "CHAMP001",
      "peso": 2.8,
      "altura": 48,
      "color": "Giro",
      "estado": "activo",
      "id_gallo_genealogico": 123,
      "padre_id": 2,
      "madre_id": 3,
      "tipo_registro": "principal",
      "foto_principal": "assets/images/gallos/gallo1.jpg",
      "created_at": "2024-01-15T10:00:00",
      "raza": {
        "id": 1,
        "nombre": "Kelso"
      }
    },
    {
      "id": 2,
      "nombre": "Padre Campeón",
      "codigo_identificacion": "PAD001",
      "id_gallo_genealogico": 123,
      "tipo_registro": "padre_generado",
      "padre_id": 4,
      "madre_id": 5
    },
    {
      "id": 3,
      "nombre": "Madre Campeona",
      "codigo_identificacion": "MAD001",
      "id_gallo_genealogico": 123,
      "tipo_registro": "madre_generada"
    }
  ],
  "razas": [
    {"id": 1, "nombre": "Kelso"},
    {"id": 2, "nombre": "Hatch"},
    {"id": 3, "nombre": "Sweater"}
  ]
}
```

---

## 🔄 SERVICIO DE CONEXIÓN Y SINCRONIZACIÓN

### ConnectionService - Estados
```mermaid
stateDiagram-v2
    [*] --> Checking: App inicia
    Checking --> Online: Backend responde
    Checking --> Offline: Backend no responde
    
    Online --> Checking: Error de red
    Offline --> Checking: Retry cada 30s
    
    Online --> Syncing: Hay datos pendientes
    Syncing --> Online: Sync completo
    
    state Online {
        [*] --> Connected
        Connected --> LoadingFromAPI
        LoadingFromAPI --> ShowingData
    }
    
    state Offline {
        [*] --> NoConnection
        NoConnection --> LoadingFromMock
        LoadingFromMock --> ShowingMockData
        ShowingMockData --> QueueingChanges
    }
```

---

## 🎯 MAPEO DE ENDPOINTS A SERVICIOS

| Pantalla | Acción | Endpoint Backend | Método Servicio | Fallback Offline |
|----------|---------|-----------------|-----------------|------------------|
| **PedigriScreen** | Listar gallos | `GET /api/v1/gallos` | `GalloService.getGallos()` | `gallos_mock.json` |
| | Eliminar gallo | `DELETE /api/v1/gallos/{id}` | `GalloService.deleteGallo()` | Queue para sync |
| **AddGalloMultistep** | Crear con pedigrí | `POST /api/v1/gallos/con-pedigri` | `GalloService.crearGalloConPedigri()` | Guardar local + queue |
| | Actualizar gallo | `PUT /api/v1/gallos/{id}` | `GalloService.updateGallo()` | Queue para sync |
| | Subir foto | `POST /api/v1/gallos/{id}/foto` | `FotoService.subirFoto()` | Guardar path local |
| **GenealogyTree** | Árbol completo | `GET /api/v1/gallos/{id}/genealogia` | `GalloService.getGenealogiaCompleta()` | Búsqueda en mock |
| | Detalle gallo | `GET /api/v1/gallos/{id}` | `GalloService.getGalloDetalle()` | Buscar en mock |

---

## 🚀 PASOS DE IMPLEMENTACIÓN

### FASE 1: Base Services
1. ✅ `connection_service.dart` - Monitor de conexión
2. ✅ `gallo_service.dart` - CRUD gallos con técnica épica
3. ✅ `foto_service.dart` - Gestión fotos Cloudinary
4. ✅ `offline_queue_service.dart` - Cola de sincronización

### FASE 2: UI Adaptation
1. ✅ Banner de estado conexión en `BaseScreen`
2. ✅ Modificar `PedigriScreen` para dual mode
3. ✅ Adaptar `AddGalloMultistep` con queue
4. ✅ Update `GenealogyTree` para offline

### FASE 3: Sync System
1. ✅ Background sync cuando vuelve internet
2. ✅ Resolver conflictos de IDs temporales
3. ✅ Notificaciones de sync status

---

## 📱 EXPERIENCIA DE USUARIO

### Modo Online 🌐
- Banner verde: "✅ Conectado al servidor"
- Datos en tiempo real
- Fotos se suben a Cloudinary
- Técnica épica funciona completa

### Modo Offline 📴
- Banner naranja: "📴 Modo sin cobertura - Datos de prueba"
- Usa datos mock para lectura
- Cambios se guardan en cola
- Fotos se guardan localmente
- Sync automático cuando vuelve internet

---

## 🔒 CONSIDERACIONES DE SEGURIDAD

1. **JWT Token**: Renovar automáticamente
2. **Datos sensibles**: No guardar en SharedPrefs sin encriptar
3. **Fotos**: Limpiar caché periódicamente
4. **Mock data**: Marcar claramente como "DEMO"

---

*Documento actualizado para GALLOS APP con técnica épica de pedigrí*