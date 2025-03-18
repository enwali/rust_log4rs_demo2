#!/bin/bash

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# 检查必要的目录和文件
print_info "检查iOS项目目录..."
if [ ! -d "ios" ]; then
    print_error "iOS目录不存在！"
    exit 1
fi

if [ ! -d "ios/Runner" ]; then
    print_error "ios/Runner目录不存在！"
    exit 1
fi

if [ ! -d "rust/target/ios" ]; then
    print_warning "rust/target/ios目录不存在，可能需要先运行build_rust.sh"
    mkdir -p rust/target/ios
fi

# 创建包含Rust函数声明的头文件
print_info "创建Rust函数头文件..."
cat > rust/include/rust_log4rs_demo2.h << 'EOF'
#ifndef RUST_LOG4RS_DEMO2_H
#define RUST_LOG4RS_DEMO2_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// 初始化日志系统
bool init_logger(const char* log_path);

// 记录不同级别的日志消息
void log_debug(const char* message);
void log_info(const char* message);
void log_warn(const char* message);
void log_error(const char* message);

#ifdef __cplusplus
}
#endif

#endif // RUST_LOG4RS_DEMO2_H
EOF

# 复制Rust头文件到iOS项目
print_info "复制Rust头文件到iOS项目..."
mkdir -p "ios/Runner/include"
cp "rust/include/rust_log4rs_demo2.h" "ios/Runner/include/"

# 创建RustFunctions.swift如果不存在
if [ ! -f "ios/Runner/RustFunctions.swift" ]; then
    print_info "创建RustFunctions.swift..."
    cat > ios/Runner/RustFunctions.swift << 'EOF'
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
EOF
else
    print_info "RustFunctions.swift已存在，跳过创建..."
fi

# 创建RustLogger.swift如果不存在
if [ ! -f "ios/Runner/RustLogger.swift" ]; then
    print_info "创建RustLogger.swift..."
    cat > ios/Runner/RustLogger.swift << 'EOF'
import Foundation

@objc class RustLogger: NSObject {
    
    // 初始化日志系统
    @objc static func initialize(logPath: String) -> Bool {
        // 确保Rust函数被链接
        RustFunctions.ensureLinked()
        
        // 转换路径为C字符串并调用Rust初始化函数
        return logPath.withCString { cPath in
            return init_logger(cPath)
        }
    }
    
    // 记录调试级别日志
    @objc static func debug(_ message: String) {
        message.withCString { cMessage in
            log_debug(cMessage)
        }
    }
    
    // 记录信息级别日志
    @objc static func info(_ message: String) {
        message.withCString { cMessage in
            log_info(cMessage)
        }
    }
    
    // 记录警告级别日志
    @objc static func warn(_ message: String) {
        message.withCString { cMessage in
            log_warn(cMessage)
        }
    }
    
    // 记录错误级别日志
    @objc static func error(_ message: String) {
        message.withCString { cMessage in
            log_error(cMessage)
        }
    }
    
    // 获取应用文档目录的日志文件路径
    @objc static func getDefaultLogPath() -> String {
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logDirectory = documentsDirectory.appendingPathComponent("logs")
            
            // 创建日志目录（如果不存在）
            try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
            
            return logDirectory.appendingPathComponent("app.log").path
        }
        
        // 如果无法获取文档目录，则返回一个临时文件路径
        return NSTemporaryDirectory() + "/app.log"
    }
}
EOF
else
    print_info "RustLogger.swift已存在，跳过创建..."
fi

