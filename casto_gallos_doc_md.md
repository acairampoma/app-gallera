# 🔥 CASTO_DE_GALLOSAPP API - Documentación Completa

> **Sistema profesional para gestión de gallos de pelea**  
> Desarrollado por el equipo de Casto de Gallos 🐓

---

## 📍 Ubicación del Proyecto

```
📁 C:\Users\acairamp\Documents\proyecto\Curso\Flutter\galloapp_backend\
```

---

## 🏗️ Arquitectura del Sistema

```mermaid
graph TB
    subgraph "Frontend"
        FL[Flutter Mobile App]
    end
    
    subgraph "Backend - CASTO_DE_GALLOSAPP API"
        FA[FastAPI Server]
        JWT[JWT Auth]
        EP[Endpoints]
    end
    
    subgraph "Servicios Externos"
        CL[Cloudinary<br/>📸 Fotos]
        PG[(PostgreSQL<br/>🗄️ Railway)]
    end
    
    subgraph "Funcionalidades Épicas"
        PED[🧬 Técnica Pedigrí<br/>1 → 3 registros]
        GEN[🌳 Genealogía Recursiva<br/>Infinita]
        FOT[📸 Gestión Fotos<br/>Cloudinary]
    end
    
    FL --> FA
    FA --> JWT
    FA --> EP
    EP --> PED
    EP --> GEN
    EP --> FOT
    FA --> CL
    FA --> PG
```

---

## 📁 Estructura de Archivos

### 🗄️ Modelos (SQLAlchemy)
```
├── app/models/
│   ├── __init__.py               # ✅ Imports corregidos
│   ├── user.py                   # Usuario base
│   ├── profile.py                # Perfil de usuario
│   ├── raza_simple.py            # Razas de gallos
│   └── gallo_simple.py           # 🔥 MODELO ÉPICO - Técnica Recursiva
├── app/models_init.py            # 🔧 Fix SQLAlchemy imports
```

### 🌐 Endpoints (FastAPI)
```
├── app/api/v1/
│   ├── auth.py                   # Autenticación JWT
│   ├── profiles.py               # Perfiles + Avatar Cloudinary
│   ├── gallos_real.py            # CRUD básico gallos
│   ├── gallos_con_pedigri.py     # 🧬 TÉCNICA PEDIGRÍ ÉPICA
│   ├── fotos_final.py            # 📸 Fotos Cloudinary
│   ├── gallos_genealogia_epica.py # 🔥 Endpoint épico (corregido)
│   └── fotos_gallos_epica.py     # 📸 Fotos épicas avanzadas
```

### 🔧 Servicios (Business Logic)
```
├── app/services/
│   ├── auth_service.py           # Lógica autenticación
│   ├── profile_service.py        # Lógica perfiles
│   ├── cloudinary_service.py     # 📸 Gestión Cloudinary
│   ├── genealogy_service.py      # 🧬 Técnica recursiva genealógica
│   └── validation_service.py     # ✅ Validaciones robustas
```

### 📋 Schemas (Pydantic)
```
├── app/schemas/
│   ├── auth.py                   # Schemas autenticación
│   ├── profile.py                # Schemas perfiles
│   └── gallo.py                  # Schemas gallos y genealogía
```

### ⚙️ Configuración
```
├── app/core/
│   ├── config.py                 # Settings JWT/DB/Cloudinary
│   └── security.py               # JWT + Hash passwords
├── app/database.py               # Conexión PostgreSQL Railway
├── app/main.py                   # 🚀 FastAPI app principal
├── .env                          # Variables de entorno
├── requirements.txt              # Dependencias Python
├── railway.toml                  # Configuración Railway
└── Procfile                      # Railway deploy config
```

---

## 🔐 Diagrama de Flujo de Autenticación

```mermaid
sequenceDiagram
    participant U as Usuario
    participant A as Flutter App
    participant API as CASTO_DE_GALLOSAPP API
    participant DB as PostgreSQL
    participant JWT as JWT Service
    
    Note over U,JWT: 🔐 Proceso de Autenticación
    
    U->>A: Registrar usuario
    A->>API: POST /auth/register
    API->>DB: Crear usuario + perfil
    DB-->>API: Usuario creado
    API-->>A: RegisterResponse
    A-->>U: Usuario registrado ✅
    
    U->>A: Hacer login
    A->>API: POST /auth/login
    API->>DB: Verificar credenciales
    DB-->>API: Usuario válido
    API->>JWT: Generar tokens
    JWT-->>API: access_token + refresh_token
    API-->>A: LoginResponse con tokens
    A-->>U: Login exitoso 🔑
    
    Note over A,API: Token dura 30 minutos
```

---

## 🧬 Diagrama de Técnica Pedigrí Épica

