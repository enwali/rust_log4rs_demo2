import Foundation

// 这个文件的目的是确保Rust库中的函数在链接时被包含

// Rust函数类型定义
typealias InitLoggerFunc = @convention(c) (UnsafePointer<CChar>) -> Bool
typealias LogMessageFunc = @convention(c) (UnsafePointer<CChar>) -> Void

// 在运行时加载Rust函数
class RustFunctions {
    
    // 强制链接器包含Rust函数
    @inline(never)
    static func ensureLinked() {
        // 这些函数调用永远不会被执行，但会强制链接器保留这些符号
        let _ = _loadInitLogger()
        let _ = _loadLogDebug()
        let _ = _loadLogInfo()
        let _ = _loadLogWarn() 
        let _ = _loadLogError()
    }
    
    // 加载Rust初始化函数
    @inline(never)
    private static func _loadInitLogger() -> InitLoggerFunc? {
        let name = "init_logger"
        guard let sym = _loadSymbol(name: name) else {
            print("无法加载Rust函数: \(name)")
            return nil
        }
        return unsafeBitCast(sym, to: InitLoggerFunc.self)
    }
    
    // 加载Rust调试日志函数
    @inline(never)
    private static func _loadLogDebug() -> LogMessageFunc? {
        let name = "log_debug"
        guard let sym = _loadSymbol(name: name) else {
            print("无法加载Rust函数: \(name)")
            return nil
        }
        return unsafeBitCast(sym, to: LogMessageFunc.self)
    }
    
    // 加载Rust信息日志函数
    @inline(never)
    private static func _loadLogInfo() -> LogMessageFunc? {
        let name = "log_info"
        guard let sym = _loadSymbol(name: name) else {
            print("无法加载Rust函数: \(name)")
            return nil
        }
        return unsafeBitCast(sym, to: LogMessageFunc.self)
    }
    
    // 加载Rust警告日志函数
    @inline(never)
    private static func _loadLogWarn() -> LogMessageFunc? {
        let name = "log_warn"
        guard let sym = _loadSymbol(name: name) else {
            print("无法加载Rust函数: \(name)")
            return nil
        }
        return unsafeBitCast(sym, to: LogMessageFunc.self)
    }
    
    // 加载Rust错误日志函数
    @inline(never)
    private static func _loadLogError() -> LogMessageFunc? {
        let name = "log_error"
        guard let sym = _loadSymbol(name: name) else {
            print("无法加载Rust函数: \(name)")
            return nil
        }
        return unsafeBitCast(sym, to: LogMessageFunc.self)
    }
    
    // 通用符号加载函数
    private static func _loadSymbol(name: String) -> UnsafeMutableRawPointer? {
        let handle = dlopen(nil, RTLD_NOW)
        defer { if handle != nil { dlclose(handle) } }
        
        let sym = dlsym(handle, name)
        if sym == nil {
            print("无法加载符号: \(name), 错误: \(String(cString: dlerror()))")
        }
        return sym
    }
} 