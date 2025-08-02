# 🚀 DEPLOY BACKEND - CAMBIO DE CONTRASEÑA

## 📋 **RESUMEN DE CAMBIOS:**

### ✅ **Archivos modificados en backend:**

1. **📄 `/app/schemas/auth.py`**
   - ✅ Agregado `ChangePassword` schema
   - ✅ Validación nueva contraseña (mínimo 6 caracteres)

2. **📄 `/app/services/auth_service.py`**
   - ✅ Función `change_password()` agregada
   - ✅ Verificación contraseña actual
   - ✅ Hash y actualización nueva contraseña

3. **📄 `/app/api/v1/auth.py`**
   - ✅ Endpoint `PUT /auth/change-password`
   - ✅ Protegido con JWT
   - ✅ Manejo de errores completo

## 🚀 **PARA HACER DEPLOY A RAILWAY:**

### **Opción 1: GitHub + Railway (RECOMENDADO)**

```bash
# 1. Ve a tu directorio del backend
cd C:\Users\acairamp\Documents\proyecto\Curso\Flutter\galloapp_backend

# 2. Add cambios a git
git add .
git commit -m "🔐 Agregar endpoint cambio de contraseña"

# 3. Push a GitHub
git push origin main

# 4. Railway hará auto-deploy automáticamente
```

### **Opción 2: Railway CLI**

```bash
# 1. Instalar Railway CLI
npm install -g @railway/cli

# 2. Login a Railway
railway login

# 3. Deploy directo
railway up
```

## 🔍 **VERIFICAR DEPLOY:**

### **1. Comprobar logs de Railway:**
- Ve a tu proyecto en railway.app
- Mira los logs de deploy
- Asegúrate que no hay errores

### **2. Probar endpoint manualmente:**

```bash
# Login para obtener token
curl -X POST "https://gallerappback-production.up.railway.app/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "juan.salas.nuevo@galloapp.com", 
    "password": "123456"
  }'

# Usar token para cambiar contraseña
curl -X PUT "https://gallerappback-production.up.railway.app/auth/change-password" \
  -H "Authorization: Bearer TU_TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{
    "current_password": "123456",
    "new_password": "nuevaclave123"
  }'
```

### **3. Respuesta esperada:**
```json
{
  "message": "Contraseña cambiada exitosamente",
  "success": true
}
```

## 📱 **FLUTTER YA ESTÁ LISTO:**

- ✅ **API call implementado** en `ApiService.changePassword()`
- ✅ **UI funcional** en ProfileScreen
- ✅ **Manejo de errores** completo
- ✅ **Validaciones** del lado cliente
- ✅ **Loading states** y feedback

## 🎯 **DESPUÉS DEL DEPLOY:**

1. **🚀 Hacer hot restart** en Flutter
2. **🔐 Probar cambio de contraseña** desde la app
3. **✅ Verificar** que funciona correctamente

## ❌ **SI HAY PROBLEMAS:**

### **Error 404 Not Found:**
- El endpoint no está desplegado aún
- Verificar que el deploy terminó exitosamente

### **Error 401 Unauthorized:**
- Token JWT expirado o inválido
- Hacer logout/login en la app

### **Error 422 Validation Error:**
- Datos del request mal formateados
- Verificar schema ChangePassword

### **Error 500 Internal Server Error:**
- Error en el código del backend
- Revisar logs de Railway

---

## 🏆 **UNA VEZ DESPLEGADO:**

**Tu app tendrá cambio de contraseña completamente funcional:**
- 🔐 **Autenticación JWT** protegida
- 🛡️ **Validación contraseña actual**
- 🔒 **Hash seguro** nueva contraseña
- 💾 **Actualización PostgreSQL**
- 📱 **UX completa** en Flutter

**¡Stack completo funcionando!** 🎉