```mermaid
flowchart TD
    START[🚀 Usuario crea gallo<br/>con pedigrí] --> INPUT[📝 Datos del gallo<br/>+ crear_padre=true<br/>+ crear_madre=true]
    
    INPUT --> VALIDATE[✅ Validar datos<br/>códigos únicos]
    VALIDATE --> GENID[🔢 Generar<br/>id_gallo_genealogico]
    
    GENID --> CREATE1[📝 Crear gallo principal<br/>tipo: 'principal']
    CREATE1 --> CREATE2[📝 Crear padre<br/>tipo: 'padre_generado']
    CREATE2 --> CREATE3[📝 Crear madre<br/>tipo: 'madre_generada']
    
    CREATE3 --> LINK[🔗 Vincular relaciones<br/>padre_id, madre_id]
    LINK --> RESULT[🎉 RESULTADO:<br/>1 request → 3 registros<br/>Familia completa creada]
    
    subgraph "🗄️ Base de Datos"
        DB1[ID: 1 - El Campeón<br/>genealogico: 123<br/>padre_id: 2, madre_id: 3]
        DB2[ID: 2 - Padre Campeón<br/>genealogico: 123<br/>tipo: padre_generado]
        DB3[ID: 3 - Madre Campeona<br/>genealogico: 123<br/>tipo: madre_generada]
    end
    
    RESULT --> DB1
    RESULT --> DB2
    RESULT --> DB3
    
    style START fill:#ff6b6b
    style RESULT fill:#51cf66
    style GENID fill:#ffd43b
```

---

## 🌳 Consulta Genealógica Mágica

```mermaid
graph TD
    subgraph "🔍 Una sola consulta"
        QUERY[SELECT * FROM gallos<br/>WHERE id_gallo_genealogico = 123]
    end
    
    subgraph "📊 Resultado Instantáneo"
        R1[🐓 El Campeón<br/>principal]
        R2[👨 Padre Campeón<br/>padre_generado]
        R3[👩 Madre Campeona<br/>madre_generada]
    end
    
    QUERY --> R1
    QUERY --> R2
    QUERY --> R3
    
    subgraph "🚀 Escalabilidad Infinita"
        EXP[Expandir genealogía<br/>agregando abuelos,<br/>bisabuelos, etc.]
    end
    
    R2 --> EXP
    R3 --> EXP
    
    style QUERY fill:#4ecdc4
    style R1 fill:#45b7d1
    style R2 fill:#96ceb4
    style R3 fill:#ffeaa7
```

---

## 📸 Flujo de Gestión de Fotos

```mermaid
sequenceDiagram
    participant U as Usuario
    participant A as App
    participant API as API
    participant CL as Cloudinary
    participant DB as Database
    
    Note over U,DB: 📸 Subida de Fotos
    
    U->>A: Seleccionar foto
    A->>A: Redimensionar/optimizar
    A->>API: POST /profiles/avatar<br/>multipart/form-data
    API->>API: Validar archivo<br/>(tipo, tamaño)
    API->>CL: Upload imagen
    CL-->>API: URL optimizada
    API->>DB: Guardar URL en perfil
    DB-->>API: Perfil actualizado
    API-->>A: ProfileResponse<br/>con avatar_url
    A->>A: Mostrar imagen
    A-->>U: Avatar actualizado ✅
    
    Note over API,CL: URLs automáticamente<br/>optimizadas (WebP, thumbnails)
```

---

## 🚀 Endpoints Disponibles

### 🔐 Autenticación
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/auth/register` | Registrar nuevo usuario |
| `POST` | `/auth/login` | Login con JWT |
| `POST` | `/auth/refresh` | Renovar access token |
| `GET` | `/auth/me` | Obtener perfil actual |
| `POST` | `/auth/logout` | Logout seguro |
| `PUT` | `/auth/change-password` | Cambiar contraseña |

### 👤 Perfiles
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/profiles/me` | Mi perfil |
| `PUT` | `/profiles/me` | Actualizar perfil |
| `POST` | `/profiles/avatar` | 📸 **Subir avatar a Cloudinary** |
| `DELETE` | `/profiles/avatar` | Eliminar avatar |
| `GET` | `/profiles/me/complete` | Perfil completo con usuario |

### 🐓 Gallos
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/v1/gallos` | Listar gallos con filtros |
| `POST` | `/api/v1/gallos` | Crear gallo básico |
| `GET` | `/api/v1/gallos/{id}` | Detalle completo del gallo |
| `PUT` | `/api/v1/gallos/{id}` | Actualizar gallo |
| `DELETE` | `/api/v1/gallos/{id}` | Eliminar gallo |

### 🧬 Pedigrí (Técnica Épica)
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/v1/gallos/con-pedigri` | 🔥 **1 → 3 registros automáticos** |
| `GET` | `/api/v1/gallos/{id}/genealogia` | Árbol genealógico completo |

### 📸 Fotos de Gallos
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/v1/gallos/{id}/foto` | Subir foto del gallo |
| `GET` | `/api/v1/gallos/{id}/fotos` | Listar todas las fotos |
| `DELETE` | `/api/v1/gallos/{id}/fotos/{numero}` | Eliminar foto específica |

### 🔥 Sistema
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/health` | Health check general |
| `GET` | `/test-db` | Test conexión PostgreSQL |
| `GET` | `/test-cloudinary` | Test conexión Cloudinary |
| `GET` | `/docs` | 📋 **Swagger UI Interactivo** |

---

## 🧪 Ejemplos de Uso con cURL

