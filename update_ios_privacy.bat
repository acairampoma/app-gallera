@echo off
echo =========================================
echo ACTUALIZANDO APP PARA iOS CON PRIVACY MANIFESTS
echo =========================================

REM Hacer backup del pubspec actual
echo.
echo [1/8] Creando backup del pubspec actual...
copy pubspec.yaml pubspec_backup_%date:~-4%%date:~-10,2%%date:~-7,2%.yaml

REM Actualizar pubspec
echo.
echo [2/8] Actualizando pubspec.yaml...
copy /Y pubspec_ios_fixed.yaml pubspec.yaml

REM Limpiar Flutter
echo.
echo [3/8] Limpiando cache de Flutter...
call flutter clean
if errorlevel 1 goto error

REM Actualizar dependencias
echo.
echo [4/8] Actualizando dependencias...
call flutter pub get
if errorlevel 1 goto error

REM Actualizar iOS específicamente
echo.
echo [5/8] Preparando iOS...
cd ios
if exist Podfile.lock del Podfile.lock
if exist Pods rmdir /s /q Pods

REM Actualizar Podfile
echo.
echo [6/8] Actualizando Podfile...
copy /Y Podfile_fixed Podfile

REM Actualizar CocoaPods
echo.
echo [7/8] Actualizando CocoaPods...
pod repo update
pod install --repo-update
cd ..

REM Verificar la build
echo.
echo [8/8] Verificando build iOS...
call flutter build ios --release --no-codesign
if errorlevel 1 goto error

echo.
echo =========================================
echo ✅ ACTUALIZACIÓN COMPLETADA CON ÉXITO
echo =========================================
echo.
echo PRÓXIMOS PASOS:
echo 1. Abre el proyecto en Xcode
echo 2. Selecciona Product -^> Archive
echo 3. Sube a TestFlight
echo.
goto end

:error
echo.
echo =========================================
echo ❌ ERROR EN LA ACTUALIZACIÓN
echo =========================================
echo Por favor revisa los mensajes de error arriba
echo.

:end
pause
