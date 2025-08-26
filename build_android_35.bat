@echo off
echo =========================================
echo  COMPILANDO GALLOS APP - ANDROID API 35
echo =========================================
echo.

echo [1/6] Limpiando el proyecto...
flutter clean

echo.
echo [2/6] Obteniendo dependencias...
flutter pub get

echo.
echo [3/6] Verificando configuración Flutter...
flutter doctor

echo.
echo [4/6] Compilando APK de debug para pruebas...
flutter build apk --debug

echo.
echo [5/6] Compilando AAB (Android App Bundle) para Play Store...
flutter build appbundle --release

echo.
echo [6/6] ¡Compilación completada!
echo.
echo ARCHIVOS GENERADOS:
echo - APK Debug: build/app/outputs/flutter-apk/app-debug.apk
echo - AAB Release: build/app/outputs/bundle/release/app-release.aab
echo.
echo El archivo AAB es el que debes subir a Google Play Store.
echo.
pause