### 1️⃣ Registrar Usuario
```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testcasto@galloapp.com",
    "password": "CastoGallo123@",
    "nombre_completo": "Usuario Test Casto",
    "telefono": "987654321",
    "nombre_galpon": "Galpon Casto Test",
    "ciudad": "Lima"
  }'
```

### 2️⃣ Login y Obtener JWT
```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testcasto@galloapp.com",
    "password": "CastoGallo123@"
  }'
```

### 3️⃣ Crear Gallo con Pedigrí (🔥 TÉCNICA ÉPICA)
```bash
curl -X POST http://localhost:8000/api/v1/gallos/con-pedigri \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nombre=Campeón con Pedigrí&codigo_identificacion=PED001&peso=2.8&altura=48&color=Giro&crear_padre=true&padre_nombre=Padre Campeón&padre_codigo=PAD001&crear_madre=true&madre_nombre=Madre Campeona&madre_codigo=MAD001"
```

### 4️⃣ Subir Avatar
```bash
curl -X POST http://localhost:8000/profiles/avatar \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/ruta/a/imagen.jpg"
```

---

## 🔧 Configuración del Sistema

### 📋 Variables de Entorno (.env)
```env
# 🗄️ PostgreSQL Railway
DATABASE_URL=postgresql://postgres:KfktiHjbugWVTzvalfwxiVZwsvVFatrk@gondola.proxy.rlwy.net:54162/railway

# 🔐 JWT
SECRET_KEY=galloapp-super-secret-key-development
ACCESS_TOKEN_EXPIRE_MINUTES=30

# 📸 Cloudinary
CLOUDINARY_CLOUD_NAME=dz4czc3en
CLOUDINARY_API_KEY=455285241939111
CLOUDINARY_API_SECRET=1uzQrkFD1Rbj8vPOClFBUEIwBn0

# 🌐 CORS
ALLOWED_HOSTS=["*"]

# 🔄 Environment
ENVIRONMENT=local
```

### 🚀 Ejecutar el Servidor
```bash
# Activar entorno virtual
venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar servidor
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

---

## 🗄️ Esquema de Base de Datos

### Tabla: usuarios
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT true,
    is_premium BOOLEAN DEFAULT false,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabla: profiles
```sql
CREATE TABLE profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    nombre_completo VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    nombre_galpon VARCHAR(255),
    ciudad VARCHAR(100),
    avatar_url TEXT,  -- 📸 URL de Cloudinary
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabla: gallos (🔥 CON TÉCNICA RECURSIVA)
```sql
CREATE TABLE gallos (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    raza_id INTEGER REFERENCES razas(id),
    
    -- 🐓 Información básica
    nombre VARCHAR(255) NOT NULL,
    codigo_identificacion VARCHAR(50) NOT NULL,
    peso NUMERIC(5,2),
    altura INTEGER,
    color VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'activo',
    
    -- 🧬 TÉCNICA RECURSIVA GENEALÓGICA
    id_gallo_genealogico INTEGER,  -- 🔥 CAMPO MÁGICO
    padre_id INTEGER REFERENCES gallos(id),
    madre_id INTEGER REFERENCES gallos(id),
    tipo_registro VARCHAR(20) DEFAULT 'principal',
    
    -- 📸 Fotos Cloudinary
    foto_principal_url TEXT,
    url_foto_cloudinary TEXT,
    fotos_adicionales JSONB,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 🚀 Índices para performance épica
CREATE INDEX idx_gallos_genealogico ON gallos(id_gallo_genealogico);
CREATE INDEX idx_gallos_padre ON gallos(padre_id);
CREATE INDEX idx_gallos_madre ON gallos(madre_id);
```

---

## 🏆 Ventajas de la Técnica Recursiva

### ⚡ Performance
- **Una sola consulta** obtiene toda la familia
- **Índices optimizados** para búsquedas rápidas
- **Escalable** a millones de registros

### 🧠 Usabilidad
- **1 formulario → 3 registros** automáticamente
- **Expansión fácil** de genealogía
- **Búsqueda intuitiva** por familias

### 🔒 Robustez
- **Validaciones completas** anti-ciclos
- **Transacciones seguras** con rollback
- **Error handling** robusto

---

## 🌐 URLs del Sistema

| Ambiente | URL | Estado |
|----------|-----|--------|
| **Local** | http://localhost:8000 | ✅ Funcionando |
| **Railway** | https://gallerappback-production.up.railway.app | ✅ Funcionando |
| **Swagger Local** | http://localhost:8000/docs | 📋 Documentación |

---

## 🎉 Conclusión

**CASTO_DE_GALLOSAPP API** es un sistema completo y robusto que incluye:

- ✅ **Autenticación JWT** segura
- ✅ **Gestión de perfiles** con Cloudinary
- ✅ **Técnica pedigrí épica** (1 → 3 registros)
- ✅ **Genealogía recursiva** infinita
- ✅ **Gestión de fotos** optimizada
- ✅ **Base de datos** PostgreSQL Railway
- ✅ **API documentada** con Swagger

**¡El sistema está listo para producción! 🚀🐓**

---

*Desarrollado con ❤️ por el equipo de Casto de Gallos*