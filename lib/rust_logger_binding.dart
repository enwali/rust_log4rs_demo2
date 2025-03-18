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

  static DynamicLibrary _loadLibrary() {
    if (_dylib != null) {
      return _dylib!;
    }

    if (Platform.isAndroid) {
      _dylib = DynamicLibrary.open('librust_log4rs_demo2.so');
    } else if (Platform.isIOS) {
      _dylib = DynamicLibrary.process();
    } else {
      throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
    }
    return _dylib!;
  }

  static final InitLogger _initLogger = _loadLibrary()
      .lookupFunction<InitLoggerNative, InitLogger>('init_logger');

  static final LogInfo _logInfo = _loadLibrary()
      .lookupFunction<LogInfoNative, LogInfo>('log_info');

  static final LogDebug _logDebug = _loadLibrary()
      .lookupFunction<LogDebugNative, LogDebug>('log_debug');

  static final LogWarn _logWarn = _loadLibrary()
      .lookupFunction<LogWarnNative, LogWarn>('log_warn');

  static final LogError _logError = _loadLibrary()
      .lookupFunction<LogErrorNative, LogError>('log_error');

  /// Initialize the Rust logger with a file path
  /// 
  /// [logFilePath] is the absolute path to the log file
  static bool initLogger(String logFilePath) {
    final pathPointer = logFilePath.toNativeUtf8();
    try {
      return _initLogger(pathPointer);
    } finally {
      malloc.free(pathPointer);
    }
  }

  /// Log a message at the info level
  static void info(String message) {
    final messagePointer = message.toNativeUtf8();
    try {
      _logInfo(messagePointer);
    } finally {
      malloc.free(messagePointer);
    }
  }

  /// Log a message at the debug level
  static void debug(String message) {
    final messagePointer = message.toNativeUtf8();
    try {
      _logDebug(messagePointer);
    } finally {
      malloc.free(messagePointer);
    }
  }

  /// Log a message at the warn level
  static void warn(String message) {
    final messagePointer = message.toNativeUtf8();
    try {
      _logWarn(messagePointer);
    } finally {
      malloc.free(messagePointer);
    }
  }

  /// Log a message at the error level
  static void error(String message) {
    final messagePointer = message.toNativeUtf8();
    try {
      _logError(messagePointer);
    } finally {
      malloc.free(messagePointer);
    }
  }
} 