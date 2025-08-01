# 🐓 Casta de Gallos - App Flutter Profesional

## 📱 Aplicación móvil completa para gestión de gallos de pelea

### ⭐ Características Principales

- 🐓 **Gestión completa de gallos** con pedigrí y genealogía
- 📸 **Galería multimedia** con fotos y videos HD
- 🧬 **Sistema genealógico** recursivo infinito
- 👤 **Perfiles de usuario** con autenticación JWT
- 🏆 **Historial de peleas** y estadísticas
- 💉 **Control de vacunas** y medicina veterinaria
- 📊 **Dashboard analítico** con gráficos y métricas
- 🌐 **Modo offline** con sincronización automática

### 📱 Plataformas Soportadas

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (PWA Ready)
- ✅ **Windows** (Desktop)
- ✅ **Linux** (Desktop)
- ✅ **macOS** (Desktop)

### 🚀 Instalación Rápida

```bash
# Clonar repositorio
git clone https://github.com/acairampoma/app-gallera.git
cd app-gallera

# Instalar dependencias Flutter
flutter pub get

# Generar iconos personalizados
flutter pub run flutter_launcher_icons:main

# Ejecutar en modo desarrollo
flutter run

# Build para producción Android
flutter build apk --release

# Build para web
flutter build web --release
```

### 🛠️ Tecnologías

- **Flutter 3.2+** - Framework multiplataforma
- **Provider** - Gestión de estado reactiva
- **Go Router** - Navegación declarativa
- **HTTP** - Cliente REST optimizado
- **Image Picker** - Captura multimedia
- **Cached Network Image** - Cache inteligente
- **Shared Preferences** - Almacenamiento local
- **Connectivity Plus** - Estado de conexión

### 🎨 Arquitectura

```
lib/
├── core/           # Configuraciones y utilidades
├── data/           # Modelos y servicios API
├── providers/      # Gestión de estado
├── screens/        # Pantallas de la app
├── widgets/        # Componentes reutilizables
├── utils/          # Helpers y constantes
└── main.dart       # Punto de entrada
```

### 🔧 Configuración Backend

1. **Backend FastAPI**: https://github.com/acairampoma/gallerapp_back
2. **Base URL**: Configurar en `lib/core/config.dart`
3. **Cloudinary**: Para gestión de imágenes
4. **PostgreSQL**: Base de datos en Railway

### 📱 Capturas

- 🏠 **Dashboard**: Vista general con estadísticas
- 🐓 **Lista de Gallos**: Grid view con fotos
- 👤 **Perfil de Gallo**: Información detallada + genealogía
- 📸 **Galería**: Fotos y videos HD
- 🧬 **Pedigrí**: Árbol genealógico interactivo
- 💉 **Vacunas**: Control veterinario
- 🏆 **Historial**: Peleas y resultados

### 🚀 Deploy

#### Android Play Store
```bash
flutter build appbundle --release
```

#### iOS App Store
```bash
flutter build ios --release
```

#### Web (Firebase Hosting)
```bash
flutter build web --release
firebase deploy
```

### 🧪 Testing

```bash
# Tests unitarios
flutter test

# Tests de integración
flutter drive --target=test_driver/app.dart

# Análisis de código
flutter analyze
```

### 🎯 Roadmap

- [ ] 🔔 **Push Notifications**
- [ ] 🌍 **Múltiples idiomas** (i18n)
- [ ] 🎮 **Modo competencia** con torneos
- [ ] 📈 **Analytics avanzados**
- [ ] 🤖 **IA para predicciones**
- [ ] 🎥 **Livestreaming** de peleas
- [ ] 💰 **Sistema de apuestas**
- [ ] 🏪 **Marketplace** de gallos

### 👨‍💻 Desarrollador

**Equipo Casto de Gallos** 🐓  
App Flutter profesional con backend FastAPI + PostgreSQL + Cloudinary

### 📄 Licencia

Propietario - Desarrollado para Casto de Gallos

---

*Versión 1.0.0 - Enero 2025*  
*Flutter App + FastAPI Backend - Sistema Completo* 🚀