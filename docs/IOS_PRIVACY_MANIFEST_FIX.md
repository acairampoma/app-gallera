# iOS – Guía para resolver ITMS-91061 (Missing privacy manifest)

Esta guía explica cómo corregir el rechazo de App Store Connect por ITMS-91061 “Missing privacy manifest” en el proyecto `gallos_app_new`.

Se corrige en 3 frentes:
- Actualizar Pods para que los frameworks de terceros incluyan su `PrivacyInfo.xcprivacy`.
- Dejar de excluir manifests en el `Podfile`.
- Mantener un `PrivacyInfo.xcprivacy` válido a nivel app (Runner) sin declarar APIs que no uses directamente.

---

## 1) Requisitos previos

- Xcode 15.x
- CocoaPods actualizado (`sudo gem install cocoapods` si hace falta)
- Flutter estable con los plugins ya configurados (según `pubspec.yaml` actual)

---

## 2) Revisar `pubspec.yaml` (ya OK)

Ya usas versiones modernas con manifests en sus Pods:
- `firebase_core: ^3.8.0`, `firebase_messaging: ^15.1.8`
- `flutter_local_notifications: ^18.0.1`
- `image_picker: ^1.1.2`
- `url_launcher: ^6.2.5`
- `video_player: ^2.9.1`
- `sqflite: ^2.4.2`

No es necesario cambiarlas ahora. El problema estaba en Pods/Podfile.

---

## 3) Arreglar `ios/Podfile`

Archivo: `ios/Podfile`

- Asegúrate de tener plataforma global:

```ruby
platform :ios, '12.0'
```

- Mantén `use_frameworks!` / `use_modular_headers!` si ya están en el target `Runner`.

- En el bloque `post_install`, **elimina** la exclusión de manifests:

ANTES (problemático):
```ruby
installer.pods_project.build_configurations.each do |config|
  config.build_settings['EXCLUDED_SOURCE_FILE_NAMES'] = ['**/PrivacyInfo.xcprivacy']
  config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
end
```

DESPUÉS (correcto):
```ruby
installer.pods_project.build_configurations.each do |config|
  # No excluir PrivacyInfo.xcprivacy
  config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
end
```

- Puedes mantener este ajuste para simulador si lo necesitas:
```ruby
config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
```

---

## 4) Corregir `ios/Runner/PrivacyInfo.xcprivacy`

Archivo: `ios/Runner/PrivacyInfo.xcprivacy`

- Corrige la clave mal escrita:
  - `NSPrivacyCollectedDataTypePhotosorVideos` -> `NSPrivacyCollectedDataTypePhotosOrVideos` (la “O” en mayúscula)

- Deja `NSPrivacyAccessedAPITypes` vacío a nivel app, salvo que TU código llame directamente esas Required Reason APIs (RRA). Los SDKs deben declarar sus propias RRAs en sus manifests.

Ejemplo mínimo seguro:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyTracking</key>
  <false/>

  <key>NSPrivacyTrackingDomains</key>
  <array/>

  <key>NSPrivacyCollectedDataTypes</key>
  <array>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypePhotosOrVideos</string>
      <key>NSPrivacyCollectedDataTypeLinked</key><false/>
      <key>NSPrivacyCollectedDataTypeTracking</key><false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array>
        <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
      </array>
    </dict>
  </array>

  <key>NSPrivacyAccessedAPITypes</key>
  <array/>
</dict>
</plist>
```

Notas:
- Declara solo datos que realmente recolectas con fines reales.
- No declares RRAs a menos que las uses directamente.

---

## 5) Limpiar y actualizar Pods

En carpeta `ios/` (en Mac/CI):

```bash
rm -rf Pods Podfile.lock
pod repo update
pod install   # o: pod update (para forzar últimas compatibles)
```

> Motivo: muchas veces el rechazo viene de Pods antiguos sin manifest aunque el plugin Flutter esté actualizado.

---

## 6) Compilar y verificar el .ipa

1) En Xcode: Product > Archive (con Xcode 15.x)
2) Exporta el `.ipa` (o extrae del organizer)
3) Verifica que los frameworks listados por Apple contengan `PrivacyInfo.xcprivacy` dentro de:
   `Payload/Runner.app/Frameworks/<Framework>.framework/PrivacyInfo.xcprivacy`

En particular valida (según el rechazo recibido):
- FBLPromises, FirebaseCore, FirebaseCoreInternal, FirebaseInstallations, FirebaseMessaging
- GoogleDataTransport, GoogleUtilities, nanopb
- flutter_local_notifications, image_picker_ios, sqflite_darwin, url_launcher_ios, video_player_avfoundation

Si alguno falta tras `pod install/update`, ve a la sección de solución de problemas.

---

## 7) Enviar a revisión

- Sube con Transporter o desde Xcode Organizer.
- En App Store Connect, selecciona el nuevo build y envía a revisión.

---

## 8) Solución de problemas

- Aún aparece ITMS-91061 para un SDK específico:
  - Ejecuta `pod update <PodName>` para ese Pod.
  - Fija una versión mínima en `Podfile` si necesitas forzar el release que ya trae manifest.

- Otro rechazo por RRAs declaradas inválidas:
  - Quita RRAs del `PrivacyInfo.xcprivacy` a nivel app; deja que los SDKs declaren las suyas.

- Build viejo sigue subiendo:
  - Asegúrate de limpiar (`Clean Build Folder`) y de que el archive corresponda al último commit con los cambios.

---

## 9) Cambiar versión y build

- Aumenta la `version` en `pubspec.yaml` (ej. `1.4.9+839`).
- Sincroniza con Xcode si gestionas versión desde Flutter o ajústala en `Runner` > `General`.

---

## 10) Resumen

- Quitar la exclusión de `PrivacyInfo.xcprivacy` en `ios/Podfile`.
- Corregir `NSPrivacyCollectedDataTypePhotosOrVideos` en `ios/Runner/PrivacyInfo.xcprivacy` y no declarar RRAs si no las usas directamente.
- Limpiar/actualizar Pods y recompilar con Xcode 15.x.
- Verificar `.ipa` y reenviar. Con esto se soluciona ITMS-91061.
