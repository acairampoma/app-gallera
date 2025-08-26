@echo off
echo.
echo 🍎 ===== ACTIVANDO MODO iOS LIMPIO =====
echo.
echo 📋 Copiando configuraciones iOS limpias...

REM Backup actual
if exist pubspec.yaml (
    copy /Y pubspec.yaml pubspec_backup_antes_ios.yaml >nul 2>&1
    echo ✅ Backup creado: pubspec_backup_antes_ios.yaml
)

if exist lib\main.dart (
    copy /Y lib\main.dart main_backup_antes_ios.dart >nul 2>&1
    echo ✅ Backup creado: main_backup_antes_ios.dart
)

REM Aplicar configuración iOS limpia
copy /Y pubspec_ios_clean.yaml pubspec.yaml >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ pubspec.yaml actualizado con configuración iOS limpia
) else (
    echo ❌ Error copiando pubspec_ios_clean.yaml
    pause
    exit /b 1
)

copy /Y main_ios_clean.dart lib\main.dart >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ main.dart actualizado con configuración iOS limpia
) else (
    echo ❌ Error copiando main_ios_clean.dart
    pause
    exit /b 1
)

echo.
echo 🔧 DEPENDENCIAS REMOVIDAS PARA iOS:
echo    ❌ printing, pdf (causa win32 + size parameter error)
echo    ❌ permission_handler (causa win32 + App Store issues)
echo    ❌ firebase_* (causa deprecated warnings)
echo    ❌ share_plus (causa warnings prototypes)
echo    ❌ video_player (no esencial para MVP)
echo    ❌ flutter_local_notifications (errores implementación)
echo    ❌ url_launcher (Swift Launcher protocol error)
echo.
echo ✅ CONFIGURACIÓN iOS LIMPIA ACTIVADA!
echo.
echo 📱 SIGUIENTES PASOS:
echo    1. flutter clean
echo    2. flutter pub get  
echo    3. flutter build ios --release
echo.
pause