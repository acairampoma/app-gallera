import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 📱 Registrar plugin nativo de compartir
    NativeSharePlugin.register(with: self.registrar(forPlugin: "NativeSharePlugin")!)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
