// 📱🔥 NATIVE SHARE PLUGIN - iOS UIActivityViewController
// Windsurf Strategy: Direct iOS native sharing without third-party SDKs
import Flutter
import UIKit

public class NativeSharePlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_share", binaryMessenger: registrar.messenger())
    let instance = NativeSharePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "shareIOS":
      shareIOS(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  /// 📱 COMPARTIR PDF EN iOS USANDO UIActivityViewController NATIVO
  private func shareIOS(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let pdfBytes = args["pdfBytes"] as? FlutterStandardTypedData,
          let fileName = args["fileName"] as? String,
          let text = args["text"] as? String else {
      result([
        "success": false,
        "error": "Argumentos inválidos para shareIOS"
      ])
      return
    }
    
    DispatchQueue.main.async {
      do {
        print("📱 Iniciando compartir iOS nativo...")
        print("📄 Archivo: \(fileName)")
        print("📊 PDF bytes: \(pdfBytes.data.count)")
        
        // 1. Obtener el view controller actual
        guard let viewController = self.getCurrentViewController() else {
          result([
            "success": false,
            "error": "No se pudo obtener el view controller actual"
          ])
          return
        }
        
        // 2. Crear archivo temporal para el PDF
        let tempDir = NSTemporaryDirectory()
        let tempFilePath = "\(tempDir)\(fileName)"
        let fileURL = URL(fileURLWithPath: tempFilePath)
        
        // 3. Escribir PDF bytes al archivo temporal
        try pdfBytes.data.write(to: fileURL)
        print("✅ PDF temporal creado en: \(tempFilePath)")
        
        // 4. Preparar items para compartir
        var activityItems: [Any] = []
        
        // Agregar texto descriptivo
        activityItems.append(text)
        
        // Agregar archivo PDF
        activityItems.append(fileURL)
        
        // 5. Crear UIActivityViewController - 100% NATIVO iOS
        let activityViewController = UIActivityViewController(
          activityItems: activityItems,
          applicationActivities: nil
        )
        
        // 6. Configurar subject para email
        if let subject = args["subject"] as? String {
          activityViewController.setValue(subject, forKey: "subject")
        }
        
        // 7. Configurar para iPad (popover)
        if let popover = activityViewController.popoverPresentationController {
          popover.sourceView = viewController.view
          popover.sourceRect = CGRect(x: viewController.view.bounds.midX, 
                                    y: viewController.view.bounds.midY, 
                                    width: 0, height: 0)
          popover.permittedArrowDirections = []
        }
        
        // 8. Configurar completion handler
        activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
          
          // Limpiar archivo temporal
          DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2.0) {
            do {
              try FileManager.default.removeItem(at: fileURL)
              print("✅ Archivo temporal limpiado")
            } catch {
              print("⚠️ Error limpiando archivo temporal: \(error)")
            }
          }
          
          if let error = error {
            print("❌ Error en UIActivityViewController: \(error)")
            result([
              "success": false,
              "error": "Error compartiendo: \(error.localizedDescription)"
            ])
            return
          }
          
          if completed {
            let activityName = activityType?.rawValue ?? "unknown"
            print("✅ Compartido exitosamente via: \(activityName)")
            result([
              "success": true,
              "message": "PDF compartido exitosamente via \(activityName)",
              "activityType": activityName
            ])
          } else {
            print("ℹ️ Usuario canceló el compartir")
            result([
              "success": true,
              "message": "Usuario canceló el compartir"
            ])
          }
        }
        
        // 9. Presentar el UIActivityViewController - MOSTRAR SHARE SHEET NATIVO
        viewController.present(activityViewController, animated: true) {
          print("✅ UIActivityViewController presentado")
        }
        
      } catch {
        print("❌ Error creando archivo temporal: \(error)")
        result([
          "success": false,
          "error": "Error creando archivo temporal: \(error.localizedDescription)"
        ])
      }
    }
  }
  
  /// 🔍 OBTENER VIEW CONTROLLER ACTUAL
  private func getCurrentViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else {
      return nil
    }
    
    guard let window = windowScene.windows.first else {
      return nil
    }
    
    guard let rootViewController = window.rootViewController else {
      return nil
    }
    
    return getTopViewController(from: rootViewController)
  }
  
  /// 🔍 OBTENER TOP VIEW CONTROLLER
  private func getTopViewController(from viewController: UIViewController) -> UIViewController {
    if let navigationController = viewController as? UINavigationController {
      return getTopViewController(from: navigationController.visibleViewController!)
    }
    
    if let tabBarController = viewController as? UITabBarController {
      return getTopViewController(from: tabBarController.selectedViewController!)
    }
    
    if let presentedViewController = viewController.presentedViewController {
      return getTopViewController(from: presentedViewController)
    }
    
    return viewController
  }
}