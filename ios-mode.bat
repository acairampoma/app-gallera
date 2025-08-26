@echo off
echo 🍎 ACTIVANDO MODO iOS...
copy /Y pubspec_ios.yaml pubspec.yaml
copy /Y main_ios.dart lib\main.dart
echo ✅ Configuración iOS activada!
echo.
echo 📱 Ahora ejecuta:
echo    flutter clean
echo    flutter pub get
echo    flutter build ios --release
pause