import Flutter
import UIKit

class RustLoggerPlugin: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.rust_logger", binaryMessenger: registrar.messenger())
        let instance = RustLoggerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            if let args = call.arguments as? [String: Any],
               let logPath = args["logPath"] as? String {
                let success = RustLogger.initialize(logPath: logPath)
                result(success)
            } else {
                let success = RustLogger.initialize(logPath: RustLogger.getDefaultLogPath())
                result(success)
            }
            
        case "debug":
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                RustLogger.debug(message)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing message argument", details: nil))
            }
            
        case "info":
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                RustLogger.info(message)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing message argument", details: nil))
            }
            
        case "warn":
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                RustLogger.warn(message)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing message argument", details: nil))
            }
            
        case "error":
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                RustLogger.error(message)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing message argument", details: nil))
            }
            
        case "getDefaultLogPath":
            result(RustLogger.getDefaultLogPath())
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
} 