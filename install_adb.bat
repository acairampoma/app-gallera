@echo off
echo INSTALANDO APK EN CELULAR VIA ADB...
cd /d "C:\Users\acairamp\Documents\proyecto\Curso\Flutter\gallos_app_new"
adb devices
echo.
echo Si aparece tu dispositivo arriba, presiona ENTER para instalar
pause
adb install -r build\app\outputs\flutter-apk\app-release.apk
echo.
echo INSTALACION COMPLETADA
pause