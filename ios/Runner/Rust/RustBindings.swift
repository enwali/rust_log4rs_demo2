import Foundation

// Swift封装Rust库的函数
@objc class RustLogger: NSObject {
    
    // 初始化日志库
    @objc static func initLogger(logPath: String) -> Bool {
        guard let cString = logPath.cString(using: .utf8) else {
            print("无法转换路径为C字符串")
            return false
        }
        
        let result = init_logger(cString)
        return result
    }
    
    // 记录debug级别日志
    @objc static func debug(_ message: String) {
        guard let cString = message.cString(using: .utf8) else {
            print("无法转换消息为C字符串")
            return
        }
        
        log_debug(cString)
    }
    
    // 记录info级别日志
    @objc static func info(_ message: String) {
        guard let cString = message.cString(using: .utf8) else {
            print("无法转换消息为C字符串")
            return
        }
        
        log_info(cString)
    }
    
    // 记录warn级别日志
    @objc static func warn(_ message: String) {
        guard let cString = message.cString(using: .utf8) else {
            print("无法转换消息为C字符串")
            return
        }
        
        log_warn(cString)
    }
    
    // 记录error级别日志
    @objc static func error(_ message: String) {
        guard let cString = message.cString(using: .utf8) else {
            print("无法转换消息为C字符串")
            return
        }
        
        log_error(cString)
    }
} 