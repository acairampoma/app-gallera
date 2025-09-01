# 🌐 Dockerfile para Flutter Web - Casta de Gallos
# Optimizado para Railway deployment con Dart SDK 3.5.x

FROM ghcr.io/cirruslabs/flutter:3.24.5 AS build

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración web-específico
COPY pubspec.web.yaml ./pubspec.yaml
COPY pubspec.lock ./

# Instalar dependencias (solo compatibles con web)
RUN flutter pub get

# Copiar el código fuente
COPY . .

# Construir la aplicación web
RUN flutter build web --release --web-renderer canvaskit --base-href /

# Etapa de producción - servidor HTTP ligero
FROM python:3.11-alpine AS runtime

# http.server es built-in en Python, no necesita instalación

# Crear usuario no-root para seguridad
RUN addgroup -g 1000 flutteruser && \
    adduser -u 1000 -G flutteruser -s /bin/sh -D flutteruser

# Crear directorio para la app
RUN mkdir -p /app/web && chown -R flutteruser:flutteruser /app

# Cambiar a usuario no-root
USER flutteruser

# Copiar archivos web construidos
COPY --from=build --chown=flutteruser:flutteruser /app/build/web /app/web

# Establecer directorio de trabajo
WORKDIR /app/web

# Exponer puerto
EXPOSE 8080

# Comando para servir la aplicación
CMD ["python", "-m", "http.server", "8080", "--bind", "0.0.0.0"]