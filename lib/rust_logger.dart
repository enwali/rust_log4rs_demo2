import 'package:flutter/services.dart';

class RustLogger {
  static const platform = MethodChannel('com.example.rust_logger');
  
  // 初始化日志系统
  static Future<bool> initialize({String? logPath}) async {
    try {
      final bool result = await platform.invokeMethod('initialize', {'logPath': logPath});
      return result;
    } on PlatformException catch (e) {
      print('初始化日志系统失败: ${e.message}');
      return false;
    }
  }
  
  // 记录调试级别日志
  static Future<void> debug(String message) async {
    try {
      await platform.invokeMethod('debug', {'message': message});
    } on PlatformException catch (e) {
      print('记录调试日志失败: ${e.message}');
    }
  }
  
  // 记录信息级别日志
  static Future<void> info(String message) async {
    try {
      await platform.invokeMethod('info', {'message': message});
    } on PlatformException catch (e) {
      print('记录信息日志失败: ${e.message}');
    }
  }
  
  // 记录警告级别日志
  static Future<void> warn(String message) async {
    try {
      await platform.invokeMethod('warn', {'message': message});
    } on PlatformException catch (e) {
      print('记录警告日志失败: ${e.message}');
    }
  }
  
  // 记录错误级别日志
  static Future<void> error(String message) async {
    try {
      await platform.invokeMethod('error', {'message': message});
    } on PlatformException catch (e) {
      print('记录错误日志失败: ${e.message}');
    }
  }
  
  // 获取默认日志文件路径
  static Future<String?> getDefaultLogPath() async {
    try {
      final String? path = await platform.invokeMethod('getDefaultLogPath');
      return path;
    } on PlatformException catch (e) {
      print('获取日志路径失败: ${e.message}');
      return null;
    }
  }
} 