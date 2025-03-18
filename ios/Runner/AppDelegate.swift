import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 初始化Rust日志系统
    let logPath = RustLogger.getDefaultLogPath()
    if RustLogger.initialize(logPath: logPath) {
      print("Rust日志系统初始化成功，日志文件路径: \(logPath)")
    } else {
      print("Rust日志系统初始化失败")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    RustLoggerPlugin.register(with: self.registrar(forPlugin: "RustLoggerPlugin"))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
