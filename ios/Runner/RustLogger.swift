import Foundation

class RustLogger {
    static func initialize(logPath: String) -> Bool {
        return RustLoggerBridge.initializeLogger(logPath)
    }
    
    static func debug(_ message: String) {
        RustLoggerBridge.logDebug(message)
    }
    
    static func info(_ message: String) {
        RustLoggerBridge.logInfo(message)
    }
    
    static func warn(_ message: String) {
        RustLoggerBridge.logWarn(message)
    }
    
    static func error(_ message: String) {
        RustLoggerBridge.logError(message)
    }
    
    static func getDefaultLogPath() -> String {
        return RustLoggerBridge.getDefaultLogPath()
    }
} 