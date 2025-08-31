@echo off
echo =========================================
echo SOLUCION PRIVACY MANIFESTS PARA iOS
echo =========================================
echo.

REM Hacer backup
echo [1/6] Creando backup de pubspec.yaml...
copy pubspec.yaml pubspec_backup_%date:~-4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.yaml

REM Actualizar pubspec con las versiones correctas
echo [2/6] Actualizando dependencias en pubspec.yaml...
copy /Y pubspec_ios_fixed.yaml pubspec.yaml

REM Limpiar todo
echo [3/6] Limpiando proyecto...
call flutter clean

REM Actualizar dependencias
echo [4/6] Descargando nuevas dependencias...
call flutter pub get

REM Actualizar iOS
echo [5/6] Actualizando iOS...
cd ios

REM Limpiar CocoaPods completamente
if exist