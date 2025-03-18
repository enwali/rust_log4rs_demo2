import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

// FFI signature of the Rust functions
typedef InitLoggerNative = Bool Function(Pointer<Utf8>);
typedef InitLogger = bool Function(Pointer<Utf8>);

typedef LogInfoNative = Void Function(Pointer<Utf8>);
typedef LogInfo = void Function(Pointer<Utf8>);

typedef LogDebugNative = Void Function(Pointer<Utf8>);
typedef LogDebug = void Function(Pointer<Utf8>);

typedef LogWarnNative = Void Function(Pointer<Utf8>);
typedef LogWarn = void Function(Pointer<Utf8>);

typedef LogErrorNative = Void Function(Pointer<Utf8>);
typedef LogError = void Function(Pointer<Utf8>);

class RustLogger {
  static DynamicLibrary? _dylib;
  // 标记是否是调试模式，当找不到符号时会打印更多日志
  static const bool _debug = true;

  static DynamicLibrary _loadLibrary() {
    if (_dylib != null) {
      return _dylib!;
    }

    try {
      if (Platform.isAndroid) {
        // Android上加载动态库文件
        _dylib = DynamicLibrary.open('librust_log4rs_demo2.so');
        if (_debug) print('已加载Android动态库');
      } else if (Platform.isIOS) {
        // iOS上直接使用进程空间中的符号
        _dylib = DynamicLibrary.process();
        
        // 这一行会抛出异常如果符号不存在
        if (_debug) {
          try {
            _dylib!.lookup('init_logger');
            print('成功在进程空间找到init_logger符号');
          } catch (e) {
            print('警告: 在进程空间无法找到init_logger符号');
            // 继续执行，可能是其他符号存在
          }
        }
      } else {
        throw UnsupportedError('不支持的平台: ${Platform.operatingSystem}');
      }
    } catch (e) {
      print('加载Rust库时出错: $e');
      rethrow;
    }
    
    return _dylib!;
  }

  // 使用懒加载方式查找函数，避免在初始化时就查找所有函数
  static InitLogger? _cachedInitLogger;
  static InitLogger get _initLogger {
    _cachedInitLogger ??= _loadLibrary()
        .lookupFunction<InitLoggerNative, InitLogger>('init_logger');
    return _cachedInitLogger!;
  }

  static LogInfo? _cachedLogInfo;
  static LogInfo get _logInfo {
    _cachedLogInfo ??= _loadLibrary()
        .lookupFunction<LogInfoNative, LogInfo>('log_info');
    return _cachedLogInfo!;
  }

  static LogDebug? _cachedLogDebug;
  static LogDebug get _logDebug {
    _cachedLogDebug ??= _loadLibrary()
        .lookupFunction<LogDebugNative, LogDebug>('log_debug');
    return _cachedLogDebug!;
  }

  static LogWarn? _cachedLogWarn;
  static LogWarn get _logWarn {
    _cachedLogWarn ??= _loadLibrary()
        .lookupFunction<LogWarnNative, LogWarn>('log_warn');
    return _cachedLogWarn!;
  }

  static LogError? _cachedLogError;
  static LogError get _logError {
    _cachedLogError ??= _loadLibrary()
        .lookupFunction<LogErrorNative, LogError>('log_error');
    return _cachedLogError!;
  }

  /// 初始化Rust日志器，指定日志文件路径
  /// 
  /// [logFilePath] 是日志文件的绝对路径
  static bool initLogger(String logFilePath) {
    try {
      final pathPointer = logFilePath.toNativeUtf8();
      try {
        return _initLogger(pathPointer);
      } catch (e) {
        print('初始化Rust日志器时出错: $e');
        return false;
      } finally {
        malloc.free(pathPointer);
      }
    } catch (e) {
      print('初始化Rust日志器时出错: $e');
      return false;
    }
  }

  /// 记录debug级别的日志消息
  static void debug(String message) {
    try {
      final messagePointer = message.toNativeUtf8();
      try {
        _logDebug(messagePointer);
      } catch (e) {
        print('记录debug日志时出错: $e');
        print('原始消息: $message');
      } finally {
        malloc.free(messagePointer);
      }
    } catch (e) {
      print('记录debug日志时出错: $e');
    }
  }

  /// 记录info级别的日志消息
  static void info(String message) {
    try {
      final messagePointer = message.toNativeUtf8();
      try {
        _logInfo(messagePointer);
      } catch (e) {
        print('记录info日志时出错: $e');
        print('原始消息: $message');
      } finally {
        malloc.free(messagePointer);
      }
    } catch (e) {
      print('记录info日志时出错: $e');
    }
  }

  /// 记录warn级别的日志消息
  static void warn(String message) {
    try {
      final messagePointer = message.toNativeUtf8();
      try {
        _logWarn(messagePointer);
      } catch (e) {
        print('记录warn日志时出错: $e');
        print('原始消息: $message');
      } finally {
        malloc.free(messagePointer);
      }
    } catch (e) {
      print('记录warn日志时出错: $e');
    }
  }

  /// 记录error级别的日志消息
  static void error(String message) {
    try {
      final messagePointer = message.toNativeUtf8();
      try {
        _logError(messagePointer);
      } catch (e) {
        print('记录error日志时出错: $e');
        print('原始消息: $message');
      } finally {
        malloc.free(messagePointer);
      }
    } catch (e) {
      print('记录error日志时出错: $e');
    }
  }
} 