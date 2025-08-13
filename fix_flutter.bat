@echo off
echo 🔧 SOLUCIONANDO PROBLEMA FLUTTER - GALLOS APP
echo =============================================

echo.
echo 📍 Navegando al directorio del proyecto...
cd /d "C:\Users\acairamp\Documents\proyecto\Curso\Flutter\gallos_app_new"

echo.
echo 📋 PASO 1: Respaldando pubspec.yaml original...
if exist "pubspec.yaml" (
    copy "pubspec.yaml" "pubspec_backup.yaml"
    echo ✅ Backup creado: pubspec_backup.yaml
)

echo.
echo 📋 PASO 2: Usando pubspec.yaml corregido...
if exist "pubspec_fixed.yaml" (
    copy "pubspec_fixed.yaml" "pubspec.yaml"
    echo ✅ pubspec.yaml actualizado con versiones compatibles
)

echo.
echo 📋 PASO 3: Eliminando archivos problemáticos...
if exist "pubspec.lock" (
    del "pubspec.lock"
    echo ✅ pubspec.lock eliminado
)
if exist ".dart_tool" (
    rmdir /s /q ".dart_tool"
    echo ✅ .dart_tool eliminado
)
if exist "build" (
    rmdir /s /q "build"
    echo ✅ build eliminado
)
if exist ".flutter-plugins" (
    del ".flutter-plugins"
    echo ✅ .flutter-plugins eliminado
)
if exist ".flutter-plugins-dependencies" (
    del ".flutter-plugins-dependencies"
    echo ✅ .flutter-plugins-dependencies eliminado
)

echo.
echo 📋 PASO 4: Limpiando cache de Flutter...
flutter pub cache clean
echo ✅ Cache de pub limpiado

echo.
echo 📋 PASO 5: Limpiando proyecto...
flutter clean
echo ✅ Proyecto limpiado

echo.
echo 📋 PASO 6: Obteniendo dependencias...
flutter pub get

echo.
echo 📋 PASO 7: Verificando estado...
flutter doctor

echo.
echo ✅ PROCESO COMPLETADO
echo ==================
echo.
echo 🎯 PRÓXIMOS PASOS:
echo   1. Si no hay errores, ejecutar: flutter run
echo   2. Si persisten errores, ejecutar: flutter upgrade
echo   3. Para restaurar pubspec original: copy pubspec_backup.yaml pubspec.yaml
echo.
pause