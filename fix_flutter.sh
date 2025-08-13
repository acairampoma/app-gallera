#!/bin/bash

echo "🔧 SOLUCIONANDO PROBLEMA FLUTTER - GALLOS APP"
echo "============================================="

echo ""
echo "📍 Navegando al directorio del proyecto..."
cd "/c/Users/acairamp/Documents/proyecto/Curso/Flutter/gallos_app_new"

echo ""
echo "📋 PASO 1: Verificando directorio actual..."
pwd
ls -la pubspec.yaml

echo ""
echo "📋 PASO 2: Verificando contenido de pubspec.yaml..."
head -20 pubspec.yaml

echo ""
echo "📋 PASO 3: Eliminando archivos problemáticos..."
echo "Eliminando pubspec.lock..."
rm -f pubspec.lock && echo "✅ pubspec.lock eliminado" || echo "⚠️ pubspec.lock no existe"

echo "Eliminando .dart_tool..."
rm -rf .dart_tool && echo "✅ .dart_tool eliminado" || echo "⚠️ .dart_tool no existe"

echo "Eliminando build..."
rm -rf build && echo "✅ build eliminado" || echo "⚠️ build no existe"

echo "Eliminando .flutter-plugins..."
rm -f .flutter-plugins && echo "✅ .flutter-plugins eliminado" || echo "⚠️ .flutter-plugins no existe"

echo "Eliminando .flutter-plugins-dependencies..."
rm -f .flutter-plugins-dependencies && echo "✅ .flutter-plugins-dependencies eliminado" || echo "⚠️ .flutter-plugins-dependencies no existe"

echo ""
echo "✅ LIMPIEZA COMPLETADA"
echo "===================="
echo ""
echo "🎯 PRÓXIMOS PASOS MANUALES:"
echo "   1. Ejecutar: flutter pub cache clean"
echo "   2. Ejecutar: flutter clean"
echo "   3. Ejecutar: flutter pub get"
echo "   4. Ejecutar: flutter doctor"
echo ""