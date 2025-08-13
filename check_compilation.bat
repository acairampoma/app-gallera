@echo off
echo 🛠️ Verificando compilacion de Flutter...

cd "C:\Users\acairamp\Documents\proyecto\Curso\Flutter\gallos_app_new"

echo 📋 Proyecto actual:
pwd

echo 🔍 Ejecutando flutter analyze...
flutter analyze --no-pub

echo 📱 Estado de flutter doctor:
flutter doctor --verbose

pause