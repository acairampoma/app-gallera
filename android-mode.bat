@echo off
echo 🤖 ACTIVANDO MODO ANDROID...
copy /Y pubspec_android.yaml pubspec.yaml
copy /Y main_android.dart lib\main.dart
echo ✅ Configuración Android activada!
echo.
echo 📱 Ahora ejecuta:
echo    flutter clean
echo    flutter pub get
echo    flutter build apk --release
pause