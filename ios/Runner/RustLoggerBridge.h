#ifndef RustLoggerBridge_h
#define RustLoggerBridge_h

#import <Foundation/Foundation.h>

@interface RustLoggerBridge : NSObject

+ (BOOL)initializeLogger:(NSString *)logPath;
+ (void)logDebug:(NSString *)message;
+ (void)logInfo:(NSString *)message;
+ (void)logWarn:(NSString *)message;
+ (void)logError:(NSString *)message;
+ (NSString *)getDefaultLogPath;

@end

#endif /* RustLoggerBridge_h */ 