# 创建RustLoggerPlugin.swift如果不存在
if [ ! -f "ios/Runner/RustLoggerPlugin.swift" ]; then
    print_info "创建RustLoggerPlugin.swift..."
    cat > ios/Runner/RustLoggerPlugin.swift << 'EOF'
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
                // 如果没有提供路径，使用默认路径
                let defaultPath = RustLogger.getDefaultLogPath()
                let success = RustLogger.initialize(logPath: defaultPath)
                result(success)
            }
            
        case "debug":
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                RustLogger.debug(message)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "消息不能为空",
                                  details: nil))
            }
            
        case "info":
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                RustLogger.info(message)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "消息不能为空",
                                  details: nil))
            }
            
        case "warn":
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                RustLogger.warn(message)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "消息不能为空",
                                  details: nil))
            }
            
        case "error":
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                RustLogger.error(message)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "消息不能为空",
                                  details: nil))
            }
            
        case "getDefaultLogPath":
            let path = RustLogger.getDefaultLogPath()
            result(path)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
EOF
else
    print_info "RustLoggerPlugin.swift已存在，跳过创建..."
fi

# 更新桥接头文件
print_info "更新桥接头文件..."
if [ -f "ios/Runner/Runner-Bridging-Header.h" ]; then
    # 检查是否已经包含了我们的头文件
    if ! grep -q "rust_log4rs_demo2.h" "ios/Runner/Runner-Bridging-Header.h"; then
        # 添加我们的头文件引用
        echo '#import "include/rust_log4rs_demo2.h"' >> "ios/Runner/Runner-Bridging-Header.h"
        print_info "已将Rust头文件添加到桥接头文件"
    else
        print_info "桥接头文件已包含Rust头文件引用"
    fi
    
    # 确保包含了dlfcn.h (用于动态加载库)
    if ! grep -q "dlfcn.h" "ios/Runner/Runner-Bridging-Header.h"; then
        echo '#import <dlfcn.h>' >> "ios/Runner/Runner-Bridging-Header.h"
        print_info "已将dlfcn.h添加到桥接头文件"
    else
        print_info "桥接头文件已包含dlfcn.h引用"
    fi
else
    # 创建新的桥接头文件
    cat > "ios/Runner/Runner-Bridging-Header.h" << 'EOF'
//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#import <dlfcn.h>
#import "include/rust_log4rs_demo2.h"
EOF
    print_info "已创建新的桥接头文件"
fi

# 复制库文件
for arch in "aarch64" "x86_64"; do
    if [ -f "rust/target/$arch-apple-ios/release/librust_log4rs_demo2.a" ]; then
        mkdir -p "rust/target/ios/release/$arch"
        cp "rust/target/$arch-apple-ios/release/librust_log4rs_demo2.a" "rust/target/ios/release/$arch/"
        print_info "已复制 $arch 架构的库文件"
    fi
done

# 检查是否需要创建通用库文件
if [ -f "rust/target/ios/release/aarch64/librust_log4rs_demo2.a" ] && [ -f "rust/target/ios/release/x86_64/librust_log4rs_demo2.a" ]; then
    mkdir -p "rust/target/ios/release/universal"
    
    # 创建通用库文件
    lipo -create "rust/target/ios/release/aarch64/librust_log4rs_demo2.a" "rust/target/ios/release/x86_64/librust_log4rs_demo2.a" -output "rust/target/ios/release/universal/librust_log4rs_demo2.a"
    print_info "已创建通用库文件"
    
    # 复制到Flutter目录
    mkdir -p "ios/Flutter"
    cp "rust/target/ios/release/universal/librust_log4rs_demo2.a" "ios/Flutter/"
    print_info "已将通用库文件复制到Flutter目录"
else
    print_warning "未找到所有架构的库文件，跳过创建通用库"
fi

print_info "iOS项目设置完成!"
print_info "请在Xcode中执行以下步骤:"
print_info "1. 打开ios/Runner.xcworkspace"
print_info "2. 选择Runner项目 -> Build Phases -> Link Binary With Libraries"
print_info "3. 点击+按钮，然后点击'Add Other...' -> 'Add Files...'"
print_info "4. 导航到项目根目录/ios/Flutter并选择librust_log4rs_demo2.a"
print_info "5. 确认'Runner' -> 'Build Settings' -> 'Swift Compiler - General' -> 'Objective-C Bridging Header'设置为'Runner/Runner-Bridging-Header.h'"
print_info "6. 重新构建项目" 