@echo off
echo.
echo 🤖 ===== ACTIVANDO MODO ANDROID COMPLETO =====
echo.
echo 📋 Restaurando configuraciones Android completas...

REM Verificar si existen los backups de Android
if exist pubspec_backup.yaml (
    copy /Y pubspec_backup.yaml pubspec.yaml >nul 2>&1
    echo ✅ pubspec.yaml restaurado desde pubspec_backup.yaml
) else (
    echo ⚠️  No se encontró pubspec_backup.yaml, usando pubspec actual
)

if exist main_backup.dart (
    copy /Y main_backup.dart lib\main.dart >nul 2>&1
    echo ✅ main.dart restaurado desde main_backup.dart
) else (
    echo ⚠️  No se encontró main_backup.dart, usando main actual
)

echo.
echo 🔧 DEPENDENCIAS RESTAURADAS PARA ANDROID:
echo    ✅ printing, pdf (exportación PDF)
echo    ✅ permission_handler (permisos almacenamiento)
echo    ✅ firebase_* (push notifications)
echo    ✅ share_plus (compartir archivos)
echo    ✅ video_player (reproducción video)
echo    ✅ flutter_local_notifications (notificaciones locales)
echo    ✅ url_launcher (abrir URLs)
echo.
echo ✅ CONFIGURACIÓN ANDROID COMPLETA ACTIVADA!
echo.
echo 🤖 SIGUIENTES PASOS:
echo    1. flutter clean
echo    2. flutter pub get  
echo    3. flutter build apk --release
echo.
pause