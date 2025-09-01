// 🤖🔥 NATIVE SHARE PLUGIN - Android Intent.ACTION_SEND
// Windsurf Strategy: Direct Android native sharing without third-party SDKs
package com.castagallos.app

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream
import android.util.Log

class NativeSharePlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "native_share")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "shareAndroid" -> shareAndroid(call, result)
            else -> result.notImplemented()
        }
    }

    /// 🤖 COMPARTIR PDF EN ANDROID USANDO Intent.ACTION_SEND NATIVO
    private fun shareAndroid(call: MethodCall, result: Result) {
        try {
            Log.d("NativeShare", "🤖 Iniciando compartir Android nativo...")

            val pdfBytes = call.argument<ByteArray>("pdfBytes")
            val fileName = call.argument<String>("fileName")
            val text = call.argument<String>("text")
            val mimeType = call.argument<String>("mimeType") ?: "application/pdf"

            if (pdfBytes == null || fileName == null || text == null) {
                result.error("INVALID_ARGUMENTS", "Argumentos requeridos faltantes", null)
                return
            }

            Log.d("NativeShare", "📄 Archivo: $fileName")
            Log.d("NativeShare", "📊 PDF bytes: ${pdfBytes.size}")
            Log.d("NativeShare", "📝 Texto: $text")

            // 1. Crear directorio temporal para PDFs
            val tempDir = File(context.cacheDir, "shared_pdfs")
            if (!tempDir.exists()) {
                tempDir.mkdirs()
                Log.d("NativeShare", "✅ Directorio temporal creado: ${tempDir.absolutePath}")
            }

            // 2. Crear archivo temporal
            val tempFile = File(tempDir, fileName)
            
            // 3. Escribir PDF bytes al archivo
            FileOutputStream(tempFile).use { fos ->
                fos.write(pdfBytes)
                fos.flush()
            }
            
            Log.d("NativeShare", "✅ PDF temporal creado: ${tempFile.absolutePath}")

            // 4. Crear URI usando FileProvider para Android 7+ (API 24+)
            val authority = "${context.packageName}.fileprovider"
            val fileUri = FileProvider.getUriForFile(context, authority, tempFile)
            
            Log.d("NativeShare", "✅ FileProvider URI: $fileUri")

            // 5. Crear Intent.ACTION_SEND - 100% NATIVO ANDROID
            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                type = mimeType
                putExtra(Intent.EXTRA_TEXT, text)
                putExtra(Intent.EXTRA_STREAM, fileUri)
                putExtra(Intent.EXTRA_SUBJECT, "Ficha de Gallo")
                
                // Permitir acceso temporal al archivo
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            // 6. Crear chooser para mostrar apps disponibles
            val chooserIntent = Intent.createChooser(shareIntent, "Compartir ficha via").apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            // 7. Verificar que hay apps que pueden manejar el intent
            val packageManager = context.packageManager
            if (chooserIntent.resolveActivity(packageManager) != null) {
                
                // Iniciar el chooser de Android
                context.startActivity(chooserIntent)
                
                Log.d("NativeShare", "✅ Android chooser iniciado exitosamente")
                
                // Programar limpieza del archivo temporal
                cleanupTempFileAfterDelay(tempFile, 30000) // 30 segundos
                
                result.success(mapOf(
                    "success" to true,
                    "message" to "PDF compartido exitosamente",
                    "filePath" to tempFile.absolutePath
                ))
                
            } else {
                Log.e("NativeShare", "❌ No hay apps disponibles para compartir")
                result.error("NO_APPS", "No hay aplicaciones disponibles para compartir", null)
            }

        } catch (e: Exception) {
            Log.e("NativeShare", "❌ Error compartiendo Android: ${e.message}", e)
            result.error("SHARE_ERROR", "Error compartiendo: ${e.message}", e.toString())
        }
    }

    /// 🧹 LIMPIAR ARCHIVO TEMPORAL DESPUÉS DE DELAY
    private fun cleanupTempFileAfterDelay(file: File, delayMs: Long) {
        Thread {
            try {
                Thread.sleep(delayMs)
                if (file.exists()) {
                    val deleted = file.delete()
                    if (deleted) {
                        Log.d("NativeShare", "✅ Archivo temporal limpiado: ${file.name}")
                    } else {
                        Log.w("NativeShare", "⚠️ No se pudo limpiar archivo temporal: ${file.name}")
                    }
                }
            } catch (e: Exception) {
                Log.w("NativeShare", "⚠️ Error limpiando archivo temporal: ${e.message}")
            }
        }.start()
    }

    /// 📱 VERIFICAR SI WHATSAPP ESTÁ INSTALADO
    private fun isWhatsAppInstalled(): Boolean {
        return try {
            context.packageManager.getPackageInfo("com.whatsapp", 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    /// 🔍 OBTENER APPS QUE PUEDEN COMPARTIR
    private fun getShareableApps(): List<String> {
        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = "application/pdf"
        }
        
        val activities = context.packageManager.queryIntentActivities(shareIntent, 0)
        return activities.map { it.activityInfo.packageName }
    }
}