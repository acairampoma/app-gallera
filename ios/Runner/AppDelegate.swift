import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 📱 Registrar canal de compartir nativo directamente aquí
    let controller = window?.rootViewController as! FlutterViewController
    let nativeShareChannel = FlutterMethodChannel(
      name: "com.castagallos.app/native_share",
      binaryMessenger: controller.binaryMessenger
    )
    
    nativeShareChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "sharePDF" {
        guard let args = call.arguments as? [String: Any],
              let pdfData = args["pdfBytes"] as? FlutterStandardTypedData,
              let fileName = args["fileName"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
          return
        }
        
        self?.sharePDF(pdfData: pdfData.data, fileName: fileName, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func sharePDF(pdfData: Data, fileName: String, result: @escaping FlutterResult) {
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent(fileName)
    
    do {
      try pdfData.write(to: fileURL)
      
      DispatchQueue.main.async {
        let activityViewController = UIActivityViewController(
          activityItems: [fileURL],
          applicationActivities: nil
        )
        
        if let rootViewController = self.window?.rootViewController {
          if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX, y: rootViewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
          }
          
          rootViewController.present(activityViewController, animated: true) {
            result(true)
          }
        }
      }
    } catch {
      result(FlutterError(code: "FILE_ERROR", message: "Failed to write PDF file", details: error.localizedDescription))
    }
  }
}
