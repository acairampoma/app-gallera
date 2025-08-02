# 🔧 SOLUCIÓN AVATAR FLUTTER WEB + MÓVIL

## ❌ PROBLEMA IDENTIFICADO:
- **Error**: `MultipartFile is only supported where dart:io is available`
- **Causa**: Estás corriendo en Flutter Web donde `MultipartFile` no funciona
- **Solución**: Crear versión universal que funcione en Web y Móvil

## ✅ SOLUCIÓN IMPLEMENTADA EN FLUTTER:

### 1. **ApiService mejorado** (YA APLICADO):
```dart
// Detecta automáticamente si es Web o Móvil
if (kIsWeb) {
  // WEB: Usa base64 + JSON
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);
  // POST a /profiles/avatar/web
} else {
  // MÓVIL: Usa MultipartFile tradicional
  // POST a /profiles/avatar
}
```

## 🚀 BACKEND: CREAR ENDPOINT PARA WEB

### Necesitas agregar este endpoint en tu FastAPI:

```python
# En tu archivo de rutas de profiles (profiles.py)

@router.post("/avatar/web")
async def upload_avatar_web(
    avatar_data: dict,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload avatar desde Flutter Web usando base64"""
    try:
        import base64
        from io import BytesIO
        
        # Obtener datos del request
        image_data = avatar_data.get("image_data")
        filename = avatar_data.get("filename", "avatar.jpg")
        
        if not image_data:
            raise HTTPException(status_code=400, detail="No image data provided")
        
        # Decodificar base64
        image_bytes = base64.b64decode(image_data)
        
        # Subir a Cloudinary
        cloudinary_response = cloudinary.uploader.upload(
            image_bytes,
            folder="avatars",
            public_id=f"user_{current_user.id}_avatar",
            overwrite=True,
            resource_type="image"
        )
        
        avatar_url = cloudinary_response.get("secure_url")
        
        # Actualizar perfil
        profile = ProfileService.update_avatar(db, current_user.id, avatar_url)
        
        return {
            "id": profile.id,
            "user_id": profile.user_id,
            "nombre_completo": profile.nombre_completo,
            "avatar_url": profile.avatar_url,
            # ... otros campos
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error uploading avatar: {str(e)}")
```

## 🎯 PRUEBAS:

### **En Móvil/Emulador:**
- ✅ Usa el endpoint original `/profiles/avatar` con MultipartFile
- ✅ Funciona como antes

### **En Flutter Web:**
- ✅ Usa el nuevo endpoint `/profiles/avatar/web` con base64
- ✅ Evita el error de MultipartFile

## 📝 PASOS PARA COMPLETAR:

1. ✅ **Flutter actualizado** (ya hecho)
2. 🔄 **Backend**: Agregar endpoint `/profiles/avatar/web`
3. 🧪 **Probar**: En web y móvil
4. 🎉 **Avatar funcionando universal**

## 🔗 ENDPOINTS FINALES:

- **Móvil**: `POST /profiles/avatar` (MultipartFile)
- **Web**: `POST /profiles/avatar/web` (JSON + base64)
- **Eliminar**: `DELETE /profiles/avatar` (ambos)
