@echo off
echo GENERANDO APK DEBUG PARA PRESENTACION...
cd /d "C:\Users\acairamp\Documents\proyecto\Curso\Flutter\gallos_app_new"
flutter clean
flutter pub get
flutter build apk --debug
echo.
echo APK DEBUG GENERADO EN: build\app\outputs\flutter-apk\app-debug.apk
echo ESTE APK SIEMPRE SE INSTALA EN CUALQUIER CELULAR
pause