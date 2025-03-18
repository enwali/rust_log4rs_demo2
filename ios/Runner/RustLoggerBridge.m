#import <Foundation/Foundation.h>
#import "RustLoggerBridge.h"
#import "rust_log4rs_demo2.h"

// 这里实现函数，直接转发给Rust库中的同名函数
// 因为这些函数与Rust库同名，链接器会自动将其连接到Rust静态库的实现

bool init_logger(const char* log_dir) {
    // 实际实现在Rust静态库中，链接器会解析到正确的函数
    // 这个声明只是为了确保符号导出正确
    extern bool init_logger(const char* log_dir);
    return init_logger(log_dir);
}

void log_debug(const char* message) {
    extern void log_debug(const char* message);
    log_debug(message);
}

void log_info(const char* message) {
    extern void log_info(const char* message);
    log_info(message);
}

void log_warn(const char* message) {
    extern void log_warn(const char* message);
    log_warn(message);
}

void log_error(const char* message) {
    extern void log_error(const char* message);
    log_error(message);
}

@implementation RustLoggerBridge

+ (BOOL)initializeLogger:(NSString *)logPath {
    return init_logger([logPath UTF8String]);
}

+ (void)logDebug:(NSString *)message {
    log_debug([message UTF8String]);
}

+ (void)logInfo:(NSString *)message {
    log_info([message UTF8String]);
}

+ (void)logWarn:(NSString *)message {
    log_warn([message UTF8String]);
}

+ (void)logError:(NSString *)message {
    log_error([message UTF8String]);
}

+ (NSString *)getDefaultLogPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return [documentsDirectory stringByAppendingPathComponent:@"rust_logs.log"];
}

@end 